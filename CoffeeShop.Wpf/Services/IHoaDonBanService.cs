using CoffeeShop.Wpf.Models;

namespace CoffeeShop.Wpf.Services;

public interface IHoaDonBanService
{
    Task<ServiceResult<HoaDonBan>> CreateAsync(
        int createdByUserId,
        decimal giamGia,
        int? banId,
        int? caLamViecId,
        IReadOnlyList<HoaDonBanChiTietInputModel> chiTietInputs,
        int? khachHangId = null,
        int? khuyenMaiId = null,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<HoaDonBan>> GetByDateRangeAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default);
}

