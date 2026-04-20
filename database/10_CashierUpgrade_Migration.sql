-- =============================================
-- Script: Nâng cấp nghiệp vụ thu ngân
-- Mô tả:
--   PHẦN A: Thêm các cột thu ngân vào bảng HoaDonBan
--   PHẦN B: Sửa dữ liệu tiếng Việt bị mã hóa sai (dùng NCHAR an toàn)
-- Lưu ý: Script an toàn, chạy nhiều lần không gây lỗi.
--         Không xóa, không rename bất kỳ cột/bảng nào.
-- =============================================

USE CoffeeShopDb;
GO

-- ========================================
-- PHẦN A: ĐẢM BẢO CÁC CỘT THU NGÂN TỒN TẠI
-- ========================================

IF COL_LENGTH(N'dbo.HoaDonBan', N'HinhThucThanhToan') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD HinhThucThanhToan NVARCHAR(50) NULL
        CONSTRAINT DF_HoaDonBan_HinhThucThanhToan DEFAULT N'Tiền mặt';
    PRINT N'Đã thêm cột HinhThucThanhToan';
END
GO

IF COL_LENGTH(N'dbo.HoaDonBan', N'TrangThaiThanhToan') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD TrangThaiThanhToan NVARCHAR(50) NULL
        CONSTRAINT DF_HoaDonBan_TrangThaiThanhToan DEFAULT N'Đã thanh toán';
    PRINT N'Đã thêm cột TrangThaiThanhToan';
END
GO

IF COL_LENGTH(N'dbo.HoaDonBan', N'TienKhachDua') IS NULL
    ALTER TABLE dbo.HoaDonBan ADD TienKhachDua DECIMAL(18,2) NULL;
GO
IF COL_LENGTH(N'dbo.HoaDonBan', N'TienThoiLai') IS NULL
    ALTER TABLE dbo.HoaDonBan ADD TienThoiLai DECIMAL(18,2) NULL;
GO
IF COL_LENGTH(N'dbo.HoaDonBan', N'MaGiaoDich') IS NULL
    ALTER TABLE dbo.HoaDonBan ADD MaGiaoDich NVARCHAR(100) NULL;
GO
IF COL_LENGTH(N'dbo.HoaDonBan', N'GhiChuThanhToan') IS NULL
    ALTER TABLE dbo.HoaDonBan ADD GhiChuThanhToan NVARCHAR(255) NULL;
GO
IF COL_LENGTH(N'dbo.HoaDonBan', N'GhiChuHoaDon') IS NULL
    ALTER TABLE dbo.HoaDonBan ADD GhiChuHoaDon NVARCHAR(255) NULL;
GO
IF COL_LENGTH(N'dbo.HoaDonBan', N'LyDoHuy') IS NULL
    ALTER TABLE dbo.HoaDonBan ADD LyDoHuy NVARCHAR(255) NULL;
GO
IF COL_LENGTH(N'dbo.HoaDonBan', N'NguoiHuy') IS NULL
    ALTER TABLE dbo.HoaDonBan ADD NguoiHuy NVARCHAR(50) NULL;
GO
IF COL_LENGTH(N'dbo.HoaDonBan', N'NgayHuy') IS NULL
    ALTER TABLE dbo.HoaDonBan ADD NgayHuy DATETIME NULL;
GO

PRINT N'Phần A hoàn thành: các cột thu ngân đã đảm bảo.';
GO

-- ========================================
-- PHẦN B: SỬA DỮ LIỆU TIẾNG VIỆT BỊ LỖI MÃ HÓA
-- Sử dụng LIKE pattern thay vì literal encoding sai
-- để tránh lỗi SQL syntax do ký tự đặc biệt.
-- ========================================

PRINT N'=== Bắt đầu sửa lỗi encoding tiếng Việt ===';

-- Sửa HinhThucThanhToan: dùng LIKE pattern an toàn
-- "Tiền mặt" bị encoding sai thường chứa "Ti" + ký tự lạ
UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Tiền mặt'
WHERE HinhThucThanhToan LIKE N'Ti%n m%t'
  AND HinhThucThanhToan <> N'Tiền mặt';
PRINT N'  HTTT -> Tiền mặt: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- "Thẻ" bị encoding sai thường chứa "Th" + ký tự lạ
UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Thẻ'
WHERE HinhThucThanhToan LIKE N'Th%'
  AND LEN(HinhThucThanhToan) <= 10
  AND HinhThucThanhToan NOT IN (N'Thẻ', N'Tiền mặt', N'Chuyển khoản', N'Ví điện tử');
PRINT N'  HTTT -> Thẻ: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- "Chuyển khoản" bị encoding sai
UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Chuyển khoản'
WHERE HinhThucThanhToan LIKE N'Chuy%n kho%n'
  AND HinhThucThanhToan <> N'Chuyển khoản';
