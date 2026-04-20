-- =============================================
-- Script: Nâng cấp nghiệp vụ thu ngân (PHIÊN BẢN ĐẦY ĐỦ)
-- Mô tả:
--   PHẦN A: Thêm các cột thu ngân vào bảng HoaDonBan
--   PHẦN B: Sửa dữ liệu tiếng Việt bị mã hóa sai
--   PHẦN C: Trigger validation nghiệp vụ thu ngân (5 trigger)
--   PHẦN D: Integrity check (chỉ SELECT, không sửa dữ liệu)
-- Lưu ý: Script an toàn, chạy nhiều lần không gây lỗi.
--         Không xóa, không rename bất kỳ cột/bảng nào.
--         KHÔNG tự động trừ kho/cộng điểm (code C# đã xử lý).
-- =============================================

USE CoffeeShopDb;
GO

-- ========================================
-- PHẦN A: ĐẢM BẢO CÁC CỘT THU NGÂN TỒN TẠI
-- ========================================

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

-- 3. Tiền khách đưa
IF COL_LENGTH(N'dbo.HoaDonBan', N'TienKhachDua') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan ADD TienKhachDua DECIMAL(18,2) NULL;
    PRINT N'✅ Đã thêm cột TienKhachDua';
END
ELSE
    PRINT N'ℹ️ Cột TienKhachDua đã tồn tại';
GO

-- 4. Tiền thối lại
IF COL_LENGTH(N'dbo.HoaDonBan', N'TienThoiLai') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan ADD TienThoiLai DECIMAL(18,2) NULL;
    PRINT N'✅ Đã thêm cột TienThoiLai';
END
ELSE
    PRINT N'ℹ️ Cột TienThoiLai đã tồn tại';
GO

-- 5. Mã giao dịch
IF COL_LENGTH(N'dbo.HoaDonBan', N'MaGiaoDich') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan ADD MaGiaoDich NVARCHAR(100) NULL;
    PRINT N'✅ Đã thêm cột MaGiaoDich';
END
ELSE
    PRINT N'ℹ️ Cột MaGiaoDich đã tồn tại';
GO

-- 6. Ghi chú thanh toán
IF COL_LENGTH(N'dbo.HoaDonBan', N'GhiChuThanhToan') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan ADD GhiChuThanhToan NVARCHAR(255) NULL;
    PRINT N'✅ Đã thêm cột GhiChuThanhToan';
END
ELSE
    PRINT N'ℹ️ Cột GhiChuThanhToan đã tồn tại';
GO

-- 7. Ghi chú hóa đơn
IF COL_LENGTH(N'dbo.HoaDonBan', N'GhiChuHoaDon') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan ADD GhiChuHoaDon NVARCHAR(255) NULL;
    PRINT N'✅ Đã thêm cột GhiChuHoaDon';
END
ELSE
    PRINT N'ℹ️ Cột GhiChuHoaDon đã tồn tại';
GO

-- 8. Lý do hủy
IF COL_LENGTH(N'dbo.HoaDonBan', N'LyDoHuy') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan ADD LyDoHuy NVARCHAR(255) NULL;
    PRINT N'✅ Đã thêm cột LyDoHuy';
END
ELSE
    PRINT N'ℹ️ Cột LyDoHuy đã tồn tại';
GO

-- 9. Người hủy
IF COL_LENGTH(N'dbo.HoaDonBan', N'NguoiHuy') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan ADD NguoiHuy NVARCHAR(50) NULL;
    PRINT N'✅ Đã thêm cột NguoiHuy';
END
ELSE
    PRINT N'ℹ️ Cột NguoiHuy đã tồn tại';
GO

-- 10. Ngày hủy
IF COL_LENGTH(N'dbo.HoaDonBan', N'NgayHuy') IS NULL
BEGIN
    ALTER TABLE dbo.HoaDonBan ADD NgayHuy DATETIME NULL;
    PRINT N'✅ Đã thêm cột NgayHuy';
END
ELSE
    PRINT N'ℹ️ Cột NgayHuy đã tồn tại';
GO

-- ========================================
-- PHẦN B: SỬA DỮ LIỆU TIẾNG VIỆT BỊ LỖI MÃ HÓA
-- ========================================

PRINT N'';
PRINT N'=== Bắt đầu sửa lỗi encoding tiếng Việt ===';

-- Sửa HinhThucThanhToan
UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Tiền mặt'
WHERE HinhThucThanhToan IN (N'Tiá»n máº·t', N'Tiá»n mạt', N'Tiá»n mặt');
PRINT N'  HinhThucThanhToan → Tiền mặt: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Thẻ'
WHERE HinhThucThanhToan IN (N'Tháº»', N'Tháº', N'Tháº½');
PRINT N'  HinhThucThanhToan → Thẻ: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Chuyển khoản'
WHERE HinhThucThanhToan IN (N'Chuyá»ƒn khoáº£n', N'Chuyá»ƒn khoản', N'Chuyển khoáº£n');
PRINT N'  HinhThucThanhToan → Chuyển khoản: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Ví điện tử'
WHERE HinhThucThanhToan IN (N'VÃ Ä''iá»‡n tá»', N'VÃ điện tử', N'Ví Ä''iá»‡n tử');
PRINT N'  HinhThucThanhToan → Ví điện tử: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET HinhThucThanhToan = N'Tiền mặt'
WHERE HinhThucThanhToan IS NULL;
PRINT N'  HinhThucThanhToan NULL → Tiền mặt: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

-- Sửa TrangThaiThanhToan
UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Đã thanh toán'
WHERE TrangThaiThanhToan IN (N'ÄÃ£ thanh toÃ¡n', N'ĐÃ£ thanh toán', N'Äã thanh toán');
PRINT N'  TrangThaiThanhToan → Đã thanh toán: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Đã hủy'
WHERE TrangThaiThanhToan IN (N'ÄÃ£ há»§y', N'ĐÃ£ hủy', N'Äã hủy');
PRINT N'  TrangThaiThanhToan → Đã hủy: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Chưa thanh toán'
WHERE TrangThaiThanhToan IN (N'ChÆ°a thanh toÃ¡n', N'Chưa thanh toÃ¡n', N'ChÆ°a thanh toán');
PRINT N'  TrangThaiThanhToan → Chưa thanh toán: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

UPDATE dbo.HoaDonBan SET TrangThaiThanhToan = N'Đã thanh toán'
WHERE TrangThaiThanhToan IS NULL;
PRINT N'  TrangThaiThanhToan NULL → Đã thanh toán: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng';

PRINT N'=== Hoàn thành sửa lỗi encoding ===';
GO

-- ========================================
-- PHẦN C: TRIGGER VALIDATION NGHIỆP VỤ THU NGÂN
-- Mục đích: Bảo vệ dữ liệu, chặn dữ liệu sai.
-- KHÔNG tự trừ kho / cộng điểm (code C# đã xử lý).
-- Tất cả trigger xử lý multi-row an toàn.
-- ========================================

PRINT N'';
PRINT N'=== Tạo trigger validation ===';
GO

-- Xóa trigger encoding cũ (logic gộp vào trigger validate mới)
IF OBJECT_ID(N'dbo.TR_HoaDonBan_NormalizeVietnamese_Insert', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_HoaDonBan_NormalizeVietnamese_Insert;
IF OBJECT_ID(N'dbo.TR_HoaDonBan_NormalizeVietnamese_Update', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_HoaDonBan_NormalizeVietnamese_Update;
GO

-- =============================================
-- TRIGGER 1: HoaDonBan — Validate nghiệp vụ chính
-- =============================================
IF OBJECT_ID(N'dbo.TR_HoaDonBan_Cashier_Validate_AIU', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_HoaDonBan_Cashier_Validate_AIU;
GO

CREATE TRIGGER dbo.TR_HoaDonBan_Cashier_Validate_AIU
ON dbo.HoaDonBan
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- ===== BƯỚC 1: Chuẩn hóa encoding tiếng Việt (tự động sửa, không chặn) =====
    UPDATE h
    SET h.HinhThucThanhToan = 
        CASE
            WHEN h.HinhThucThanhToan IS NULL OR LTRIM(RTRIM(h.HinhThucThanhToan)) = N''
                THEN N'Tiền mặt'
            WHEN h.HinhThucThanhToan IN (N'Tiá»n máº·t', N'Tiá»n mạt', N'Tiá»n mặt')
                THEN N'Tiền mặt'
            WHEN h.HinhThucThanhToan IN (N'Tháº»', N'Tháº', N'Tháº½')
                THEN N'Thẻ'
            WHEN h.HinhThucThanhToan IN (N'Chuyá»ƒn khoáº£n', N'Chuyá»ƒn khoản', N'Chuyển khoáº£n')
                THEN N'Chuyển khoản'
            WHEN h.HinhThucThanhToan IN (N'VÃ Ä''iá»‡n tá»', N'VÃ điện tử', N'Ví Ä''iá»‡n tử')
                THEN N'Ví điện tử'
            ELSE h.HinhThucThanhToan
        END,
        h.TrangThaiThanhToan = 
        CASE
            WHEN h.TrangThaiThanhToan IS NULL OR LTRIM(RTRIM(h.TrangThaiThanhToan)) = N''
                THEN N'Đã thanh toán'
            WHEN h.TrangThaiThanhToan IN (N'ÄÃ£ thanh toÃ¡n', N'ĐÃ£ thanh toán', N'Äã thanh toán')
                THEN N'Đã thanh toán'
            WHEN h.TrangThaiThanhToan IN (N'ÄÃ£ há»§y', N'ĐÃ£ hủy', N'Äã hủy')
                THEN N'Đã hủy'
            WHEN h.TrangThaiThanhToan IN (N'ChÆ°a thanh toÃ¡n', N'Chưa thanh toÃ¡n', N'ChÆ°a thanh toán')
                THEN N'Chưa thanh toán'
            ELSE h.TrangThaiThanhToan
        END
    FROM dbo.HoaDonBan h
    INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
    WHERE h.HinhThucThanhToan IS NULL
       OR h.HinhThucThanhToan NOT IN (N'Tiền mặt', N'Chuyển khoản', N'Thẻ', N'Ví điện tử')
       OR h.TrangThaiThanhToan IS NULL
       OR h.TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Chưa thanh toán', N'Đã hủy');

    -- ===== BƯỚC 2: Validate hình thức thanh toán =====
    -- Đọc lại dữ liệu sau khi chuẩn hóa
    IF EXISTS (
        SELECT 1 FROM dbo.HoaDonBan h
        INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
        WHERE h.HinhThucThanhToan NOT IN (N'Tiền mặt', N'Chuyển khoản', N'Thẻ', N'Ví điện tử')
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Hình thức thanh toán không hợp lệ. Chỉ chấp nhận: Tiền mặt, Chuyển khoản, Thẻ, Ví điện tử.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== BƯỚC 3: Validate trạng thái thanh toán =====
    IF EXISTS (
        SELECT 1 FROM dbo.HoaDonBan h
        INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
        WHERE h.TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Chưa thanh toán', N'Đã hủy')
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Trạng thái thanh toán không hợp lệ. Chỉ chấp nhận: Đã thanh toán, Chưa thanh toán, Đã hủy.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== BƯỚC 4: Validate tổng tiền không âm =====
    IF EXISTS (
        SELECT 1 FROM inserted WHERE TongTien < 0
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Tổng tiền hóa đơn không được âm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== BƯỚC 5: Validate giảm giá không âm =====
    IF EXISTS (
        SELECT 1 FROM inserted WHERE GiamGia < 0
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Giảm giá không được âm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== BƯỚC 6: Validate giảm giá <= tổng tiền =====
    IF EXISTS (
        SELECT 1 FROM inserted WHERE GiamGia > TongTien
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Giảm giá không được lớn hơn tổng tiền hóa đơn.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== BƯỚC 7: Validate tiền mặt phải có tiền khách đưa đủ =====
    -- Chỉ kiểm tra khi HTTT = Tiền mặt VÀ trạng thái = Đã thanh toán
    IF EXISTS (
        SELECT 1 FROM dbo.HoaDonBan h
        INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
        WHERE h.HinhThucThanhToan = N'Tiền mặt'
          AND h.TrangThaiThanhToan = N'Đã thanh toán'
          AND (h.TienKhachDua IS NULL OR h.TienKhachDua < (i.TongTien - i.GiamGia))
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Thanh toán tiền mặt: Tiền khách đưa phải >= số tiền cần thanh toán (TongTien - GiamGia).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== BƯỚC 8: Validate hóa đơn hủy phải có đủ thông tin =====
    IF EXISTS (
        SELECT 1 FROM dbo.HoaDonBan h
        INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
        WHERE h.TrangThaiThanhToan = N'Đã hủy'
          AND (h.LyDoHuy IS NULL OR LTRIM(RTRIM(h.LyDoHuy)) = N'')
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Hóa đơn đã hủy phải có lý do hủy.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM dbo.HoaDonBan h
        INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
        WHERE h.TrangThaiThanhToan = N'Đã hủy'
          AND h.NgayHuy IS NULL
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Hóa đơn đã hủy phải có ngày hủy.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== BƯỚC 9: Chặn chuyển trạng thái ngược từ Đã hủy (chỉ UPDATE) =====
    IF EXISTS (SELECT 1 FROM deleted) -- Chỉ kiểm tra khi UPDATE
    BEGIN
        IF EXISTS (
            SELECT 1 FROM deleted d
            INNER JOIN inserted i ON d.HoaDonBanId = i.HoaDonBanId
            INNER JOIN dbo.HoaDonBan h ON h.HoaDonBanId = i.HoaDonBanId
            WHERE d.TrangThaiThanhToan = N'Đã hủy'
              AND h.TrangThaiThanhToan <> N'Đã hủy'
        )
        BEGIN
            RAISERROR(N'[HoaDonBan] Không thể chuyển hóa đơn đã hủy về trạng thái khác.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- ===== BƯỚC 10: Chặn sửa tiền của hóa đơn đã hủy =====
        IF EXISTS (
            SELECT 1 FROM deleted d
            INNER JOIN inserted i ON d.HoaDonBanId = i.HoaDonBanId
            WHERE d.TrangThaiThanhToan = N'Đã hủy'
              AND (d.TongTien <> i.TongTien OR d.GiamGia <> i.GiamGia)
        )
        BEGIN
            RAISERROR(N'[HoaDonBan] Không thể sửa tổng tiền hoặc giảm giá của hóa đơn đã hủy.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

PRINT N'✅ Đã tạo trigger TR_HoaDonBan_Cashier_Validate_AIU';
GO

-- =============================================
-- TRIGGER 2: ChiTietHoaDonBan — Validate chi tiết
-- =============================================
IF OBJECT_ID(N'dbo.TR_ChiTietHoaDonBan_Cashier_Validate_AIU', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_ChiTietHoaDonBan_Cashier_Validate_AIU;
GO

CREATE TRIGGER dbo.TR_ChiTietHoaDonBan_Cashier_Validate_AIU
ON dbo.ChiTietHoaDonBan
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- ===== 1. SoLuong phải > 0 =====
    IF EXISTS (
        SELECT 1 FROM inserted WHERE SoLuong <= 0
    )
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Số lượng phải lớn hơn 0.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 2. DonGiaBan phải > 0 =====
    IF EXISTS (
        SELECT 1 FROM inserted WHERE DonGiaBan <= 0
    )
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Đơn giá bán phải lớn hơn 0.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 3. HoaDonBanId phải tồn tại =====
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.HoaDonBan h WHERE h.HoaDonBanId = i.HoaDonBanId
        )
    )
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Mã hóa đơn bán không tồn tại.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 4. MonId phải tồn tại =====
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.Mon m WHERE m.MonId = i.MonId
        )
    )
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Mã món không tồn tại.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 5. Không cho thêm/sửa chi tiết của hóa đơn đã hủy =====
    IF EXISTS (
        SELECT 1 FROM inserted i
        INNER JOIN dbo.HoaDonBan h ON h.HoaDonBanId = i.HoaDonBanId
        WHERE ISNULL(h.TrangThaiThanhToan, N'Đã thanh toán') = N'Đã hủy'
    )
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Không thể thêm hoặc sửa chi tiết của hóa đơn đã hủy.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

PRINT N'✅ Đã tạo trigger TR_ChiTietHoaDonBan_Cashier_Validate_AIU';
GO

-- =============================================
-- TRIGGER 3: CaLamViec — Chặn mở nhiều ca cùng lúc
-- =============================================
IF OBJECT_ID(N'dbo.TR_CaLamViec_Cashier_Validate_AIU', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_CaLamViec_Cashier_Validate_AIU;
GO

CREATE TRIGGER dbo.TR_CaLamViec_Cashier_Validate_AIU
ON dbo.CaLamViec
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- ===== 1. Chặn mở nhiều ca cùng lúc cho 1 nhân viên =====
    -- Tìm nhân viên có > 1 ca DangMo
    IF EXISTS (
        SELECT c.NguoiDungId
        FROM dbo.CaLamViec c
        WHERE c.TrangThaiCa = N'DangMo'
          AND c.NguoiDungId IN (SELECT i.NguoiDungId FROM inserted i WHERE i.TrangThaiCa = N'DangMo')
        GROUP BY c.NguoiDungId
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR(N'[CaLamViec] Một nhân viên không thể mở nhiều ca làm việc cùng lúc.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 2. Thời gian đóng ca không được < thời gian mở ca =====
    -- (CHECK constraint CK_CaLamViec_ThoiGian đã bao, nhưng trigger báo lỗi rõ hơn)
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE ThoiGianDongCa IS NOT NULL
          AND ThoiGianDongCa < ThoiGianMoCa
    )
    BEGIN
        RAISERROR(N'[CaLamViec] Thời gian đóng ca không được nhỏ hơn thời gian mở ca.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 3. Không cho đóng ca nếu ca không phải DangMo =====
    IF EXISTS (SELECT 1 FROM deleted) -- Chỉ kiểm tra khi UPDATE
    BEGIN
        IF EXISTS (
            SELECT 1 FROM deleted d
            INNER JOIN inserted i ON d.CaLamViecId = i.CaLamViecId
            WHERE d.TrangThaiCa = N'DaDong'
              AND i.TrangThaiCa = N'DangMo'
        )
        BEGIN
            RAISERROR(N'[CaLamViec] Không thể mở lại ca đã đóng.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

PRINT N'✅ Đã tạo trigger TR_CaLamViec_Cashier_Validate_AIU';
GO

-- =============================================
-- TRIGGER 4: Mon — Validate sản phẩm/tồn kho
-- KHÔNG tự trừ kho (code C# đã xử lý)
-- =============================================
IF OBJECT_ID(N'dbo.TR_Mon_Cashier_Validate_AIU', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_Mon_Cashier_Validate_AIU;
GO

CREATE TRIGGER dbo.TR_Mon_Cashier_Validate_AIU
ON dbo.Mon
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- ===== 1. Tên món không được rỗng =====
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE TenMon IS NULL OR LTRIM(RTRIM(TenMon)) = N''
    )
    BEGIN
        RAISERROR(N'[Mon] Tên món không được để trống.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 2. Đơn giá không được âm =====
    IF EXISTS (
        SELECT 1 FROM inserted WHERE DonGia < 0
    )
    BEGIN
        RAISERROR(N'[Mon] Đơn giá không được âm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 3. Tồn kho không được âm =====
    IF EXISTS (
        SELECT 1 FROM inserted WHERE TonKho < 0
    )
    BEGIN
        RAISERROR(N'[Mon] Tồn kho không được âm. Kiểm tra lại số lượng bán hoặc nhập.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

PRINT N'✅ Đã tạo trigger TR_Mon_Cashier_Validate_AIU';
GO

-- =============================================
-- TRIGGER 5: KhachHang — Validate điểm tích lũy
-- KHÔNG tự cộng/trừ điểm (code C# đã xử lý)
-- =============================================
IF OBJECT_ID(N'dbo.TR_KhachHang_Cashier_Validate_AIU', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_KhachHang_Cashier_Validate_AIU;
GO

CREATE TRIGGER dbo.TR_KhachHang_Cashier_Validate_AIU
ON dbo.KhachHang
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- ===== 1. Tên khách hàng không được rỗng =====
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE HoTen IS NULL OR LTRIM(RTRIM(HoTen)) = N''
    )
    BEGIN
        RAISERROR(N'[KhachHang] Tên khách hàng không được để trống.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- ===== 2. Điểm tích lũy không được âm =====
    -- (CHECK constraint CK_KhachHang_Diem đã bao, trigger báo lỗi rõ hơn)
    IF EXISTS (
        SELECT 1 FROM inserted WHERE DiemTichLuy < 0
    )
    BEGIN
        RAISERROR(N'[KhachHang] Điểm tích lũy không được âm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

PRINT N'✅ Đã tạo trigger TR_KhachHang_Cashier_Validate_AIU';
GO

-- ========================================
-- PHẦN D: KIỂM TRA TÍNH TOÀN VẸN DỮ LIỆU
-- Chỉ SELECT, KHÔNG sửa dữ liệu.
-- Nếu có kết quả → cần kiểm tra lại dữ liệu.
-- ========================================

PRINT N'';
PRINT N'============================================';
PRINT N'  KIỂM TRA TÍNH TOÀN VẸN DỮ LIỆU THU NGÂN';
PRINT N'============================================';
PRINT N'';

-- 1. Hóa đơn có hình thức thanh toán không hợp lệ
PRINT N'--- 1. Hóa đơn có hình thức thanh toán không hợp lệ ---';
SELECT HoaDonBanId, HinhThucThanhToan, N'HTTT không hợp lệ' AS VanDe
FROM dbo.HoaDonBan
WHERE HinhThucThanhToan NOT IN (N'Tiền mặt', N'Chuyển khoản', N'Thẻ', N'Ví điện tử')
   OR HinhThucThanhToan IS NULL;

-- 2. Hóa đơn có trạng thái thanh toán không hợp lệ
PRINT N'--- 2. Hóa đơn có trạng thái không hợp lệ ---';
SELECT HoaDonBanId, TrangThaiThanhToan, N'TTTT không hợp lệ' AS VanDe
FROM dbo.HoaDonBan
WHERE TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Chưa thanh toán', N'Đã hủy')
   OR TrangThaiThanhToan IS NULL;

-- 3. Hóa đơn tiền mặt + đã thanh toán nhưng thiếu tiền khách đưa
PRINT N'--- 3. Hóa đơn tiền mặt thiếu tiền khách đưa ---';
SELECT HoaDonBanId, TongTien, GiamGia, TienKhachDua,
       N'Tiền mặt nhưng thiếu TienKhachDua' AS VanDe
FROM dbo.HoaDonBan
WHERE HinhThucThanhToan = N'Tiền mặt'
  AND TrangThaiThanhToan = N'Đã thanh toán'
  AND (TienKhachDua IS NULL OR TienKhachDua < (TongTien - GiamGia));

-- 4. Hóa đơn đã hủy thiếu lý do hủy
PRINT N'--- 4. Hóa đơn đã hủy thiếu lý do hủy ---';
SELECT HoaDonBanId, TrangThaiThanhToan,
       N'Đã hủy nhưng thiếu LyDoHuy' AS VanDe
FROM dbo.HoaDonBan
WHERE TrangThaiThanhToan = N'Đã hủy'
  AND (LyDoHuy IS NULL OR LTRIM(RTRIM(LyDoHuy)) = N'');

-- 5. Hóa đơn đã hủy thiếu người hủy
PRINT N'--- 5. Hóa đơn đã hủy thiếu người hủy ---';
SELECT HoaDonBanId, TrangThaiThanhToan,
       N'Đã hủy nhưng thiếu NguoiHuy' AS VanDe
FROM dbo.HoaDonBan
WHERE TrangThaiThanhToan = N'Đã hủy'
  AND (NguoiHuy IS NULL OR LTRIM(RTRIM(NguoiHuy)) = N'');

-- 6. Hóa đơn đã hủy thiếu ngày hủy
PRINT N'--- 6. Hóa đơn đã hủy thiếu ngày hủy ---';
SELECT HoaDonBanId, TrangThaiThanhToan,
       N'Đã hủy nhưng thiếu NgayHuy' AS VanDe
FROM dbo.HoaDonBan
WHERE TrangThaiThanhToan = N'Đã hủy'
  AND NgayHuy IS NULL;

-- 7. Chi tiết hóa đơn có số lượng <= 0
PRINT N'--- 7. Chi tiết có SoLuong <= 0 ---';
SELECT ChiTietHoaDonBanId, HoaDonBanId, MonId, SoLuong,
       N'SoLuong <= 0' AS VanDe
FROM dbo.ChiTietHoaDonBan
WHERE SoLuong <= 0;

-- 8. Chi tiết hóa đơn có đơn giá <= 0
PRINT N'--- 8. Chi tiết có DonGiaBan <= 0 ---';
SELECT ChiTietHoaDonBanId, HoaDonBanId, MonId, DonGiaBan,
       N'DonGiaBan <= 0' AS VanDe
FROM dbo.ChiTietHoaDonBan
WHERE DonGiaBan <= 0;

-- 9. Một món trùng nhiều dòng trong cùng HĐ
PRINT N'--- 9. Món trùng nhiều dòng trong cùng hóa đơn ---';
SELECT HoaDonBanId, MonId, COUNT(*) AS SoDong,
       N'Món trùng nhiều dòng' AS VanDe
FROM dbo.ChiTietHoaDonBan
GROUP BY HoaDonBanId, MonId
HAVING COUNT(*) > 1;

-- 10. Tồn kho âm
PRINT N'--- 10. Món có tồn kho âm ---';
SELECT MonId, TenMon, TonKho,
       N'TonKho < 0' AS VanDe
FROM dbo.Mon
WHERE TonKho < 0;

-- 11. Điểm khách hàng âm
PRINT N'--- 11. Khách hàng có điểm âm ---';
SELECT KhachHangId, HoTen, DiemTichLuy,
       N'DiemTichLuy < 0' AS VanDe
FROM dbo.KhachHang
WHERE DiemTichLuy < 0;

-- 12. Một nhân viên có nhiều ca đang mở
PRINT N'--- 12. Nhân viên có nhiều ca DangMo ---';
SELECT c.NguoiDungId, nd.HoTen, COUNT(*) AS SoCaDangMo,
       N'Nhiều ca DangMo cùng lúc' AS VanDe
FROM dbo.CaLamViec c
JOIN dbo.NguoiDung nd ON nd.NguoiDungId = c.NguoiDungId
WHERE c.TrangThaiCa = N'DangMo'
GROUP BY c.NguoiDungId, nd.HoTen
HAVING COUNT(*) > 1;

-- 13. Trạng thái bàn không hợp lệ
PRINT N'--- 13. Bàn có trạng thái không hợp lệ ---';
SELECT BanId, TenBan, TrangThaiBan,
       N'TrangThaiBan không hợp lệ' AS VanDe
FROM dbo.Ban
WHERE TrangThaiBan NOT IN (N'Trong', N'DangPhucVu', N'ChoThanhToan', N'TamKhoa');

-- 14. Tổng kết
PRINT N'';
PRINT N'============================================';
PRINT N'  ĐÃ HOÀN THÀNH KIỂM TRA TÍNH TOÀN VẸN';
PRINT N'  Nếu các query trên trả kết quả rỗng';
PRINT N'  → dữ liệu thu ngân đang toàn vẹn.';
PRINT N'============================================';
GO

-- ========================================
-- TỔNG KẾT
-- ========================================
PRINT N'';
PRINT N'============================================';
PRINT N'✅ HOÀN THÀNH MIGRATION v10';
PRINT N'============================================';
PRINT N'';
PRINT N'PHẦN A: Các cột thu ngân đã thêm/kiểm tra:';
PRINT N'  - HinhThucThanhToan, TrangThaiThanhToan';
PRINT N'  - TienKhachDua, TienThoiLai';
PRINT N'  - MaGiaoDich, GhiChuThanhToan, GhiChuHoaDon';
PRINT N'  - LyDoHuy, NguoiHuy, NgayHuy';
PRINT N'';
PRINT N'PHẦN B: Dữ liệu encoding đã sửa.';
PRINT N'';
PRINT N'PHẦN C: Trigger validation đã tạo:';
PRINT N'  1. TR_HoaDonBan_Cashier_Validate_AIU';
PRINT N'     → HTTT, TTTT, tiền, hủy, encoding, chặn chuyển ngược';
PRINT N'  2. TR_ChiTietHoaDonBan_Cashier_Validate_AIU';
PRINT N'     → SoLuong, DonGiaBan, HĐ hủy, FK check';
PRINT N'  3. TR_CaLamViec_Cashier_Validate_AIU';
PRINT N'     → Chặn nhiều ca cùng lúc, thời gian, trạng thái';
PRINT N'  4. TR_Mon_Cashier_Validate_AIU';
PRINT N'     → TenMon, DonGia, TonKho không âm';
PRINT N'  5. TR_KhachHang_Cashier_Validate_AIU';
PRINT N'     → HoTen, DiemTichLuy không âm';
PRINT N'';
PRINT N'PHẦN D: Integrity check đã chạy (14 query).';
PRINT N'';
PRINT N'⚠️ KHÔNG có trigger tự trừ kho / cộng điểm';
PRINT N'   (code C# đã xử lý, tránh xung đột).';
GO
