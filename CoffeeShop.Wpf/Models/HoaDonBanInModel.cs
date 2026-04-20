namespace CoffeeShop.Wpf.Models;

public sealed class HoaDonBanInModel
{
    public int HoaDonBanId { get; set; }

    public DateTime NgayBan { get; set; }

    public string TenNhanVien { get; set; } = string.Empty;

    public string? TenBan { get; set; }

    public string? TenKhuVuc { get; set; }

    public decimal TongTien { get; set; }

    public decimal GiamGia { get; set; }

    public decimal ThanhToan { get; set; }

    public int? CaLamViecId { get; set; }

    public IReadOnlyList<HoaDonBanInChiTietDong> ChiTiet { get; set; } = [];
}

