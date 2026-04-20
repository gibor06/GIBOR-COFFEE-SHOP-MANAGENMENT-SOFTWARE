namespace CoffeeShop.Wpf.Models;

public sealed class ThongKeTongHopModel
{
    public IReadOnlyList<ThongKeDoanhThu> DoanhThuTheoNgay { get; init; } = [];

    public IReadOnlyList<HoaDonBanTimKiemDong> DanhSachHoaDon { get; init; } = [];

    public IReadOnlyList<ThongKeTopSanPhamDong> TopSanPhamBanChay { get; init; } = [];

    public int TongSoHoaDon { get; init; }

    public decimal TongDoanhThuGop { get; init; }

    public decimal TongGiamGia { get; init; }

    public decimal TongDoanhThuThuan { get; init; }
}
