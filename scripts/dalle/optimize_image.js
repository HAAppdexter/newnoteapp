const sharp = require("sharp");
const fs = require("fs");
const path = require("path");

async function optimizeImage(inputPath, outputPath) {
  try {
    console.log("🔄 Đang tối ưu ảnh...");

    // Tạo thư mục output nếu chưa tồn tại
    const outputDir = path.dirname(outputPath);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // Tối ưu ảnh
    await sharp(inputPath)
      .resize(1024, 1024, {
        fit: "contain",
        background: { r: 255, g: 255, b: 255, alpha: 0 },
      })
      .png({
        quality: 90,
        compressionLevel: 9,
        palette: true,
      })
      .toFile(outputPath);

    console.log("✅ Đã tối ưu ảnh thành công!");
    console.log("📍 Ảnh được lưu tại:", outputPath);
  } catch (error) {
    console.error("❌ Lỗi khi tối ưu ảnh:", error.message);
    process.exit(1);
  }
}

// Xử lý tham số dòng lệnh
const args = process.argv.slice(2);
const inputIndex = args.indexOf("--input");
const outputIndex = args.indexOf("--output");

if (inputIndex === -1 || outputIndex === -1) {
  console.error("Vui lòng cung cấp đầy đủ tham số --input và --output");
  process.exit(1);
}

const inputPath = args[inputIndex + 1];
const outputPath = args[outputIndex + 1];

optimizeImage(inputPath, outputPath);
