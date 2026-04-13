## ctetris
### Quy tắc đặt tên branch
 - Luôn có tiền tố phía trước là mã tên.
 - Về mã tên, ví dụ: Phạm Tấn Phúc, thì lấy tên (Phúc) và các ký tự trong phần còn lại từ trái qua phải, nên là phucpt.
 - Ở giữa tiền tố và hậu tố làm việc cần ký tự "/", ví dụ: phucpt/hau-to
 - Hậu tố không được bỏ dâu và cần dùng ký tự "-" thay vì khoảng trắng giữa 2 từ, ví dụ: phucpt/hau-to-can-lam-viec
 - Cách đặt tên hậu tố sao cho dễ hiểu mục đích làm việc, ví dụ: phucpt/sua-lai-logic-xoa-hang
### Quy tắc commit files
  - Luôn chạy lệnh `git pull origin main` mỗi khi có ý định commit hoặc bắt đầu làm việc.
  - không dùng lệnh, `git add .` hoặc `git add -a`.
  - Commit từng file và diễn giải mục đích thay đổi phải, ví dụ: sửa logic xoá hàng trong file app.cpp và row.h của gameCore thì sẽ có thể có trong tình huống bên dươi:
    - TH1:
      - Vị trí con trỏ trên terminal ở thư mục Desktop.
      - Giả sử dự án đã được git clone để ở màn hình (Desktop), thư mục dự án là ctetris
      - Giả sử ký tự "%" là con trỏ.
      - Cần di chuyển con trỏ tới vị trí `dự án ctetris` bằng lệnh `cd`
      - (Option) dùng lệnh `ls -a`kiểm tra tính tồn tại của thư mục ẩn `.git` nhằm đẳm bảo chạy được các lệnh `git`
      - Cần chạy lệnh `git add dir1/dir2/.../file_cần_commit`
      - Khi chạy lệnh `git commit` nhớ khi báo cờ (flag) `m` và viết ngắn gọn không bỏ dấu nội dung thay đổi file.
```
tên_user_laptop@tên_laptop Desktop % cd ctetris
tên_user_laptop@tên_laptop ctetris % ls -a
.vscode .git .gitignore app doc CONTRIBUTION.md README.md
tên_user_laptop@tên_laptop ctetris % git add app/src/gameCore/app.cpp
tên_user_laptop@tên_laptop ctetris % git commit -m "phucpt: sua lai logic xoa 1 hang và nhieu hang"
tên_user_laptop@tên_laptop ctetris % git add app/src/gameCore/include/row.h
tên_user_laptop@tên_laptop ctetris % git commit -m "phucpt: sua lai class cho logic xoa 1 hang và nhieu hang"
```
    - TH2:
      - Vị trí con trỏ trên terminal ở thư mục Desktop.
      - Giả sử dự án đã được git clone để ở màn hình (Desktop), thư mục dự án là ctetris
      - Giả sử ký tự "%" là con trỏ.
      - Giả sử thư mục đang làm việc là gameCore, nợi trực tiếp cófilx
      - Cần di chuyển con trỏ tới vị trí `thư mục đang làm việc trong dự án` ctetris bằng lệnh `cd`
      - Cần chạy lệnh `git add file_cần_commit`
      - Khi chạy lệnh `git commit` nhớ khi báo cờ (flag) `m` và viết ngắn gọn không bỏ dấu nội dung thay đổi file.
```
tên_user_laptop@tên_laptop Desktop % cd ctetris/app/src/gameCore
tên_user_laptop@tên_laptop ctetris % git add app.cpp
tên_user_laptop@tên_laptop ctetris % git commit -m "phucpt: sua lai logic xoa 1 hang và nhieu hang"
tên_user_laptop@tên_laptop ctetris % git add include/row.h
tên_user_laptop@tên_laptop ctetris % git commit -m "phucpt: sua lai class cho logic xoa 1 hang và nhieu hang"
```
### Quy tắc tạo PR
- Trừ main và nhánh theo tên người khác, mọi người đều tự do tạo và nhập.
- Các nhánh theo tên người khác, muốn tạo PR thì tự liên lạc với họ trao đổi xin phép lẫ nhau.
- Nhánh main phải báo trưởng nhóm để trưởng nhóm review.
- Gợi ý: có thể tạo 1 nhánh riếng cho chính mình để dễ quản lý. Ví dụ: tạo một nhánh mới tên "vint/gamecore" từ main, sau đó tạo tiếp 1 nhánh tên "vint/gamecore-sua-logic-tinh-diem" từ nhánh "vint/gamecore" để làm việc.

### Quy tắc làm việc trên trello
- Khuyến khích tự chia nhỏ thẻ tác vụ mình thêm
- Tự do sáng tạo thêm tác vụ phù hợp với tính năng mình làm, miễn sao hạn chế nhất thay đổi file người khác vì mất thời gian trao đổi thống nhất.
- Thẻ nào đang nên kéo vào cột `doing`
- Thẻ nào làm xong thì đánh dấu xanh và nên kéo qua cột Done (nếu không cần mọi người xem trước khi họp) hoặc các cột theo ngày họp (nếu cần mọi ngừoi đóng góp ý tưởng hoặc phụ sửa chữa)
