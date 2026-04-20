namespace CoffeeShop.Wpf.Models;

public sealed class HoaDonBanInChiTietDong
{
    public int MonId { get; set; }

    public string TenMon { get; set; } = string.Empty;

    public int SoLuong { get; set; }

    public decimal DonGiaBan { get; set; }

    public decimal ThanhTien { get; set; }
}

