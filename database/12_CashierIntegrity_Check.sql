-- =============================================
-- Script: Kiểm tra tính toàn vẹn dữ liệu thu ngân
-- Tiên quyết: Chạy 10, 11 trước.
-- CHỈ SELECT — KHÔNG update, KHÔNG delete.
-- Nếu query trả kết quả → có dữ liệu cần kiểm tra.
-- =============================================

USE CoffeeShopDb;
GO

PRINT N'============================================';
PRINT N'  KIỂM TRA TÍNH TOÀN VẸN DỮ LIỆU THU NGÂN';
PRINT N'============================================';
PRINT N'';

-- 1. HTTT không hợp lệ
PRINT N'--- 1. Hóa đơn có HTTT không hợp lệ ---';
SELECT HoaDonBanId, HinhThucThanhToan, N'HTTT không hợp lệ' AS VanDe
FROM dbo.HoaDonBan
WHERE HinhThucThanhToan NOT IN (N'Tiền mặt', N'Chuyển khoản', N'Thẻ', N'Ví điện tử')
   OR HinhThucThanhToan IS NULL;

-- 2. TTTT không hợp lệ
PRINT N'--- 2. Hóa đơn có TTTT không hợp lệ ---';
SELECT HoaDonBanId, TrangThaiThanhToan, N'TTTT không hợp lệ' AS VanDe
FROM dbo.HoaDonBan
WHERE TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Chưa thanh toán', N'Đã hủy')
   OR TrangThaiThanhToan IS NULL;

-- 3. Tiền mặt + Đã thanh toán thiếu TienKhachDua
PRINT N'--- 3. HĐ tiền mặt thiếu tiền khách đưa ---';
SELECT HoaDonBanId, TongTien, GiamGia, ThanhToan, TienKhachDua,
       N'TienKhachDua thiếu hoặc < ThanhToan' AS VanDe
FROM dbo.HoaDonBan
WHERE HinhThucThanhToan = N'Tiền mặt'
  AND TrangThaiThanhToan = N'Đã thanh toán'
  AND (TienKhachDua IS NULL OR TienKhachDua < (TongTien - GiamGia));

-- 4. HĐ hủy thiếu lý do
PRINT N'--- 4. HĐ đã hủy thiếu lý do ---';
SELECT HoaDonBanId, N'Thiếu LyDoHuy' AS VanDe
FROM dbo.HoaDonBan
WHERE TrangThaiThanhToan = N'Đã hủy'
  AND (LyDoHuy IS NULL OR LTRIM(RTRIM(LyDoHuy)) = N'');

-- 5. HĐ hủy thiếu người hủy
PRINT N'--- 5. HĐ đã hủy thiếu người hủy ---';
SELECT HoaDonBanId, N'Thiếu NguoiHuy' AS VanDe
FROM dbo.HoaDonBan
WHERE TrangThaiThanhToan = N'Đã hủy'
  AND (NguoiHuy IS NULL OR LTRIM(RTRIM(NguoiHuy)) = N'');

-- 6. HĐ hủy thiếu ngày hủy
PRINT N'--- 6. HĐ đã hủy thiếu ngày hủy ---';
SELECT HoaDonBanId, N'Thiếu NgayHuy' AS VanDe
FROM dbo.HoaDonBan
WHERE TrangThaiThanhToan = N'Đã hủy'
  AND NgayHuy IS NULL;

-- 7. Chi tiết SoLuong <= 0
PRINT N'--- 7. Chi tiết có SoLuong <= 0 ---';
SELECT ChiTietHoaDonBanId, HoaDonBanId, MonId, SoLuong,
       N'SoLuong <= 0' AS VanDe
FROM dbo.ChiTietHoaDonBan
WHERE SoLuong <= 0;

-- 8. Chi tiết DonGiaBan <= 0
PRINT N'--- 8. Chi tiết có DonGiaBan <= 0 ---';
SELECT ChiTietHoaDonBanId, HoaDonBanId, MonId, DonGiaBan,
       N'DonGiaBan <= 0' AS VanDe
FROM dbo.ChiTietHoaDonBan
WHERE DonGiaBan <= 0;

-- 9. Món trùng nhiều dòng trong cùng HĐ
PRINT N'--- 9. Món trùng nhiều dòng trong cùng HĐ ---';
SELECT HoaDonBanId, MonId, COUNT(*) AS SoDong,
       N'Món trùng dòng' AS VanDe
FROM dbo.ChiTietHoaDonBan
GROUP BY HoaDonBanId, MonId
HAVING COUNT(*) > 1;

-- 10. Tồn kho âm
PRINT N'--- 10. Món có tồn kho âm ---';
SELECT MonId, TenMon, TonKho, N'TonKho < 0' AS VanDe
FROM dbo.Mon WHERE TonKho < 0;

-- 11. Điểm KH âm
PRINT N'--- 11. Khách hàng có điểm âm ---';
SELECT KhachHangId, HoTen, DiemTichLuy, N'DiemTichLuy < 0' AS VanDe
FROM dbo.KhachHang WHERE DiemTichLuy < 0;

-- 12. NV có nhiều ca đang mở
PRINT N'--- 12. NV có nhiều ca DangMo ---';
SELECT c.NguoiDungId, nd.HoTen, COUNT(*) AS SoCaDangMo,
       N'Nhiều ca DangMo' AS VanDe
FROM dbo.CaLamViec c
JOIN dbo.NguoiDung nd ON nd.NguoiDungId = c.NguoiDungId
WHERE c.TrangThaiCa = N'DangMo'
GROUP BY c.NguoiDungId, nd.HoTen
HAVING COUNT(*) > 1;

-- 13. Bàn sai trạng thái
PRINT N'--- 13. Bàn có trạng thái không hợp lệ ---';
SELECT BanId, TenBan, TrangThaiBan, N'TrangThaiBan sai' AS VanDe
FROM dbo.Ban
WHERE TrangThaiBan NOT IN (N'Trong', N'DangPhucVu', N'ChoThanhToan', N'TamKhoa');

-- 14. HĐ có tổng tiền âm
PRINT N'--- 14. HĐ có tổng tiền âm ---';
SELECT HoaDonBanId, TongTien, N'TongTien < 0' AS VanDe
FROM dbo.HoaDonBan WHERE TongTien < 0;

-- 15. HĐ có giảm giá > tổng tiền
PRINT N'--- 15. HĐ có giảm giá > tổng tiền ---';
SELECT HoaDonBanId, TongTien, GiamGia, N'GiamGia > TongTien' AS VanDe
FROM dbo.HoaDonBan WHERE GiamGia > TongTien;

PRINT N'';
PRINT N'============================================';
PRINT N'  HOÀN THÀNH KIỂM TRA (15 query)';
PRINT N'  Query rỗng = dữ liệu OK.';
PRINT N'============================================';
GO
