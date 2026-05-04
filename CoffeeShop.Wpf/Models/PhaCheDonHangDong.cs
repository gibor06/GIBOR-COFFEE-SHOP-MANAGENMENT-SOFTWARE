namespace CoffeeShop.Wpf.Models;

public sealed class PhaCheDonHangDong
{
    public int HoaDonBanId { get; set; }

    public string MaHoaDonHienThi => $"HD{HoaDonBanId:D5}";

    public int? SoThuTuGoiMon { get; set; }

    public string SoGoiMonHienThi => SoThuTuGoiMon.HasValue
        ? SoThuTuGoiMon.Value.ToString("D3")
        : HoaDonBanId.ToString("D3");

    public DateTime NgayBan { get; set; }

    public string TenNhanVien { get; set; } = string.Empty;

    public string TenKhachHang { get; set; } = "Khách lẻ";

    public string? TenBan { get; set; }

    public string? TenKhuVuc { get; set; }

    public string ViTriHienThi =>
        $"{(string.IsNullOrWhiteSpace(TenBan) ? "N/A" : TenBan)} / {(string.IsNullOrWhiteSpace(TenKhuVuc) ? "N/A" : TenKhuVuc)}";

    public decimal ThanhToan { get; set; }

    public string TrangThaiPhaChe { get; set; } = TrangThaiPhaCheConst.ChoPhaChe;

    public string TrangThaiPhaCheHienThi => TrangThaiPhaCheConst.ToDisplayName(TrangThaiPhaChe);

    public string DanhSachMonTomTat { get; set; } = string.Empty;

    public DateTime? ThoiGianBatDauPhaChe { get; set; }

    public DateTime? ThoiGianHoanThanhPhaChe { get; set; }

    public DateTime? ThoiGianGiaoKhach { get; set; }
}
