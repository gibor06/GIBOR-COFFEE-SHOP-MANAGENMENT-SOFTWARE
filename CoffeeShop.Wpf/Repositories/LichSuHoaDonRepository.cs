using CoffeeShop.Wpf.Infrastructure;
using CoffeeShop.Wpf.Models;
using Microsoft.Data.SqlClient;

namespace CoffeeShop.Wpf.Repositories;

public sealed class LichSuHoaDonRepository : ILichSuHoaDonRepository
{
    public Task<IReadOnlyList<LichSuHoaDonDong>> GetDanhSachHoaDonAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default)
    {
        return TimKiemHoaDonAsync(fromDate, toDate, null, null, null, null, cancellationToken);
    }

    public async Task<IReadOnlyList<LichSuHoaDonDong>> TimKiemHoaDonAsync(
        DateTime fromDate,
        DateTime toDate,
        int? hoaDonBanId,
        int? createdByUserId,
        int? banId,
        int? caLamViecId,
        CancellationToken cancellationToken = default)
    {
        const string sql = @"
SELECT hb.HoaDonBanId,
       hb.NgayBan,
       hb.TongTien,
       hb.GiamGia,
       hb.CreatedByUserId,
       nd.HoTen AS TenNhanVien,
       hb.BanId,
       b.TenBan,
       kv.TenKhuVuc,
       hb.CaLamViecId
FROM dbo.HoaDonBan hb
LEFT JOIN dbo.NguoiDung nd ON nd.NguoiDungId = hb.CreatedByUserId
LEFT JOIN dbo.Ban b ON b.BanId = hb.BanId
LEFT JOIN dbo.KhuVuc kv ON kv.KhuVucId = b.KhuVucId
WHERE hb.NgayBan >= @FromDate
  AND hb.NgayBan < @ToDateExclusive
  AND (@HoaDonBanId IS NULL OR hb.HoaDonBanId = @HoaDonBanId)
  AND (@CreatedByUserId IS NULL OR hb.CreatedByUserId = @CreatedByUserId)
  AND (@BanId IS NULL OR hb.BanId = @BanId)
  AND (@CaLamViecId IS NULL OR hb.CaLamViecId = @CaLamViecId)
ORDER BY hb.NgayBan DESC;";

        var result = new List<LichSuHoaDonDong>();

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@FromDate", fromDate.Date);
        command.Parameters.AddWithValue("@ToDateExclusive", toDate.Date.AddDays(1));
        command.Parameters.AddWithValue("@HoaDonBanId", (object?)hoaDonBanId ?? DBNull.Value);
        command.Parameters.AddWithValue("@CreatedByUserId", (object?)createdByUserId ?? DBNull.Value);
        command.Parameters.AddWithValue("@BanId", (object?)banId ?? DBNull.Value);
        command.Parameters.AddWithValue("@CaLamViecId", (object?)caLamViecId ?? DBNull.Value);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new LichSuHoaDonDong
            {
                HoaDonBanId = reader.GetInt32(reader.GetOrdinal("HoaDonBanId")),
                NgayBan = reader.GetDateTime(reader.GetOrdinal("NgayBan")),
                TongTien = reader.GetDecimal(reader.GetOrdinal("TongTien")),
                GiamGia = reader.GetDecimal(reader.GetOrdinal("GiamGia")),
                CreatedByUserId = reader.GetInt32(reader.GetOrdinal("CreatedByUserId")),
                TenNhanVien = reader.IsDBNull(reader.GetOrdinal("TenNhanVien"))
                    ? string.Empty
                    : reader.GetString(reader.GetOrdinal("TenNhanVien")),
                BanId = reader.IsDBNull(reader.GetOrdinal("BanId"))
                    ? null
                    : reader.GetInt32(reader.GetOrdinal("BanId")),
                TenBan = reader.IsDBNull(reader.GetOrdinal("TenBan"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("TenBan")),
                TenKhuVuc = reader.IsDBNull(reader.GetOrdinal("TenKhuVuc"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("TenKhuVuc")),
                CaLamViecId = reader.IsDBNull(reader.GetOrdinal("CaLamViecId"))
                    ? null
                    : reader.GetInt32(reader.GetOrdinal("CaLamViecId"))
            });
        }

        return result;
    }

    public async Task<IReadOnlyList<LichSuHoaDonChiTietDong>> GetChiTietHoaDonAsync(
        int hoaDonBanId,
        CancellationToken cancellationToken = default)
    {
        const string sql = @"
SELECT ct.MonId,
       m.TenMon,
       ct.SoLuong,
       ct.DonGiaBan,
       ct.ThanhTien
FROM dbo.ChiTietHoaDonBan ct
JOIN dbo.Mon m ON m.MonId = ct.MonId
WHERE ct.HoaDonBanId = @HoaDonBanId
ORDER BY ct.ChiTietHoaDonBanId;";

        var result = new List<LichSuHoaDonChiTietDong>();

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@HoaDonBanId", hoaDonBanId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new LichSuHoaDonChiTietDong
            {
                MonId = reader.GetInt32(reader.GetOrdinal("MonId")),
                TenMon = reader.GetString(reader.GetOrdinal("TenMon")),
                SoLuong = reader.GetInt32(reader.GetOrdinal("SoLuong")),
                DonGiaBan = reader.GetDecimal(reader.GetOrdinal("DonGiaBan")),
                ThanhTien = reader.GetDecimal(reader.GetOrdinal("ThanhTien"))
            });
        }

        return result;
    }
}

