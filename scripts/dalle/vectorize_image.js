#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { program } = require("commander");
const { execSync } = require("child_process");
// const chalk = require("chalk");
const sharp = require("sharp");
const potrace = require("potrace");

// Configure command-line options
program
  .name("vectorize_image")
  .description("Convert bitmap images to vector SVG format")
  .requiredOption("-i, --input <path>", "Path to the input image")
  .option(
    "-o, --output <path>",
    "Path to save the output SVG file",
    "./output.svg"
  )
  .option(
    "-m, --mode <mode>",
    "Conversion mode (auto, posterize, color, grayscale)",
    "auto"
  )
  .option("-c, --colors <number>", "Number of colors to retain (2-256)", "16")
  .option("-s, --simplify <level>", "Simplification level (0-100)", "50")
  .option("-b, --background", "Keep background in vectorization", false)
  .option("-O, --optimize", "Optimize SVG after conversion", true)
  .version("1.0.0")
  .parse(process.argv);

const options = program.opts();

// Validate input file
function validateInputFile(filePath) {
  if (!fs.existsSync(filePath)) {
    console.error(`Error: Input file does not exist: ${filePath}`);
    process.exit(1);
  }

  const ext = path.extname(filePath).toLowerCase();
  const validExtensions = [".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp"];

  if (!validExtensions.includes(ext)) {
    console.error(`Error: Invalid image format: ${ext}`);
    console.log("Supported formats:", validExtensions.join(", "));
    process.exit(1);
  }
}

// Check if potrace is installed
function checkPotraceInstallation() {
  try {
    execSync("potrace --version", { stdio: "ignore" });
    return true;
  } catch (error) {
    console.error("Error: Potrace is not installed");
    console.log("Please install potrace to use this tool:");
    console.log("  npm install -g potrace");
    console.log("  or");
    console.log("  brew install potrace");
    return false;
  }
}

// Pre-process image using sharp
async function preprocessImage(inputPath, outputPath, mode, colors) {
  try {
    console.log(`Pre-processing image: ${mode} mode, ${colors} colors...`);

    let sharpInstance = sharp(inputPath);

    switch (mode) {
      case "posterize":
        // Posterize effect with limited colors
        sharpInstance = sharpInstance
          .normalize()
          .modulate({ brightness: 1.1 })
          .posterize(parseInt(colors));
        break;

      case "color":
        // Color quantization for limited palette
        sharpInstance = sharpInstance
          .normalize()
          .modulate({ brightness: 1.1 })
          .toColorspace("srgb")
          .quantize({
            colors: parseInt(colors),
            dither: 1,
          });
        break;

      case "grayscale":
        // Convert to grayscale
        sharpInstance = sharpInstance.grayscale().normalize();
        break;

      case "auto":
      default:
        // Auto mode - detect if color or grayscale is better
        const metadata = await sharp(inputPath).metadata();
        if (metadata.channels >= 3) {
          // Color image - use color mode
          sharpInstance = sharpInstance
            .normalize()
            .modulate({ brightness: 1.1 })
            .toColorspace("srgb")
            .quantize({
              colors: parseInt(colors),
              dither: 1,
            });
        } else {
          // Already grayscale - use grayscale mode
          sharpInstance = sharpInstance.grayscale().normalize();
        }
        break;
    }

    // Save the pre-processed image
    await sharpInstance.png().toFile(outputPath);

    return outputPath;
  } catch (error) {
    console.error(`Error pre-processing image: ${error.message}`);
    process.exit(1);
  }
}

