# 📖 Hướng dẫn Setup Project

## 🎯 Dành cho người mới clone project

### Bước 1: Clone repository

```bash
git clone https://github.com/yourusername/Coffee_Shop_Management_WPF.git
cd Coffee_Shop_Management_WPF
```

### Bước 2: Cấu hình Database

1. Mở SQL Server Management Studio
2. Tạo database mới tên `CoffeeShopDB`
3. Chạy script SQL để tạo tables (nếu có)

### Bước 3: Cấu hình Payment API

```bash
# Copy file example
cp CoffeeShop.PaymentApi/appsettings.Development.json.example CoffeeShop.PaymentApi/appsettings.Development.json
```

Mở file `appsettings.Development.json` và điền:

```json
{
  "ConnectionStrings": {
    "CoffeeShopDb": "Server=.;Database=CoffeeShopDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"
  },
  "PaymentMode": "VietQR",
  "VietQR": {
    "BankId": "970422",
    "AccountNo": "0909158974",
    "AccountName": "TRAN GIA BAO",
    "Template": "compact"
  }
}
```

**Lưu ý**: Thay thông tin ngân hàng bằng thông tin của bạn!

### Bước 4: Cấu hình WPF App

```bash
# Copy file example
cp CoffeeShop.Wpf/App.config.example CoffeeShop.Wpf/App.config
```

Mở file `App.config` và điền connection string.

### Bước 5: Build và chạy

1. Mở solution trong Visual Studio 2022
2. Click chuột phải vào Solution → Properties
3. Chọn **Multiple Startup Projects**
4. Set cả `CoffeeShop.PaymentApi` và `CoffeeShop.Wpf` thành **Start**
5. Nhấn F5

### Bước 6: Test thanh toán QR

1. Tạo hóa đơn mới
2. Chọn "Thanh toán QR"
3. QR code sẽ hiển thị
4. Quét QR bằng app ngân hàng
5. Hoặc nhấn "✅ Xác Nhận Đã Thanh Toán" để test

## ❓ Troubleshooting

### Lỗi: Cannot connect to database
- Kiểm tra SQL Server đang chạy
- Kiểm tra connection string đúng
- Kiểm tra database đã tạo chưa

### Lỗi: Port 5002 already in use
- Tắt các instance API cũ
- Hoặc đổi port trong `launchSettings.json`

### Lỗi: QR không hiển thị
- Kiểm tra thông tin VietQR trong config
- Kiểm tra API đang chạy
- Xem log trong Output window

## 📚 Tài liệu thêm

- [CAU_HINH_VIETQR.md](CAU_HINH_VIETQR.md) - Cấu hình VietQR chi tiết
- [HUONG_DAN_CHON_PAYMENT_MODE.md](HUONG_DAN_CHON_PAYMENT_MODE.md) - Chọn PayOS hoặc VietQR
- [README.md](README.md) - Tổng quan project
