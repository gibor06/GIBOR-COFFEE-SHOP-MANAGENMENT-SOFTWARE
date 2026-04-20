# SKILL — Đồ án WPF Quản lý quán cà phê (chỉ phạm vi NHÂN VIÊN THU NGÂN)

## 1) Mục tiêu của skill này
Skill này dùng để yêu cầu AI hỗ trợ một sinh viên hoàn thành **đồ án WPF quản lý quán cà phê** nhưng **chỉ tập trung vào nghiệp vụ của nhân viên thu ngân**. Không phân tích và không cài đặt các nghiệp vụ khác như quản lý kho, quản lý nhân viên, quản lý menu tổng thể, phân quyền quản trị, nhập hàng, chấm công.

Skill này buộc AI làm việc theo tinh thần của một sinh viên giỏi:
- Phân tích đúng nghiệp vụ trước khi code.
- Bám sát nội dung học phần: **WPF, XAML, layout, UserControl, MVVM, Binding, Entity Framework Database First, CRUD, Validation, LINQ, Crystal Report**.
- Mọi code phải có **comment rõ ràng bằng tiếng Việt**.
- Phần nâng cao được phép thêm, nhưng phải **ghi rõ là nâng cao** và **không làm rối phần cơ bản**.
- Ưu tiên thiết kế dễ demo, dễ chấm điểm, dễ giải thích khi bảo vệ đồ án.

---

## 2) Vai trò cần phân tích: NHÂN VIÊN THU NGÂN

### 2.1. Mục tiêu công việc của thu ngân
Nhân viên thu ngân là người trực tiếp thao tác với khách tại quầy hoặc tại bàn để:
1. Nhận thông tin khách hàng.
2. Chọn bàn hoặc xác định vị trí phục vụ.
3. Ghi nhận món khách gọi.
4. Tính tiền tạm tính.
5. Áp dụng ưu đãi hợp lệ.
6. Xác nhận thanh toán.
7. Lưu hóa đơn.
8. In/xem hóa đơn hoặc báo cáo doanh thu cơ bản trong ca.

### 2.2. Phạm vi chức năng được làm
Chỉ làm các chức năng sau:
- Lập hóa đơn bán hàng.
- Chọn bàn.
- Chọn món.
- Tính tổng tiền.
- Áp dụng giảm giá đơn giản.
- Thanh toán và lưu hóa đơn.
- Xem danh sách hóa đơn đã thanh toán.
- Tìm kiếm / lọc hóa đơn cơ bản.
- Thống kê cơ bản theo ngày hoặc theo ca.
- In hóa đơn / xuất báo cáo đơn giản.

### 2.3. Những gì KHÔNG làm
Không làm:
- Nhập hàng.
- Kiểm kê kho.
- Phân quyền nhiều vai trò phức tạp.
- Quản lý lương.
- Đặt hàng nhà cung cấp.
- Quản lý công thức pha chế.
- Đồng bộ nhiều máy hoặc nghiệp vụ online real-time.

---

## 3) Phân tích nghiệp vụ thu ngân

### 3.1. Tác nhân
- **Nhân viên thu ngân**: người sử dụng hệ thống.
- **Khách hàng**: người mua hàng, không thao tác trực tiếp trên phần mềm.

### 3.2. Dữ liệu mà thu ngân cần xử lý
- Thông tin khách hàng: tên khách, số điện thoại (hoặc để trống nếu đồ án muốn đơn giản).
- Thông tin bàn: mã bàn, tên bàn, trạng thái bàn.
- Thông tin món: mã món, tên món, loại món, đơn giá, trạng thái còn bán/không bán.
- Hóa đơn: mã hóa đơn, ngày lập, bàn, nhân viên, tổng tiền, giảm giá, thành tiền, trạng thái thanh toán.
- Chi tiết hóa đơn: hóa đơn nào gồm những món nào, số lượng bao nhiêu, đơn giá bao nhiêu, thành tiền từng dòng.

### 3.3. Luồng nghiệp vụ chuẩn của thu ngân

#### Nghiệp vụ 1: Lập hóa đơn mới
**Mục đích**: tạo một đơn bán hàng cho khách.

