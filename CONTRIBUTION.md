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