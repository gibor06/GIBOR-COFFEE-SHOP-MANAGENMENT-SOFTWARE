using CoffeeShop.Wpf.Models;
using CoffeeShop.Wpf.Repositories;

namespace CoffeeShop.Wpf.Services;

public sealed class LichSuHoaDonService : ILichSuHoaDonService
{
    private readonly ILichSuHoaDonRepository _lichSuHoaDonRepository;

    public LichSuHoaDonService(ILichSuHoaDonRepository lichSuHoaDonRepository)
    {
        _lichSuHoaDonRepository = lichSuHoaDonRepository;
    }

    public async Task<ServiceResult<IReadOnlyList<LichSuHoaDonDong>>> GetDanhSachHoaDonAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default)
    {
        if (fromDate.Date > toDate.Date)
        {
            return ServiceResult<IReadOnlyList<LichSuHoaDonDong>>.Fail("Ngày bắt đầu không được lớn hơn ngày kết thúc.");
        }

        var data = await _lichSuHoaDonRepository.GetDanhSachHoaDonAsync(fromDate, toDate, cancellationToken);
        return ServiceResult<IReadOnlyList<LichSuHoaDonDong>>.Success(data, "Tải danh sách hóa đơn thành công.");
    }

    public async Task<ServiceResult<IReadOnlyList<LichSuHoaDonDong>>> TimKiemHoaDonAsync(
        DateTime fromDate,
        DateTime toDate,
        int? hoaDonBanId,
        int? createdByUserId,
        int? banId,
        int? caLamViecId,
        string? tenKhachHang = null,
        string? soDienThoai = null,
        string? hinhThucThanhToan = null,
        string? trangThaiThanhToan = null,
        CancellationToken cancellationToken = default)
    {
        if (fromDate.Date > toDate.Date)
        {
            return ServiceResult<IReadOnlyList<LichSuHoaDonDong>>.Fail("Ngày bắt đầu không được lớn hơn ngày kết thúc.");
        }

        var data = await _lichSuHoaDonRepository.TimKiemHoaDonAsync(
            fromDate,
            toDate,
            hoaDonBanId,
            createdByUserId,
            banId,
            caLamViecId,
            tenKhachHang,
            soDienThoai,
            hinhThucThanhToan,
            trangThaiThanhToan,
            cancellationToken);

        return ServiceResult<IReadOnlyList<LichSuHoaDonDong>>.Success(data, "Tìm kiếm hóa đơn thành công.");
    }

    public async Task<ServiceResult<IReadOnlyList<LichSuHoaDonChiTietDong>>> GetChiTietHoaDonAsync(
        int hoaDonBanId,
        CancellationToken cancellationToken = default)
    {
        if (hoaDonBanId <= 0)
        {
            return ServiceResult<IReadOnlyList<LichSuHoaDonChiTietDong>>.Fail("Mã hóa đơn không hợp lệ.");
        }

        var data = await _lichSuHoaDonRepository.GetChiTietHoaDonAsync(hoaDonBanId, cancellationToken);
        return ServiceResult<IReadOnlyList<LichSuHoaDonChiTietDong>>.Success(data, "Tải chi tiết hóa đơn thành công.");
    }

    /// <summary>
    /// Hủy hóa đơn: validate rồi gọi repository cập nhật trạng thái.
    /// Không xóa dữ liệu.
    /// </summary>
    public async Task<ServiceResult> HuyHoaDonAsync(
        int hoaDonBanId,
        string lyDoHuy,
        string? nguoiHuy,
        CancellationToken cancellationToken = default)
    {
        if (hoaDonBanId <= 0)
        {
            return ServiceResult.Fail("Mã hóa đơn không hợp lệ.");
        }

        if (string.IsNullOrWhiteSpace(lyDoHuy))
        {
            return ServiceResult.Fail("Vui lòng nhập lý do hủy hóa đơn.");
        }

        var success = await _lichSuHoaDonRepository.HuyHoaDonAsync(hoaDonBanId, lyDoHuy, nguoiHuy, cancellationToken);
        if (!success)
        {
            return ServiceResult.Fail("Không thể hủy hóa đơn. Hóa đơn có thể đã bị hủy trước đó.");
        }

        return ServiceResult.Success("Hủy hóa đơn thành công.");
    }
}

