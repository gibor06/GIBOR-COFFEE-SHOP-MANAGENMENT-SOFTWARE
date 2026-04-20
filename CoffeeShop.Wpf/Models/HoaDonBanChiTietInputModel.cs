namespace CoffeeShop.Wpf.Models;

public sealed class HoaDonBanChiTietInputModel
{
    public int MonId { get; set; }

    public int SoLuong { get; set; }

    public decimal DonGiaBan { get; set; }

    public decimal ThanhTien => SoLuong * DonGiaBan;
}
