using CoffeeShop.Wpf.Infrastructure;
using CoffeeShop.Wpf.Models;
using Microsoft.Data.SqlClient;

namespace CoffeeShop.Wpf.Repositories;

public sealed class HoaDonBanRepository : IHoaDonBanRepository
{
    public async Task<int> CreateAsync(
        HoaDonBan hoaDonBan,
        IReadOnlyList<ChiTietHoaDonBan> chiTietHoaDonBans,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);
        await using var transaction = await connection.BeginTransactionAsync(cancellationToken);

        try
        {
            const string insertHoaDonBanSql = @"
INSERT INTO dbo.HoaDonBan
(
    NgayBan,
    TongTien,
    GiamGia,
    CreatedByUserId,
    BanId,
    CaLamViecId,
    KhachHangId,
    KhuyenMaiId,
    SoTienGiam,
    DiemCong
)
VALUES
(
    @NgayBan,
    @TongTien,
    @GiamGia,
    @CreatedByUserId,
    @BanId,
    @CaLamViecId,
    @KhachHangId,
    @KhuyenMaiId,
    @SoTienGiam,
    @DiemCong
);
SELECT CAST(SCOPE_IDENTITY() AS INT);";

            await using var insertHoaDonBanCommand = new SqlCommand(insertHoaDonBanSql, connection, (SqlTransaction)transaction);
            insertHoaDonBanCommand.Parameters.AddWithValue("@NgayBan", hoaDonBan.NgayBan);
            insertHoaDonBanCommand.Parameters.AddWithValue("@TongTien", hoaDonBan.TongTien);
            insertHoaDonBanCommand.Parameters.AddWithValue("@GiamGia", hoaDonBan.GiamGia);
            insertHoaDonBanCommand.Parameters.AddWithValue("@CreatedByUserId", hoaDonBan.CreatedByUserId);
            insertHoaDonBanCommand.Parameters.AddWithValue("@BanId", (object?)hoaDonBan.BanId ?? DBNull.Value);
            insertHoaDonBanCommand.Parameters.AddWithValue("@CaLamViecId", (object?)hoaDonBan.CaLamViecId ?? DBNull.Value);
            insertHoaDonBanCommand.Parameters.AddWithValue("@KhachHangId", (object?)hoaDonBan.KhachHangId ?? DBNull.Value);
            insertHoaDonBanCommand.Parameters.AddWithValue("@KhuyenMaiId", (object?)hoaDonBan.KhuyenMaiId ?? DBNull.Value);
            insertHoaDonBanCommand.Parameters.AddWithValue("@SoTienGiam", hoaDonBan.SoTienGiam);
            insertHoaDonBanCommand.Parameters.AddWithValue("@DiemCong", hoaDonBan.DiemCong);

            var newHoaDonBanId = Convert.ToInt32(await insertHoaDonBanCommand.ExecuteScalarAsync(cancellationToken));

            const string updateTonKhoSql = @"
UPDATE dbo.Mon
SET TonKho = TonKho - @SoLuongBan
WHERE MonId = @MonId
  AND TonKho >= @SoLuongBan;";

            const string insertChiTietSql = @"
INSERT INTO dbo.ChiTietHoaDonBan (HoaDonBanId, MonId, DonGiaBan, SoLuong)
VALUES (@HoaDonBanId, @MonId, @DonGiaBan, @SoLuong);";

            foreach (var chiTiet in chiTietHoaDonBans)
            {
                await using var updateTonKhoCommand = new SqlCommand(updateTonKhoSql, connection, (SqlTransaction)transaction);
                updateTonKhoCommand.Parameters.AddWithValue("@MonId", chiTiet.MonId);
                updateTonKhoCommand.Parameters.AddWithValue("@SoLuongBan", chiTiet.SoLuong);

                var affectedRows = await updateTonKhoCommand.ExecuteNonQueryAsync(cancellationToken);
                if (affectedRows == 0)
                {
                    throw new InvalidOperationException($"Tồn kho không đủ cho sản phẩm mã {chiTiet.MonId}.");
                }

                await using var insertChiTietCommand = new SqlCommand(insertChiTietSql, connection, (SqlTransaction)transaction);
                insertChiTietCommand.Parameters.AddWithValue("@HoaDonBanId", newHoaDonBanId);
                insertChiTietCommand.Parameters.AddWithValue("@MonId", chiTiet.MonId);
                insertChiTietCommand.Parameters.AddWithValue("@DonGiaBan", chiTiet.DonGiaBan);
                insertChiTietCommand.Parameters.AddWithValue("@SoLuong", chiTiet.SoLuong);
                await insertChiTietCommand.ExecuteNonQueryAsync(cancellationToken);
            }

            if (hoaDonBan.KhachHangId.HasValue && hoaDonBan.DiemCong > 0)
            {
                const string updateDiemSql = @"
UPDATE dbo.KhachHang
SET DiemTichLuy = DiemTichLuy + @DiemCong
WHERE KhachHangId = @KhachHangId
  AND IsActive = 1;";

                await using var updateDiemCommand = new SqlCommand(updateDiemSql, connection, (SqlTransaction)transaction);
                updateDiemCommand.Parameters.AddWithValue("@KhachHangId", hoaDonBan.KhachHangId.Value);
                updateDiemCommand.Parameters.AddWithValue("@DiemCong", hoaDonBan.DiemCong);
                await updateDiemCommand.ExecuteNonQueryAsync(cancellationToken);
            }

            await transaction.CommitAsync(cancellationToken);
            return newHoaDonBanId;
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }

