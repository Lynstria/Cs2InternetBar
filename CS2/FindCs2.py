import os
import sys
import pathlib
import winreg
import concurrent.futures
import traceback
import argparse

# --- Thư viện bên thứ ba (Cần pip install) ---
# pip install vdf
import vdf
import vdf# pip install psutil
import psutil
# pip install pywin32 (cần cho win32api, win32con, win32com)
import win32api
import win32con
import win32com.client

# --- Global Constants ---
CS2_APP_ID = "730"
CS2_EXE_RELATIVE_PATH = pathlib.Path("game/bin/win64/cs2.exe")
STEAM_REGISTRY_PATH_UNINSTALL = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 730"
STEAM_REGISTRY_PATH_INSTALL = r"Software\Valve\Steam"
STEAM_LIBRARY_FOLDERS_VDF = pathlib.Path("steamapps/libraryfolders.vdf")

# Danh sách thư mục hệ thống cần loại bỏ khi quét shortcut (dùng để lọc, không bắt buộc)
EXCLUDE_DIRS = ["Windows", "System32", "ProgramData", "$Recycle.Bin", "$WINDOWS.~BT", "Recovery", "Documents and Settings"]

# --- Hàm tiện ích kiểm tra đường dẫn game ---
def _validate_cs2_path(base_path: pathlib.Path) -> pathlib.Path | None:
    """Kiểm tra xem thư mục gốc có chứa CS2 không."""
    full_cs2_path = base_path / CS2_EXE_RELATIVE_PATH
    if full_cs2_path.is_file():
        print(f"DEBUG: Xác thực thành công: {base_path}")
        return base_path
    return None

# --- Tầng 1: Registry Uninstall ---
def find_cs2_by_registry_uninstall() -> pathlib.Path | None:
    print("Tầng 1: Tìm trong Registry Uninstall...")
    try:
        # Thử cả 64-bit và 32-bit view
        for access_flag in [0, winreg.KEY_WOW64_64KEY, winreg.KEY_WOW64_32KEY]:
            try:
                with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, STEAM_REGISTRY_PATH_UNINSTALL, 0,
                                    winreg.KEY_READ | access_flag) as key:
                    install_location, _ = winreg.QueryValueEx(key, "InstallLocation")
                    base = pathlib.Path(install_location)
                    result = _validate_cs2_path(base)
                    if result:
                        return result
            except FileNotFoundError:
                continue
        print("Tầng 1: Không tìm thấy khóa Uninstall.")
    except Exception as e:
        print(f"Tầng 1: Lỗi {e}")
    return None

# --- Tầng 2: Phân tích Steam VDF ---
def _get_steam_install_path() -> pathlib.Path | None:
    """Trả về đường dẫn cài đặt Steam từ registry (HKCU) hoặc tìm steam.exe đang chạy."""
    # Cách 1: Registry HKCU
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, STEAM_REGISTRY_PATH_INSTALL) as key:
            steam_path_str, _ = winreg.QueryValueEx(key, "SteamPath")
            steam_path = pathlib.Path(steam_path_str)
            if steam_path.is_dir():
                return steam_path
    except FileNotFoundError:
        pass

    # Cách 2: Từ steam.exe đang chạy (nếu có quá trình, không cần quét lại tầng 3 ở đây)
    try:
        for proc in psutil.process_iter(['name', 'exe']):
            if proc.name().lower() == 'steam.exe':
                return pathlib.Path(proc.exe()).parent
    except Exception:
        pass
    return None

def find_cs2_by_steam_vdf() -> pathlib.Path | None:
    print("Tầng 2: Phân tích Steam libraryfolders.vdf...")
    steam_install = _get_steam_install_path()
    if not steam_install:
        print("Tầng 2: Không xác định được đường dẫn Steam.")
        return None

    vdf_path = steam_install / STEAM_LIBRARY_FOLDERS_VDF
    if not vdf_path.is_file():
        print(f"Tầng 2: Không tìm thấy {vdf_path}")
        return None

    try:
        with open(vdf_path, 'r', encoding='utf-8') as f:
            data = vdf.load(f)

        library_paths = []
        if 'libraryfolders' in data:
            for key, value in data['libraryfolders'].items():
                if key.isdigit() and 'path' in value:
                    library_paths.append(pathlib.Path(value['path']))
        library_paths.append(steam_install)

        for lib in set(library_paths):
            game_path = lib / "steamapps" / "common" / "Counter-Strike Global Offensive"
            result = _validate_cs2_path(game_path)
            if result:
                return result
        print("Tầng 2: Không tìm thấy trong các thư viện.")
    except Exception as e:
        print(f"Tầng 2: Lỗi {e}")
    return None

