#!/usr/bin/env node

require("dotenv").config({ path: process.cwd() + "/.env" });
const fs = require("fs");
const path = require("path");
const axios = require("axios");
const { program } = require("commander");
const readline = require("readline");
const OpenAI = require("openai");

// Kiểm tra API key
const DALL_E_API_KEY = process.env.DALL_E_API_KEY;
if (!DALL_E_API_KEY) {
  console.error("Lỗi: Thiếu DALL_E_API_KEY trong file .env");
  process.exit(1);
}

// Cấu hình chương trình CLI
program
  .name("generate-image")
  .description("Tạo ảnh sử dụng DALL-E 3 API")
  .version("1.0.0");

program
  .option("-p, --prompt <prompt>", "Prompt mô tả ảnh cần tạo")
  .option(
    "-s, --style <style>",
    "Phong cách ảnh (vector, icon, realistic, cartoon, app-icon, ui-icons)",
    "natural"
  )
  .option("-o, --output <output>", "Đường dẫn lưu ảnh output", "./output.png")
  .option(
    "-v, --vector",
    "Tối ưu prompt để tạo ảnh phong cách vector/icon",
    false
  )
  .option("-i, --icon", "Tối ưu prompt để tạo icon", false)
  .option("-a, --app-icon", "Tối ưu prompt để tạo icon ứng dụng", false)
  .option("-u, --ui-icons", "Tối ưu prompt để tạo bộ UI icons", false)
  .option("-y, --yes", "Bỏ qua cảnh báo chi phí", false)
  .option(
    "-q, --quality <quality>",
    "Chất lượng ảnh (standard, hd)",
    "standard"
  )
  .option(
    "-m, --model <model>",
    "Model DALL-E (dall-e-3, dall-e-2)",
    "dall-e-3"
  )
  .option("-f, --from-image <image>", "Tạo ảnh từ ảnh input");

program.parse();
const options = program.opts();

// Kiểm tra tham số bắt buộc
if (!options.prompt && !options.fromImage) {
  console.error("Lỗi: Bạn phải cung cấp prompt hoặc ảnh input");
  program.help();
}

// Khởi tạo OpenAI client
const openai = new OpenAI({
  apiKey: process.env.DALL_E_API_KEY,
});

// Hàm hiển thị cảnh báo chi phí và xác nhận
async function costWarningPrompt() {
  if (options.yes) {
    return true;
  }

  console.log("\n⚠️ CẢNH BÁO CHI PHÍ ⚠️");
  console.log(
    "Mỗi ảnh tạo bởi DALL-E 3 có chi phí khoảng 0,08$ (1.024x1.024 pixels)"
  );
  console.log(
    "Vui lòng cân nhắc trước khi tạo ảnh và chỉ tạo khi thực sự cần thiết."
  );

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question("Bạn có muốn tiếp tục? (y/n): ", (answer) => {
      rl.close();
      resolve(answer.toLowerCase() === "y");
    });
  });
}

// Tối ưu prompt cho ảnh vector
function optimizeVectorPrompt(prompt) {
  return `Create a minimalist vector illustration with simple clean lines, flat design style, using only essential shapes. The illustration should show: ${prompt}. Make it suitable for SVG conversion, with clean outlines, limited color palette, and no gradients or complex details.`;
}

// Tối ưu prompt cho icon
function optimizeIconPrompt(prompt) {
  return `Create a simple, minimalist icon representing ${prompt}. Use flat design with clean outlines, minimal details, solid colors, and simple shapes. The icon should be recognizable at small sizes and suitable for UI design. Avoid gradients, shadows, and complex details. Use a limited color palette with strong contrast.`;
}

// Tối ưu prompt cho app icon
function optimizeAppIconPrompt(prompt) {
  return `Design a modern app icon for ${prompt}, using a simple and recognizable symbol. The icon should follow material design or iOS guidelines with a limited color palette (2-3 colors maximum). Create clean shapes with strong silhouettes that remain recognizable at small sizes. Avoid text, intricate details, and overly complex imagery.`;
}

// Tối ưu prompt cho UI icon set
function optimizeUIIconsPrompt(prompt) {
  return `Create a consistent set of minimal UI icons for ${prompt}. Icons should be simple, single-color (monochrome) line/solid style, uniform thickness, with clean geometric shapes. Design them to work well at small sizes (24x24px) with clear silhouettes. Ensure consistent style across all icons.`;
}

