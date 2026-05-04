## Với vai trờ lập trình viên
### Về mã nguồn:
    - Chọn 1 trong thư mục 3 ứng dụng bên dưới để viết mã nguồn.
        + app/src/gameConsole: Ứng dụng quản lý cấu hình trò chơi và hướng dẫn chơi
        + app/src/gameCore: Ứng dụng chính chứa logic trò chơi.
        + app/src/gameStory: Ứng dụng giới thiệu cốt truyện.
    - Chỉ có 1 file c++ (app/src/game*/app.cpp) duy nhất để viết.
    - Các *.h phải để trong thư mục include của ứng dụng (app/src/game*/include).
    - Cần tách 1 file layout.h (app/src/game*/include/layout.h) để đảm bảo ứng dụng chạy theo khung hình có tỷ lệ 9:16 trên windown.
    - Cần tạo thành công exe từ app.cpp để chạy trên windown cho ứng dụng mình phụ trách. 
    - Việc ghép 3 ứng dụng lại vào để tạo exe từ main.cpp để chạy trên windown sẽ do trưởng nhóm phụ trách. Mọi tác động vào main.cpp phải có sự đồng ý của trưởng nhóm.
    - Các file hình ảnh, âm thanh, phim ... phải để trong chính thư mục đang làm việc và đặt tên bắt đầu bằng tiền tố là tên thư mục. VD: cần thêm 1 file nhạc nền tên background.mp3 cho gameCore thì phải để trong app/src/gameCore/gameCore_background.mp3.
### Về báo cáo:
    - Chỉ cần quan tâm viết 3 file trong thư mục doc/src/content. Ba file đó sẽ có cấu trúc soThuTu-tenUngDung*.tex. VD: 3 files cần viết về gameCore sẽ có tên 4-gameCoreRequirements.tex, 7-gameCoreEngineering.tex, 10-gameCoreGuide.tex
    - Các hình ảnh minh hoạ cần để trong thư mục doc/assets và đặt tên bắt đầu bằng tiền tố là tên ứng dụng. VD: cần thêm 1 file hình ảnh minh hoạ cho gameCore thì phải để trong doc/assets/gameCore_*.svg hoặc doc/assets/gameCore_*.png.
    - Các file trong thư mục doc/src/libs chỉ là các khối dùng chung cho mọi tài liệu, không cần quan tâm đến việc viết mã nguồn cho các file này. Tuy nhiên, khi tương tác với các file mình viết (hoặc dùng AI viết),  không được can thiệp vào các khi báo trước dòng <beginDocument>. Lập trình viên chỉ nên viết ở giữa 2 dòng <beginDocument> và <endDocument> của file mình phụ trách.
## Với các vai trò khác:
### Về mã nguồn:
    - Không cần quan tâm đến việc viết mã nguồn.
    - Chỉ quan tâm các PR để được nhờ review mã nguồn của lập trình viên rồi kiểm thử tính năng của ứng dụng.
### Về báo cáo:
    - Chỉ cần quan tâm đến việc viết báo cáo được phân công cụ thể. 

## Các làm việc với github

### Quy tắc đặt tên branch
- Luôn có tiền tố phía trước là mã tên.
- Về mã tên, ví dụ: Phạm Tấn Phúc, thì lấy tên (Phúc) và các ký tự trong phần còn lại từ trái qua phải, nên là `phucpt`.
- Ở giữa tiền tố và hậu tố làm việc cần ký tự `/`, ví dụ: `phucpt/hau-to`
- Hậu tố không được để dấu và cần dùng ký tự `-` thay vì khoảng trắng giữa 2 từ, ví dụ: `phucpt/hau-to-can-lam-viec`
- Cách đặt tên hậu tố sao cho dễ hiểu mục đích làm việc, ví dụ: `phucpt/sua-lai-logic-xoa-hang`

