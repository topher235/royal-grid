# Localization

Localization in Godot is handled mainly through a CSV import where each column is a new language and each row is a single piece of text.

## Editing & Updating

The main localization file is a Google Sheets file currently stored in Google Drive. Once done editing, download and copy into this localization directory. Godot will auto-update the translation files.

**NOTE:** The first time a language gets added, its generated translation needs to be added in the project settings.

It would be nice to have an in-editor tool to edit the CSV file here rather than having to download the file and copy it over every time.

## Using

Everywhere we want translated text, instead of using a raw piece of text, we'll use a key that can be mapped to a key in the localization file. For example, on a Label node's text, we can use "SETTINGS_MODAL_TITLE" and Godot will automatically retrieve the correct translation, falling back to a default value in English. If there is no key in our fallback language, then Godot will render the key as a literal string.

To disable automatic translation on a node, disable **Localization > Auto Translate** in the inspector.