# --- Tầng 3: Truy vết tiến trình ---
def find_cs2_by_process_trace() -> pathlib.Path | None:
    print("Tầng 3: Truy vết process cs2.exe hoặc steam.exe...")
    try:
        for proc in psutil.process_iter(['name', 'exe']):
            try:
                if proc.name().lower() == 'cs2.exe':
                    exe_path = pathlib.Path(proc.exe())
                    base = exe_path.parent.parent.parent.parent
                    return _validate_cs2_path(base)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
    except Exception as e:
        print(f"Tầng 3: Lỗi {e}")
    print("Tầng 3: Không tìm thấy cs2.exe.")
    return None

# --- Tầng 4: Tìm trong shortcut Windows ---
def _read_shortcut_target(lnk_path: pathlib.Path) -> str | None:
    """Dùng WScript.Shell để đọc đường dẫn đích của file .lnk."""
    try:
        shell = win32com.client.Dispatch("WScript.Shell")
        shortcut = shell.CreateShortCut(str(lnk_path))
        return shortcut.TargetPath
    except Exception:
        return None

def _collect_shortcut_folders() -> list[pathlib.Path]:
    """Trả về danh sách thư mục chứa shortcut: Desktop, Start Menu của user và common."""
    folders = []
    # Desktop
    folders.append(pathlib.Path(os.environ.get('USERPROFILE', ''), 'Desktop'))
    folders.append(pathlib.Path(os.environ.get('PUBLIC', ''), 'Desktop'))
    # Start Menu Programs
    folders.append(pathlib.Path(os.environ.get('APPDATA', ''), 'Microsoft/Windows/Start Menu/Programs'))
    folders.append(pathlib.Path(os.environ.get('PROGRAMDATA', ''), 'Microsoft/Windows/Start Menu/Programs'))
    return [f for f in folders if f.is_dir()]

def find_cs2_by_shortcuts() -> pathlib.Path | None:
    print("Tầng 4: Kiểm tra shortcut Desktop/Start Menu...")
    folders = _collect_shortcut_folders()
    for folder in folders:
        try:
            for root, dirs, files in os.walk(folder):
                for file in files:
                    if file.lower().endswith('.lnk'):
                        lnk_path = pathlib.Path(root) / file
                        target = _read_shortcut_target(lnk_path)
                        if target and target.lower().endswith('cs2.exe'):
                            exe_path = pathlib.Path(target)
                            base = exe_path.parent.parent.parent.parent
                            result = _validate_cs2_path(base)
                            if result:
                                return result
        except PermissionError:
            continue
    print("Tầng 4: Không tìm thấy qua shortcut.")
    return None

# --- Tầng 5: Rà soát các đường dẫn suy đoán trên các ổ đĩa (không đệ quy) ---
def _get_all_drives() -> list[str]:
    """Lấy danh sách ký tự ổ đĩa (Fixed, Removable, Remote), trả về dạng 'D:\\',..."""
    drives = []
    try:
        for drive in win32api.GetLogicalDriveStrings().split('\000')[:-1]:
            try:
                dtype = win32api.GetDriveType(drive)
                if dtype in (win32con.DRIVE_FIXED, win32con.DRIVE_REMOVABLE, win32con.DRIVE_REMOTE):
                    drives.append(drive)
            except Exception:
                pass
    except Exception:
        pass
    return drives

def find_cs2_by_known_paths() -> pathlib.Path | None:
    print("Tầng 5: Dò tìm đường dẫn quen thuộc trên các ổ đĩa...")
    candidate_patterns = [
        pathlib.Path("SteamLibrary/steamapps/common/Counter-Strike Global Offensive"),
        pathlib.Path("Program Files (x86)/Steam/steamapps/common/Counter-Strike Global Offensive"),
        pathlib.Path("Program Files/Steam/steamapps/common/Counter-Strike Global Offensive"),
        pathlib.Path("Games/Counter-Strike Global Offensive"),
        pathlib.Path("Counter-Strike Global Offensive"),
    ]
    for drive_root in _get_all_drives():
        root = pathlib.Path(drive_root)
        if not root.exists():
            continue
        for pattern in candidate_patterns:
            candidate = root / pattern
            result = _validate_cs2_path(candidate)
            if result:
                return result
    print("Tầng 5: Không tìm thấy.")
    return None

