using System.Windows;
using System.Windows.Controls;

namespace CoffeeShop.Wpf.Services;

public sealed class DialogService : IDialogService
{
    public bool ShowConfirmation(string message, string title)
    {
        var result = MessageBox.Show(message, title, MessageBoxButton.YesNo, MessageBoxImage.Question);
        return result == MessageBoxResult.Yes;
    }

    public string? ShowPasswordInput(string message, string title)
    {
        var dialog = new Window
        {
            Title = title,
            Width = 400,
            Height = 200,
            WindowStartupLocation = WindowStartupLocation.CenterScreen,
            ResizeMode = ResizeMode.NoResize
        };

        var stackPanel = new StackPanel { Margin = new Thickness(20) };

        stackPanel.Children.Add(new TextBlock
        {
            Text = message,
            Margin = new Thickness(0, 0, 0, 10),
            TextWrapping = TextWrapping.Wrap
        });

        var passwordBox = new PasswordBox
        {
            Margin = new Thickness(0, 0, 0, 15)
        };
        stackPanel.Children.Add(passwordBox);

        var buttonPanel = new StackPanel
        {
            Orientation = Orientation.Horizontal,
            HorizontalAlignment = HorizontalAlignment.Right
        };

        var okButton = new Button
        {
            Content = "Xác nhận",
            Width = 100,
            Margin = new Thickness(0, 0, 10, 0),
            IsDefault = true
        };
        okButton.Click += (s, e) =>
        {
            if (string.IsNullOrWhiteSpace(passwordBox.Password))
            {
                MessageBox.Show("Mật khẩu không được để trống.", "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            dialog.Tag = passwordBox.Password;
            dialog.DialogResult = true;
            dialog.Close();
        };

        var cancelButton = new Button
        {
            Content = "Hủy",
            Width = 100,
            IsCancel = true
        };
        cancelButton.Click += (s, e) =>
        {
            dialog.DialogResult = false;
            dialog.Close();
        };

        buttonPanel.Children.Add(okButton);
        buttonPanel.Children.Add(cancelButton);
        stackPanel.Children.Add(buttonPanel);

        dialog.Content = stackPanel;

        return dialog.ShowDialog() == true ? dialog.Tag as string : null;
    }

    public void ShowError(string message, string title = "Lỗi")
    {
        MessageBox.Show(message, title, MessageBoxButton.OK, MessageBoxImage.Error);
    }

    public void ShowInformation(string message, string title = "Thông báo")
    {
        MessageBox.Show(message, title, MessageBoxButton.OK, MessageBoxImage.Information);
    }
}
