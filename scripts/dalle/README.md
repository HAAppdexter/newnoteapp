# DALL-E Image Scripts

Bộ công cụ dòng lệnh để tạo và xử lý ảnh sử dụng DALL-E API và các công cụ khác.

## ⚠️ Cảnh Báo Chi Phí ⚠️

Sử dụng DALL-E API có chi phí:

- **DALL-E 3**: ~0,08$ mỗi ảnh (1024x1024 pixels)
- **DALL-E 2**: ~0,02$ mỗi ảnh

Xin lưu ý cân nhắc trước khi tạo ảnh và chỉ tạo khi thực sự cần thiết.

## Cài đặt

```bash
cd scripts/dalle
npm install
```

Để sử dụng tính năng chuyển đổi ảnh sang vector, cần cài đặt thêm:

```bash
npm install -g potrace
# hoặc
brew install potrace
```

## Cấu hình

Đảm bảo bạn đã có file `.env` ở thư mục gốc dự án với API key của DALL-E:

```
DALL-E_API_KEY=your_api_key_here
```

## Các scripts có sẵn

### 1. Tạo ảnh từ prompt

Tạo ảnh sử dụng DALL-E 3 dựa trên mô tả văn bản.

```bash
node scripts/dalle/generate_image.js --prompt "Mô tả ảnh bạn muốn tạo" --output "output.png"
```

#### Tham số

- `--prompt, -p`: (Bắt buộc) Mô tả ảnh bạn muốn tạo
- `--output, -o`: Đường dẫn file output (mặc định: ./output.png)
- `--style, -s`: Phong cách ảnh (natural, vivid, vector, icon, app-icon, ui-icons) (mặc định: natural)
- `--vector, -v`: Tối ưu prompt để tạo ảnh phong cách vector/illustration
- `--icon, -i`: Tối ưu prompt để tạo icon đơn giản
- `--app-icon, -a`: Tối ưu prompt để tạo app icon
- `--ui-icons, -u`: Tối ưu prompt để tạo UI icon set
- `--yes, -y`: Bỏ qua cảnh báo chi phí
- `--quality, -q`: Chất lượng ảnh (standard, hd) (mặc định: standard)
- `--model, -m`: Model DALL-E (dall-e-3, dall-e-2) (mặc định: dall-e-3)

#### Ví dụ

```bash
# Tạo ảnh thông thường
node scripts/dalle/generate_image.js -p "A colorful sunset over mountains" -o "sunset.png"

# Tạo icon vector
node scripts/dalle/generate_image.js -p "Email icon" -i -o "email-icon.png"

# Tạo app icon
node scripts/dalle/generate_image.js -p "Weather app" -a -o "weather-app-icon.png"
```

### 2. Phân tích ảnh và tạo prompt

Phân tích ảnh có sẵn và tạo prompt mô tả để có thể tạo ảnh tương tự.

```bash
node scripts/dalle/analyze_image.js --input "input.jpg" --output "prompt.txt"
```

#### Tham số

- `--input, -i`: (Bắt buộc) Đường dẫn đến ảnh cần phân tích
- `--output, -o`: File để lưu prompt (mặc định: hiển thị trong console)
- `--vector, -v`: Tối ưu prompt cho ảnh vector/icon
- `--detail, -d`: Mức độ chi tiết (low, medium, high) (mặc định: medium)

#### Ví dụ

```bash
# Phân tích ảnh và hiển thị prompt
node scripts/dalle/analyze_image.js -i "photo.jpg"

# Phân tích và lưu prompt tối ưu cho vector
node scripts/dalle/analyze_image.js -i "logo.png" -v -o "logo-prompt.txt"
```

### 3. Chuyển đổi ảnh bitmap thành vector

Chuyển đổi ảnh bitmap (PNG, JPG, etc.) thành định dạng vector SVG.

```bash
node scripts/dalle/vectorize_image.js --input "input.png" --output "output.svg"
```

#### Tham số