**Luồng chính**:
1. Thu ngân mở màn hình Lập hóa đơn.
2. Hệ thống sinh mã hóa đơn tự động.
3. Thu ngân nhập thông tin khách hàng.
4. Thu ngân chọn bàn.
5. Thu ngân chọn món từ danh sách.
6. Thu ngân nhập số lượng cho từng món.
7. Hệ thống tự tính thành tiền từng dòng.
8. Hệ thống cộng tổng tạm tính.
9. Thu ngân chọn ưu đãi nếu có.
10. Hệ thống tính tổng cuối cùng.
11. Thu ngân xác nhận Thanh toán.
12. Hệ thống lưu hóa đơn + chi tiết hóa đơn.
13. Hệ thống cập nhật trạng thái bàn (nếu mô hình có quản lý bàn).
14. Hệ thống làm rỗng form để lập hóa đơn tiếp.

**Ngoại lệ**:
- Chưa chọn bàn.
- Chưa chọn món.
- Số lượng <= 0.
- Món trùng trong cùng hóa đơn.
- Thanh toán khi hóa đơn chưa có dòng chi tiết.

#### Nghiệp vụ 2: Thêm món vào hóa đơn
**Mục đích**: bổ sung món khách vừa gọi.

**Luồng chính**:
1. Thu ngân chọn món.
2. Nhập số lượng.
3. Nhấn nút “Thêm món”.
4. Nếu món chưa tồn tại trong giỏ hóa đơn, hệ thống thêm dòng mới.
5. Nếu món đã tồn tại, hệ thống tăng số lượng.
6. Hệ thống cập nhật tổng tiền ngay trên giao diện.

**Quy tắc**:
- Không cho phép số lượng âm hoặc bằng 0.
- Đơn giá lấy từ bảng món, không nhập tay ở bản cơ bản.

#### Nghiệp vụ 3: Sửa / xóa món trong hóa đơn tạm
**Mục đích**: xử lý khi khách đổi món.

**Luồng chính**:
1. Thu ngân chọn dòng chi tiết món.
2. Chọn “Sửa số lượng” hoặc “Xóa món”.
3. Hệ thống cập nhật lại tổng tiền.

**Quy tắc**:
- Nếu số lượng về 0 thì xóa dòng.
- Không sửa trực tiếp hóa đơn đã thanh toán trong bản cơ bản.

#### Nghiệp vụ 4: Áp dụng ưu đãi
**Mục đích**: giảm giá hợp lệ cho khách.

**Bản cơ bản**:
- CheckBox “Khách là sinh viên” → giảm 20% tổng tiền.

**Quy tắc**:
- Chỉ áp dụng 1 loại giảm giá trong bản cơ bản.
- Tiền giảm = Tổng tạm tính × Tỷ lệ giảm.
- Thành tiền = Tổng tạm tính − Tiền giảm.

#### Nghiệp vụ 5: Thanh toán hóa đơn
**Mục đích**: chốt đơn và lưu dữ liệu chính thức.

**Luồng chính**:
1. Thu ngân kiểm tra lại thông tin hóa đơn.
2. Nhấn “Thanh toán”.
3. Hệ thống xác nhận người dùng.
4. Hệ thống lưu bảng HoaDon.
5. Hệ thống lưu bảng ChiTietHoaDon.
6. Hệ thống thông báo thành công.
7. Hệ thống cho phép in hóa đơn.

**Quy tắc**:
- Chỉ thanh toán khi hóa đơn có ít nhất 1 món.
- Không cho sửa giỏ hàng sau khi hóa đơn đã thanh toán, trừ khi có chức năng hủy hóa đơn nâng cao.

#### Nghiệp vụ 6: Xem danh sách hóa đơn
**Mục đích**: theo dõi các hóa đơn đã thanh toán.

**Luồng chính**:
1. Thu ngân mở màn hình Danh sách hóa đơn.
2. Hệ thống tải toàn bộ hóa đơn.
3. Thu ngân có thể lọc theo ngày, mã hóa đơn, tên khách, bàn.
4. Thu ngân chọn một hóa đơn để xem chi tiết.

#### Nghiệp vụ 7: Thống kê cơ bản
**Mục đích**: phục vụ báo cáo nhanh trong buổi demo.

**Chỉ tiêu nên có**:
- Số lượng hóa đơn trong ngày.
- Tổng doanh thu trong ngày.
- Hóa đơn có giá trị cao nhất.
- Món bán nhiều nhất (nâng cao vừa phải).

---

## 4) Quy tắc nghiệp vụ nên chốt ngay từ đầu

