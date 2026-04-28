# Hướng dẫn chọn Payment Mode

Hệ thống hỗ trợ **2 modes thanh toán**:
1. **VietQR** - QR chuyển khoản ngân hàng (mặc định, miễn phí)
2. **PayOS** - Cổng thanh toán PayOS (cần đăng ký, có phí)

## 🎯 So sánh 2 modes

| Tiêu chí | VietQR | PayOS |
|----------|--------|-------|
| **Chi phí** | Miễn phí | Có phí giao dịch |
| **Đăng ký** | Không cần | Cần đăng ký tài khoản |
| **QR Code** | Chuyển khoản ngân hàng | QR PayOS (hỗ trợ nhiều ví) |
| **Webhook** | Không có (cần xác nhận thủ công) | Có (tự động) |
| **Đối soát** | Theo nội dung CK | Tự động qua API |
| **Phù hợp** | Quán nhỏ, startup | Doanh nghiệp lớn |

## 🏦 Mode 1: VietQR (Mặc định)

### Ưu điểm
✅ Miễn phí hoàn toàn  
✅ Không cần đăng ký  
✅ Chỉ cần có tài khoản ngân hàng  
✅ Khách quét QR → chuyển khoản trực tiếp  
✅ Không qua trung gian  

### Nhược điểm
❌ Không có webhook tự động  
❌ Cần xác nhận thủ công (click nút "Xác nhận thanh toán")  
❌ Đối soát thủ công theo nội dung chuyển khoản  

### Cấu hình

File: `appsettings.Development.json`

```json
{
  "PaymentMode": "VietQR",
  "VietQR": {
    "BankId": "970422",           // Mã ngân hàng của bạn
    "AccountNo": "0909158974",    // Số tài khoản của bạn
    "AccountName": "TRAN GIA BAO", // Tên (HOA, không dấu)
    "Template": "compact"
  }
}
```

### Quy trình sử dụng

```
1. Tạo hóa đơn → Lưu
2. Click "Tạo QR Thanh Toán"
3. QR VietQR hiển thị
4. Khách quét QR bằng app ngân hàng
5. Khách xác nhận chuyển khoản
6. Nhân viên click "Xác nhận thanh toán (Test)"
7. Hệ thống cập nhật PAID
```

## 💳 Mode 2: PayOS

### Ưu điểm
✅ Webhook tự động (không cần xác nhận thủ công)  
✅ Hỗ trợ nhiều ví điện tử (Momo, ZaloPay, v.v.)  
✅ Đối soát tự động qua API  
✅ Báo cáo chi tiết  
✅ Chuyên nghiệp hơn  

### Nhược điểm
❌ Có phí giao dịch (~1-2%)  
❌ Cần đăng ký tài khoản PayOS  
❌ Cần xác minh doanh nghiệp  
❌ Phức tạp hơn để setup  

### Đăng ký PayOS

1. Truy cập: https://payos.vn
2. Đăng ký tài khoản
3. Xác minh doanh nghiệp
4. Lấy credentials:
   - Client ID
   - API Key
   - Checksum Key

### Cấu hình

File: `appsettings.Development.json`

```json
{
  "PaymentMode": "PayOS",
  "PayOS": {
    "ClientId": "abc123...",      // Client ID từ PayOS
    "ApiKey": "xyz789...",         // API Key từ PayOS
    "ChecksumKey": "def456...",    // Checksum Key từ PayOS
    "BaseUrl": "https://api-merchant.payos.vn",
    "ReturnUrl": "https://localhost:5002/payment/success",
    "CancelUrl": "https://localhost:5002/payment/cancel"
  }
}
```

### Quy trình sử dụng

```
1. Tạo hóa đơn → Lưu
2. Click "Tạo QR Thanh Toán"
3. QR PayOS hiển thị
4. Khách quét QR
5. Khách chọn ví/ngân hàng và thanh toán
6. PayOS gửi webhook → API
7. Hệ thống TỰ ĐỘNG cập nhật PAID (không cần click gì!)
```

## 🔄 Chuyển đổi giữa 2 modes

### Từ VietQR sang PayOS

1. Đăng ký tài khoản PayOS
2. Lấy credentials
3. Sửa `appsettings.Development.json`:
   ```json
   {
     "PaymentMode": "PayOS",
     "PayOS": {
       "ClientId": "your_real_client_id",
       "ApiKey": "your_real_api_key",
       "ChecksumKey": "your_real_checksum_key"
     }
   }
   ```
4. Restart API
5. Done! Hệ thống tự động dùng PayOS

### Từ PayOS về VietQR

1. Sửa `appsettings.Development.json`:
   ```json
   {
     "PaymentMode": "VietQR"
   }
   ```
2. Restart API
3. Done! Hệ thống dùng VietQR

## 🛡️ Fallback tự động

Nếu `PaymentMode = "PayOS"` nhưng:
- Credentials không hợp lệ
- PayOS API lỗi
- Không kết nối được

→ Hệ thống **tự động fallback về VietQR** để không bị gián đoạn dịch vụ!

## 📊 Khuyến nghị

### Dùng VietQR khi:
- Quán nhỏ, vừa
- Mới bắt đầu
- Muốn tiết kiệm chi phí
- Chấp nhận xác nhận thủ công

### Dùng PayOS khi:
- Quán lớn, chuỗi
- Nhiều giao dịch/ngày
- Cần tự động hóa hoàn toàn
- Có ngân sách cho phí giao dịch
- Muốn hỗ trợ nhiều ví điện tử

## 🧪 Test cả 2 modes

### Test VietQR
```json
{ "PaymentMode": "VietQR" }
```
→ Restart → Tạo QR → Quét bằng app ngân hàng

### Test PayOS
```json
{ "PaymentMode": "PayOS" }
```
→ Restart → Tạo QR → Quét và thanh toán

## 💡 Tips

### Development
Dùng **VietQR** để test, không tốn phí

### Production
- Quán nhỏ: **VietQR**
- Quán lớn: **PayOS**

### Hybrid
Có thể dùng cả 2:
- VietQR cho khách chuyển khoản
- PayOS cho khách dùng ví điện tử

## 📞 Hỗ trợ

### VietQR
- Website: https://vietqr.io
- Docs: https://vietqr.io/docs
- Miễn phí, không cần support

### PayOS
- Website: https://payos.vn
- Docs: https://payos.vn/docs
- Support: support@payos.vn
- Hotline: (có trên website)

---

**Tóm lại**: 
- Bắt đầu với **VietQR** (miễn phí, đơn giản)
- Nâng cấp lên **PayOS** khi cần tự động hóa
