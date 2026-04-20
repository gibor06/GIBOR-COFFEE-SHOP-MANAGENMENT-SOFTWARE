using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace CoffeeShop.Wpf.Views;

public partial class LoginView : UserControl
{
    public LoginView()
    {
        InitializeComponent();
    }

    private void UsernameTextBox_OnKeyDown(object sender, KeyEventArgs e)
    {
        if (e.Key != Key.Enter || sender is not UIElement element)
        {
            return;
        }

        element.MoveFocus(new TraversalRequest(FocusNavigationDirection.Next));
        e.Handled = true;
    }
}
