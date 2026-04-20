namespace CoffeeShop.Wpf.Models;

public sealed class LichSuHoaDonDong
{
    public int HoaDonBanId { get; set; }

    public DateTime NgayBan { get; set; }

    public decimal TongTien { get; set; }

    public decimal GiamGia { get; set; }

    public decimal ThanhToan => TongTien - GiamGia;

    public int CreatedByUserId { get; set; }

    public string TenNhanVien { get; set; } = string.Empty;

    public int? BanId { get; set; }

    public string? TenBan { get; set; }

    public string? TenKhuVuc { get; set; }

    public int? CaLamViecId { get; set; }
}

