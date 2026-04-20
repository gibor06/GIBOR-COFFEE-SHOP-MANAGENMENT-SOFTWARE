namespace CoffeeShop.Wpf.Models;

public sealed class Mon
{
    public int MonId { get; set; }

    public string TenMon { get; set; } = string.Empty;

    public int DanhMucId { get; set; }

    public string? TenDanhMuc { get; set; }

    public decimal DonGia { get; set; }

    public int TonKho { get; set; }

    public string? HinhAnhPath { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; }
}
