namespace CoffeeShop.Wpf.Models;

public sealed class ChiTietHoaDonBan
{
    public int ChiTietHoaDonBanId { get; set; }

    public int HoaDonBanId { get; set; }

    public int MonId { get; set; }

    public decimal DonGiaBan { get; set; }

    public int SoLuong { get; set; }

    public decimal ThanhTien => DonGiaBan * SoLuong;
}
