# SPEditor - Sprite Editor in Lua

## Project Description

SPEditor is a lightweight, Lua-based sprite editor. With SPEditor, users can create, edit, and manage pixel art and sprites seamlessly.

## Table of Contents

1. Project Title
2. Project Description
3. Table of Contents
4. How to Install and Run the Project
5. How to Use the Project
6. License

## How to Install and Run the Project

### Prerequisites

1. LOVE2D (version 11.0 or later) installed on your system.
2. nativefs library for file system operations.
3. A text editor or IDE (e.g., Visual Studio Code) for editing the Lua code if needed.

### Installation Steps

1. Clone this repository or download the project as a ZIP file and extract it to your desired location:
  ```
  git clone https://github.com/Onebit5/SPEditor.git
  cd SPEditor
  ```
2. Ensure that the required dependencies (LOVE2D and nativefs) are installed.
3. Navigate to the project folder and run the project using LOVE2D:

   ```
   love .
   ```

## How to Use the Project

### Features

1. Canvas Management:

   * Create a new canvas with custom dimensions.

   * Load an existing .speditor file to restore a previous project.

2. Sprite Editing:

   * Pixel drawing and erasing tools (planned).

   * Color selection and fill tool (planned).

3. File Management:

   * Save your sprite work as .speditor files.

   * Export your canvas as a PNG image.
### Usage Instructions

1. Launching SPEditor:
   Open a terminal in the project directory and execute:
   ```
   love .
   ```
2. Creating a New Canvas:
  Use the canvas creation tool to specify width and height for your new sprite.

3. Saving Your Work:
   Save your project to a .speditor file to retain layers, colors, and other details.

4. Loading a Canvas:
   Load an existing .speditor file to continue work on a saved project.

5. Exporting to PNG:
   Export the canvas to a PNG file for external use in game engines or other applications.

## License

This project is licensed under the GPL License. See the LICENSE file for details.