- `--input, -i`: (Bắt buộc) Đường dẫn đến ảnh cần chuyển đổi
- `--output, -o`: Đường dẫn lưu file SVG output (mặc định: ./output.svg)
- `--mode, -m`: Chế độ chuyển đổi (auto, posterize, color, grayscale) (mặc định: auto)
- `--colors, -c`: Số lượng màu giữ lại (2-256) (mặc định: 16)
- `--simplify, -s`: Mức độ đơn giản hóa (0-100) (mặc định: 50)
- `--background, -b`: Giữ lại background
- `--optimize, -O`: Tối ưu file SVG sau khi chuyển đổi (mặc định: true)

#### Ví dụ

```bash
# Chuyển đổi ảnh cơ bản
node scripts/dalle/vectorize_image.js -i "photo.png" -o "vector.svg"

# Chuyển đổi với số màu giới hạn
node scripts/dalle/vectorize_image.js -i "logo.png" -o "logo.svg" -m posterize -c 5
```

## Quy trình làm việc đầy đủ

### Từ ảnh gốc đến vector tùy chỉnh

1. Phân tích ảnh gốc:

```bash
node scripts/dalle/analyze_image.js -i "original.jpg" -o "description.txt"
```

2. Chỉnh sửa file `description.txt` để tùy chỉnh mô tả

3. Tạo ảnh mới từ mô tả đã chỉnh sửa:

```bash
node scripts/dalle/generate_image.js -p "$(cat description.txt)" -o "generated.png"
```

4. Chuyển đổi ảnh thành vector:

```bash
node scripts/dalle/vectorize_image.js -i "generated.png" -o "final.svg" -c 8 -s 70
```

## Tối ưu Prompt

Để có kết quả tốt nhất, scripts hỗ trợ tối ưu prompt tự động cho các loại ảnh khác nhau:

### Vector/Illustration

```
node scripts/dalle/generate_image.js -p "Mountain landscape" -v -o "mountain-vector.png"
```

Tạo ra prompt tối ưu: "Create a minimalist vector illustration with simple clean lines, flat design style, using only essential shapes. The illustration should show: Mountain landscape. Make it suitable for SVG conversion, with clean outlines, limited color palette, and no gradients or complex details."

### Icon

```
node scripts/dalle/generate_image.js -p "Email" -i -o "email-icon.png"
```

Tạo ra prompt tối ưu: "Create a simple, minimalist icon representing Email. Use flat design with clean outlines, minimal details, solid colors, and simple shapes. The icon should be recognizable at small sizes and suitable for UI design. Avoid gradients, shadows, and complex details. Use a limited color palette with strong contrast."

### App Icon

```
node scripts/dalle/generate_image.js -p "Weather app" -a -o "weather-icon.png"
```

Tạo ra prompt tối ưu: "Design a modern app icon for Weather app, using a simple and recognizable symbol. The icon should follow material design or iOS guidelines with a limited color palette (2-3 colors maximum). Create clean shapes with strong silhouettes that remain recognizable at small sizes. Avoid text, intricate details, and overly complex imagery."

### UI Icon Set

```
node scripts/dalle/generate_image.js -p "Email, Calendar, Settings" -u -o "ui-icons.png"
```

Tạo ra prompt tối ưu: "Create a consistent set of minimal UI icons for Email, Calendar, Settings. Icons should be simple, single-color (monochrome) line/solid style, uniform thickness, with clean geometric shapes. Design them to work well at small sizes (24x24px) with clear silhouettes. Ensure consistent style across all icons."

## Tiết Kiệm Chi Phí

Để tránh chi phí không cần thiết:

1. Sử dụng flag `-y` chỉ khi bạn chắc chắn về prompt và đã tối ưu nó kỹ lưỡng
2. Tối ưu prompt thật kỹ trước khi gửi request, sử dụng các flags tối ưu (-v, -i, -a, -u)
3. Bắt đầu với DALL-E 2 nếu bạn chỉ đang thử nghiệm (`-m dall-e-2`)
4. Lưu ý rằng khi tạo ảnh, script sẽ lưu prompt vào file .txt đi kèm để tiện tham khảo sau này

## Hỗ trợ và đóng góp

Nếu gặp vấn đề hoặc có ý tưởng cải thiện, vui lòng tạo issue hoặc pull request.
