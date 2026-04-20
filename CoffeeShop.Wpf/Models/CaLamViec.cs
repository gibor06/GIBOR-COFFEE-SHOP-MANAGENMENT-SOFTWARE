namespace CoffeeShop.Wpf.Models;

public sealed class CaLamViec
{
    public int CaLamViecId { get; set; }

    public int NguoiDungId { get; set; }

    public string TenNhanVien { get; set; } = string.Empty;

    public DateTime ThoiGianMoCa { get; set; }

    public DateTime? ThoiGianDongCa { get; set; }

    public string TrangThaiCa { get; set; } = string.Empty;

    public string? GhiChu { get; set; }

    public int SoHoaDon { get; set; }

    public decimal TongDoanhThu { get; set; }

    public string TrangThaiCaHienThi => TrangThaiCa switch
    {
        "DangMo" => "Đang mở",
        "DaDong" => "Đã đóng",
        _ => TrangThaiCa
    };
}
