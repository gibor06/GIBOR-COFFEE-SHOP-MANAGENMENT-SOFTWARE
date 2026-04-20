using CoffeeShop.Wpf.Models;

namespace CoffeeShop.Wpf.Repositories;

public interface IHoaDonBanRepository
{
    Task<int> CreateAsync(
        HoaDonBan hoaDonBan,
        IReadOnlyList<ChiTietHoaDonBan> chiTietHoaDonBans,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<HoaDonBan>> GetByDateRangeAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default);
}