# --- Tầng 6: Phân tích libraryfolders.vdf trong thư mục SteamLibrary trên các ổ đĩa ---
def find_cs2_by_libraries_on_drives() -> pathlib.Path | None:
    print("Tầng 6: Dò tìm libraryfolders.vdf trong thư mục SteamLibrary trên các ổ đĩa...")
    for drive_root in _get_all_drives():
        root = pathlib.Path(drive_root)
        if not root.exists():
            continue
        # Kiểm tra xem có thư mục SteamLibrary ở gốc không
        steamlib_folder = root / "SteamLibrary"
        vdf_file = steamlib_folder / "steamapps" / "libraryfolders.vdf"
        if vdf_file.is_file():
            try:
                with open(vdf_file, 'r', encoding='utf-8') as f:
                    data = vdf.load(f)
                if 'libraryfolders' in data:
                    for key, value in data['libraryfolders'].items():
                        if key.isdigit() and 'path' in value:
                            lib_path = pathlib.Path(value['path'])
                            game_path = lib_path / "steamapps" / "common" / "Counter-Strike Global Offensive"
                            result = _validate_cs2_path(game_path)
                            if result:
                                return result
            except Exception as e:
                print(f"Tầng 6: Lỗi đọc {vdf_file}: {e}")
    print("Tầng 6: Không tìm thấy.")
    return None

# --- Tầng 7: Thủ công bằng Folder Browser (GUI) ---
def find_cs2_by_manual_input() -> pathlib.Path | None:
    """
    Hiển thị hộp thoại chọn thư mục nếu các tầng tự động thất bại.
    Không bao giờ chặn stdin – an toàn cho mọi môi trường.
    """
    print("\nTầng 7: Không tìm thấy tự động. Đang mở hộp thoại chọn thư mục...")
    try:
        # Sử dụng Shell.Application để hiển thị BrowseForFolder
        shell = win32com.client.Dispatch("Shell.Application")
        folder = shell.BrowseForFolder(
            0, 
            "Hãy chọn thư mục gốc của CS2 (Counter-Strike Global Offensive)", 
            0x0001 | 0x0010,  # BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE
            0x11  # Start in My Computer
        )
        if folder is not None:
            selected_path = pathlib.Path(folder.Self.Path)
            # Kiểm tra nếu đây là thư mục gốc CS2
            if _validate_cs2_path(selected_path):
                return selected_path
            # Đôi khi người dùng chọn nhầm thư mục cha (vd D:\Games)
            # Thử kiểm tra bên trong xem có "Counter-Strike Global Offensive" không
            potential = selected_path / "Counter-Strike Global Offensive"
            if potential.is_dir() and _validate_cs2_path(potential):
                return potential
            # Thử thêm "steamapps/common/Counter-Strike Global Offensive" nếu chọn SteamLibrary
            potential2 = selected_path / "steamapps/common/Counter-Strike Global Offensive"
            if potential2.is_dir() and _validate_cs2_path(potential2):
                return potential2
            print("Thư mục đã chọn không chứa CS2. Hãy thử lại.")
            return find_cs2_by_manual_input()  # Gọi lại nếu chọn sai
        else:
            print("Người dùng đã hủy chọn folder.")
            return None
    except Exception as e:
        print(f"Lỗi hiển thị hộp thoại: {e}. Thử nhập tay (fallback)...")
        # Fallback cuối cùng: nhập console (nếu có terminal)
        while True:
            user_input = input("Nhập đường dẫn (hoặc 'q' để thoát): ").strip()
            if user_input.lower() == 'q':
                return None
            base = pathlib.Path(user_input)
            if base.is_dir():
                result = _validate_cs2_path(base)
                if result:
                    return result
                print("Đường dẫn không chứa game/bin/win64/cs2.exe.")
            else:
                print("Thư mục không tồn tại.")


# --- Hàm điều phối chính ---
def find_cs2_path() -> pathlib.Path | None:
    print("Bắt đầu tìm kiếm đường dẫn CS2 (7 tầng)...")
    return (
        find_cs2_by_registry_uninstall() or
        find_cs2_by_steam_vdf() or
        find_cs2_by_process_trace() or
        find_cs2_by_shortcuts() or
        find_cs2_by_known_paths() or
        find_cs2_by_libraries_on_drives() or
        find_cs2_by_manual_input()          # Luôn chạy nếu các tầng trên None
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--non-interactive', action='store_true',
                        help='Tắt hộp thoại chọn folder (tầng 7)')
    args = parser.parse_args()

    # Nếu chạy non-interactive thì vô hiệu hóa tầng 7 trước
    if args.non_interactive:
        find_cs2_by_manual_input = lambda: None

    result = find_cs2_path()
    if result:
        print(f"\n Tìm thấy CS2 tại: {result}")
        print(f"CS2PATH:{result}")
    else:
        print("\n Không tìm thấy CS2.")
        print("CS2PATH:NOT_FOUND")
