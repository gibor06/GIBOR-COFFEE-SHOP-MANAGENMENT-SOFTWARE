using CoffeeShop.Wpf.Models;
using CoffeeShop.Wpf.Repositories;
using CoffeeShop.Wpf.Helpers;

namespace CoffeeShop.Wpf.Services;

public sealed class HoaDonBanService : IHoaDonBanService
{
    private readonly IHoaDonBanRepository _hoaDonBanRepository;
    private readonly IMonService _monService;
    private readonly IBanRepository _banRepository;
    private readonly ICaLamViecRepository _caLamViecRepository;
    private readonly IAuditLogService _auditLogService;
    private readonly IKhuyenMaiService _khuyenMaiService;
    private readonly IKhachHangService _khachHangService;

    public HoaDonBanService(
        IHoaDonBanRepository hoaDonBanRepository,
        IMonService monService,
        IBanRepository banRepository,
        ICaLamViecRepository caLamViecRepository,
        IAuditLogService auditLogService,
        IKhuyenMaiService khuyenMaiService,
        IKhachHangService khachHangService)
    {
        _hoaDonBanRepository = hoaDonBanRepository;
        _monService = monService;
        _banRepository = banRepository;
        _caLamViecRepository = caLamViecRepository;
        _auditLogService = auditLogService;
        _khuyenMaiService = khuyenMaiService;
        _khachHangService = khachHangService;
    }