// Vectorize using potrace
async function vectorizeImage(inputPath, outputPath) {
  try {
    console.log("🔄 Đang chuyển đổi ảnh sang vector...");

    const trace = new potrace.Potrace();

    // Thiết lập các tham số cho việc vector hóa
    trace.setParameters({
      turdSize: 2,
      alphaMax: 1,
      optCurve: true,
      optTolerance: 0.2,
      threshold: 128,
    });

    // Tạo thư mục output nếu chưa tồn tại
    const outputDir = path.dirname(outputPath);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // Chuyển đổi ảnh sang SVG
    await new Promise((resolve, reject) => {
      trace.loadImage(inputPath, (err) => {
        if (err) reject(err);
        const svg = trace.getSVG();
        fs.writeFileSync(outputPath, svg);
        resolve();
      });
    });

    console.log("✅ Đã chuyển đổi thành công!");
    console.log("📍 File SVG được lưu tại:", outputPath);
  } catch (error) {
    console.error("❌ Lỗi khi chuyển đổi ảnh:", error.message);
    process.exit(1);
  }
}

// Optimize SVG using svgo
function optimizeSVG(svgPath) {
  try {
    // Check if svgo is installed
    try {
      execSync("svgo --version", { stdio: "ignore" });
    } catch (error) {
      console.log("Warning: SVGO not installed. Skipping optimization.");
      console.log(
        "To enable SVG optimization, install SVGO: npm install -g svgo"
      );
      return;
    }

    console.log("Optimizing SVG...");

    // Create temporary file
    const tempFile = `${svgPath}.temp`;

    // Run SVGO optimization
    execSync(`svgo "${svgPath}" -o "${tempFile}"`, { stdio: "ignore" });

    // Replace original with optimized
    fs.renameSync(tempFile, svgPath);

    console.log("SVG optimization complete");
  } catch (error) {
    console.log("Warning: SVG optimization failed: " + error.message);
  }
}

// Function for color vectorization (multi-layer)
async function vectorizeColorImage(inputPath, outputPath, options) {
  try {
    console.log("Performing color vectorization...");

    // Create temp directory for processing
    const tempDir = path.join(path.dirname(outputPath), ".temp_vectorize");
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }

    // Get color palette from image
    const { data: palette } = await sharp(inputPath).stats();

    // Extract dominant colors
    const dominantColors = palette.channels
      .map((channel, i) => {
        return channel.mean > 127 ? 255 : 0;
      })
      .slice(0, 3); // RGB only

    console.log(`Detected ${dominantColors.length} color channels`);

    // Create separate layers for each color
    const svgParts = [];

    // Processing each color channel
    for (let i = 0; i < dominantColors.length; i++) {
      const channelFile = path.join(tempDir, `channel_${i}.png`);

      // Extract channel
      await sharp(inputPath).extractChannel(i).toFile(channelFile);

      // Vectorize channel
      const channelSvgFile = path.join(tempDir, `channel_${i}.svg`);
      await vectorizeImage(channelFile, channelSvgFile);

      // Read SVG content
      const svgContent = fs.readFileSync(channelSvgFile, "utf8");
      svgParts.push(svgContent);
    }

    // Combine SVG layers
    const combinedSvg = `
<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 800 600">
  ${svgParts.join("\n")}
</svg>`;

    // Save final SVG
    fs.writeFileSync(outputPath, combinedSvg);

    // Clean up temp directory
    fs.rmSync(tempDir, { recursive: true, force: true });

    console.log(`Color vectorization complete! SVG saved to: ${outputPath}`);
  } catch (error) {
    console.error(`Error in color vectorization: ${error.message}`);
    process.exit(1);
  }
}

// Main function
async function main() {
  try {
    // Validate input file
    validateInputFile(options.input);

    // Check if potrace is installed
    if (!checkPotraceInstallation()) {
      process.exit(1);
    }

    // Create output directory if it doesn't exist
    const outputDir = path.dirname(options.output);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // Create temp file for pre-processing
    const tempImagePath = path.join(
      path.dirname(options.output),
      `.temp_${path.basename(options.input)}`
    );

    // Pre-process the image
    await preprocessImage(
      options.input,
      tempImagePath,
      options.mode,
      options.colors
    );

    // Vectorize the image
    await vectorizeImage(tempImagePath, options.output);

    // Clean up temporary files
    if (fs.existsSync(tempImagePath)) {
      fs.unlinkSync(tempImagePath);
    }

    console.log("Vector conversion complete!");
    console.log(`SVG file saved to: ${options.output}`);
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

main();
