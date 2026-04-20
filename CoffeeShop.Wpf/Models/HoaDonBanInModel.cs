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

    // === Thông tin khách hàng ===
    public string? TenKhachHang { get; set; }
    public string? SoDienThoaiKhachHang { get; set; }

    // === Thông tin thanh toán ===
    public string HinhThucThanhToan { get; set; } = "Tiền mặt";
    public string TrangThaiThanhToan { get; set; } = "Đã thanh toán";
    public decimal? TienKhachDua { get; set; }
    public decimal? TienThoiLai { get; set; }
    public string? MaGiaoDich { get; set; }
    public string? GhiChuThanhToan { get; set; }
    public string? GhiChuHoaDon { get; set; }

    public IReadOnlyList<HoaDonBanInChiTietDong> ChiTiet { get; set; } = [];
}

