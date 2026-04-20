-- =============================================
-- Script: Nâng cấp nghiệp vụ thu ngân
-- Mô tả: Thêm các cột hỗ trợ thanh toán nâng cao cho bảng HoaDonBan
--         Bao gồm: hình thức thanh toán, trạng thái, tiền khách đưa,
--         tiền thối, mã giao dịch, ghi chú, và thông tin hủy hóa đơn.
-- Lưu ý: Script sử dụng IF COL_LENGTH để kiểm tra trước khi thêm cột.
--         Không xóa, không đổi tên bất kỳ cột nào.
-- =============================================

USE CoffeeShopDb;
GO

-- 1. Hình thức thanh toán: Tiền mặt, Chuyển khoản, Thẻ, Ví điện tử
IF COL_LENGTH(N'dbo.HoaDonBan', N'HinhThucThanhToan') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD HinhThucThanhToan NVARCHAR(50) NULL
        CONSTRAINT DF_HoaDonBan_HinhThucThanhToan DEFAULT N'Tiền mặt';
    PRINT N'✅ Đã thêm cột HinhThucThanhToan';
END
ELSE
    PRINT N'ℹ️ Cột HinhThucThanhToan đã tồn tại';
GO

-- 2. Trạng thái thanh toán: Đã thanh toán, Chưa thanh toán, Đã hủy
IF COL_LENGTH(N'dbo.HoaDonBan', N'TrangThaiThanhToan') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD TrangThaiThanhToan NVARCHAR(50) NULL
        CONSTRAINT DF_HoaDonBan_TrangThaiThanhToan DEFAULT N'Đã thanh toán';
    PRINT N'✅ Đã thêm cột TrangThaiThanhToan';
END
ELSE
    PRINT N'ℹ️ Cột TrangThaiThanhToan đã tồn tại';
GO

-- 3. Tiền khách đưa (chỉ áp dụng khi thanh toán tiền mặt)
IF COL_LENGTH(N'dbo.HoaDonBan', N'TienKhachDua') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD TienKhachDua DECIMAL(18,2) NULL;
    PRINT N'✅ Đã thêm cột TienKhachDua';
END
ELSE
    PRINT N'ℹ️ Cột TienKhachDua đã tồn tại';
GO

-- 4. Tiền thối lại (= TienKhachDua - ThanhToan)
IF COL_LENGTH(N'dbo.HoaDonBan', N'TienThoiLai') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD TienThoiLai DECIMAL(18,2) NULL;
    PRINT N'✅ Đã thêm cột TienThoiLai';
END
ELSE
    PRINT N'ℹ️ Cột TienThoiLai đã tồn tại';
GO

-- 5. Mã giao dịch (dùng cho chuyển khoản, thẻ, ví điện tử)
IF COL_LENGTH(N'dbo.HoaDonBan', N'MaGiaoDich') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD MaGiaoDich NVARCHAR(100) NULL;
    PRINT N'✅ Đã thêm cột MaGiaoDich';
END
ELSE
    PRINT N'ℹ️ Cột MaGiaoDich đã tồn tại';
GO

-- 6. Ghi chú thanh toán
IF COL_LENGTH(N'dbo.HoaDonBan', N'GhiChuThanhToan') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD GhiChuThanhToan NVARCHAR(255) NULL;
    PRINT N'✅ Đã thêm cột GhiChuThanhToan';
END
ELSE
    PRINT N'ℹ️ Cột GhiChuThanhToan đã tồn tại';
GO

-- 7. Ghi chú hóa đơn (ghi chú chung cho hóa đơn)
IF COL_LENGTH(N'dbo.HoaDonBan', N'GhiChuHoaDon') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD GhiChuHoaDon NVARCHAR(255) NULL;
    PRINT N'✅ Đã thêm cột GhiChuHoaDon';
END
ELSE
    PRINT N'ℹ️ Cột GhiChuHoaDon đã tồn tại';
GO

-- 8. Lý do hủy hóa đơn
IF COL_LENGTH(N'dbo.HoaDonBan', N'LyDoHuy') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD LyDoHuy NVARCHAR(255) NULL;
    PRINT N'✅ Đã thêm cột LyDoHuy';
END
ELSE
    PRINT N'ℹ️ Cột LyDoHuy đã tồn tại';
GO

-- 9. Người thực hiện hủy hóa đơn
IF COL_LENGTH(N'dbo.HoaDonBan', N'NguoiHuy') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD NguoiHuy NVARCHAR(50) NULL;
    PRINT N'✅ Đã thêm cột NguoiHuy';
END
ELSE
    PRINT N'ℹ️ Cột NguoiHuy đã tồn tại';
GO

-- 10. Ngày hủy hóa đơn
IF COL_LENGTH(N'dbo.HoaDonBan', N'NgayHuy') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan
    ADD NgayHuy DATETIME NULL;
    PRINT N'✅ Đã thêm cột NgayHuy';
END
ELSE
    PRINT N'ℹ️ Cột NgayHuy đã tồn tại';
GO

-- Cập nhật dữ liệu cũ: đặt TrangThaiThanhToan = 'Đã thanh toán' cho hóa đơn đã tồn tại
UPDATE dbo.HoaDonBan
SET TrangThaiThanhToan = N'Đã thanh toán'
WHERE TrangThaiThanhToan IS NULL;

-- Cập nhật dữ liệu cũ: đặt HinhThucThanhToan = 'Tiền mặt' cho hóa đơn đã tồn tại
UPDATE dbo.HoaDonBan
SET HinhThucThanhToan = N'Tiền mặt'
WHERE HinhThucThanhToan IS NULL;

PRINT N'';
PRINT N'✅ Hoàn thành migration nâng cấp nghiệp vụ thu ngân';
PRINT N'Các cột đã thêm vào bảng HoaDonBan:';
PRINT N'  - HinhThucThanhToan (Tiền mặt / Chuyển khoản / Thẻ / Ví điện tử)';
PRINT N'  - TrangThaiThanhToan (Đã thanh toán / Chưa thanh toán / Đã hủy)';
PRINT N'  - TienKhachDua, TienThoiLai';
PRINT N'  - MaGiaoDich, GhiChuThanhToan, GhiChuHoaDon';
PRINT N'  - LyDoHuy, NguoiHuy, NgayHuy';
GO
