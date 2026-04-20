using CoffeeShop.Wpf.Models;

namespace CoffeeShop.Wpf.Services;

public interface IExportPrintService
{
    Task<ServiceResult<string>> XuatPdfBaoCaoDonGianAsync(
        DateTime fromDate,
        DateTime toDate,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default);

    Task<ServiceResult<string>> XuatPdfBaoCaoNangCaoAsync(
        DateTime fromDate,
        DateTime toDate,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default);

    Task<ServiceResult<string>> XuatExcelThongKeAsync(
        DateTime fromDate,
        DateTime toDate,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default);

    Task<ServiceResult<string>> InHoaDonBanAsync(
        int hoaDonBanId,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default);

    Task<ServiceResult<string>> PreviewBaoCaoAsync(
        DateTime fromDate,
        DateTime toDate,
        string loaiBaoCao,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default);
}