1. Một hóa đơn thuộc về **1 bàn**.
2. Một hóa đơn có **nhiều chi tiết hóa đơn**.
3. Một chi tiết hóa đơn tương ứng với **1 món**.
4. Một món có đơn giá cố định trong bản cơ bản.
5. Tổng tiền hóa đơn = tổng các dòng chi tiết.
6. Tiền giảm giá chỉ tính sau khi đã cộng tổng tạm tính.
7. Trạng thái bàn trong bản đơn giản có thể là:
   - Trống
   - Đang phục vụ
   - Đã thanh toán
8. Sau khi thanh toán thành công:
   - hóa đơn chuyển trạng thái “Đã thanh toán”
   - bàn có thể trả về “Trống” nếu mô hình phục vụ theo lượt
9. Không cho xóa hóa đơn đã thanh toán trong bản cơ bản.
10. Toàn bộ dữ liệu nhập phải được kiểm tra trước khi lưu.

---

## 5) Điểm rất quan trọng để làm đúng đồ án môn học

### 5.1. Kiến trúc nên dùng
Dùng đúng kiến trúc:
- **Model**: Entity / DTO / lớp dữ liệu.
- **View**: Window, UserControl, XAML.
- **ViewModel**: binding, command, xử lý logic nghiệp vụ.

### 5.2. Phân tách module giao diện
Nên chia thành:
- `MainWindow.xaml`: khung chính, menu điều hướng.
- `Views/LapHoaDonView.xaml`
- `Views/DanhSachHoaDonView.xaml`
- `Views/ThongKeDoanhThuView.xaml`
- `Views/InHoaDonView.xaml` hoặc `Report` riêng.

### 5.3. Tách mức độ theo đúng chương trình học
- **Mức 1**: WPF thuần + code-behind vừa phải để dựng giao diện và chạy demo nhanh.
- **Mức 2**: WPF + MVVM chuẩn hơn.
- **Mức 3**: WPF + MVVM + EF Database First + Validation + LINQ + Crystal Report.

=> Nếu mục tiêu là **đồ án đẹp, dễ bảo vệ và sát môn học**, hãy chọn **Mức 3**, nhưng khi code phải triển khai theo thứ tự từ Mức 1 lên Mức 3, không nhảy thẳng vào phần khó.

---

## 6) Đề xuất CSDL tối thiểu cho phạm vi thu ngân

### 6.1. Bảng BAN
- MaBan (PK)
- TenBan
- TrangThai

### 6.2. Bảng MON
- MaMon (PK)
- TenMon
- LoaiMon
- DonGia
- ConBan

### 6.3. Bảng KHACHHANG
- MaKH (PK)
- TenKH
- SoDienThoai
- LaSinhVien

### 6.4. Bảng HOADON
- MaHD (PK)
- NgayLap
- MaBan (FK)
- MaKH (FK, có thể null nếu bản đơn giản)
- TongTien
- GiamGia
- ThanhTien
- TrangThaiThanhToan

### 6.5. Bảng CHITIETHOADON
- MaHD (FK)
- MaMon (FK)
- SoLuong
- DonGia
- ThanhTien

### 6.6. Nếu muốn đúng kiểu chấm đồ án hơn
Có thể thêm:
- NHANVIEN (chỉ để lưu người lập hóa đơn)
- CA_LAM hoặc NgayBan để thống kê theo ca

---

## 7) Giao diện cần làm cho riêng thu ngân

## 7.1. MainWindow
Chỉ cần menu trái hoặc menu trên gồm:
- Lập hóa đơn
- Danh sách hóa đơn
- Thống kê
- In báo cáo
- Thoát

## 7.2. Màn hình Lập hóa đơn
### Khu trái: thông tin đơn hàng
- TextBox tên khách
- TextBox số điện thoại
- CheckBox khách là sinh viên
- ComboBox hoặc nhóm nút chọn bàn
- ComboBox chọn món
- TextBox số lượng
- Button Thêm món

### Khu phải: giỏ hàng / chi tiết hóa đơn
- DataGrid chi tiết hóa đơn
  - STT
  - Tên món
  - Đơn giá
  - Số lượng
  - Thành tiền
- Button Xóa món
- Button Cập nhật số lượng

### Khu cuối form
- TextBlock/TextBox Tổng tạm tính
- TextBlock/TextBox Giảm giá
- TextBlock/TextBox Thành tiền
- Button Làm mới
- Button Thanh toán
- Button In hóa đơn

