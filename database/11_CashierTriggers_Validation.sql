-- =============================================
-- Script: Trigger Validation nghiệp vụ thu ngân
-- Tiên quyết: Chạy 10_CashierUpgrade_Migration.sql trước.
-- Mục đích: Bảo vệ dữ liệu, chặn dữ liệu sai.
-- KHÔNG tự trừ kho / cộng điểm (code C# đã xử lý).
-- Tất cả trigger xử lý multi-row an toàn.
-- =============================================

USE CoffeeShopDb;
GO

-- Xóa trigger encoding cũ nếu tồn tại (logic đã gộp vào trigger validate mới)
IF OBJECT_ID(N'dbo.TR_HoaDonBan_NormalizeVietnamese_Insert', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_HoaDonBan_NormalizeVietnamese_Insert;
IF OBJECT_ID(N'dbo.TR_HoaDonBan_NormalizeVietnamese_Update', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_HoaDonBan_NormalizeVietnamese_Update;
GO

-- =============================================
-- TRIGGER 1: HoaDonBan — Validate nghiệp vụ chính
-- Chức năng:
--   - Chuẩn hóa encoding tiếng Việt (tự sửa, không chặn)
--   - Validate HTTT, TTTT, tiền, giảm giá
--   - Validate hóa đơn hủy: lý do, ngày hủy
--   - Chặn chuyển ngược trạng thái từ Đã hủy
--   - Chặn sửa tiền hóa đơn đã hủy
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

    -- BƯỚC 1: Chuẩn hóa encoding (tự sửa nếu giá trị lạ, dùng LIKE an toàn)
    -- Sửa HinhThucThanhToan
    UPDATE h
    SET h.HinhThucThanhToan = N'Tiền mặt'
    FROM dbo.HoaDonBan h
    INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
    WHERE (h.HinhThucThanhToan IS NULL OR LTRIM(RTRIM(h.HinhThucThanhToan)) = N'')
       OR (h.HinhThucThanhToan LIKE N'Ti%n m%t' AND h.HinhThucThanhToan <> N'Tiền mặt');

    UPDATE h
    SET h.HinhThucThanhToan = N'Thẻ'
    FROM dbo.HoaDonBan h
    INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
    WHERE h.HinhThucThanhToan LIKE N'Th%'
      AND LEN(h.HinhThucThanhToan) <= 10
      AND h.HinhThucThanhToan NOT IN (N'Thẻ', N'Tiền mặt', N'Chuyển khoản', N'Ví điện tử');

    UPDATE h
    SET h.HinhThucThanhToan = N'Chuyển khoản'
    FROM dbo.HoaDonBan h
    INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
    WHERE h.HinhThucThanhToan LIKE N'Chuy%n kho%n'
      AND h.HinhThucThanhToan <> N'Chuyển khoản';

    UPDATE h
    SET h.HinhThucThanhToan = N'Ví điện tử'
    FROM dbo.HoaDonBan h
    INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
    WHERE h.HinhThucThanhToan LIKE N'V%i%n t%'
      AND h.HinhThucThanhToan <> N'Ví điện tử'
      AND h.HinhThucThanhToan NOT IN (N'Tiền mặt', N'Chuyển khoản', N'Thẻ');

    -- Sửa TrangThaiThanhToan
    UPDATE h
    SET h.TrangThaiThanhToan = N'Đã thanh toán'
    FROM dbo.HoaDonBan h
    INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
    WHERE (h.TrangThaiThanhToan IS NULL OR LTRIM(RTRIM(h.TrangThaiThanhToan)) = N'')
       OR (h.TrangThaiThanhToan LIKE N'%thanh to%n'
           AND h.TrangThaiThanhToan <> N'Đã thanh toán'
           AND h.TrangThaiThanhToan <> N'Chưa thanh toán');

    UPDATE h
    SET h.TrangThaiThanhToan = N'Đã hủy'
    FROM dbo.HoaDonBan h
    INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
    WHERE h.TrangThaiThanhToan LIKE N'%h%y'
      AND LEN(h.TrangThaiThanhToan) <= 20
      AND h.TrangThaiThanhToan <> N'Đã hủy'
      AND h.TrangThaiThanhToan NOT LIKE N'%thanh to%';

    UPDATE h
    SET h.TrangThaiThanhToan = N'Chưa thanh toán'
    FROM dbo.HoaDonBan h
    INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
    WHERE h.TrangThaiThanhToan LIKE N'Ch%a thanh to%n'
      AND h.TrangThaiThanhToan <> N'Chưa thanh toán';

    -- BƯỚC 2: Validate HTTT
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

    -- BƯỚC 3: Validate TTTT
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

    -- BƯỚC 4: Tổng tiền không âm
    IF EXISTS (SELECT 1 FROM inserted WHERE TongTien < 0)
    BEGIN
        RAISERROR(N'[HoaDonBan] Tổng tiền hóa đơn không được âm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- BƯỚC 5: Giảm giá không âm
    IF EXISTS (SELECT 1 FROM inserted WHERE GiamGia < 0)
    BEGIN
        RAISERROR(N'[HoaDonBan] Giảm giá không được âm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- BƯỚC 6: Giảm giá <= tổng tiền
    IF EXISTS (SELECT 1 FROM inserted WHERE GiamGia > TongTien)
    BEGIN
        RAISERROR(N'[HoaDonBan] Giảm giá không được lớn hơn tổng tiền hóa đơn.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- BƯỚC 7: Tiền mặt + Đã thanh toán phải có tiền khách đưa đủ
    IF EXISTS (
        SELECT 1 FROM dbo.HoaDonBan h
        INNER JOIN inserted i ON h.HoaDonBanId = i.HoaDonBanId
        WHERE h.HinhThucThanhToan = N'Tiền mặt'
          AND h.TrangThaiThanhToan = N'Đã thanh toán'
          AND (h.TienKhachDua IS NULL OR h.TienKhachDua < (i.TongTien - i.GiamGia))
    )
    BEGIN
        RAISERROR(N'[HoaDonBan] Thanh toán tiền mặt: Tiền khách đưa phải >= số tiền cần thanh toán.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- BƯỚC 8: Hóa đơn hủy phải có lý do
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

    -- BƯỚC 9: Hóa đơn hủy phải có ngày hủy
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

    -- BƯỚC 10: Chặn chuyển ngược từ Đã hủy (chỉ UPDATE)
    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM deleted d
            INNER JOIN dbo.HoaDonBan h ON h.HoaDonBanId = d.HoaDonBanId
            WHERE d.TrangThaiThanhToan = N'Đã hủy'
              AND h.TrangThaiThanhToan <> N'Đã hủy'
        )
        BEGIN
            RAISERROR(N'[HoaDonBan] Không thể chuyển hóa đơn đã hủy về trạng thái khác.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- BƯỚC 11: Chặn sửa tiền hóa đơn đã hủy
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

PRINT N'Trigger 1/6: TR_HoaDonBan_Cashier_Validate_AIU';
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

    IF EXISTS (SELECT 1 FROM inserted WHERE SoLuong <= 0)
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Số lượng phải lớn hơn 0.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM inserted WHERE DonGiaBan <= 0)
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Đơn giá bán phải lớn hơn 0.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE NOT EXISTS (SELECT 1 FROM dbo.HoaDonBan h WHERE h.HoaDonBanId = i.HoaDonBanId)
    )
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Mã hóa đơn bán không tồn tại.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE NOT EXISTS (SELECT 1 FROM dbo.Mon m WHERE m.MonId = i.MonId)
    )
    BEGIN
        RAISERROR(N'[ChiTietHoaDonBan] Mã món không tồn tại.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

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

PRINT N'Trigger 2/6: TR_ChiTietHoaDonBan_Cashier_Validate_AIU';
GO

-- =============================================
-- TRIGGER 3: CaLamViec — Chặn mở nhiều ca
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

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE ThoiGianDongCa IS NOT NULL AND ThoiGianDongCa < ThoiGianMoCa
    )
    BEGIN
        RAISERROR(N'[CaLamViec] Thời gian đóng ca không được nhỏ hơn thời gian mở ca.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM deleted d
            INNER JOIN inserted i ON d.CaLamViecId = i.CaLamViecId
            WHERE d.TrangThaiCa = N'DaDong' AND i.TrangThaiCa = N'DangMo'
        )
        BEGIN
            RAISERROR(N'[CaLamViec] Không thể mở lại ca đã đóng.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

PRINT N'Trigger 3/6: TR_CaLamViec_Cashier_Validate_AIU';
GO

-- =============================================
-- TRIGGER 4: Ban — Validate trạng thái bàn
-- Bảng Ban đã có CHECK constraint CK_Ban_TrangThaiBan
-- và UNIQUE constraint UQ_Ban_KhuVuc_TenBan.
-- Trigger bổ sung: tên bàn không rỗng, trạng thái không null.
-- =============================================
IF OBJECT_ID(N'dbo.TR_Ban_Cashier_Validate_AIU', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_Ban_Cashier_Validate_AIU;
GO

CREATE TRIGGER dbo.TR_Ban_Cashier_Validate_AIU
ON dbo.Ban
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE TenBan IS NULL OR LTRIM(RTRIM(TenBan)) = N''
    )
    BEGIN
        RAISERROR(N'[Ban] Tên bàn không được để trống.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE TrangThaiBan IS NULL
    )
    BEGIN
        RAISERROR(N'[Ban] Trạng thái bàn không được để trống.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

PRINT N'Trigger 4/6: TR_Ban_Cashier_Validate_AIU';
GO

-- =============================================
-- TRIGGER 5: Mon — Validate sản phẩm/tồn kho
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

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE TenMon IS NULL OR LTRIM(RTRIM(TenMon)) = N''
    )
    BEGIN
        RAISERROR(N'[Mon] Tên món không được để trống.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM inserted WHERE DonGia < 0)
    BEGIN
        RAISERROR(N'[Mon] Đơn giá không được âm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM inserted WHERE TonKho < 0)
    BEGIN
        RAISERROR(N'[Mon] Tồn kho không được âm. Kiểm tra lại số lượng bán hoặc nhập.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

PRINT N'Trigger 5/6: TR_Mon_Cashier_Validate_AIU';
GO

-- =============================================
-- TRIGGER 6: KhachHang — Validate điểm tích lũy
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

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE HoTen IS NULL OR LTRIM(RTRIM(HoTen)) = N''
    )
    BEGIN
        RAISERROR(N'[KhachHang] Tên khách hàng không được để trống.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM inserted WHERE DiemTichLuy < 0)
    BEGIN
        RAISERROR(N'[KhachHang] Điểm tích lũy không được âm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

PRINT N'Trigger 6/6: TR_KhachHang_Cashier_Validate_AIU';
GO

PRINT N'';
PRINT N'=== Hoàn thành tạo 6 trigger validation ===';
PRINT N'  1. TR_HoaDonBan_Cashier_Validate_AIU';
PRINT N'  2. TR_ChiTietHoaDonBan_Cashier_Validate_AIU';
PRINT N'  3. TR_CaLamViec_Cashier_Validate_AIU';
PRINT N'  4. TR_Ban_Cashier_Validate_AIU';
PRINT N'  5. TR_Mon_Cashier_Validate_AIU';
PRINT N'  6. TR_KhachHang_Cashier_Validate_AIU';
PRINT N'';
PRINT N'Không có trigger tự trừ kho/cộng điểm (code C# xử lý).';
GO
