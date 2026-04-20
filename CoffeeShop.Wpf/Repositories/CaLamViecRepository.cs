using CoffeeShop.Wpf.Infrastructure;
using CoffeeShop.Wpf.Models;
using Microsoft.Data.SqlClient;

namespace CoffeeShop.Wpf.Repositories;

public sealed class CaLamViecRepository : ICaLamViecRepository
{
    public async Task<CaLamViec?> GetCaDangMoAsync(int nguoiDungId, CancellationToken cancellationToken = default)
    {
        const string sql = @"
        SELECT TOP (1)
               c.CaLamViecId,
               c.NguoiDungId,
               nd.HoTen AS TenNhanVien,
               c.ThoiGianMoCa,
               c.ThoiGianDongCa,
               c.TrangThaiCa,
               c.GhiChu,
               COUNT(hb.HoaDonBanId) AS SoHoaDon,
               ISNULL(SUM(hb.ThanhToan), 0) AS TongDoanhThu
        FROM dbo.CaLamViec c
        JOIN dbo.NguoiDung nd ON nd.NguoiDungId = c.NguoiDungId
        LEFT JOIN dbo.HoaDonBan hb ON hb.CaLamViecId = c.CaLamViecId
        WHERE c.NguoiDungId = @NguoiDungId
          AND c.TrangThaiCa = N'DangMo'
        GROUP BY c.CaLamViecId, c.NguoiDungId, nd.HoTen, c.ThoiGianMoCa, c.ThoiGianDongCa, c.TrangThaiCa, c.GhiChu
        ORDER BY c.ThoiGianMoCa DESC;";

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@NguoiDungId", nguoiDungId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapCaLamViec(reader);
    }

    public async Task<int> MoCaAsync(int nguoiDungId, string? ghiChu, CancellationToken cancellationToken = default)
    {
        const string sql = @"
        INSERT INTO dbo.CaLamViec (NguoiDungId, ThoiGianMoCa, TrangThaiCa, GhiChu)
        VALUES (@NguoiDungId, SYSDATETIME(), N'DangMo', @GhiChu);
        SELECT CAST(SCOPE_IDENTITY() AS INT);";

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@NguoiDungId", nguoiDungId);
        command.Parameters.AddWithValue("@GhiChu", string.IsNullOrWhiteSpace(ghiChu) ? DBNull.Value : ghiChu.Trim());

        var scalar = await command.ExecuteScalarAsync(cancellationToken);
        return Convert.ToInt32(scalar);
    }

    public async Task<bool> DongCaAsync(int caLamViecId, string? ghiChu, CancellationToken cancellationToken = default)
    {
        const string sql = @"
        UPDATE dbo.CaLamViec
        SET ThoiGianDongCa = SYSDATETIME(),
            TrangThaiCa = N'DaDong',
            GhiChu = CASE
                         WHEN @GhiChu IS NULL OR LTRIM(RTRIM(@GhiChu)) = N'' THEN GhiChu
                         ELSE @GhiChu
                     END
        WHERE CaLamViecId = @CaLamViecId
          AND TrangThaiCa = N'DangMo';";

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@CaLamViecId", caLamViecId);
        command.Parameters.AddWithValue("@GhiChu", string.IsNullOrWhiteSpace(ghiChu) ? DBNull.Value : ghiChu.Trim());

        return await command.ExecuteNonQueryAsync(cancellationToken) > 0;
    }

    public async Task<IReadOnlyList<CaLamViec>> GetLichSuCaAsync(
        DateTime fromDate,
        DateTime toDate,
        int? nguoiDungId,
        CancellationToken cancellationToken = default)
    {
        const string sql = @"
        SELECT c.CaLamViecId,
               c.NguoiDungId,
               nd.HoTen AS TenNhanVien,
               c.ThoiGianMoCa,
               c.ThoiGianDongCa,
               c.TrangThaiCa,
               c.GhiChu,
               COUNT(hb.HoaDonBanId) AS SoHoaDon,
               ISNULL(SUM(hb.ThanhToan), 0) AS TongDoanhThu
        FROM dbo.CaLamViec c
        JOIN dbo.NguoiDung nd ON nd.NguoiDungId = c.NguoiDungId
        LEFT JOIN dbo.HoaDonBan hb ON hb.CaLamViecId = c.CaLamViecId
        WHERE c.ThoiGianMoCa >= @FromDate
          AND c.ThoiGianMoCa < @ToDateExclusive
          AND (@NguoiDungId IS NULL OR c.NguoiDungId = @NguoiDungId)
        GROUP BY c.CaLamViecId, c.NguoiDungId, nd.HoTen, c.ThoiGianMoCa, c.ThoiGianDongCa, c.TrangThaiCa, c.GhiChu
        ORDER BY c.ThoiGianMoCa DESC;";

        var result = new List<CaLamViec>();

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@FromDate", fromDate.Date);
        command.Parameters.AddWithValue("@ToDateExclusive", toDate.Date.AddDays(1));
        command.Parameters.AddWithValue("@NguoiDungId", (object?)nguoiDungId ?? DBNull.Value);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(MapCaLamViec(reader));
        }

        return result;
    }

    public async Task<CaTongKetModel?> GetTongKetCaAsync(int caLamViecId, CancellationToken cancellationToken = default)
    {
        const string sql = @"
        SELECT c.CaLamViecId,
               COUNT(hb.HoaDonBanId) AS SoHoaDon,
               ISNULL(SUM(hb.ThanhToan), 0) AS TongDoanhThu
        FROM dbo.CaLamViec c
        LEFT JOIN dbo.HoaDonBan hb ON hb.CaLamViecId = c.CaLamViecId
        WHERE c.CaLamViecId = @CaLamViecId
        GROUP BY c.CaLamViecId;";

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@CaLamViecId", caLamViecId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return new CaTongKetModel
        {
            CaLamViecId = reader.GetInt32(reader.GetOrdinal("CaLamViecId")),
            SoHoaDon = reader.GetInt32(reader.GetOrdinal("SoHoaDon")),
            TongDoanhThu = reader.GetDecimal(reader.GetOrdinal("TongDoanhThu"))
        };
    }

    private static CaLamViec MapCaLamViec(SqlDataReader reader)
    {
        return new CaLamViec
        {
            CaLamViecId = reader.GetInt32(reader.GetOrdinal("CaLamViecId")),
            NguoiDungId = reader.GetInt32(reader.GetOrdinal("NguoiDungId")),
            TenNhanVien = reader.GetString(reader.GetOrdinal("TenNhanVien")),
            ThoiGianMoCa = reader.GetDateTime(reader.GetOrdinal("ThoiGianMoCa")),
            ThoiGianDongCa = reader.IsDBNull(reader.GetOrdinal("ThoiGianDongCa"))
                ? null
                : reader.GetDateTime(reader.GetOrdinal("ThoiGianDongCa")),
            TrangThaiCa = reader.GetString(reader.GetOrdinal("TrangThaiCa")),
            GhiChu = reader.IsDBNull(reader.GetOrdinal("GhiChu")) ? null : reader.GetString(reader.GetOrdinal("GhiChu")),
            SoHoaDon = reader.GetInt32(reader.GetOrdinal("SoHoaDon")),
            TongDoanhThu = reader.GetDecimal(reader.GetOrdinal("TongDoanhThu"))
        };
    }
}

