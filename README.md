
**Hướng Dẫn Build & Selft Test**

- **Mục tiêu:** Tài liệu này hướng dẫn lập trình cách sử dụng các script build và workflow CI có trong repo: `build.ps1`, `build.sh`, `.github/workflows/deploy-pages.yml` và `.github/workflows/test-build.yml`.

**Yêu cầu chung:**
- **Prereqs:**: Cài đặt `git`, `cmake` (>= `3.16`), `python`/`python3`, `curl`/`wget`, và toolchain phù hợp cho platform (ví dụ `emsdk` cho WASM). Các script có kiểm tra/khuyến nghị phiên bản và sẽ cố gắng dùng bản trong `app/libs/<OS>/downloads` nếu cần.
- **Không sinh tệp nguồn:**: Một số header (ví dụ `*_svg.h`, `*_layout.h`) **phải** được commit sẵn trong repo; script KHÔNG tạo các file này từ nội dung nhúng.
- **Cache downloads:**: Heavy downloads và clones được lưu ở `app/libs/<OS>/downloads` để giúp CI cache; nếu bạn muốn làm sạch, xóa thư mục đó.

**Cài đặt nhanh theo nền tảng**

Dưới đây là các lệnh cài nhanh các công cụ cần thiết theo từng nền tảng và cách cài Homebrew / Chocolatey nếu máy chưa có.

- macOS (Homebrew)

	- Cài Homebrew (nếu chưa có):

		```bash
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		```

	- Cài các package cần thiết:

		```bash
		brew update
		brew install git cmake python curl wget
		```

	- Kiểm tra phiên bản:

		```bash
		git --version
		cmake --version
		python3 --version || python --version
		curl --version
		wget --version
		```

- Ubuntu (apt) — cách nhanh + cách dùng Kitware để có CMake >= 3.16 nếu cần

	- Cài nhanh bằng apt (phiên bản cmake trong repo Ubuntu có thể cũ):

		```bash
		sudo apt-get update
		sudo apt-get install -y git cmake python3 curl wget build-essential
		```

	- Nếu `cmake --version` < 3.16, dùng Kitware APT repo để lấy CMake mới hơn:

		```bash
		sudo apt-get update
		sudo apt-get install -y apt-transport-https ca-certificates gnupg software-properties-common wget
		wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | sudo apt-key add -
		sudo apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
		sudo apt-get update
		sudo apt-get install -y cmake
		```

	- Kiểm tra phiên bản:

		```bash
		git --version
		cmake --version
		python3 --version
		curl --version
		wget --version
		```

- Windows (Chocolatey)

	- Cài Chocolatey (chạy PowerShell với quyền Administrator):

		```powershell
		Set-ExecutionPolicy Bypass -Scope Process -Force; \
			[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
			iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
		```

	- Cài các package (PowerShell, Administrator):

		```powershell
		choco install -y git cmake python curl wget
		```

	- Kiểm tra phiên bản (PowerShell):

		```powershell
		git --version
		cmake --version
		python --version
		curl --version
		wget --version
		```

Ghi chú chung:
- Trên macOS `python3` thường là tên thực thi; trên Windows `python` do Chocolatey cài sẽ cung cấp Python.
- Nếu cài `cmake` mà vẫn thấp hơn `3.16`, dùng các nguồn chính thức (Kitware) hoặc tải installer phù hợp từ https://cmake.org/download/.
- Sau khi cài xong, chạy các lệnh kiểm tra phiên bản để đảm bảo môi trường đáp ứng yêu cầu của build script.

**1) `build.ps1` (Windows, PowerShell)**
- **Mục đích:**: Script PowerShell để build native và WASM trên Windows (dành cho lập trình viên sử dụng hệ điều hành windows). 
- **Chạy:**: Mở PowerShell (thường `pwsh`) rồi vào thư mục `app`:
	- `cd app`  
	- `.\build.ps1 native`  (build binary native cho Windows)
	- `.\build.ps1 wasm`    (build artifact WASM)
	- `.\build.ps1 all`     (build cả native + wasm)
