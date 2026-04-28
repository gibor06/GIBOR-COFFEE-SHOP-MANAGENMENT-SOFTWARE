# Cấu hình VietQR - QR Chuyển khoản ngân hàng

## ✅ Đã cập nhật

Hệ thống đã được chuyển sang sử dụng **VietQR** - QR code chuyển khoản ngân hàng thực sự, quét là chuyển khoản được ngay!

## 🏦 Cấu hình thông tin ngân hàng

Mở file `CoffeeShop.PaymentApi/appsettings.Development.json` và cập nhật thông tin ngân hàng của bạn:

```json
{
  "VietQR": {
    "BankId": "970422",           // Mã ngân hàng (VCB = 970436, TCB = 970407, MB = 970422, v.v.)
    "AccountNo": "0123456789",    // Số tài khoản của bạn
    "AccountName": "NGUYEN VAN A", // Tên chủ tài khoản (viết HOA, không dấu)
    "Template": "compact"          // Template QR: compact, qr_only, print
  }
}
```

## 🏦 Danh sách mã ngân hàng phổ biến

| Ngân hàng | Mã BankId |
|-----------|-----------|
| Vietcombank (VCB) | 970436 |
| Techcombank (TCB) | 970407 |
| MB Bank (MB) | 970422 |
| VietinBank (CTG) | 970415 |
| BIDV | 970418 |
| Agribank | 970405 |
| ACB | 970416 |
| Sacombank (STB) | 970403 |
| VPBank | 970432 |
| TPBank | 970423 |

[Xem danh sách đầy đủ tại đây](https://api.vietqr.io/v2/banks)

## 🎯 Cách hoạt động

### 1. Tạo QR Payment
```
WPF → API → Tạo VietQR URL
```

### 2. VietQR URL Format
```
https://img.vietqr.io/image/{BANK_ID}-{ACCOUNT_NO}-{TEMPLATE}.jpg
  ?amount={AMOUNT}
  &addInfo={DESCRIPTION}
  &accountName={ACCOUNT_NAME}
```

### 3. Khách quét QR
- Mở app ngân hàng
- Quét QR code
- Thông tin chuyển khoản tự động điền:
  - Số tài khoản: `{AccountNo}`
  - Tên người nhận: `{AccountName}`
  - Số tiền: `{Amount}`
  - Nội dung: `HD{OrderCode}`

### 4. Xác nhận thanh toán
- Khách xác nhận chuyển khoản
- Click nút "Xác nhận thanh toán (Test)" trong WPF
- Hoặc đợi webhook từ ngân hàng (nếu có tích hợp)

## 📝 Ví dụ

### Config
```json
{
  "VietQR": {
    "BankId": "970436",
    "AccountNo": "1234567890",
    "AccountName": "COFFEE SHOP ABC",
    "Template": "compact"
  }
}
```

### QR URL được tạo
```
https://img.vietqr.io/image/970436-1234567890-compact.jpg
  ?amount=57000
  &addInfo=HD177737458600014
  &accountName=COFFEE%20SHOP%20ABC
```

### Khi khách quét
```
Ngân hàng: Vietcombank
Số TK: 1234567890
Tên: COFFEE SHOP ABC
Số tiền: 57,000 VNĐ
Nội dung: HD177737458600014
```

## 🎨 Templates

### compact (Khuyến nghị)
- QR code nhỏ gọn
- Phù hợp hiển thị trên màn hình

### qr_only
- Chỉ có QR code
- Không có thông tin text

### print
- QR code lớn
- Có thông tin chi tiết
- Phù hợp in ra giấy

## ⚠️ Lưu ý quan trọng

### 1. Tên chủ tài khoản
- **Phải viết HOA**
- **Không dấu**
- Ví dụ: "NGUYEN VAN A" ✅
- Sai: "Nguyễn Văn A" ❌

### 2. Nội dung chuyển khoản
- Format: `HD{OrderCode}`
- Ví dụ: `HD177737458600014`
- Dùng để đối soát thanh toán

### 3. Số tiền
- Đơn vị: VNĐ
- Tự động điền vào app ngân hàng
- Khách không thể sửa

## 🔄 Quy trình thanh toán

```
1. Nhân viên tạo hóa đơn
   ↓
2. Click "Tạo QR Thanh Toán"
   ↓
3. QR VietQR hiển thị
   ↓
4. Khách quét QR bằng app ngân hàng
   ↓
5. Thông tin tự động điền
   ↓
6. Khách xác nhận chuyển khoản
   ↓
7. Nhân viên click "Xác nhận thanh toán (Test)"
   ↓
8. Hệ thống cập nhật trạng thái PAID
   ↓
9. In bill và chuyển pha chế
```

## 🧪 Test

### 1. Cấu hình thông tin ngân hàng
Sửa file `appsettings.Development.json`

### 2. Restart API
```bash
# Trong Visual Studio: Shift+F5 rồi F5
```

### 3. Tạo QR trong WPF
- Tạo hóa đơn
- Lưu hóa đơn
- Tạo QR Payment

### 4. Kiểm tra QR
- QR sẽ hiển thị
- Copy URL và mở trong browser để xem
- Hoặc quét bằng app ngân hàng

### 5. Test thanh toán
- Click "Xác nhận thanh toán (Test)"
- Hệ thống sẽ cập nhật trạng thái

## 💡 Tips

### Lấy mã ngân hàng
```bash
# Gọi API VietQR
curl https://api.vietqr.io/v2/banks
```

### Test QR trước
Mở URL trong browser để xem QR có đúng không:
```
https://img.vietqr.io/image/970422-0123456789-compact.jpg?amount=50000&addInfo=TEST
```

### Tùy chỉnh template
Thử các template khác nhau:
- `compact` - Nhỏ gọn
- `qr_only` - Chỉ QR
- `print` - In ra giấy

## 🚀 Production

Khi deploy production:

1. **Cập nhật thông tin ngân hàng thật** trong `appsettings.Production.json`
2. **Tích hợp webhook ngân hàng** (nếu có) để tự động xác nhận
3. **Đối soát** theo nội dung chuyển khoản `HD{OrderCode}`

## 📞 Hỗ trợ

- VietQR API: https://vietqr.io
- Docs: https://vietqr.io/docs
- Support: support@vietqr.io

---

**Lưu ý**: VietQR là dịch vụ miễn phí, không cần đăng ký API key!
