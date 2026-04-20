using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Text;
using CoffeeShop.Wpf.Models;
using CoffeeShop.Wpf.Repositories;

namespace CoffeeShop.Wpf.Services;

public sealed class ExportPrintService : IExportPrintService
{
    private readonly IExportPrintRepository _exportPrintRepository;
    private readonly IAuditLogService _auditLogService;
    private readonly ICauHinhHeThongService? _cauHinhHeThongService;

    public ExportPrintService(
        IExportPrintRepository exportPrintRepository,
        IAuditLogService auditLogService,
        ICauHinhHeThongService? cauHinhHeThongService = null)
    {
        _exportPrintRepository = exportPrintRepository;
        _auditLogService = auditLogService;
        _cauHinhHeThongService = cauHinhHeThongService;
    }

    public async Task<ServiceResult<string>> XuatPdfBaoCaoDonGianAsync(
        DateTime fromDate,
        DateTime toDate,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default)
    {
        var validation = ValidateDateRange(fromDate, toDate);
        if (!validation.IsSuccess)
        {
            return ServiceResult<string>.Fail(validation.Message);
        }

        var rows = await _exportPrintRepository.GetDuLieuBaoCaoDonGianAsync(fromDate, toDate, cancellationToken);
        var lines = new List<string>();
        lines.AddRange(await BuildHeaderLinesAsync(cancellationToken));
        lines.Add("BÁO CÁO ĐƠN GIẢN");
        lines.Add($"Từ ngày: {fromDate:dd/MM/yyyy}");
        lines.Add($"Đến ngày: {toDate:dd/MM/yyyy}");
        lines.Add($"Số dòng dữ liệu: {rows.Count}");
        lines.Add(string.Empty);

        lines.AddRange(rows.Select(x =>
            $"{x.Ngay:dd/MM/yyyy} | Số HĐ: {x.SoHoaDon} | Tổng: {x.TongTien:N0} | Giảm: {x.TongGiamGia:N0} | Thuần: {x.DoanhThuThuan:N0}"));

        var outputPath = BuildOutputPath(outputDirectory, "BaoCaoDonGian", "pdf");
        await SimplePdfWriter.WriteLinesAsPdfAsync(outputPath, lines, cancellationToken);

        await TryWriteAuditAsync(
            nguoiDungId,
            "Xuất PDF báo cáo đơn giản",
            "BaoCao",
            $"Từ {fromDate:dd/MM/yyyy} đến {toDate:dd/MM/yyyy}, số dòng: {rows.Count}",
            cancellationToken);

        return ServiceResult<string>.Success(outputPath, "Xuất PDF báo cáo đơn giản thành công.");
    }

    public async Task<ServiceResult<string>> XuatPdfBaoCaoNangCaoAsync(
        DateTime fromDate,
        DateTime toDate,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default)
    {
        var validation = ValidateDateRange(fromDate, toDate);
        if (!validation.IsSuccess)
        {
            return ServiceResult<string>.Fail(validation.Message);
        }

        var rows = await _exportPrintRepository.GetDuLieuBaoCaoNangCaoAsync(fromDate, toDate, cancellationToken);
        var lines = new List<string>();
        lines.AddRange(await BuildHeaderLinesAsync(cancellationToken));
        lines.Add("BÁO CÁO NÂNG CAO");
        lines.Add($"Từ ngày: {fromDate:dd/MM/yyyy}");
        lines.Add($"Đến ngày: {toDate:dd/MM/yyyy}");
        lines.Add($"Số dòng dữ liệu: {rows.Count}");
        lines.Add(string.Empty);

        lines.AddRange(rows.Select(x =>
            $"{x.MonId} | {x.TenMon} | Số lượng: {x.SoLuongBan} | Doanh thu: {x.DoanhThuGop:N0} | Giá TB: {x.GiaBanTrungBinh:N0}"));

        var outputPath = BuildOutputPath(outputDirectory, "BaoCaoNangCao", "pdf");
        await SimplePdfWriter.WriteLinesAsPdfAsync(outputPath, lines, cancellationToken);

        await TryWriteAuditAsync(
            nguoiDungId,
            "Xuất PDF báo cáo nâng cao",
            "BaoCao",
            $"Từ {fromDate:dd/MM/yyyy} đến {toDate:dd/MM/yyyy}, số dòng: {rows.Count}",
            cancellationToken);

        return ServiceResult<string>.Success(outputPath, "Xuất PDF báo cáo nâng cao thành công.");
    }