PRINT N'  HTTT -> Chuyển khoản: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- "Ví điện tử" bị encoding sai (chứa ký tự nháy đơn gây lỗi SQL)
UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Ví điện tử'
WHERE HinhThucThanhToan LIKE N'V%i%n t%'
  AND HinhThucThanhToan <> N'Ví điện tử'
  AND HinhThucThanhToan NOT IN (N'Tiền mặt', N'Chuyển khoản', N'Thẻ');
PRINT N'  HTTT -> Ví điện tử: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- NULL -> mặc định
UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Tiền mặt'
WHERE HinhThucThanhToan IS NULL;
PRINT N'  HTTT NULL -> Tiền mặt: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- Sửa TrangThaiThanhToan
UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Đã thanh toán'
WHERE TrangThaiThanhToan LIKE N'%thanh to%n'
  AND TrangThaiThanhToan <> N'Đã thanh toán'
  AND TrangThaiThanhToan <> N'Chưa thanh toán';
PRINT N'  TTTT -> Đã thanh toán: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Đã hủy'
WHERE TrangThaiThanhToan LIKE N'%h%y'
  AND LEN(TrangThaiThanhToan) <= 20
  AND TrangThaiThanhToan <> N'Đã hủy'
  AND TrangThaiThanhToan NOT LIKE N'%thanh to%';
PRINT N'  TTTT -> Đã hủy: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Chưa thanh toán'
WHERE TrangThaiThanhToan LIKE N'Ch%a thanh to%n'
  AND TrangThaiThanhToan <> N'Chưa thanh toán';
PRINT N'  TTTT -> Chưa thanh toán: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Đã thanh toán'
WHERE TrangThaiThanhToan IS NULL;
PRINT N'  TTTT NULL -> Đã thanh toán: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- Dọn dẹp: nếu vẫn còn giá trị lạ sau khi sửa pattern
-- thì đặt mặc định an toàn
UPDATE dbo.HoaDonBan
SET HinhThucThanhToan = LTRIM(RTRIM(HinhThucThanhToan))
WHERE HinhThucThanhToan IS NOT NULL
  AND HinhThucThanhToan <> LTRIM(RTRIM(HinhThucThanhToan));
PRINT N'  HTTT trim khoảng trắng: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- Sửa trực tiếp các giá trị bị lỗi encoding đã gặp thực tế
UPDATE dbo.HoaDonBan
SET HinhThucThanhToan = N'Tiền mặt'
WHERE HinhThucThanhToan IN (N'Tiá»n máº·t', N'Tiá»\u0081n máº·t', N'Tiá»n máº·t');
PRINT N'  HTTT lỗi encoding -> Tiền mặt: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan
SET HinhThucThanhToan = N'Chuyển khoản'
WHERE HinhThucThanhToan IN (N'Chuyá»n khoáº£n', N'Chuyá»ƒn khoáº£n');
PRINT N'  HTTT lỗi encoding -> Chuyển khoản: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan
SET HinhThucThanhToan = N'Thẻ'
WHERE HinhThucThanhToan IN (N'Tháº»', N'Tháº½');
PRINT N'  HTTT lỗi encoding -> Thẻ: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan
SET HinhThucThanhToan = N'Ví điện tử'
WHERE HinhThucThanhToan IN (N'VÃ\u00AD Ä\u0091iá»\u0087n tá»­', N'VÃ Ä''iá»‡n tá»');
PRINT N'  HTTT lỗi encoding -> Ví điện tử: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Tiền mặt'
WHERE HinhThucThanhToan NOT IN (N'Tiền mặt', N'Chuyển khoản', N'Thẻ', N'Ví điện tử');
PRINT N'  HTTT còn lại -> Tiền mặt: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Đã thanh toán'
WHERE TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Chưa thanh toán', N'Đã hủy');
PRINT N'  TTTT còn lại -> Đã thanh toán: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- ========================================
-- PHẦN C: SỬA LẠI CHECK CONSTRAINT HÌNH THỨC THANH TOÁN
-- ========================================

IF EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_HoaDonBan_HinhThucThanhToan'
      AND parent_object_id = OBJECT_ID(N'dbo.HoaDonBan'))
BEGIN
    ALTER TABLE dbo.HoaDonBan DROP CONSTRAINT CK_HoaDonBan_HinhThucThanhToan;
    PRINT N'Đã drop CK_HoaDonBan_HinhThucThanhToan cũ.';
END

ALTER TABLE dbo.HoaDonBan WITH CHECK
ADD CONSTRAINT CK_HoaDonBan_HinhThucThanhToan
CHECK (HinhThucThanhToan IN (N'Tiền mặt', N'Chuyển khoản', N'Thẻ', N'Ví điện tử'));

ALTER TABLE dbo.HoaDonBan CHECK CONSTRAINT CK_HoaDonBan_HinhThucThanhToan;
PRINT N'Đã tạo lại CK_HoaDonBan_HinhThucThanhToan với 4 giá trị hợp lệ.';

PRINT N'=== Hoàn thành sửa encoding ===';
PRINT N'';
PRINT N'Tiếp theo chạy: 11_CashierTriggers_Validation.sql';
PRINT N'Sau đó chạy:    12_CashierIntegrity_Check.sql';
GO