- **Quyền & ExecutionPolicy:**: Nếu bị chặn bởi execution policy, chạy trong session tạm thời: `pwsh -ExecutionPolicy Bypass -File .\\build.ps1 wasm`.
- **Những gì script làm:**: Kiểm tra công cụ cần thiết, tìm/clone `emsdk` nếu cần, build SDL3 (nếu không có sẵn) vào `app/libs/windows/downloads/...`, cài đặt nanosvg nếu vắng, và tạo artifact tại `app/build/desktop/windows/` và `app/build/wasm/windows/`.
- **Logs:**: Script xuất log; CI lưu `build-native.log` và `build-wasm.log` nếu chạy trong workflow.

**2) `build.sh` (macOS / Linux, Bash)**
- **Mục đích:**: Script Bash cross-platform cho macOS và Linux để build native và WASM (dành cho lập trình viên sử dụng hệ điều hành macOS/Ubuntu).
- **Chạy:**: Từ thư mục `app`:
	- `./build.sh native`  
	- `./build.sh wasm`    
	- `./build.sh all`     
- **Detect OS:**: Script tự detect OS và dùng `app/libs/<OS>/downloads` làm cache cho heavy downloads (emsdk, SDL3 source, nanosvg...).
- **Những gì script làm:**: Tương tự `build.ps1` nhưng theo phong cách POSIX: kiểm tra/activate `emsdk` (ưu tiên `em++` trên PATH, `~/emsdk`, rồi `app/libs/.../emsdk`), build SDL3 từ source nếu cần, đặt artifact vào `app/build/desktop/<OS>/` và `app/build/wasm/<OS>/`.
- **Chạy nhanh local (WASM):**: Sau khi `./build.sh wasm` thành công, mở `app/build/wasm/<OS>/cTetris.html` (hoặc serve folder bằng `python -m http.server` từ folder chứa file HTML).

**3) Workflow `deploy-pages.yml` (GitHub Actions) — Deploy WASM lên Pages**
- **Khi chạy:**: Kích hoạt khi push lên `main` và khi có thay đổi trong `app/src`, `app/web`, `app/CMakeLists.txt`, v.v.
- **Job chính:**: `build` trên `ubuntu-latest`:
	- Checkout code
	- Cache heavy downloads: `app/libs/ubuntu/downloads`
	- Chạy `app/build.sh wasm` (working-dir `app`)
	- Stage artifact vào `public/` (copy `cTetris.html`, `cTetris.js`, `cTetris.wasm`, cùng PWA assets)
	- Upload artifact và deploy Pages (bước tiếp theo `actions/deploy-pages@v4`).
- **Lưu ý:**: Nếu PWA assets (ví dụ `favicon.svg`, `manifest.webmanifest`, `sw.js`) không có trong đầu ra build, workflow sẽ log cảnh báo; đảm bảo `app/web/` và `app/brandkit/` có các file cần thiết committed.

**Kết quả khi Pages deploy thành công**
- **Tệp được deploy:** workflow deploy sẽ publish toàn bộ nội dung thư mục `public/` — thường bao gồm:
	- `index.html` (workflow copy `cTetris.html` → `index.html`)
	- `cTetris.js`, `cTetris.wasm`
	- PWA assets: `favicon.svg`/`favicon.ico`, `manifest.webmanifest`, `sw.js` (nếu có)
- **URL truy cập:** sau khi job `deploy` chạy thành công, trang sẽ được phục vụ trên GitHub Pages của repository. Bạn có thể tìm URL bằng các cách sau:
	- Vào tab **Actions** → chọn run tương ứng → mở job `deploy` → xem bước `Deploy` (id `deployment`) — logs hoặc outputs thường chứa `page_url`.
	- Hoặc vào **Settings → Pages** của repository để thấy URL trang đã publish.
- **Kiểm tra nhanh sau deploy:** mở URL Pages, kiểm tra Developer Tools (console/network) để xác nhận `cTetris.wasm` được tải thành công và service worker (nếu có) hoạt động; kiểm tra lỗi 404 cho các asset.

- **Trang Pages chính thức của dự án:** https://phuctanpham.github.io/ctetris