## 7.3. Màn hình Danh sách hóa đơn
- DatePicker từ ngày / đến ngày
- TextBox tìm mã hóa đơn
- TextBox tìm tên khách
- ComboBox lọc theo bàn
- Button Tìm kiếm
- DataGrid danh sách hóa đơn
- Khu xem chi tiết hóa đơn đã chọn

## 7.4. Màn hình Thống kê
- Tổng số hóa đơn hôm nay
- Tổng doanh thu hôm nay
- Món bán chạy
- DataGrid top hóa đơn
- Button Xuất / In báo cáo

---

## 8) Mapping nghiệp vụ sang chức năng phần mềm

| Nghiệp vụ thu ngân | Chức năng hệ thống | Màn hình | Mức độ |
|---|---|---|---|
| Nhận order | Tạo hóa đơn tạm | Lập hóa đơn | Bắt buộc |
| Chọn món | Thêm chi tiết hóa đơn | Lập hóa đơn | Bắt buộc |
| Tính tiền | Tính tổng tự động | Lập hóa đơn | Bắt buộc |
| Áp dụng giảm giá | Check sinh viên / phần trăm giảm | Lập hóa đơn | Bắt buộc |
| Chốt đơn | Thanh toán + lưu DB | Lập hóa đơn | Bắt buộc |
| Tra cứu | Tìm kiếm hóa đơn | Danh sách hóa đơn | Nên có |
| Theo dõi doanh thu | Thống kê | Thống kê | Nên có |
| In chứng từ | Crystal Report | Báo cáo | Nâng cao hợp lý |

---

## 9) Kế hoạch triển khai rõ ràng theo từng giai đoạn

## Giai đoạn 1 — Chốt đề tài và phạm vi
Mục tiêu:
- Chỉ làm thu ngân.
- Chốt actor, use case, quy tắc nghiệp vụ.
- Chốt dữ liệu cần lưu.

Sản phẩm đầu ra:
- Danh sách chức năng.
- Sơ đồ quan hệ bảng.
- Danh sách màn hình.

## Giai đoạn 2 — Thiết kế CSDL
Mục tiêu:
- Tạo database SQL Server.
- Tạo bảng Ban, Mon, KhachHang, HoaDon, ChiTietHoaDon.
- Thêm dữ liệu mẫu.

Sản phẩm đầu ra:
- Script SQL tạo CSDL.
- Script insert data mẫu.

## Giai đoạn 3 — Dựng giao diện WPF cơ bản
Mục tiêu:
- Tạo MainWindow.
- Tạo UserControl cho từng chức năng.
- Dùng Grid, StackPanel, Border, DataGrid, ComboBox, Button đúng bài học.

Sản phẩm đầu ra:
- Khung chương trình chạy được.
- Có thể điều hướng giữa các UserControl.

## Giai đoạn 4 — Áp dụng MVVM
Mục tiêu:
- Tạo ViewModel cho từng màn hình.
- Tạo BaseViewModel với INotifyPropertyChanged.
- Binding dữ liệu giao diện.

Sản phẩm đầu ra:
- Không xử lý dồn hết vào code-behind.
- Dữ liệu thay đổi thì UI cập nhật đúng.

## Giai đoạn 5 — Kết nối CSDL bằng EF Database First
Mục tiêu:
- Sinh model từ database.
- Kết nối App.config.
- Đọc dữ liệu bàn, món, hóa đơn.

Sản phẩm đầu ra:
- Tải được danh sách bàn và món lên UI.

## Giai đoạn 6 — Cài đặt nghiệp vụ lập hóa đơn
Mục tiêu:
- Thêm món vào giỏ.
- Xóa / sửa món.
- Tính tổng.
- Giảm giá sinh viên.
- Thanh toán.

Sản phẩm đầu ra:
- Demo quy trình thu ngân từ đầu đến cuối.

## Giai đoạn 7 — Validation
Mục tiêu:
- Kiểm tra dữ liệu nhập.
- Không cho lưu nếu sai.
- Hiển thị lỗi ngay trên giao diện.

Sản phẩm đầu ra:
- Form rõ ràng, ít lỗi runtime.

## Giai đoạn 8 — Danh sách hóa đơn + thống kê
Mục tiêu:
- Xem hóa đơn đã lưu.
- Tìm kiếm.
- Lọc theo ngày.
- Thống kê doanh thu.

Sản phẩm đầu ra:
- Có màn hình quản lý sau bán hàng.

