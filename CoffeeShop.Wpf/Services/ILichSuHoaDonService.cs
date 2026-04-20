using CoffeeShop.Wpf.Models;

namespace CoffeeShop.Wpf.Services;

public interface ILichSuHoaDonService
{
    Task<ServiceResult<IReadOnlyList<LichSuHoaDonDong>>> GetDanhSachHoaDonAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default);

    Task<ServiceResult<IReadOnlyList<LichSuHoaDonDong>>> TimKiemHoaDonAsync(
        DateTime fromDate,
        DateTime toDate,
        int? hoaDonBanId,
        int? createdByUserId,
        int? banId,
        int? caLamViecId,
        CancellationToken cancellationToken = default);

    Task<ServiceResult<IReadOnlyList<LichSuHoaDonChiTietDong>>> GetChiTietHoaDonAsync(
        int hoaDonBanId,
        CancellationToken cancellationToken = default);
}