**Kiểm tra GitHub Actions (self-test) — xem job build có thành công không**
- **Mở Actions UI:** truy cập `https://github.com/<owner>/<repo>/actions` hoặc bấm tab **Actions** trong repo.
- **Chọn workflow tương ứng:** ví dụ `Test Build (cross-platform)` để xem ma trận build hoặc `Deploy WASM to GitHub Pages` để xem quá trình deploy.
- **Quan sát trạng thái job:**
	- Mỗi job (matrix) sẽ hiển thị trạng thái: success (xanh), failed (đỏ) hoặc cancelled.
	- Nhấp vào một job để xem log chi tiết từng bước.
- **Tải logs / artifacts:** nếu job upload artifacts (ví dụ `build-native.log`, `build-wasm.log`), bạn có thể tải từ phần `Artifacts` trên trang run để debug.
- **Chạy lại / debug:** sử dụng nút `Re-run jobs` (trên trang run) để chạy lại toàn bộ workflow hoặc job cụ thể.


**4) Workflow `test-build.yml` (GitHub Actions) — Kiểm thử build cross-platform**
- **Mục đích:**: Kiểm tra build native + wasm trên ma trận runner (Windows, Ubuntu, macOS) để phát hiện lỗi sớm.
- **Chi tiết:**
	- Matrix gồm 3 môi trường: `windows-latest` (chạy `app/build.ps1`), `ubuntu-latest` (chạy `app/build.sh`), `macos-latest` (chạy `app/build.sh`).
	- Mỗi job: cache `app/libs/<OS>/downloads`, build native rồi build wasm, lưu logs `build-native.log` và `build-wasm.log` (được upload khi thất bại).
- **Lưu ý cho contributor:**: Nếu bạn thay đổi logic build, cập nhật key cache (workflow hash) hoặc paths tương ứng để CI cache đúng.

**Mẹo debug & khắc phục (Troubleshooting)**
- **Xem log chi tiết:**: Nếu build lỗi trong CI, tải `build-native.log` hoặc `build-wasm.log` từ artifact để xem chi tiết.
- **emsdk không tìm thấy:**: Kiểm tra xem `em++` đã có trên PATH hoặc cài `emsdk` theo hướng dẫn của Emscripten; script sẽ cố gắng clone và activate `emsdk` trong `app/libs/<OS>/downloads/emsdk` nếu cần.
- **SDL3:**: Script có thể build SDL3 từ source nếu hệ thống không có SDL3 phù hợp; điều này tốn thời gian lần đầu nhưng được cached ở `app/libs/<OS>/downloads`.
- **Thiếu file nguồn bắt buộc:**: Nếu script báo các file bắt buộc thiếu, kiểm tra `validate_sources()` trong `build.sh` hoặc `Test-Sources` trong `build.ps1` để biết danh sách file cần commit.

**Các lệnh thường dùng (tóm tắt)**
- Build native local (macOS/Linux): `cd app && ./build.sh native`
- Build wasm local (macOS/Linux): `cd app && ./build.sh wasm`
- Build native Windows (PowerShell): `cd app; .\\build.ps1 native` (dùng `pwsh`)
- Build wasm Windows (PowerShell): `cd app; .\\build.ps1 wasm`
- Serve artifact WASM nhanh: `cd app/build/wasm/<OS> && python3 -m http.server 8000` → mở `http://localhost:8000/cTetris.html`.

**Muốn làm sạch cache / downloads?**
- Xóa `app/libs/<OS>/downloads` để buộc script clone/tải lại dependencies.

**Muốn CI tương tự local?**
- Chạy tương đương local theo runner bạn muốn kiểm thử (ví dụ dùng Ubuntu container hoặc Windows VM), và đảm bảo export `$HOME/emsdk` hoặc để script clone `emsdk` vào `app/libs/<OS>/downloads`.

Nếu bạn muốn tôi bổ sung mục cụ thể (ví dụ danh sách đầy đủ các file kiểm tra của `validate_sources()` hoặc hướng dẫn cài riêng từng package manager), cho tôi biết file hoặc phần bạn muốn mở rộng.

***Hết***
