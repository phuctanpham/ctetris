## Tasks:
[x] Task 1.1: viết v1 gameStory/app.cpp - tạo layout.h và file build trên macOS đảm bảo màn hình 9:16 trước khi viết code tiếp
    - Comment codeblock này trong gamestory/app.cpp là: gameconsole-tao-giao-dien-169-00
    - Đặt thứ tự codeblock này từ trên xuống ở vị trí đầu tiên sau các khai báo và cài đặt thư viện cần thiét
[x] Task 1.2: viết v1 gameStory/app.cpp - làm hiển thị logo UIT có hiệu ứng tự chọn hiển thị và âm thanh
    - Comment codeblock này trong gamestory/app.cpp là: gameconsole-logo-intro-01
    - Đặt thứ tự codeblock này từ trên xuống ở vị trí đầu tiên sau 00 và trước 02
[x] Task 1.3: viết v1 gameStory/app.cpp - tạo loading bar theo theo thời gian hiệu ứng của logo
    - Comment codeblock này trong gamestory/app.cpp là: gamestory-loading-bar-02
    - Đặt thứ tự codeblock này từ trên xuống ở vị trí đầu tiên sau 01 và trước 03
[ ] Task 2.1: viết v2 gameStory/app.cpp - tạo dialogue story đơn giản để giới thiệu game kèm nhạc nền phù hợp
[ ] Task 2.2:  viết v2 gameStory/app.cpp - nút skip để bỏ qua phần cốt truyện
[ ] Task 3.1: viết v3 gameStory/app.cpp - download âm thanh và các hình ảnh trong story mỗi lần khởi động qua API thay vì build trực tiếp vào .exe file
[ ] Task 3.2: viết v3 gameStory/app.cpp - thay tốc độ loading bar bằng tốc độ download và repeat hiệu ứng logo cho đến khi download xong hết
## Rules:
    - Chỉ có 1 file c++ (app/src/gameStory/app.cpp) duy nhất để viết.
    - Các *.h phải để trong thư mục include của ứng dụng (app/src/gameStory/include).
    - Cần tách 1 file layout.h (app/src/gameStory/include/layout.h) để đảm bảo ứng dụng chạy theo khung hình có tỷ lệ 9:16 trên windown.
    - Cần tạo thành công build file từ app.cpp để chạy trên macos cho.
    - Các file hình ảnh, âm thanh, phim ... phải để trong chính thư mục đang làm việc và đặt tên bắt đầu bằng tiền tố là tên thư mục. VD: cần thêm 1 file nhạc nền tên logo.mp4 cho gameCore thì phải để trong app/src/gameStory/gameStory_logo.mp4