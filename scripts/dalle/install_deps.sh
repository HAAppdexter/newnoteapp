#!/bin/bash

# Script để cài đặt các dependencies cho DALL-E scripts

# Kiểm tra Node.js đã được cài đặt
if ! command -v node &> /dev/null; then
    echo "Node.js chưa được cài đặt. Vui lòng cài đặt Node.js trước khi tiếp tục."
    exit 1
fi

# Kiểm tra thư mục hiện tại
if [ ! -f "package.json" ]; then
    echo "Vui lòng chạy script này trong thư mục scripts/dalle"
    exit 1
fi

echo "🚀 Bắt đầu cài đặt dependencies..."

# Cài đặt các npm packages
echo "📦 Cài đặt npm packages..."
npm install

# Kiểm tra potrace cho vectorize tool
if ! command -v potrace &> /dev/null; then
    echo "⚠️ Potrace không được tìm thấy, bạn cần cài đặt để sử dụng tính năng vectorize."
    
    # Kiểm tra hệ điều hành
    OS=$(uname -s)
    
    if [ "$OS" = "Darwin" ]; then
        echo "🍎 Phát hiện macOS. Bạn có muốn cài đặt potrace qua Homebrew? (y/n)"
        read -r install_brew
        
        if [ "$install_brew" = "y" ] || [ "$install_brew" = "Y" ]; then
            if command -v brew &> /dev/null; then
                echo "🍺 Cài đặt potrace thông qua Homebrew..."
                brew install potrace
            else
                echo "❌ Homebrew không được cài đặt. Vui lòng cài đặt Homebrew trước:"
                echo "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            fi
        else
            echo "Bạn có thể cài đặt potrace sau bằng cách sử dụng:"
            echo "brew install potrace"
        fi
    elif [ "$OS" = "Linux" ]; then
        echo "🐧 Phát hiện Linux. Bạn có thể cài đặt potrace bằng lệnh:"
        echo "sudo apt-get install potrace   # Cho Ubuntu/Debian"
        echo "sudo yum install potrace       # Cho CentOS/RHEL"
    else
        echo "🪟 Trên Windows, bạn có thể cài đặt potrace qua: https://potrace.sourceforge.net/"
    fi
else
    echo "✅ Potrace đã được cài đặt."
fi

# Kiểm tra API key
echo "🔑 Kiểm tra DALL-E API key..."
ENV_FILE="../../.env"

if [ -f "$ENV_FILE" ]; then
    if grep -q "DALL-E_API_KEY" "$ENV_FILE"; then
        echo "✅ DALL-E_API_KEY đã được cấu hình trong .env"
    else
        echo "⚠️ Không tìm thấy DALL-E_API_KEY trong file .env"
        echo "Bạn cần thêm dòng sau vào file .env:"
        echo "DALL-E_API_KEY=your_api_key_here"
    fi
else
    echo "⚠️ Không tìm thấy file .env trong thư mục gốc"
    echo "Bạn cần tạo file .env trong thư mục gốc với nội dung:"
    echo "DALL-E_API_KEY=your_api_key_here"
fi

echo "✨ Cài đặt hoàn tất!"
echo "Để tạo ảnh, bạn có thể sử dụng lệnh:"
echo "node generate_image.js -p \"Your prompt here\" -o output.png"