    public async Task<ServiceResult<string>> XuatExcelThongKeAsync(
        DateTime fromDate,
        DateTime toDate,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default)
    {
        var validation = ValidateDateRange(fromDate, toDate);
        if (!validation.IsSuccess)
        {
            return ServiceResult<string>.Fail(validation.Message);
        }

        var rows = await _exportPrintRepository.GetDuLieuThongKeDoanhThuAsync(fromDate, toDate, cancellationToken);
        var outputPath = BuildOutputPath(outputDirectory, "ThongKeDoanhThu", "csv");

        var csv = new StringBuilder();
        csv.AppendLine("Ngay,SoHoaDon,DoanhThuGop,GiamGia,DoanhThuThuan");
        foreach (var row in rows)
        {
            csv.Append(row.Ngay.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture));
            csv.Append(',');
            csv.Append(row.SoHoaDon);
            csv.Append(',');
            csv.Append(row.DoanhThuGop.ToString(CultureInfo.InvariantCulture));
            csv.Append(',');
            csv.Append(row.GiamGia.ToString(CultureInfo.InvariantCulture));
            csv.Append(',');
            csv.Append(row.DoanhThuThuan.ToString(CultureInfo.InvariantCulture));
            csv.AppendLine();
        }

        await File.WriteAllTextAsync(outputPath, csv.ToString(), new UTF8Encoding(true), cancellationToken);

        await TryWriteAuditAsync(
            nguoiDungId,
            "Xuất Excel thống kê",
            "ThongKe",
            $"Từ {fromDate:dd/MM/yyyy} đến {toDate:dd/MM/yyyy}, số dòng: {rows.Count}",
            cancellationToken);

