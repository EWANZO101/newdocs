# Locale Manager

A Node.js script to automate the process of adding new locales to your project. It duplicates the existing `en` locale folder, renames it to the new locale code, opens the folder in your default editor for editing, and updates the `i18n.config.mjs` configuration file.

## Features

- **Duplicate Locale Folder:** Copies the `en` locale folder to a new locale folder based on user selection.
- **Interactive Prompts:** Guides the user through selecting a locale from a numbered list or entering a custom locale code.
- **Automatic Configuration Update:** Adds the new locale to the `i18n.config.mjs` file.
- **Open in Editor:** Automatically opens the new locale folder in your default editor for immediate editing.

## Prerequisites

- **Node.js:** Ensure you have Node.js (version 14 or higher) installed. [Download Node.js](https://nodejs.org/)
- **Git:** To clone the repository. [Download Git](https://git-scm.com/downloads)

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-username/locale-manager.git
