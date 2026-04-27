  CS2 InternetBar Optimizer (CIBO)
High-Performance Pipeline for Windows Gaming Optimization

!

🛠 Overview
CIBO là một giải pháp triển khai (deployment) tự động hóa theo mô hình Streaming Pipeline. Dự án được thiết kế để biến bất kỳ máy Windows "bloatware" nào thành một trạm chiến game chuyên dụng cho CS2 chỉ trong vài giây thông qua giao thức thực thi trực tiếp từ RAM.

⚡ Key Features
In-Memory Execution: Script chính (Main.ps1) và các bản tinh chỉnh hệ thống (WinTweaks) được nạp trực tiếp vào RAM qua irm | iex, không để lại tệp rác trên ổ cứng.

Zero-Footprint Delivery: Cơ chế "bồi bàn" (middleware) giúp điều phối dữ liệu từ GitHub đến thẳng bộ xử lý PowerShell hệ thống.

Smart Path Detection: Tự động dò tìm thư mục Steam và CS2 thông qua Registry, hỗ trợ mọi phân vùng ổ cứng (C, D, E...).

DPI Override Automation: Tự động can thiệp Registry để kích hoạt High DPI Scaling Override (Application) cho cs2.exe.

Config Sync: Đồng bộ hóa tệp cấu hình chuyên sâu (autoexec.cfg) từ GitHub Repo vào đúng thư mục game.

🚀 Quick Start
Mở PowerShell (Admin) và thực thi lệnh duy nhất bên dưới để bắt đầu quy trình tối ưu:

PowerShell
irm https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main/Main.ps1 | iex
📁 Project Structure
/CS2: Chứa các tệp cấu hình game (autoexec.cfg).

/WinTweaks: Thư viện script PowerShell tối ưu hóa Network, Registry và Services.

Main.ps1: Bộ điều phối trung tâm (The Orchestrator).

Status: v1.0.0-Stable

Last Deployment: 2026-04-27 | Intermediate Pipeline Completed. Developed by: Lynstria
