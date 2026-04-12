<!-- phucpt: app/appTree.md -->
```text
app/
├── main.cpp                 # File build chương trình chính
└── src/
    ├── gameConsole/         # Module giao diện console
    │   ├── app.cpp          # Triển khai logic điều khiển console
    │   └── include/         # Header công khai của gameConsole
    ├── gameCore/            # Module logic lõi của trò chơi
    │   ├── app.cpp          # Triển khai logic lõi
    │   └── include/         # Header công khai của gameCore
    └── gameStory/           # Module nội dung và mạch truyện
        ├── app.cpp          # Triển khai phần nội dung truyện
        └── include/         # Header công khai của gameStory
```
