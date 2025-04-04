#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { program } = require("commander");
const { exec } = require("child_process");
const fetch = require("node-fetch");
const dotenv = require("dotenv");
const chalk = require("chalk");

// Load environment variables
dotenv.config({ path: path.join(__dirname, "../../.env") });

// Check if DALL-E API key exists
const DALLE_API_KEY = process.env.DALL_E_API_KEY;
if (!DALLE_API_KEY) {
  console.error(chalk.red.bold("Error: DALL-E API key not found in .env file"));
  console.log("Please add your API key to .env file in the project root:");
  console.log("DALL_E_API_KEY=your_api_key_here");
  process.exit(1);
}

// Configure command-line options
program
  .name("analyze_image")
  .description("Analyze image and generate a descriptive prompt")
  .requiredOption("-i, --input <path>", "Path to the input image")
  .option(
    "-o, --output <path>",
    "Path to save the generated prompt (omit to print to console)"
  )
  .option("-v, --vector", "Optimize prompt for vector/icon format")
  .option("-d, --detail <level>", "Detail level (low, medium, high)", "medium")
  .version("1.0.0")
  .parse(process.argv);

const options = program.opts();

// Function to validate image file
function validateImageFile(filePath) {
  if (!fs.existsSync(filePath)) {
    console.error(chalk.red(`Error: Input file does not exist: ${filePath}`));
    process.exit(1);
  }

  const ext = path.extname(filePath).toLowerCase();
  const validExtensions = [".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp"];

  if (!validExtensions.includes(ext)) {
    console.error(chalk.red(`Error: Invalid image format: ${ext}`));
    console.log("Supported formats:", validExtensions.join(", "));
    process.exit(1);
  }
}

// Encode image to base64
function encodeImageToBase64(imagePath) {
  return fs.readFileSync(imagePath, { encoding: "base64" });
}

// Analyze image using OpenAI Vision API
async function analyzeImage(imagePath, detailLevel, isVector) {
  console.log(chalk.blue("Analyzing image..."));

  const imageBase64 = encodeImageToBase64(imagePath);

  let systemPrompt = "You are an expert in image analysis and description. ";

  if (isVector) {
    systemPrompt +=
      "Focus on identifying key visual elements, shapes, colors, and concepts that could be used to recreate this as a vector image or icon. Ignore complex textures and small details. Provide a description that would be suitable for generating a similar vector illustration or icon.";
  } else {
    systemPrompt +=
      "Provide a detailed, descriptive caption that captures all important elements, style, composition, colors, lighting, and mood of the image.";
  }

  // Adjust detail level instruction
  let userPrompt = "";
  switch (detailLevel) {
    case "low":
      userPrompt =
        "Give a brief description of this image in 1-2 sentences, focusing on the main subject only.";
      break;
    case "medium":
      userPrompt =
        "Describe this image in a paragraph, including main subjects, style, colors, and composition.";
      break;
    case "high":
      userPrompt =
        "Give a comprehensive description of this image, including all subjects, background, style, colors, lighting, composition, mood, and any notable details.";
      break;
    default:
      userPrompt =
        "Describe this image in a paragraph, including main subjects, style, colors, and composition.";
  }

  if (isVector) {
    userPrompt +=
      " Format your description as a DALL-E prompt optimized for creating a vector image or icon based on this image.";
  }

  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${DALLE_API_KEY}`,
      },
      body: JSON.stringify({
        model: "gpt-4-vision-preview",
        messages: [
          {
            role: "system",
            content: systemPrompt,
          },
          {
            role: "user",
            content: [
              { type: "text", text: userPrompt },
              {
                type: "image_url",
                image_url: {
                  url: `data:image/jpeg;base64,${imageBase64}`,
                },
              },
            ],
          },
        ],
        max_tokens: 500,
      }),
    });

    const data = await response.json();

    if (data.error) {
      console.error(chalk.red(`API Error: ${data.error.message}`));
      process.exit(1);
    }

    return data.choices[0].message.content.trim();
  } catch (error) {
    console.error(chalk.red(`Error analyzing image: ${error.message}`));
    process.exit(1);
  }
}

// Function to optimize prompt for vector images
function optimizeVectorPrompt(prompt) {
  // Extract the core description from the generated prompt
  let coreDescription = prompt;

  // If the prompt is already formatted as a DALL-E prompt, try to extract just the description part
  if (
    prompt.toLowerCase().includes("create a") ||
    prompt.toLowerCase().includes("generate a") ||
    prompt.toLowerCase().includes("design a")
  ) {
    // We'll try to keep the original format since the vision model might have already optimized it
    return prompt;
  }

  // Create a template for vector image generation
  return `Create a minimalist vector illustration with simple clean lines and flat design style. 
The illustration should show: ${coreDescription}. 
Make it suitable for SVG conversion with clean outlines, limited color palette, and no gradients or complex details.`;
}

// Main function
async function main() {
  try {
    validateImageFile(options.input);

    const prompt = await analyzeImage(
      options.input,
      options.detail,
      options.vector
    );

    // Optimize for vector if requested
    const finalPrompt = options.vector ? optimizeVectorPrompt(prompt) : prompt;

    if (options.output) {
      fs.writeFileSync(options.output, finalPrompt);
      console.log(chalk.green(`Prompt saved to: ${options.output}`));
    } else {
      console.log(chalk.yellow("\nGenerated Prompt:"));
      console.log(chalk.white("=".repeat(50)));
      console.log(finalPrompt);
      console.log(chalk.white("=".repeat(50)));
    }

    console.log(chalk.green("Analysis complete!"));
  } catch (error) {
    console.error(chalk.red(`Error: ${error.message}`));
    process.exit(1);
  }
}

main();
