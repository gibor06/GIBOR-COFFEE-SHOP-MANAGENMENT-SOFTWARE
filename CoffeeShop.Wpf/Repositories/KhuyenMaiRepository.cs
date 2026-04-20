using CoffeeShop.Wpf.Infrastructure;
using CoffeeShop.Wpf.Models;
using Microsoft.Data.SqlClient;

namespace CoffeeShop.Wpf.Repositories;

public sealed class KhuyenMaiRepository : IKhuyenMaiRepository
{
    public async Task<IReadOnlyList<KhuyenMai>> GetDanhSachKhuyenMaiAsync(
        string? keyword,
        bool? isActive,
        CancellationToken cancellationToken = default)
    {
        const string sql = @"
SELECT KhuyenMaiId,
       TenKhuyenMai,
       LoaiKhuyenMai,
       GiaTri,
       TuNgay,
       DenNgay,
       IsActive,
       MonId,
       MoTa,
       CreatedAt
FROM dbo.KhuyenMai
WHERE (@Keyword = N'' OR TenKhuyenMai LIKE N'%' + @Keyword + N'%')
  AND (@IsActive IS NULL OR IsActive = @IsActive)
ORDER BY CreatedAt DESC, KhuyenMaiId DESC;";

        var result = new List<KhuyenMai>();

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@Keyword", (keyword ?? string.Empty).Trim());
        command.Parameters.AddWithValue("@IsActive", (object?)isActive ?? DBNull.Value);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(MapKhuyenMai(reader));
        }

        return result;
    }

    public async Task<int> TaoKhuyenMaiAsync(KhuyenMai khuyenMai, CancellationToken cancellationToken = default)
    {
        const string sql = @"
INSERT INTO dbo.KhuyenMai
(
    TenKhuyenMai,
    LoaiKhuyenMai,
    GiaTri,
    TuNgay,
    DenNgay,
    IsActive,
    MonId,
    MoTa
)
VALUES
(
    @TenKhuyenMai,
    @LoaiKhuyenMai,
    @GiaTri,
    @TuNgay,
    @DenNgay,
    @IsActive,
    @MonId,
    @MoTa
);
SELECT CAST(SCOPE_IDENTITY() AS INT);";

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@TenKhuyenMai", khuyenMai.TenKhuyenMai.Trim());
        command.Parameters.AddWithValue("@LoaiKhuyenMai", khuyenMai.LoaiKhuyenMai.Trim());
        command.Parameters.AddWithValue("@GiaTri", khuyenMai.GiaTri);
        command.Parameters.AddWithValue("@TuNgay", khuyenMai.TuNgay);
        command.Parameters.AddWithValue("@DenNgay", khuyenMai.DenNgay);
        command.Parameters.AddWithValue("@IsActive", khuyenMai.IsActive);
        command.Parameters.AddWithValue("@MonId", (object?)khuyenMai.MonId ?? DBNull.Value);
        command.Parameters.AddWithValue("@MoTa", string.IsNullOrWhiteSpace(khuyenMai.MoTa) ? DBNull.Value : khuyenMai.MoTa.Trim());

        var scalar = await command.ExecuteScalarAsync(cancellationToken);
        return Convert.ToInt32(scalar);
    }

    public async Task<bool> CapNhatKhuyenMaiAsync(KhuyenMai khuyenMai, CancellationToken cancellationToken = default)
    {
        const string sql = @"
UPDATE dbo.KhuyenMai
SET TenKhuyenMai = @TenKhuyenMai,
    LoaiKhuyenMai = @LoaiKhuyenMai,
    GiaTri = @GiaTri,
    TuNgay = @TuNgay,
    DenNgay = @DenNgay,
    IsActive = @IsActive,
    MonId = @MonId,
    MoTa = @MoTa
WHERE KhuyenMaiId = @KhuyenMaiId;";

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@KhuyenMaiId", khuyenMai.KhuyenMaiId);
        command.Parameters.AddWithValue("@TenKhuyenMai", khuyenMai.TenKhuyenMai.Trim());
        command.Parameters.AddWithValue("@LoaiKhuyenMai", khuyenMai.LoaiKhuyenMai.Trim());
        command.Parameters.AddWithValue("@GiaTri", khuyenMai.GiaTri);
        command.Parameters.AddWithValue("@TuNgay", khuyenMai.TuNgay);
        command.Parameters.AddWithValue("@DenNgay", khuyenMai.DenNgay);
        command.Parameters.AddWithValue("@IsActive", khuyenMai.IsActive);
        command.Parameters.AddWithValue("@MonId", (object?)khuyenMai.MonId ?? DBNull.Value);
        command.Parameters.AddWithValue("@MoTa", string.IsNullOrWhiteSpace(khuyenMai.MoTa) ? DBNull.Value : khuyenMai.MoTa.Trim());

        return await command.ExecuteNonQueryAsync(cancellationToken) > 0;
    }

    public async Task<IReadOnlyList<KhuyenMai>> GetKhuyenMaiHieuLucAsync(
        DateTime thoiDiem,
        CancellationToken cancellationToken = default)
    {
        const string sql = @"
SELECT KhuyenMaiId,
       TenKhuyenMai,
       LoaiKhuyenMai,
       GiaTri,
       TuNgay,
       DenNgay,
       IsActive,
       MonId,
       MoTa,
       CreatedAt
FROM dbo.KhuyenMai
WHERE IsActive = 1
  AND @ThoiDiem >= TuNgay
  AND @ThoiDiem <= DenNgay
ORDER BY CreatedAt DESC, KhuyenMaiId DESC;";

        var result = new List<KhuyenMai>();

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@ThoiDiem", thoiDiem);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(MapKhuyenMai(reader));
        }

        return result;
    }

    public async Task<KhuyenMai?> GetByIdAsync(int khuyenMaiId, CancellationToken cancellationToken = default)
    {
        const string sql = @"
SELECT KhuyenMaiId,
       TenKhuyenMai,
       LoaiKhuyenMai,
       GiaTri,
       TuNgay,
       DenNgay,
       IsActive,
       MonId,
       MoTa,
       CreatedAt
FROM dbo.KhuyenMai
WHERE KhuyenMaiId = @KhuyenMaiId;";

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@KhuyenMaiId", khuyenMaiId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapKhuyenMai(reader);
    }

    private static KhuyenMai MapKhuyenMai(SqlDataReader reader)
    {
        return new KhuyenMai
        {
            KhuyenMaiId = reader.GetInt32(reader.GetOrdinal("KhuyenMaiId")),
            TenKhuyenMai = reader.GetString(reader.GetOrdinal("TenKhuyenMai")),
            LoaiKhuyenMai = reader.GetString(reader.GetOrdinal("LoaiKhuyenMai")),
            GiaTri = reader.GetDecimal(reader.GetOrdinal("GiaTri")),
            TuNgay = reader.GetDateTime(reader.GetOrdinal("TuNgay")),
            DenNgay = reader.GetDateTime(reader.GetOrdinal("DenNgay")),
            IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
            MonId = reader.IsDBNull(reader.GetOrdinal("MonId")) ? null : reader.GetInt32(reader.GetOrdinal("MonId")),
            MoTa = reader.IsDBNull(reader.GetOrdinal("MoTa")) ? null : reader.GetString(reader.GetOrdinal("MoTa")),
            CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
        };
    }
}

