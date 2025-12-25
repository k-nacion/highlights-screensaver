# Highlights Screensaver – Community Fork v1.1.0-community

A KOReader plugin to show a random highlight or quote on your screensaver.  
This fork provides additional maintenance, fixes, and new features for the community.

---

## ⚠️ Disclaimer / Community Statement

This repository is a **community-maintained fork** of [Highlights Screensaver](https://github.com/juancoquet/highlights-screensaver) by Juancoquet.  

- All functional changes have been submitted upstream as pull requests.  
- This fork provides additional maintenance, fixes, and new features for the community.  
- If the original maintainer integrates the changes, this fork can be merged, synced, or retired accordingly.  

All changes are released under **GNU GPL v3.0**.

---

## Example images

| Light Theme 1 | Light Theme 2 | Dark Theme 1 |
|---------------|---------------|--------------|
| <img src="images/light_01.JPG" alt="Light theme example 1" width="250"/> | <img src="images/light_02.JPG" alt="Light theme example 2" width="250"/> | <img src="images/dark_01.JPG" alt="Dark theme example 2" width="250"/> |

---

## Features

- Shows the original quote, source (book & author), and any notes attached to a highlight.
- Automatically stays up to date with your latest highlights.
- Dynamically resizes text to fit varying lengths.
- Independent font selection for quote, source, and notes.
- Theme support: Light, Dark, System (follows device theme)
- Orientation support: Current Book, Portrait, Landscape
- Notes display options: Disable, Full, Short
- Import **external quotes** from text files
- Highlights layout configuration options
- Disable individual highlights to prevent repetition

---

## Installation & Setup

1. Download the latest `HighlightsScreensaver.zip` from the [releases page](https://github.com/k-nacion/highlights-screensaver/releases).  
2. Copy `highlightsscreensaver.koplugin` into `koreader/plugins/` on your device.  
3. Restart KOReader.

### Initial Setup

1. Open settings → `Screen > Sleep screen > Wallpaper`  
2. Select **“Show highlights screensaver”**

### Configure Scannable Directories

1. Navigate to your library folder.  
2. Open `Screen > Sleep screen > Highlights screensaver`  
3. Select **“Add current directory to scannable directories”**  

> Subdirectories are scanned automatically.

### Scan Book Highlights

1. Go to `Screen > Sleep screen > Highlights screensaver`  
2. Select **“Scan book highlights”**  

Automatic scanning occurs once per day; manual scan can be triggered anytime.

---

## Customize Appearance & Behavior

- Change fonts  
- Set theme mode (Light, Dark, System)  
- Choose orientation (Current Book, Portrait, Landscape)  
- Configure notes display (Disable, Full, Short with character limit)  
- Adjust highlights layout configuration  

All options under: `Screen > Sleep screen > Highlights screensaver`

---

## Adding External Quotes

### How It Works

1. Create a directory for quote files  
2. Add one or more `*.txt` files (each file = collection of quotes)  
3. All quote files must be in the same folder  

### File Format

- Each quote separated by `======`  
- Use `~` to indicate author/source  

```txt
======
Life is what happens when you're busy making other plans.
~ John Lennon
======
Happiness comes from your own actions.
~ Dalai Lama
````

### Importing

1. Go to `Screen > Sleep screen > Highlights screensaver`
2. Select **“Import external quotes”**
3. Choose the folder containing your files

> ⚠️ Note: This feature works but is still being enhanced in future updates.

---

## Roadmap / Planned Features

- [ ] **Manage scannable directories** – view, remove, edit  
- [ ] **Pause / pin a highlight** – display favorite quotes persistently  
- [ ] **Skip duplicates when importing** – avoid repeated quotes  
- [ ] **Highlight / quote sequencing** – Shuffle or Sequential display


---

## Compatibility

### Tested Devices

* **Kobo** – KOReader 2025.10
* **Linux Mint** – KOReader nightly build
* **Kindle Paperwhite 5** – KOReader 2025.10

Other devices may work; testing encouraged. Report issues or contribute if possible.

---

⭐ If you enjoy Highlights Screensaver, please consider leaving a star.