## Giai đoạn 9 — Báo cáo / in hóa đơn
Mục tiêu:
- Dùng Crystal Report hoặc report đơn giản.
- Có thể in hóa đơn / báo cáo ngày.

Sản phẩm đầu ra:
- Điểm cộng bảo vệ đồ án.

---

## 10) Trình tự code nên đi đúng để không bị rối

1. Tạo CSDL trước.
2. Thêm dữ liệu mẫu trước.
3. Tạo project WPF.
4. Dựng khung MainWindow và UserControl.
5. Dựng giao diện Lập hóa đơn trước.
6. Tạo model / EF.
7. Load dữ liệu bàn và món.
8. Viết logic giỏ hàng trong ViewModel.
9. Viết chức năng Thanh toán.
10. Viết Danh sách hóa đơn.
11. Viết Thống kê.
12. Viết Validation.
13. Viết Report.
14. Tối ưu giao diện.
15. Chuẩn bị dữ liệu demo và kịch bản bảo vệ.

---

## 11) Chuẩn comment code bắt buộc
AI phải tuân thủ:

### 11.1. Với file C#
- Mỗi class phải có comment mô tả nhiệm vụ class.
- Mỗi property quan trọng phải có comment ngắn.
- Mỗi method phải có comment:
  - dùng để làm gì
  - input là gì
  - output là gì
- Với đoạn xử lý nghiệp vụ phải có comment từng khối logic.

**Ví dụ chuẩn**:
```csharp
// Phương thức dùng để tính tổng tiền tạm tính của hóa đơn hiện tại
// Duyệt toàn bộ danh sách chi tiết hóa đơn và cộng thành tiền từng dòng
private decimal CalculateSubTotal()
{
    decimal sum = 0;

    // Duyệt từng món trong giỏ hàng
    foreach (var item in OrderDetails)
    {
        // Cộng dồn thành tiền của từng dòng
        sum += item.LineTotal;
    }

    return sum;
}
```

### 11.2. Với file XAML
- Comment chia rõ từng khu vực giao diện:
  - thông tin khách
  - chọn bàn
  - chọn món
  - danh sách món
  - thanh toán

**Ví dụ chuẩn**:
```xml
<!-- Khu vực nhập thông tin khách hàng -->
<GroupBox Header="Thông tin khách hàng">
    ...
</GroupBox>

<!-- Khu vực chọn món và thêm vào hóa đơn -->
<GroupBox Header="Chọn món">
    ...
</GroupBox>
```

---

## 12) Prompt tổng cho AI để làm toàn bộ đồ án

Sao chép prompt sau khi muốn AI làm trọn gói:

```text
Bạn là trợ lý lập trình hỗ trợ sinh viên làm đồ án WPF quản lý quán cà phê.
Hãy chỉ tập trung vào vai trò NHÂN VIÊN THU NGÂN, không làm các nghiệp vụ khác như kho, quản trị, nhân sự.

Yêu cầu bắt buộc:
1. Phân tích nghiệp vụ thu ngân trước rồi mới code.
2. Bám sát nội dung môn học: WPF, XAML, UserControl, MVVM, Data Binding, Entity Framework Database First, CRUD, Validation, LINQ, Crystal Report.
3. Code viết theo từng bước, dễ hiểu như sinh viên giỏi.
4. Tất cả code C# và XAML phải có comment tiếng Việt rõ ràng.
5. Chia nhỏ thành từng phần: CSDL -> giao diện -> model -> viewmodel -> nghiệp vụ -> validation -> báo cáo.
6. Không nhảy bước, không viết dồn một cục.
7. Mỗi phần phải có:
   - mục tiêu
   - file cần tạo
   - code đầy đủ
   - giải thích logic
   - cách test
8. Nếu có phần nâng cao thì phải ghi rõ [NÂNG CAO].
9. Ưu tiên giao diện đẹp vừa phải, dễ chấm điểm, dễ bảo vệ.
10. Nếu có chỗ yêu cầu chưa rõ, hãy tự đưa ra giả định hợp lý và ghi rõ giả định đó.

Đầu tiên hãy làm cho tôi phần phân tích nghiệp vụ thu ngân, sơ đồ chức năng và thiết kế CSDL tối thiểu.
```

---

## 13) Prompt theo từng phần

