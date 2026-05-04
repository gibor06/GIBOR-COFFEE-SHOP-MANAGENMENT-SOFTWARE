using System.Windows.Controls;
using CoffeeShop.Wpf.ViewModels;

namespace CoffeeShop.Wpf.Views;

public partial class NguyenLieuView : UserControl
{
    public NguyenLieuView()
    {
        InitializeComponent();
        Loaded += OnLoaded;
    }

    private async void OnLoaded(object sender, System.Windows.RoutedEventArgs e)
    {
        if (DataContext is NguyenLieuViewModel viewModel)
        {
            await viewModel.LoadAsync();
        }
    }

    private void CloseDetailButton_Click(object sender, System.Windows.RoutedEventArgs e)
    {
        if (DataContext is NguyenLieuViewModel viewModel)
        {
            viewModel.IsDetailVisible = false;
            viewModel.SelectedNguyenLieu = null;
        }
    }
}