// Chọn tối ưu prompt dựa trên các options
async function optimizePrompt(prompt) {
  if (options.vector) {
    return optimizeVectorPrompt(prompt);
  } else if (options.icon) {
    return optimizeIconPrompt(prompt);
  } else if (options.appIcon) {
    return optimizeAppIconPrompt(prompt);
  } else if (options.uiIcons) {
    return optimizeUIIconsPrompt(prompt);
  } else if (options.style === "vector") {
    return optimizeVectorPrompt(prompt);
  } else if (options.style === "icon") {
    return optimizeIconPrompt(prompt);
  } else if (options.style === "app-icon") {
    return optimizeAppIconPrompt(prompt);
  } else if (options.style === "ui-icons") {
    return optimizeUIIconsPrompt(prompt);
  }

  return prompt;
}

// Hàm tạo ảnh từ prompt
async function generateImageFromPrompt(prompt, style, quality, model) {
  try {
    console.log("🎨 Đang tạo ảnh với DALL-E...");
    console.log("📝 Prompt:", prompt);

    const response = await openai.images.generate({
      model: model,
      prompt: prompt,
      n: 1,
      size: "1024x1024",
      quality: quality,
      response_format: "url",
    });

    const imageUrl = response.data[0].url;

    // Tạo thư mục output nếu chưa tồn tại
    const outputDir = path.dirname(options.output);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // Tải và lưu ảnh
    const imageResponse = await fetch(imageUrl);
    const buffer = await imageResponse.arrayBuffer();
    fs.writeFileSync(options.output, Buffer.from(buffer));

    console.log("✅ Đã tạo ảnh thành công!");
    console.log("📍 Ảnh được lưu tại:", options.output);

    return imageUrl;
  } catch (error) {
    console.error("❌ Lỗi khi tạo ảnh:", error.message);
    process.exit(1);
  }
}

// Hàm tải ảnh từ URL và lưu vào file
async function downloadImage(url, outputPath) {
  try {
    console.log("Đang tải ảnh...");

    // Đảm bảo thư mục tồn tại
    const dir = path.dirname(outputPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    const response = await axios({
      method: "GET",
      url: url,
      responseType: "stream",
    });

    const writer = fs.createWriteStream(outputPath);
    response.data.pipe(writer);

    return new Promise((resolve, reject) => {
      writer.on("finish", resolve);
      writer.on("error", reject);
    });
  } catch (error) {
    console.error("Lỗi khi tải ảnh:", error.message);
    process.exit(1);
  }
}

// Lưu thông tin prompt để tái sử dụng sau này
function savePromptInfo(prompt, outputPath) {
  const promptInfoPath = outputPath.replace(/\.[^/.]+$/, "_prompt.txt");
  try {
    fs.writeFileSync(promptInfoPath, prompt, "utf8");
    console.log(`Đã lưu thông tin prompt vào: ${promptInfoPath}`);
  } catch (error) {
    console.warn(`Cảnh báo: Không thể lưu thông tin prompt: ${error.message}`);
  }
}

// Hàm chính
async function main() {
  try {
    // Xác định style dựa trên options
    let style = options.style;
    if (options.vector || options.icon) {
      style = "flat";
    }

    // Tối ưu prompt
    const optimizedPrompt = await optimizePrompt(options.prompt);

    // Cảnh báo chi phí và xác nhận
    const proceed = await costWarningPrompt();
    if (!proceed) {
      console.log("Đã hủy tạo ảnh.");
      process.exit(0);
    }

    // Tạo ảnh
    const imageUrl = await generateImageFromPrompt(
      optimizedPrompt,
      style,
      options.quality,
      options.model
    );

    // Tải và lưu ảnh
    await downloadImage(imageUrl, options.output);

    // Lưu thông tin prompt để sử dụng sau này
    savePromptInfo(optimizedPrompt, options.output);

    console.log(`✅ Đã tạo ảnh thành công: ${options.output}`);

    // Gợi ý cho việc chuyển đổi vector nếu tạo icon hoặc vector
    if (options.vector || options.icon || options.appIcon || options.uiIcons) {
      const svgPath = options.output.replace(/\.[^/.]+$/, ".svg");
      console.log(`\nĐể chuyển đổi sang vector SVG, hãy chạy:`);
      console.log(
        `node scripts/dalle/vectorize_image.js -i "${options.output}" -o "${svgPath}" -c 5 -s 80`
      );
    }
  } catch (error) {
    console.error("Lỗi:", error.message);
    process.exit(1);
  }
}

main();