## Prompt 1 — Phân tích nghiệp vụ
```text
Hãy phân tích nghiệp vụ của NHÂN VIÊN THU NGÂN trong đồ án WPF quản lý quán cà phê.
Chỉ tập trung vào thu ngân.
Tôi cần:
- actor
- mục tiêu nghiệp vụ
- luồng nghiệp vụ chính
- luồng ngoại lệ
- quy tắc nghiệp vụ
- danh sách chức năng bắt buộc / nên có / nâng cao
- mapping từ nghiệp vụ sang màn hình phần mềm
- các giả định hợp lý nếu đề bài chưa rõ
Viết rõ ràng, dễ hiểu như tài liệu phân tích đồ án.
```

## Prompt 2 — Thiết kế CSDL
```text
Dựa trên nghiệp vụ thu ngân của quán cà phê, hãy thiết kế cơ sở dữ liệu SQL Server cho bản đồ án sinh viên.
Yêu cầu:
- chỉ phục vụ thu ngân
- có các bảng tối thiểu hợp lý
- ghi rõ khóa chính, khóa ngoại
- ghi rõ quan hệ giữa các bảng
- giải thích vì sao cần từng bảng
- viết script SQL CREATE TABLE đầy đủ
- thêm INSERT dữ liệu mẫu để demo
- dữ liệu mẫu phải đủ cho ít nhất 10 hóa đơn demo
- tên bảng và cột đặt rõ ràng, thống nhất
- cuối cùng viết thêm 5 truy vấn kiểm tra dữ liệu
Comment SQL bằng tiếng Việt.
```

## Prompt 3 — Tạo cấu trúc project WPF
```text
Hãy tạo cấu trúc project WPF cho đồ án quản lý quán cà phê chỉ dành cho thu ngân.
Yêu cầu:
- dùng WPF .NET Framework
- tổ chức thư mục theo MVVM
- có Models, Views, ViewModels, Helpers, Resources, Reports
- giải thích vai trò từng thư mục
- liệt kê toàn bộ file cần tạo ở giai đoạn đầu
- viết mẫu MainWindow.xaml và sơ đồ điều hướng UserControl
- code phải có comment tiếng Việt
- giao diện đủ đơn giản để sinh viên học theo
```

## Prompt 4 — Dựng giao diện MainWindow
```text
Hãy viết code MainWindow.xaml cho đồ án WPF quản lý quán cà phê chỉ dành cho thu ngân.
Yêu cầu:
- bên trái là menu chức năng
- bên phải là vùng hiển thị UserControl
- menu gồm: Lập hóa đơn, Danh sách hóa đơn, Thống kê, Báo cáo, Thoát
- dùng Grid, Border, StackPanel, Button đúng tinh thần môn học
- giao diện sáng sủa, dễ nhìn
- code XAML phải comment rõ từng khu vực
- viết thêm MainWindow.xaml.cs hoặc ViewModel điều hướng theo cách phù hợp nhất cho sinh viên
```

## Prompt 5 — Giao diện Lập hóa đơn
```text
Hãy viết giao diện UserControl LapHoaDonView.xaml cho đồ án WPF quản lý quán cà phê, chỉ dành cho thu ngân.
Yêu cầu:
- khu thông tin khách hàng
- khu chọn bàn
- khu chọn món
- khu giỏ hàng bằng DataGrid
- khu tổng tiền / giảm giá / thành tiền
- các nút: Thêm món, Xóa món, Làm mới, Thanh toán, In hóa đơn
- binding sẵn tên thuộc tính ViewModel
- comment XAML rất rõ ràng
- không dùng control quá khó so với chương trình học
```

## Prompt 6 — ViewModel lập hóa đơn
```text
Hãy viết LapHoaDonViewModel.cs cho đồ án WPF quản lý quán cà phê theo MVVM.
Yêu cầu:
- load danh sách bàn và món từ Entity Framework
- cho phép thêm món vào giỏ hàng
- nếu món đã có trong giỏ thì cộng số lượng
- tính tổng tạm tính
- tính giảm giá sinh viên 20%
- tính thành tiền cuối cùng
- xóa món khỏi giỏ
- làm mới form
- thanh toán và lưu vào HoaDon + ChiTietHoaDon
- toàn bộ code phải comment tiếng Việt rõ ràng
- giải thích từng method
- viết theo kiểu sinh viên dễ hiểu, không quá phức tạp
```