    public async Task<ServiceResult<HoaDonBan>> CreateAsync(
        int createdByUserId,
        decimal giamGia,
        int? banId,
        int? caLamViecId,
        IReadOnlyList<HoaDonBanChiTietInputModel> chiTietInputs,
        int? khachHangId = null,
        int? khuyenMaiId = null,
        string hinhThucThanhToan = HinhThucThanhToanConst.TienMat,
        decimal? tienKhachDua = null,
        string? maGiaoDich = null,
        string? ghiChuThanhToan = null,
        string? ghiChuHoaDon = null,
        CancellationToken cancellationToken = default)
    {
        if (createdByUserId <= 0)
        {
            return ServiceResult<HoaDonBan>.Fail("Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.");
        }

        if (giamGia < 0)
        {
            return ServiceResult<HoaDonBan>.Fail("Giảm giá không được âm.");
        }

        if (!banId.HasValue || banId <= 0)
        {
            return ServiceResult<HoaDonBan>.Fail("Vui lòng chọn bàn phục vụ.");
        }

        if (!caLamViecId.HasValue || caLamViecId <= 0)
        {
            return ServiceResult<HoaDonBan>.Fail("Vui lòng mở ca làm việc trước khi tạo hóa đơn.");
        }

        var ban = await _banRepository.GetByIdAsync(banId.Value, cancellationToken);
        if (ban is null || !ban.IsActive)
        {
            return ServiceResult<HoaDonBan>.Fail("Bàn đã chọn không tồn tại hoặc đã ngừng hoạt động.");
        }

        if (string.Equals(ban.TrangThaiBan, TrangThaiBanConst.TamKhoa, StringComparison.OrdinalIgnoreCase))
        {
            return ServiceResult<HoaDonBan>.Fail("Bàn đang ở trạng thái tạm khóa.");
        }

        if (!string.Equals(ban.TrangThaiBan, TrangThaiBanConst.Trong, StringComparison.OrdinalIgnoreCase))
        {
            return ServiceResult<HoaDonBan>.Fail("Bàn đang phục vụ hoặc chờ thanh toán, không thể tạo hóa đơn mới.");
        }

        var caDangMo = await _caLamViecRepository.GetCaDangMoAsync(createdByUserId, cancellationToken);
        if (caDangMo is null || caDangMo.CaLamViecId != caLamViecId.Value)
        {
            return ServiceResult<HoaDonBan>.Fail("Không tìm thấy ca làm việc đang mở hợp lệ.");
        }

        if (chiTietInputs is null || chiTietInputs.Count == 0)
        {
            return ServiceResult<HoaDonBan>.Fail("Hóa đơn bán phải có ít nhất 1 dòng chi tiết.");
        }

        var duplicatedMonId = chiTietInputs
            .GroupBy(x => x.MonId)
            .Where(g => g.Count() > 1)
            .Select(g => g.Key)
            .FirstOrDefault();

        if (duplicatedMonId > 0)
        {
            return ServiceResult<HoaDonBan>.Fail("Mỗi sản phẩm chỉ được xuất hiện 1 lần trong chi tiết hóa đơn bán.");
        }

        var monData = await _monService.SearchAsync(null, null, cancellationToken);
        var monMap = monData.ToDictionary(x => x.MonId, x => x);

        foreach (var line in chiTietInputs)
        {
            if (line.MonId <= 0 || !monMap.TryGetValue(line.MonId, out var mon))
            {
                return ServiceResult<HoaDonBan>.Fail("Có sản phẩm không tồn tại trong chi tiết hóa đơn bán.");
            }

            if (line.SoLuong <= 0)
            {
                return ServiceResult<HoaDonBan>.Fail("Số lượng bán phải lớn hơn 0.");
            }

            if (line.DonGiaBan <= 0)
            {
                return ServiceResult<HoaDonBan>.Fail("Đơn giá bán phải lớn hơn 0.");
            }

            if (line.SoLuong > mon.TonKho)
            {
                return ServiceResult<HoaDonBan>.Fail($"Sản phẩm '{mon.TenMon}' không đủ tồn kho.");
            }
        }

        var tongTien = chiTietInputs.Sum(x => x.ThanhTien);
        if (tongTien <= 0)
        {
            return ServiceResult<HoaDonBan>.Fail("Tổng tiền hóa đơn bán không hợp lệ.");
        }

        if (giamGia > tongTien)
        {
            return ServiceResult<HoaDonBan>.Fail("Giảm giá không được lớn hơn tổng tiền.");
        }

        // === Validate + chuẩn hóa hình thức thanh toán ===
        var hinhThucThanhToanDaChuanHoa = TextNormalizationHelper.Normalize(hinhThucThanhToan)?.Trim();
        if (string.IsNullOrWhiteSpace(hinhThucThanhToanDaChuanHoa))
        {
            return ServiceResult<HoaDonBan>.Fail("Vui lòng chọn hình thức thanh toán.");
        }

        if (!HinhThucThanhToanConst.TryNormalize(hinhThucThanhToanDaChuanHoa, out var hinhThucThanhToanHopLe))
        {
            return ServiceResult<HoaDonBan>.Fail($"Hình thức thanh toán '{hinhThucThanhToanDaChuanHoa}' không hợp lệ.");
        }

        if (khachHangId.HasValue && khachHangId.Value > 0)
        {
            var khachHang = await _khachHangService.GetByIdAsync(khachHangId.Value, cancellationToken);
            if (!khachHang.IsSuccess || khachHang.Data is null || !khachHang.Data.IsActive)
            {
                return ServiceResult<HoaDonBan>.Fail("Khách hàng đã chọn không hợp lệ hoặc đã ngừng hoạt động.");
            }
        }

        var apDungKhuyenMai = await _khuyenMaiService.ApDungKhuyenMaiAsync(
            khuyenMaiId,
            tongTien,
            DateTime.Now,
            cancellationToken);

        if (!apDungKhuyenMai.IsSuccess || apDungKhuyenMai.Data is null)
        {
            return ServiceResult<HoaDonBan>.Fail(apDungKhuyenMai.Message);
        }

        var soTienGiamKhuyenMai = apDungKhuyenMai.Data.SoTienGiam;
        var tongGiamGia = giamGia + soTienGiamKhuyenMai;
        if (tongGiamGia > tongTien)
        {
            return ServiceResult<HoaDonBan>.Fail("Tổng giảm giá vượt quá tổng tiền hóa đơn.");
        }

        var thanhToanSauGiam = tongTien - tongGiamGia;

        // === Validate tiền khách đưa cho tiền mặt ===
        decimal? tienThoiLai = null;
        if (string.Equals(hinhThucThanhToanHopLe, HinhThucThanhToanConst.TienMat, StringComparison.OrdinalIgnoreCase))
        {
            if (!tienKhachDua.HasValue || tienKhachDua.Value < thanhToanSauGiam)
            {
                return ServiceResult<HoaDonBan>.Fail(
                    $"Tiền khách đưa ({tienKhachDua?.ToString("N0") ?? "0"}) không đủ. Cần ít nhất {thanhToanSauGiam:N0} đ.");
            }
            tienThoiLai = tienKhachDua.Value - thanhToanSauGiam;
        }

        var diemCong = (khachHangId.HasValue && khachHangId.Value > 0)
            ? TinhDiemTichLuy(thanhToanSauGiam)
            : 0;

        var hoaDonBan = new HoaDonBan
        {
            NgayBan = DateTime.Now,
            TongTien = tongTien,
            GiamGia = tongGiamGia,
            CreatedByUserId = createdByUserId,
            BanId = banId,
            CaLamViecId = caLamViecId,
            KhachHangId = khachHangId > 0 ? khachHangId : null,
            KhuyenMaiId = apDungKhuyenMai.Data.KhuyenMaiId,
            SoTienGiam = soTienGiamKhuyenMai,
            DiemCong = diemCong,
            // Thanh toán nâng cao
            HinhThucThanhToan = hinhThucThanhToanHopLe,
            TrangThaiThanhToan = "Đã thanh toán",
            TienKhachDua = tienKhachDua,
            TienThoiLai = tienThoiLai,
            MaGiaoDich = maGiaoDich,
            GhiChuThanhToan = ghiChuThanhToan,
            GhiChuHoaDon = ghiChuHoaDon
        };

        var chiTietHoaDonBans = chiTietInputs
            .Select(x => new ChiTietHoaDonBan
            {
                MonId = x.MonId,
                SoLuong = x.SoLuong,
                DonGiaBan = x.DonGiaBan
            })
            .ToList();

        try
        {
            var newId = await _hoaDonBanRepository.CreateAsync(hoaDonBan, chiTietHoaDonBans, cancellationToken);
            hoaDonBan.HoaDonBanId = newId;

            _ = await _banRepository.CapNhatTrangThaiBanAsync(banId.Value, TrangThaiBanConst.Trong, cancellationToken);
            _ = TryWriteAuditAsync(
                createdByUserId,
                "Tạo hóa đơn bán",
                "HoaDonBan",
                $"Hóa đơn bán #{newId}, bàn: {banId}, ca: {caLamViecId}, tổng tiền: {tongTien:N0}, giảm KM: {soTienGiamKhuyenMai:N0}, khách hàng: {(khachHangId?.ToString() ?? "N/A")}",
                cancellationToken);
            return ServiceResult<HoaDonBan>.Success(hoaDonBan, "Lưu hóa đơn bán thành công.");
        }
        catch (InvalidOperationException ex)
        {
            return ServiceResult<HoaDonBan>.Fail(ex.Message);
        }
    }

    public Task<IReadOnlyList<HoaDonBan>> GetByDateRangeAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default)
    {
        return _hoaDonBanRepository.GetByDateRangeAsync(fromDate, toDate, cancellationToken);
    }

    private async Task TryWriteAuditAsync(
        int nguoiDungId,
        string hanhDong,
        string doiTuong,
        string duLieuTomTat,
        CancellationToken cancellationToken)
    {
        try
        {
            await _auditLogService.GhiLogAsync(
                nguoiDungId,
                hanhDong,
                doiTuong,
                duLieuTomTat,
                Environment.MachineName,
                cancellationToken);
        }
        catch
        {
            // Không chặn luồng tạo hóa đơn bán khi ghi log lỗi.
        }
    }

    private static int TinhDiemTichLuy(decimal thanhToan)
    {
        if (thanhToan <= 0)
        {
            return 0;
        }

        return (int)Math.Floor(thanhToan / 10000m);
    }
}

