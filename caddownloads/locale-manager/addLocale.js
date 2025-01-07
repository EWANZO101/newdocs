// addLocale.js

import fs from 'fs-extra';
import path from 'path';
import inquirer from 'inquirer';
import open from 'open';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Retrieve target paths from environment variables
const TARGET_CONFIG_PATH = process.env.TARGET_CONFIG_PATH;
const TARGET_LOCALES_DIR = process.env.TARGET_LOCALES_DIR;

// Validate environment variables
if (!TARGET_CONFIG_PATH || !TARGET_LOCALES_DIR) {
    console.error('Error: TARGET_CONFIG_PATH and TARGET_LOCALES_DIR environment variables must be set.');
    process.exit(1);
}

// Determine the directory of the current script
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Predefined list of available locales
const availableLocales = [
    { code: 'en', description: 'English', disabled: true }, // Default locale, not selectable
    { code: 'en-gb', description: 'English (Great Britain)' },
    { code: 'ru', description: 'Russian' },
    { code: 'cn', description: 'Chinese (Simplified)' },
    { code: 'tc', description: 'Chinese (Traditional)' },
    { code: 'fr-FR', description: 'French (France)' },
    { code: 'de-DE', description: 'German (Germany)' },
    { code: 'pt-BR', description: 'Portuguese (Brazil)' },
    { code: 'cs-CZ', description: 'Czech (Czech Republic)' },
    { code: 'nl-BE', description: 'Dutch (Belgium)' },
    { code: 'zh-CN', description: 'Chinese (China)' },
    { code: 'sv', description: 'Swedish' },
    // Add more locales as needed
];

// Function to read and parse the i18n.config.mjs file
async function readConfig(configPath) {
    const configContent = await fs.readFile(configPath, 'utf-8');

    // Remove the export statement and parse as JSON
    const jsonString = configContent.replace(/export\s+const\s+i18n\s+=\s+/, '');

    // Use dynamic import to safely parse the module
    try {
        const configModule = await import('data:text/javascript,' + encodeURIComponent(jsonString));
        return configModule.i18n;
    } catch (error) {
        console.error('Failed to parse i18n.config.mjs:', error);
        process.exit(1);
    }
}

// Function to write the updated config back to i18n.config.mjs
async function writeConfig(config, configPath) {
    const localesArray = JSON.stringify(config.locales, null, 2);
    const configString = `export const i18n = {\n  locales: ${localesArray},\n  defaultLocale: "${config.defaultLocale}",\n};\n`;
    await fs.writeFile(configPath, configString, 'utf-8');
}

// Function to validate locale code
function validateLocaleCode(input) {
    const localeRegex = /^[a-z]{2}(-[A-Z]{2})?$/;
    if (localeRegex.test(input)) {
        return true;
    }
    return 'Please enter a valid locale code (e.g., "es-ES").';
}

// Main function
async function main() {
    try {
        // Step 1: Prompt user to select a new locale code from options
        const localeChoices = availableLocales.map((locale, index) => {
            if (locale.disabled) {
                return {
                    name: `{ code: '${locale.code}', description: '${locale.description}' }, (Default Locale)`,
                    value: locale.code,
                    disabled: 'Default locale, cannot be added again',
                };
            } else {
                return {
                    name: `${index}. { code: '${locale.code}', description: '${locale.description}' },`,
                    value: locale.code,
                };
            }
        });

        // Add an option for a custom locale
        const customOptionNumber = availableLocales.length;
        localeChoices.push({ name: `${customOptionNumber}. Custom Locale`, value: 'custom' });

        const { selectedLocale } = await inquirer.prompt([
            {
                type: 'rawlist',
                name: 'selectedLocale',
                message: 'Select the new locale to add:',
                choices: localeChoices,
            },
        ]);

        let newLocale = selectedLocale;

        // If user selects 'Custom', prompt to enter the locale code
        if (selectedLocale === 'custom') {
            const { customLocale } = await inquirer.prompt([
                {
                    type: 'input',
                    name: 'customLocale',
                    message: 'Enter the custom locale code (e.g., "es-ES"):',
                    validate: validateLocaleCode,
                },
            ]);
            newLocale = customLocale;
        }

        // Step 2: Check if locale already exists in config
        const config = await readConfig(TARGET_CONFIG_PATH);
        if (config.locales.includes(newLocale)) {
            console.error(`Error: Locale "${newLocale}" is already present in i18n.config.mjs.`);
            process.exit(1);
        }

        // Step 3: Check if locale folder already exists
        const newLocalePath = path.join(TARGET_LOCALES_DIR, newLocale);
        if (await fs.pathExists(newLocalePath)) {
            console.error(`Error: Locale folder "${newLocale}" already exists in ${TARGET_LOCALES_DIR}.`);
            process.exit(1);
        }

        // Step 4: Duplicate the 'en' folder
        const sourceLocalePath = path.join(TARGET_LOCALES_DIR, 'en');
        if (!await fs.pathExists(sourceLocalePath)) {
            console.error(`Error: Source locale folder "en" does not exist at ${sourceLocalePath}.`);
            process.exit(1);
        }

        await fs.copy(sourceLocalePath, newLocalePath);
        console.log(`Successfully duplicated 'en' to '${newLocale}'.`);

        // Step 5: Open the new locale folder in the default editor
        await open(newLocalePath);
        console.log(`Opened '${newLocale}' folder in the default editor.`);

        // Step 6: Update i18n.config.mjs
        config.locales.push(newLocale);
        await writeConfig(config, TARGET_CONFIG_PATH);
        console.log(`Added "${newLocale}" to i18n.config.mjs.`);

        console.log('Locale setup complete.');
    } catch (error) {
        console.error('An error occurred:', error);
    }
}

main();