## Prompt 7 — Validation
```text
Hãy bổ sung validation cho chức năng Lập hóa đơn trong WPF theo MVVM.
Yêu cầu:
- kiểm tra tên khách không rỗng
- số điện thoại không rỗng và đúng định dạng cơ bản
- bắt buộc chọn bàn
- phải có ít nhất 1 món trong giỏ hàng
- số lượng phải > 0
- hiển thị lỗi rõ ràng trên giao diện
- ưu tiên IDataErrorInfo hoặc ValidationRule đúng với môn học
- nút Thanh toán chỉ enabled khi dữ liệu hợp lệ
- code comment tiếng Việt kỹ lưỡng
```

## Prompt 8 — Danh sách hóa đơn
```text
Hãy viết màn hình DanhSachHoaDonView.xaml và DanhSachHoaDonViewModel.cs.
Yêu cầu:
- hiển thị DataGrid danh sách hóa đơn
- có tìm kiếm theo mã hóa đơn, tên khách, ngày lập
- khi chọn 1 hóa đơn thì hiển thị chi tiết bên dưới hoặc bên phải
- có tổng số hóa đơn và tổng doanh thu ở khu vực thống kê nhanh
- dùng Entity Framework + LINQ
- code comment tiếng Việt rõ ràng
- giải thích cách binding DataGrid và SelectedItem
```

## Prompt 9 — Thống kê doanh thu
```text
Hãy viết chức năng thống kê dành cho thu ngân trong đồ án WPF quản lý quán cà phê.
Yêu cầu:
- thống kê số hóa đơn theo ngày
- tổng doanh thu theo ngày
- món bán chạy
- top 5 hóa đơn giá trị cao
- dùng LINQ to Entities
- có thể dùng truy vấn async nếu phù hợp
- giao diện đơn giản, dễ chấm điểm
- code phải comment tiếng Việt từng bước
```

## Prompt 10 — Crystal Report
```text
Hãy hướng dẫn và viết phần tích hợp Crystal Report cho đồ án WPF quản lý quán cà phê chỉ ở phạm vi thu ngân.
Yêu cầu:
- tạo report hóa đơn bán hàng
- tạo report doanh thu theo ngày có tham số ngày
- chỉ rõ dữ liệu lấy từ bảng / view nào
- hướng dẫn tạo file .rpt
- hướng dẫn truyền tham số từ WPF vào report
- nếu cần, viết truy vấn SQL hoặc view hỗ trợ report
- comment rõ ràng từng bước vì đây là phần sinh viên dễ sai
```

## Prompt 11 — Chuẩn bị bảo vệ đồ án
```text
Hãy giúp tôi chuẩn bị phần demo và bảo vệ cho đồ án WPF quản lý quán cà phê chỉ dành cho thu ngân.
Tôi cần:
- kịch bản demo 5 phút
- thứ tự bấm các chức năng
- dữ liệu demo mẫu
- các câu hỏi giảng viên có thể hỏi
- câu trả lời ngắn gọn, đúng chuyên môn
- các điểm nhấn để ghi điểm như MVVM, Validation, EF, LINQ, Crystal Report
```

---

## 14) Gợi ý code base nên sinh ra
AI nên tạo lần lượt các file sau:

### Core / Base
- BaseViewModel.cs
- RelayCommand.cs

### Models / Entity / DTO
- Ban.cs
- Mon.cs
- KhachHang.cs
- HoaDon.cs
- ChiTietHoaDon.cs
- ChiTietHoaDonDisplayModel.cs (nếu cần để bind DataGrid đẹp hơn)

### Views
- MainWindow.xaml
- LapHoaDonView.xaml
- DanhSachHoaDonView.xaml
- ThongKeView.xaml
- BaoCaoView.xaml

### ViewModels
- MainViewModel.cs
- LapHoaDonViewModel.cs
- DanhSachHoaDonViewModel.cs
- ThongKeViewModel.cs
- BaoCaoViewModel.cs

### Database / EF
- QuanCafeEntities.edmx hoặc DbContext sinh từ Database First
- App.config connection string

### Report
- HoaDonReport.rpt
- DoanhThuNgayReport.rpt

---

## 15) Những lỗi sinh viên rất hay gặp và AI phải tránh

1. Nhét toàn bộ code vào `MainWindow.xaml.cs`.
2. Không tách `UserControl` cho từng chức năng.
3. Dùng `AutoGenerateColumns=True` trong DataGrid làm giao diện xấu.
4. Không validate dữ liệu trước khi lưu.
5. Không reset form sau thanh toán.
6. Không xử lý món trùng trong giỏ hàng.
7. Không tính lại tổng tiền sau khi xóa / sửa món.
8. Tên biến, tên control đặt lộn xộn.
9. Không comment code.
10. Giao diện đẹp nhưng nghiệp vụ sai.
11. Gọi DB trực tiếp từ code-behind quá nhiều.
12. Không chuẩn bị dữ liệu demo dẫn tới demo nghèo nàn.

