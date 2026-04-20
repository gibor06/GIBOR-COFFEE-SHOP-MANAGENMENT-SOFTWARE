namespace CoffeeShop.Wpf.Models;

public static class HinhThucThanhToanConst
{
    public const string TienMat = "Ti?n m?t";
    public const string ChuyenKhoan = "Chuy?n kho?n";
    public const string The = "Th?";
    public const string ViDienTu = "Ví ?i?n t?";

    public static IReadOnlyList<string> TatCa { get; } =
    [
        TienMat,
        ChuyenKhoan,
        The,
        ViDienTu
    ];

    public static bool TryNormalize(string? value, out string normalized)
    {
        normalized = string.Empty;
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        var trimmed = value.Trim();

        if (string.Equals(trimmed, TienMat, StringComparison.OrdinalIgnoreCase))
        {
            normalized = TienMat;
            return true;
        }

        if (string.Equals(trimmed, ChuyenKhoan, StringComparison.OrdinalIgnoreCase))
        {
            normalized = ChuyenKhoan;
            return true;
        }

        if (string.Equals(trimmed, The, StringComparison.OrdinalIgnoreCase))
        {
            normalized = The;
            return true;
        }

        if (string.Equals(trimmed, ViDienTu, StringComparison.OrdinalIgnoreCase))
        {
            normalized = ViDienTu;
            return true;
        }

        return false;
    }
}
