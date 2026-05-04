-- =============================================
-- Script cập nhật database cho tính năng Công thức món
-- Thêm các cột mới và bảng lịch sử
-- =============================================

USE CoffeeShopDB;
GO

-- 1. Thêm cột CacBuocThucHien vào bảng CongThucMon
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.CongThucMon') AND name = 'CacBuocThucHien')
BEGIN
    ALTER TABLE dbo.CongThucMon
    ADD CacBuocThucHien NVARCHAR(MAX) NULL;
    PRINT 'Đã thêm cột CacBuocThucHien vào bảng CongThucMon';
END
ELSE
BEGIN
    PRINT 'Cột CacBuocThucHien đã tồn tại trong bảng CongThucMon';
END
GO

-- 2. Thêm cột TyLeHaoHut vào bảng CongThucMon
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.CongThucMon') AND name = 'TyLeHaoHut')
BEGIN
    ALTER TABLE dbo.CongThucMon
    ADD TyLeHaoHut DECIMAL(5, 2) NOT NULL DEFAULT 0;
    PRINT 'Đã thêm cột TyLeHaoHut vào bảng CongThucMon';
END
ELSE
BEGIN
    PRINT 'Cột TyLeHaoHut đã tồn tại trong bảng CongThucMon';
END
GO

-- 3. Tạo bảng LichSuCapNhatCongThuc
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LichSuCapNhatCongThuc') AND type = 'U')
BEGIN
    CREATE TABLE dbo.LichSuCapNhatCongThuc
    (
        LichSuId INT IDENTITY(1,1) PRIMARY KEY,
        MonId INT NOT NULL,
        NgayCapNhat DATETIME NOT NULL DEFAULT GETDATE(),
        NguoiCapNhat NVARCHAR(100) NULL,
        NoiDungCapNhat NVARCHAR(500) NULL,
        
        CONSTRAINT FK_LichSuCapNhatCongThuc_Mon 
            FOREIGN KEY (MonId) REFERENCES dbo.Mon(MonId)
    );
    
    -- Tạo index cho tìm kiếm nhanh
    CREATE INDEX IX_LichSuCapNhatCongThuc_MonId 
        ON dbo.LichSuCapNhatCongThuc(MonId);
    
    CREATE INDEX IX_LichSuCapNhatCongThuc_NgayCapNhat 
        ON dbo.LichSuCapNhatCongThuc(NgayCapNhat DESC);
    
    PRINT 'Đã tạo bảng LichSuCapNhatCongThuc';
END
ELSE
BEGIN
    PRINT 'Bảng LichSuCapNhatCongThuc đã tồn tại';
END
GO

-- 4. Thêm dữ liệu mẫu cho lịch sử (nếu cần)
-- Uncomment phần này nếu muốn thêm dữ liệu mẫu
/*
IF EXISTS (SELECT 1 FROM dbo.Mon WHERE MonId = 1)
BEGIN
    INSERT INTO dbo.LichSuCapNhatCongThuc (MonId, NgayCapNhat, NguoiCapNhat, NoiDungCapNhat)
    VALUES 
        (1, GETDATE(), 'Admin', 'Khởi tạo công thức món'),
        (1, DATEADD(HOUR, -1, GETDATE()), 'Admin', 'Cập nhật định lượng nguyên liệu');
    
    PRINT 'Đã thêm dữ liệu mẫu vào bảng LichSuCapNhatCongThuc';
END
GO
*/

-- 5. Kiểm tra kết quả
SELECT 
    'CongThucMon' AS TableName,
    COUNT(*) AS RecordCount
FROM dbo.CongThucMon
UNION ALL
SELECT 
    'LichSuCapNhatCongThuc' AS TableName,
    COUNT(*) AS RecordCount
FROM dbo.LichSuCapNhatCongThuc;
GO

PRINT 'Hoàn tất cập nhật database!';
GO
