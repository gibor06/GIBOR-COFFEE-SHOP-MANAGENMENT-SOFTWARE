# Database Scripts — Thứ tự chạy

## Khởi tạo cơ bản

| # | File | Mô tả |
|---|------|-------|
| 1 | `01_CreateDatabase.sql` | Tạo database |
| 2 | `02_CreateTables.sql` | Tạo bảng gốc |
| 3 | `03_SeedData.sql` | Dữ liệu khởi tạo |

## Mở rộng tính năng

| # | File | Mô tả |
|---|------|-------|
| 4 | `05_Wave1_InventoryAndTop.sql` | Tồn kho cảnh báo + top sản phẩm |
| 5 | `06_Wave2_BanCaLichSuHoaDon.sql` | Bàn, ca làm việc, FK mới |
| 6 | `07_Wave3_DashboardExportAudit.sql` | AuditLog, index dashboard |
| 7 | `08_Wave4_PromotionCustomerSettings.sql` | Khuyến mãi, khách hàng, cấu hình |

## Nâng cấp thu ngân

| # | File | Mô tả |
|---|------|-------|
| 8 | `10_CashierUpgrade_Migration.sql` | Thêm cột thu ngân + sửa encoding tiếng Việt |
| 9 | `11_CashierTriggers_Validation.sql` | 6 trigger validation nghiệp vụ |
| 10 | `12_CashierIntegrity_Check.sql` | ⚠️ Chỉ đọc — 15 query kiểm tra dữ liệu |

## Dữ liệu demo/test

| # | File | Mô tả |
|---|------|-------|
| - | `05_DemoData.sql` | Dữ liệu mẫu cho demo |
| - | `04_TestQueries.sql` | Đối chiếu nhanh |

## Ghi chú

- **10 → 11 → 12** phải chạy đúng thứ tự.
- Script `05_DemoData.sql` idempotent, tránh chèn trùng.
- **12 chỉ SELECT**, không sửa/xóa dữ liệu. Dùng để kiểm tra sau khi chạy 10, 11.
- Trigger trong 11 **không tự trừ kho / cộng điểm** (code C# đã xử lý).
- Nên chạy 12 **trước** 11 để kiểm tra dữ liệu cũ có vi phạm trigger không.
