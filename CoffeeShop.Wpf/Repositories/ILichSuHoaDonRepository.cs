using CoffeeShop.Wpf.Models;

namespace CoffeeShop.Wpf.Repositories;

public interface ILichSuHoaDonRepository
{
    Task<IReadOnlyList<LichSuHoaDonDong>> GetDanhSachHoaDonAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<LichSuHoaDonDong>> TimKiemHoaDonAsync(
        DateTime fromDate,
        DateTime toDate,
        int? hoaDonBanId,
        int? createdByUserId,
        int? banId,
        int? caLamViecId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<LichSuHoaDonChiTietDong>> GetChiTietHoaDonAsync(
        int hoaDonBanId,
        CancellationToken cancellationToken = default);
}

