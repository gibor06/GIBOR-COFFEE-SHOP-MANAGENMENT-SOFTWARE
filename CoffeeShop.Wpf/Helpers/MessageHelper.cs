using System.Windows;

namespace CoffeeShop.Wpf.Helpers
{
    /// <summary>
    /// Lớp hỗ trợ hiển thị thông báo cho người dùng
    /// </summary>
    public static class MessageHelper
    {
        /// <summary>
        /// Hiển thị thông báo lỗi
        /// </summary>
        /// <param name="message">Nội dung thông báo lỗi</param>
        public static void ShowError(string message)
        {
            MessageBox.Show(
                message,
                "Lỗi",
                MessageBoxButton.OK,
                MessageBoxImage.Error
            );
        }

        /// <summary>
        /// Hiển thị thông báo thành công
        /// </summary>
        /// <param name="message">Nội dung thông báo thành công</param>
        public static void ShowSuccess(string message)
        {
            MessageBox.Show(
                message,
                "Thành công",
                MessageBoxButton.OK,
                MessageBoxImage.Information
            );
        }

        /// <summary>
        /// Hiển thị hộp thoại xác nhận
        /// </summary>
        /// <param name="message">Nội dung câu hỏi xác nhận</param>
        /// <returns>True nếu người dùng chọn Yes, False nếu chọn No</returns>
        public static bool ShowConfirm(string message)
        {
            MessageBoxResult result = MessageBox.Show(
                message,
                "Xác nhận",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question
            );

            return result == MessageBoxResult.Yes;
        }
    }
}