---

## 16) Cách AI phải trả lời khi được yêu cầu code
Khi người dùng yêu cầu code, AI phải trả lời theo khuôn:

1. **Mục tiêu phần này**
2. **Các file sẽ tạo / sửa**
3. **Code hoàn chỉnh**
4. **Giải thích logic chính**
5. **Cách chạy thử**
6. **Các lỗi thường gặp**
7. **Phần nâng cao (nếu có)**

Không được chỉ đưa code rời rạc. Phải luôn đặt code vào đúng file.

---

## 17) Giả định hợp lý nên dùng nếu đề bài chưa rõ
Nếu đề bài mơ hồ, AI nên tự chốt như sau:
- Mỗi hóa đơn thuộc một lần phục vụ.
- Mỗi món có một đơn giá hiện hành.
- Giảm giá sinh viên = 20% tổng tạm tính.
- Không quản lý tồn kho trong phạm vi thu ngân.
- Trạng thái thanh toán chỉ gồm: Chưa thanh toán / Đã thanh toán.
- Danh sách bàn phục vụ cố định từ 4 đến 10 bàn tùy dữ liệu demo.
- Không cho sửa hóa đơn đã thanh toán trong bản cơ bản.

---

## 18) Định hướng nâng cao nhưng vẫn hợp lý
Chỉ thêm nếu còn thời gian:
- [NÂNG CAO] Tìm kiếm món theo tên.
- [NÂNG CAO] Lọc hóa đơn theo khoảng ngày.
- [NÂNG CAO] Thống kê món bán chạy bằng GroupBy.
- [NÂNG CAO] In hóa đơn có logo quán.
- [NÂNG CAO] Chế độ dark/light bằng ResourceDictionary.
- [NÂNG CAO] Truy vấn async để tránh treo UI.

Không thêm các tính năng quá xa bài học như websocket, microservice, REST API phức tạp.

---

## 19) Checklist hoàn thành đồ án thu ngân

### Phần phân tích
- [ ] Có actor, use case, quy tắc nghiệp vụ.
- [ ] Có phạm vi rõ ràng chỉ dành cho thu ngân.

### Phần CSDL
- [ ] Có script tạo bảng.
- [ ] Có khóa chính, khóa ngoại.
- [ ] Có dữ liệu mẫu.

### Phần WPF
- [ ] Có MainWindow.
- [ ] Có UserControl từng chức năng.
- [ ] Có DataGrid, ComboBox, Button, TextBox.

### Phần MVVM
- [ ] Có BaseViewModel.
- [ ] Có Binding.
- [ ] Có SelectedItem.
- [ ] Có Command hoặc xử lý rõ ràng.

### Phần nghiệp vụ
- [ ] Lập hóa đơn được.
- [ ] Thêm / xóa món được.
- [ ] Tính tiền đúng.
- [ ] Giảm giá đúng.
- [ ] Thanh toán lưu DB được.

### Phần kiểm tra dữ liệu
- [ ] Không cho lưu khi dữ liệu sai.
- [ ] Có thông báo lỗi rõ ràng.

### Phần thống kê / báo cáo
- [ ] Xem danh sách hóa đơn.
- [ ] Thống kê doanh thu cơ bản.
- [ ] Có in/xem report.

### Phần trình bày
- [ ] Code có comment.
- [ ] Tên file rõ ràng.
- [ ] Dữ liệu demo đẹp.
- [ ] Có kịch bản bảo vệ.

---

## 20) Kết luận định hướng
Đồ án này nếu chỉ làm đúng vai trò thu ngân thì hoàn toàn đủ sâu để đạt điểm tốt, vì riêng phần thu ngân đã bao trùm được:
- giao diện WPF thực tế,
- tổ chức UserControl,
- mô hình MVVM,
- binding dữ liệu,
- EF Database First,
- CRUD trên hóa đơn,
- validation theo nghiệp vụ,
- LINQ thống kê,
- Crystal Report.

Cách làm tốt nhất là: **làm chắc phần lập hóa đơn và thanh toán trước**, sau đó mới mở rộng sang danh sách hóa đơn, thống kê và báo cáo.
