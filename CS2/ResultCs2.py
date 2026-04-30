import os
import sys
import pathlib
import winreg
import shutil
import traceback

# Import FindCs2 (đảm bảo file FindCs2.py cùng thư mục)
try:
    import FindCs2
except ImportError:
    print("Không tìm thấy FindCs2.py. Hãy đặt cùng thư mục.")
    sys.exit(1)

# Thư viện tải file từ internet
try:
    import requests
except ImportError:
    print("Thư viện 'requests' chưa cài đặt. Cài bằng: pip install requests")
    sys.exit(1)

# --- Cấu hình ---
GITHUB_AUTOEXEC_URL = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main/CS2/Config/autoexec.cfg"
CFG_RELATIVE_PATH = pathlib.Path("game/csgo/cfg")
CS2_EXE_RELATIVE_PATH = pathlib.Path("game/bin/win64/cs2.exe")

# --- Hàm tải file từ URL, trả về nội dung dạng text hoặc None ---
def download_file(url: str) -> str | None:
    """Tải nội dung text từ URL, có xử lý ngoại lệ."""
    try:
        print(f"Đang tải: {url}")
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        return response.text
    except Exception as e:
        print(f"Lỗi tải file: {e}")
        return None

# --- Hàm ghi đè High DPI scaling vào Registry (All Users hoặc Current User) ---
def override_high_dpi_scaling(exe_path: pathlib.Path) -> bool:
    """
    Thiết lập AppCompatFlags để override DPI scaling thành 'Application' (HIGHDPIAWARE)
    cho file exe được chỉ định. Thử ghi vào HKLM trước (All Users), nếu thất bại dùng HKCU.
    Trả về True nếu thành công.
    """
    exe_path_str = str(exe_path.resolve())
    value_data = "~ HIGHDPIAWARE"
    registry_path = r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

    # Thử ghi vào HKLM (cần quyền Administrator)
    try:
        key = winreg.CreateKeyEx(winreg.HKEY_LOCAL_MACHINE, registry_path, 0, winreg.KEY_SET_VALUE | winreg.KEY_WOW64_64KEY)
        with key:
            winreg.SetValueEx(key, exe_path_str, 0, winreg.REG_SZ, value_data)
        print(f"Đã ghi đè DPI (HKLM) cho: {exe_path_str}")
        return True
    except PermissionError:
        print("Không có quyền ghi vào HKLM. Thử dùng HKEY_CURRENT_USER...")
    except Exception as e:
        print(f"Lỗi khi ghi HKLM: {e}. Thử dùng HKCU...")

    # Fallback sang HKCU
    try:
        key = winreg.CreateKeyEx(winreg.HKEY_CURRENT_USER, registry_path, 0, winreg.KEY_SET_VALUE)
        with key:
            winreg.SetValueEx(key, exe_path_str, 0, winreg.REG_SZ, value_data)
        print(f"Đã ghi đè DPI (HKCU) cho: {exe_path_str}")
        print("Lưu ý: Thiết lập chỉ áp dụng cho người dùng hiện tại.")
        return True
    except Exception as e:
        print(f"Lỗi khi ghi HKCU: {e}")
        return False

# --- Hàm chính ---
def main():
    print("===== ResultCs2.py =====")
    # Bước 1: Lấy đường dẫn CS2 từ FindCs2.py (lưu vào RAM)
    print("Đang tìm đường dẫn CS2...")
    cs2_root = FindCs2.find_cs2_path()
    if not cs2_root:
        print("Không tìm thấy CS2. Kết thúc.")
        sys.exit(1)

    print(f"Đã xác định CS2 tại: {cs2_root}")

    # Bước 2: Xử lý nhánh 2 - Tải file autoexec.cfg về folder cfg
    cfg_folder = cs2_root / CFG_RELATIVE_PATH
    try:
        cfg_folder.mkdir(parents=True, exist_ok=True)
        print(f"Thư mục cfg: {cfg_folder}")
    except Exception as e:
        print(f"Không thể tạo thư mục cfg: {e}")
        sys.exit(1)

    cfg_content = download_file(GITHUB_AUTOEXEC_URL)
    if cfg_content is None:
        print("Không tải được autoexec.cfg. Kiểm tra kết nối mạng hoặc URL.")
        # Không thoát, vẫn tiếp tục bước DPI
    else:
        cfg_file_path = cfg_folder / "autoexec.cfg"
        try:
            with open(cfg_file_path, 'w', encoding='utf-8') as f:
                f.write(cfg_content)
            print(f"Đã lưu autoexec.cfg vào: {cfg_file_path}")
        except Exception as e:
            print(f"Lỗi ghi file autoexec.cfg: {e}")

    # Bước 3: Xử lý nhánh 1 - Override DPI scaling cho cs2.exe
    cs2_exe_path = cs2_root / CS2_EXE_RELATIVE_PATH
    if not cs2_exe_path.is_file():
        print(f"Không tìm thấy cs2.exe tại: {cs2_exe_path}")
        sys.exit(1)

    if override_high_dpi_scaling(cs2_exe_path):
        print("Hoàn tất cài đặt DPI scaling.")
    else:
        print("Không thể thiết lập DPI scaling.")

    print("\nHoàn tất các tác vụ.")
    # (Tùy chọn) Giải phóng RAM – không cần thiết, biến cục bộ sẽ tự giải phóng.

if __name__ == "__main__":
    main()