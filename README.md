# 🚀 CS2 InternetBar Optimizer (CIBO)

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0--stable-blue)
![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)
![Pipeline](https://img.shields.io/badge/deployment-one--liner-purple)

</div>

**CIBO** là giải pháp triển khai tự động, biến mọi máy Windows (kể cả máy net "bloatware") thành trạm chiến CS2 chuyên dụng chỉ trong vài giây – không cần cài đặt trước Python hay thư viện, không để lại rác trên hệ thống.

---

## ⚡ Điểm nổi bật

- **Thực thi từ RAM** – Script chính chạy trực tiếp qua `irm | iex`, không tạo file `.ps1` trên đĩa.
- **Zero‑Footprint** – Python portable + thư viện chỉ giải nén tạm, tự động xóa sạch sau khi hoàn tất.
- **Phát hiện đường dẫn CS2 thông minh** – 7 tầng dò tìm (Registry, Steam VDF, Process, Shortcut, đường dẫn quen thuộc, libraryfolders rải rác, nhập tay).
- **Override DPI Scaling (Application)** – Ghi `~ HIGHDPIAWARE` vào Registry, đảm bảo `cs2.exe` tự kiểm soát DPI, không bị mờ do scale hệ thống.
- **Đồng bộ file cấu hình** – Tải `autoexec.cfg` từ repo về đúng thư mục `cfg` của game.
- **Tối ưu Windows nâng cao** – Tự động áp dụng các tweak về network, services, registry để tăng hiệu suất chơi game.

---

## 🚀 Quick Start

**Yêu cầu duy nhất**: PowerShell chạy với quyền **Administrator**.

Dán lệnh sau vào cửa sổ PowerShell (Admin) và nhấn Enter:

```powershell
irm https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main/Main.ps1 | iex

Pipeline sẽ hỏi bạn 1 câu hỏi duy nhất:

Deploy autoexec.cfg? (Y/N)

Chọn Y → tải file cấu hình chuyên sâu từ GitHub vào thư mục cfg của CS2.

Chọn N → chỉ áp dụng DPI Override và tối ưu hệ thống, bỏ qua config.

Sau vài giây (tuỳ tốc độ mạng để tải Python portable ~50MB).

🗂 Cấu trúc Repository
Cs2InternetBar/
├── Main.ps1                 # Bộ điều phối chính (The Orchestrator)
├── CS2/
│   ├── FindCs2.py           # 7 tầng dò tìm đường dẫn CS2
│   ├── ResultCs2.py         # Triển khai config + DPI Override
│   └── Config/
│       └── autoexec.cfg     # File cấu hình game (từ GitHub)
├── WinTweaks/
│   └── optimize.ps1         # Tối ưu Windows (network, services, registry)
├── Bootstrap/
│   └── python-portable.zip  # Python portable + sẵn thư viện (đính kèm Release)
├── requirements.txt         # Danh sách thư viện Python (cho dev)
└── README.md

Lưu ý: File python-portable.zip được phân phối qua GitHub Releases để giảm tải repo chính.

🔧 Công nghệ sử dụng
PowerShell 5.1+ (In‑Memory Execution, Registry, COM)
Python 3.12 Embedded (portable, không cần cài đặt)
Các thư viện Python:
vdf – đọc cấu trúc VDF của Steam
psutil – truy vết tiến trình
pywin32 – thao tác Registry, Shortcut Windows
requests – tải file cấu hình từ GitHub
Steam / CS2 API (Registry Uninstall, libraryfolders.vdf)

🤖 Tương tác với AI
Dự án này được thiết kế để thử nghiệm làm việc hiệu quả với các công cụ AI.
Logic được chia thành các tầng rõ ràng, mỗi tầng độc lập và có chú thích chi tiết.
Tất cả thay đổi đều có thể được thực hiện bằng cách mô tả logic, AI sẽ sinh code phù hợp với kiến trúc sẵn có.

📜 License
MIT © 2026 Lynstria.

🏷 Trạng thái
v1.0.0-Stable – Đã kiểm tra hoạt động trên Windows 10/11 (máy net, máy cá nhân).

Made with ❤️ by Lynstria – because every millisecond counts.
