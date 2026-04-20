namespace CoffeeShop.Wpf.Models;

public sealed class KhuyenMai
{
    public int KhuyenMaiId { get; set; }

    public string TenKhuyenMai { get; set; } = string.Empty;

    public string LoaiKhuyenMai { get; set; } = string.Empty;

    public decimal GiaTri { get; set; }

    public DateTime TuNgay { get; set; }

    public DateTime DenNgay { get; set; }

    public bool IsActive { get; set; }

    public int? MonId { get; set; }

    public string? MoTa { get; set; }

    public DateTime CreatedAt { get; set; }

    public bool DangHieuLuc => IsActive && DateTime.Now >= TuNgay && DateTime.Now <= DenNgay;

    public string LoaiKhuyenMaiHienThi
    {
        get
        {
            return LoaiKhuyenMai switch
            {
                "PhanTramHoaDon" => "Phần trăm hóa đơn",
                "SoTienCoDinh" => "Số tiền cố định",
                "TheoSanPham" => "Theo sản phẩm",
                _ => LoaiKhuyenMai
            };
        }
    }
}