### Quy tắc commit files
- Luôn chạy lệnh `git pull origin main` mỗi khi có ý định commit hoặc bắt đầu làm việc.
- Không dùng lệnh `git add .` hoặc `git add -A`.
- Commit từng file và diễn giải mục đích thay đổi, ví dụ: sửa logic xoá hàng trong file `app.cpp` và `row.h` của `gameCore` thì sẽ có thể có trong tình huống bên dưới:
    
    - **TH1:**
        - Vị trí con trỏ trên terminal ở thư mục `Desktop`.
        - Giả sử dự án đã được git clone để ở màn hình (`Desktop`), thư mục dự án là `ctetris`.
        - Giả sử ký tự `%` là con trỏ.
        - Cần di chuyển con trỏ tới vị trí dự án `ctetris` bằng lệnh `cd`.
        - (Option) Dùng lệnh `ls -a` kiểm tra tính tồn tại của thư mục ẩn `.git` nhằm đảm bảo chạy được các lệnh `git`.
        - Cần chạy lệnh `git add dir1/dir2/.../file_cần_commit`
        - Khi chạy lệnh `git commit`, nhớ khai báo cờ (flag) `-m` và viết ngắn gọn không bỏ dấu nội dung thay đổi file.
        
        ```bash
        macos@phucpt Desktop % cd ctetris
        macos@phucpt ctetris % ls -a
        .vscode .git .gitignore app doc CONTRIBUTION.md README.md
        macos@phucpt ctetris % git add app/src/gameCore/app.cpp
        macos@phucpt ctetris % git commit -m "phucpt: sua lai logic xoa 1 hang va nhieu hang"
        macos@phucpt ctetris % git add app/src/gameCore/include/row.h
        macos@phucpt ctetris % git commit -m "phucpt: sua lai class cho logic xoa 1 hang va nhieu hang"
        ```

    - **TH2:**
        - Vị trí con trỏ trên terminal ở thư mục `Desktop`.
        - Giả sử dự án đã được git clone để ở màn hình (`Desktop`), thư mục dự án là `ctetris`.
        - Giả sử ký tự `%` là con trỏ.
        - Giả sử thư mục đang làm việc là `gameCore`, nơi trực tiếp có file.
        - Cần di chuyển con trỏ tới vị trí thư mục đang làm việc trong dự án `ctetris` bằng lệnh `cd`.
        - Cần chạy lệnh `git add file_cần_commit`
        - Khi chạy lệnh `git commit`, nhớ khai báo cờ (flag) `-m` và viết ngắn gọn không bỏ dấu nội dung thay đổi file.

        ```bash
        macos@phucpt Desktop % cd ctetris/app/src/gameCore
        macos@phucpt gameCore % git add app.cpp
        macos@phucpt gameCore % git commit -m "phucpt: sua lai logic xoa 1 hang va nhieu hang"
        macos@phucpt gameCore % git add include/row.h
        macos@phucpt gameCore % git commit -m "phucpt: sua lai class cho logic xoa 1 hang va nhieu hang"
        ```

### Quy tắc tạo PR
- Trừ nhánh `main` và nhánh theo tên người khác, mọi người đều tự do tạo và nhập (merge).
- Các nhánh theo tên người khác, muốn tạo PR thì tự liên lạc với họ để trao đổi, xin phép lẫn nhau.
- Nhánh `main` phải báo trưởng nhóm để trưởng nhóm review.
- Gợi ý: Có thể tạo 1 nhánh riêng cho chính mình để dễ quản lý. Ví dụ: tạo một nhánh mới tên `vint/gamecore` từ `main`, sau đó tạo tiếp 1 nhánh tên `vint/gamecore-sua-logic-tinh-diem` từ nhánh `vint/gamecore` để làm việc.

### Quy tắc làm việc trên Trello
- Khuyến khích tự chia nhỏ thẻ tác vụ mình thêm.
- Tự do sáng tạo thêm tác vụ phù hợp với tính năng mình làm, miễn sao hạn chế nhất việc thay đổi file của người khác vì mất thời gian trao đổi thống nhất.
- Thẻ nào đang làm thì nên kéo vào cột `Doing`.
- Thẻ nào làm xong thì đánh dấu xanh và nên kéo qua cột `Done` (nếu không cần mọi người xem trước khi họp) hoặc các cột theo ngày họp (nếu cần mọi người đóng góp ý tưởng hoặc phụ sửa chữa).
