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
}