    public async Task<IReadOnlyList<HoaDonBan>> GetByDateRangeAsync(
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default)
    {
        const string sql = @"
SELECT HoaDonBanId,
       NgayBan,
       TongTien,
       GiamGia,
       CreatedByUserId,
       BanId,
       CaLamViecId,
       KhachHangId,
       KhuyenMaiId,
       SoTienGiam,
       DiemCong
FROM dbo.HoaDonBan
WHERE NgayBan >= @FromDate
  AND NgayBan < @ToDateExclusive
ORDER BY NgayBan DESC;";

        var result = new List<HoaDonBan>();

        await using var connection = new SqlConnection(DbConnectionFactory.ConnectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@FromDate", fromDate.Date);
        command.Parameters.AddWithValue("@ToDateExclusive", toDate.Date.AddDays(1));

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(new HoaDonBan
            {
                HoaDonBanId = reader.GetInt32(reader.GetOrdinal("HoaDonBanId")),
                NgayBan = reader.GetDateTime(reader.GetOrdinal("NgayBan")),
                TongTien = reader.GetDecimal(reader.GetOrdinal("TongTien")),
                GiamGia = reader.GetDecimal(reader.GetOrdinal("GiamGia")),
                CreatedByUserId = reader.GetInt32(reader.GetOrdinal("CreatedByUserId")),
                BanId = reader.IsDBNull(reader.GetOrdinal("BanId")) ? null : reader.GetInt32(reader.GetOrdinal("BanId")),
                CaLamViecId = reader.IsDBNull(reader.GetOrdinal("CaLamViecId")) ? null : reader.GetInt32(reader.GetOrdinal("CaLamViecId")),
                KhachHangId = reader.IsDBNull(reader.GetOrdinal("KhachHangId")) ? null : reader.GetInt32(reader.GetOrdinal("KhachHangId")),
                KhuyenMaiId = reader.IsDBNull(reader.GetOrdinal("KhuyenMaiId")) ? null : reader.GetInt32(reader.GetOrdinal("KhuyenMaiId")),
                SoTienGiam = reader.GetDecimal(reader.GetOrdinal("SoTienGiam")),
                DiemCong = reader.GetInt32(reader.GetOrdinal("DiemCong"))
            });
        }

        return result;
    }
}

