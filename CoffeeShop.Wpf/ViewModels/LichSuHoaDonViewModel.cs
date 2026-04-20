using System.Collections.ObjectModel;
using System.Windows.Input;
using CoffeeShop.Wpf.Commands;
using CoffeeShop.Wpf.Models;
using CoffeeShop.Wpf.Services;

namespace CoffeeShop.Wpf.ViewModels;

public sealed class LichSuHoaDonViewModel : BaseViewModel
{
    private readonly ILichSuHoaDonService _lichSuHoaDonService;
    private readonly RelayCommand _timKiemCommand;
    private readonly RelayCommand _xemChiTietCommand;
    private readonly RelayCommand _lamMoiCommand;

    private DateTime _fromDate = DateTime.Today.AddDays(-7);
    private DateTime _toDate = DateTime.Today;
    private string _maHoaDon = string.Empty;
    private string _maNhanVien = string.Empty;
    private string _maBan = string.Empty;
    private string _maCaLamViec = string.Empty;
    private LichSuHoaDonDong? _selectedHoaDon;
    private string _errorMessage = string.Empty;
    private string _successMessage = string.Empty;
    private bool _isBusy;

    public LichSuHoaDonViewModel(ILichSuHoaDonService lichSuHoaDonService)
    {
        _lichSuHoaDonService = lichSuHoaDonService;

        DanhSachHoaDon = new ObservableCollection<LichSuHoaDonDong>();
        ChiTietHoaDon = new ObservableCollection<LichSuHoaDonChiTietDong>();

        _timKiemCommand = new RelayCommand(ExecuteTimKiem, () => !IsBusy);
        _xemChiTietCommand = new RelayCommand(ExecuteXemChiTiet, () => !IsBusy && SelectedHoaDon is not null);
        _lamMoiCommand = new RelayCommand(ExecuteLamMoi, () => !IsBusy);
    }

    public ObservableCollection<LichSuHoaDonDong> DanhSachHoaDon { get; }

    public ObservableCollection<LichSuHoaDonChiTietDong> ChiTietHoaDon { get; }

    public DateTime FromDate
    {
        get => _fromDate;
        set => SetProperty(ref _fromDate, value);
    }

    public DateTime ToDate
    {
        get => _toDate;
        set => SetProperty(ref _toDate, value);
    }

    public string MaHoaDon
    {
        get => _maHoaDon;
        set => SetProperty(ref _maHoaDon, value);
    }

    public string MaNhanVien
    {
        get => _maNhanVien;
        set => SetProperty(ref _maNhanVien, value);
    }

    public string MaBan
    {
        get => _maBan;
        set => SetProperty(ref _maBan, value);
    }

    public string MaCaLamViec
    {
        get => _maCaLamViec;
        set => SetProperty(ref _maCaLamViec, value);
    }

    public LichSuHoaDonDong? SelectedHoaDon
    {
        get => _selectedHoaDon;
        set
        {
            if (SetProperty(ref _selectedHoaDon, value))
            {
                _xemChiTietCommand.RaiseCanExecuteChanged();
            }
        }
    }

    public string ErrorMessage
    {
        get => _errorMessage;
        private set => SetProperty(ref _errorMessage, value);
    }

    public string SuccessMessage
    {
        get => _successMessage;
        private set => SetProperty(ref _successMessage, value);
    }

    public bool IsBusy
    {
        get => _isBusy;
        private set
        {
            if (SetProperty(ref _isBusy, value))
            {
                _timKiemCommand.RaiseCanExecuteChanged();
                _xemChiTietCommand.RaiseCanExecuteChanged();
                _lamMoiCommand.RaiseCanExecuteChanged();
            }
        }
    }

    public ICommand TimKiemCommand => _timKiemCommand;
    public ICommand XemChiTietCommand => _xemChiTietCommand;
    public ICommand LamMoiCommand => _lamMoiCommand;

    public async Task LoadAsync(CancellationToken cancellationToken = default)
    {
        await TimKiemAsync(cancellationToken);
    }

    private async void ExecuteTimKiem()
    {
        await TimKiemAsync();
    }

    private async void ExecuteXemChiTiet()
    {
        await XemChiTietAsync();
    }

    private async void ExecuteLamMoi()
    {
        FromDate = DateTime.Today.AddDays(-7);
        ToDate = DateTime.Today;
        MaHoaDon = string.Empty;
        MaNhanVien = string.Empty;
        MaBan = string.Empty;
        MaCaLamViec = string.Empty;
        SelectedHoaDon = null;
        ChiTietHoaDon.Clear();
        await TimKiemAsync();
    }

    private async Task TimKiemAsync(CancellationToken cancellationToken = default)
    {
        if (IsBusy)
        {
            return;
        }

        IsBusy = true;
        ErrorMessage = string.Empty;
        SuccessMessage = string.Empty;

        try
        {
            int? hoaDonId = ParseNullableInt(MaHoaDon);
            int? nhanVienId = ParseNullableInt(MaNhanVien);
            int? banId = ParseNullableInt(MaBan);
            int? caId = ParseNullableInt(MaCaLamViec);

            var result = await _lichSuHoaDonService.TimKiemHoaDonAsync(
                FromDate,
                ToDate,
                hoaDonId,
                nhanVienId,
                banId,
                caId,
                cancellationToken);

            if (!result.IsSuccess || result.Data is null)
            {
                ErrorMessage = result.Message;
                return;
            }

            DanhSachHoaDon.Clear();
            foreach (var item in result.Data)
            {
                DanhSachHoaDon.Add(item);
            }

            SuccessMessage = DanhSachHoaDon.Count == 0
                ? "Không có hóa đơn phù hợp điều kiện tìm kiếm."
                : $"Tìm thấy {DanhSachHoaDon.Count} hóa đơn.";
        }
        catch (Exception ex)
        {
            ErrorMessage = $"Không thể tải lịch sử hóa đơn: {ex.Message}";
        }
        finally
        {
            IsBusy = false;
        }
    }

    private async Task XemChiTietAsync(CancellationToken cancellationToken = default)
    {
        if (IsBusy || SelectedHoaDon is null)
        {
            return;
        }

        IsBusy = true;
        ErrorMessage = string.Empty;

        try
        {
            var result = await _lichSuHoaDonService.GetChiTietHoaDonAsync(SelectedHoaDon.HoaDonBanId, cancellationToken);
            if (!result.IsSuccess || result.Data is null)
            {
                ErrorMessage = result.Message;
                return;
            }

            ChiTietHoaDon.Clear();
            foreach (var item in result.Data)
            {
                ChiTietHoaDon.Add(item);
            }

            SuccessMessage = $"Đã tải {ChiTietHoaDon.Count} dòng chi tiết của hóa đơn #{SelectedHoaDon.HoaDonBanId}.";
        }
        catch (Exception ex)
        {
            ErrorMessage = $"Không thể tải chi tiết hóa đơn: {ex.Message}";
        }
        finally
        {
            IsBusy = false;
        }
    }

    private static int? ParseNullableInt(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
        {
            return null;
        }

        return int.TryParse(input.Trim(), out var value) ? value : null;
    }
}