        return ServiceResult<string>.Success(outputPath, "Xuất Excel thống kê doanh thu thành công.");
    }

    public async Task<ServiceResult<string>> InHoaDonBanAsync(
        int hoaDonBanId,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default)
    {
        if (hoaDonBanId <= 0)
        {
            return ServiceResult<string>.Fail("Mã hóa đơn bán không hợp lệ.");
        }

        var data = await _exportPrintRepository.GetDuLieuHoaDonBanAsync(hoaDonBanId, cancellationToken);
        if (data is null)
        {
            return ServiceResult<string>.Fail("Không tìm thấy hóa đơn bán để in.");
        }

        var outputPath = BuildOutputPath(outputDirectory, $"HoaDonBan_{hoaDonBanId}", "txt");
        var header = await BuildHeaderLinesAsync(cancellationToken);
        await File.WriteAllLinesAsync(outputPath, BuildInvoiceTextLines(data, header), cancellationToken);

        var printed = TryPrintFile(outputPath);
        await TryWriteAuditAsync(
            nguoiDungId,
            "In hóa đơn bán",
            "HoaDonBan",
            $"Hóa đơn #{hoaDonBanId}, in={(printed ? "thành công" : "fallback file")}",
            cancellationToken);

        return ServiceResult<string>.Success(
            outputPath,
            printed
                ? "Đã gửi lệnh in hóa đơn bán."
                : "Không thể gửi lệnh in trực tiếp. Đã tạo file hóa đơn để in thủ công.");
    }

    public async Task<ServiceResult<string>> PreviewBaoCaoAsync(
        DateTime fromDate,
        DateTime toDate,
        string loaiBaoCao,
        string? outputDirectory = null,
        int? nguoiDungId = null,
        CancellationToken cancellationToken = default)
    {
        var validation = ValidateDateRange(fromDate, toDate);
        if (!validation.IsSuccess)
        {
            return ServiceResult<string>.Fail(validation.Message);
        }

        if (string.IsNullOrWhiteSpace(loaiBaoCao))
        {
            return ServiceResult<string>.Fail("Loại báo cáo preview không hợp lệ.");
        }

        var loai = loaiBaoCao.Trim();
        var outputPath = BuildOutputPath(outputDirectory, $"Preview_{loai}", "txt");

        var lines = new List<string>();
        lines.AddRange(await BuildHeaderLinesAsync(cancellationToken));

        if (string.Equals(loai, "DonGian", StringComparison.OrdinalIgnoreCase))
        {
            var rows = await _exportPrintRepository.GetDuLieuBaoCaoDonGianAsync(fromDate, toDate, cancellationToken);
            lines.Add("PREVIEW BÁO CÁO ĐƠN GIẢN");
            lines.Add($"Từ ngày: {fromDate:dd/MM/yyyy}");
            lines.Add($"Đến ngày: {toDate:dd/MM/yyyy}");
            lines.Add($"Số dòng: {rows.Count}");
            lines.Add(string.Empty);
            lines.AddRange(rows.Select(x => $"{x.Ngay:dd/MM/yyyy} | HD={x.SoHoaDon} | Thuần={x.DoanhThuThuan:N0}"));
        }
        else
        {
            var rows = await _exportPrintRepository.GetDuLieuBaoCaoNangCaoAsync(fromDate, toDate, cancellationToken);
            lines.Add("PREVIEW BÁO CÁO NÂNG CAO");
            lines.Add($"Từ ngày: {fromDate:dd/MM/yyyy}");
            lines.Add($"Đến ngày: {toDate:dd/MM/yyyy}");
            lines.Add($"Số dòng: {rows.Count}");
            lines.Add(string.Empty);
            lines.AddRange(rows.Select(x => $"{x.MonId} | {x.TenMon} | Số lượng={x.SoLuongBan} | Doanh thu={x.DoanhThuGop:N0}"));
        }

        await File.WriteAllLinesAsync(outputPath, lines, cancellationToken);
        TryOpenFile(outputPath);

        await TryWriteAuditAsync(
            nguoiDungId,
            "Preview báo cáo",
            "BaoCao",
            $"Loại={loai}, từ {fromDate:dd/MM/yyyy} đến {toDate:dd/MM/yyyy}",
            cancellationToken);

        return ServiceResult<string>.Success(outputPath, "Tạo preview báo cáo thành công.");
    }

    private static ServiceResult ValidateDateRange(DateTime fromDate, DateTime toDate)
    {
        if (fromDate.Date > toDate.Date)
        {
            return ServiceResult.Fail("Ngày bắt đầu không được lớn hơn ngày kết thúc.");
        }

        if ((toDate.Date - fromDate.Date).TotalDays > 366)
        {
            return ServiceResult.Fail("Khoảng thời gian tối đa là 366 ngày.");
        }

        return ServiceResult.Success();
    }

    private static string BuildOutputPath(string? outputDirectory, string prefix, string extension)
    {
        var dir = string.IsNullOrWhiteSpace(outputDirectory)
            ? Path.Combine(AppContext.BaseDirectory, "Exports")
            : outputDirectory.Trim();

        Directory.CreateDirectory(dir);
        return Path.Combine(dir, $"{prefix}_{DateTime.Now:yyyyMMdd_HHmmss}.{extension}");
    }

    private static IReadOnlyList<string> BuildInvoiceTextLines(HoaDonBanInModel model, IReadOnlyList<string> headerLines)
    {
        var lines = new List<string>();
        lines.AddRange(headerLines);
        lines.Add($"HÓA ĐƠN BÁN #{model.HoaDonBanId}");
        lines.Add($"Ngày bán: {model.NgayBan:dd/MM/yyyy HH:mm}");
        lines.Add($"Nhân viên: {model.TenNhanVien}");
        lines.Add($"Bàn/Khu vực: {(string.IsNullOrWhiteSpace(model.TenBan) ? "N/A" : model.TenBan)} / {(string.IsNullOrWhiteSpace(model.TenKhuVuc) ? "N/A" : model.TenKhuVuc)}");
        lines.Add($"Ca làm việc: {(model.CaLamViecId.HasValue ? model.CaLamViecId.Value.ToString() : "N/A")}");
        lines.Add($"Khách hàng: {(string.IsNullOrWhiteSpace(model.TenKhachHang) ? "Khách lẻ" : model.TenKhachHang)}");
        if (!string.IsNullOrWhiteSpace(model.SoDienThoaiKhachHang))
        {
            lines.Add($"SĐT khách hàng: {model.SoDienThoaiKhachHang}");
        }
        lines.Add(string.Empty);
        lines.Add("Chi tiết:");

        lines.AddRange(model.ChiTiet.Select(x =>
            $"- {x.TenMon}: {x.SoLuong} x {x.DonGiaBan:N0} = {x.ThanhTien:N0}"));

        lines.Add(string.Empty);
        lines.Add($"Tổng tiền: {model.TongTien:N0}");
        lines.Add($"Giảm giá: {model.GiamGia:N0}");
        lines.Add($"Thanh toán: {model.ThanhToan:N0}");
        lines.Add($"Hình thức: {model.HinhThucThanhToan}");
        lines.Add($"Trạng thái: {model.TrangThaiThanhToan}");

        if (model.TienKhachDua.HasValue)
        {
            lines.Add($"Tiền khách đưa: {model.TienKhachDua.Value:N0}");
        }

        if (model.TienThoiLai.HasValue)
        {
            lines.Add($"Tiền thối: {model.TienThoiLai.Value:N0}");
        }

        if (!string.IsNullOrWhiteSpace(model.MaGiaoDich))
        {
            lines.Add($"Mã giao dịch: {model.MaGiaoDich}");
        }

        if (!string.IsNullOrWhiteSpace(model.GhiChuThanhToan))
        {
            lines.Add($"Ghi chú TT: {model.GhiChuThanhToan}");
        }

        if (!string.IsNullOrWhiteSpace(model.GhiChuHoaDon))
        {
            lines.Add($"Ghi chú: {model.GhiChuHoaDon}");
        }

        lines.Add(string.Empty);
        lines.Add("Cảm ơn quý khách. Hẹn gặp lại!");
        return lines;
    }

    private static bool TryPrintFile(string filePath)
    {
        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = filePath,
                Verb = "print",
                CreateNoWindow = true,
                UseShellExecute = true,
                WindowStyle = ProcessWindowStyle.Hidden
            };

            using var process = Process.Start(psi);
            return process is not null;
        }
        catch
        {
            return false;
        }
    }

    private static void TryOpenFile(string filePath)
    {
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = filePath,
                UseShellExecute = true
            });
        }
        catch
        {
            // Bỏ qua lỗi mở preview theo môi trường máy.
        }
    }

    private async Task<IReadOnlyList<string>> BuildHeaderLinesAsync(CancellationToken cancellationToken)
    {
        if (_cauHinhHeThongService is null)
        {
            return ["CoffeeShop.Wpf"];
        }

        var cauHinhResult = await _cauHinhHeThongService.GetCauHinhAsync(cancellationToken);
        if (!cauHinhResult.IsSuccess || cauHinhResult.Data is null)
        {
            return ["CoffeeShop.Wpf"];
        }

        var cauHinh = cauHinhResult.Data;
        var lines = new List<string> { cauHinh.TenQuan };

        if (!string.IsNullOrWhiteSpace(cauHinh.DiaChi))
        {
            lines.Add($"Địa chỉ: {cauHinh.DiaChi}");
        }

        if (!string.IsNullOrWhiteSpace(cauHinh.SoDienThoai))
        {
            lines.Add($"SĐT: {cauHinh.SoDienThoai}");
        }

        if (!string.IsNullOrWhiteSpace(cauHinh.FooterHoaDon))
        {
            lines.Add(cauHinh.FooterHoaDon);
        }

        lines.Add(string.Empty);
        return lines;
    }

    private async Task TryWriteAuditAsync(
        int? nguoiDungId,
        string hanhDong,
        string doiTuong,
        string duLieuTomTat,
        CancellationToken cancellationToken)
    {
        try
        {
            await _auditLogService.GhiLogAsync(
                nguoiDungId,
                hanhDong,
                doiTuong,
                duLieuTomTat,
                Environment.MachineName,
                cancellationToken);
        }
        catch
        {
            // Không chặn luồng xuất/in nếu ghi log thất bại.
        }
    }
}
