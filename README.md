# Highlights Screensaver
A KOReader plugin to show a random highlight or quote on your screensaver.

## What does this plugin do?
Highlights Screensaver replaces your sleep screen wallpaper with a randomly selected highlight from one of the books in your library—or from external quotes you provide.

### Example images
![Light theme example 1](images/light_01.JPG)
![Light theme example 2](images/light_02.JPG)
![Dark theme example 2](images/dark_01.JPG)

## Features
- Shows the original quote, source (book & author), and any notes attached to a highlight.
- Automatically stays up to date with your latest highlights.
- Dynamically resizes text to fit content of varying length on the sleep screen.
- Independent font selection for quote, source, and notes.
- Theme support:
  - **Light**
  - **Dark**
  - **System** (follows the device’s current theme)
- Orientation support:
  - Default (follow current book)
  - Portrait
  - Landscape
- Notes display options:
  - **Disable** – show only the quote and source.
  - **Full** – show the quote, source, and full notes (no length limit).
  - **Short** – show notes with a configurable character limit (useful for `assistant.koplugin` generated notes).
- Import **external quotes** from text files.
- Disable individual highlights to prevent them from appearing again.

## Installation & setup
1. Download the latest `HighlightsScreensaver.zip` from the releases page and unzip it.
2. Copy the `highlightsscreensaver.koplugin` directory into `koreader/plugins/` on your device.
3. Restart KOReader.

### Initial setup
1. Open the settings menu (cog icon).
2. Go to `Screen > Sleep screen > Wallpaper`.
3. Select **“Show highlights screensaver”**.

### Configure scannable directories
Highlights Screensaver needs to know where your books are stored.

1. Navigate to your library directory.
2. Open the settings menu and go to  
   `Screen > Sleep screen > Highlights screensaver`.
3. Select **“Add current directory to scannable directories”**.

You may add multiple directories, but most users only need to add their top-level library folder. All subdirectories are scanned automatically.

### Scan book highlights
1. Go to `Screen > Sleep screen > Highlights screensaver`.
2. Select **“Scan book highlights”**.

This performs an initial scan. From then on, Highlights Screensaver automatically scans once per day the first time the sleep screen is shown. You can also manually trigger a scan at any time.

### Customize appearance and behavior
All options are available under:  
`Screen > Sleep screen > Highlights screensaver`

From here you can:
- Change fonts
- Set theme mode (Light, Dark, System)
- Choose orientation
- Configure how notes are displayed

## Adding external quotes
Highlights Screensaver can import quotes from plain text files.

### How it works
1. Create a directory to store your quote files.
2. Add one or more `*.txt` files.
3. Each file represents a **collection of quotes** (e.g. `motivational.txt`, `business.txt`).
4. All quote files must be in the **same folder**.

### File format
Each quote is separated by **six equal signs (`======`)**.  
Use a tilde (`~`) to indicate the author or source.

```txt
======
Life is what happens when you're busy making other plans.
Sometimes we get lost, but we always find our way.
~ John Lennon
======
Happiness is not something ready made. It comes from your own actions.
Cherish the little things and the big things will follow.
~ Dalai Lama
```

Each block is treated as a separate quote and imported as its own JSON file.

### Importing external quotes

1. Go to `Screen > Sleep screen > Highlights screensaver`.
2. Select **“Import external quotes”**.
3. Choose the folder containing your quote files.

## Roadmap / Planned Features

The following features are planned for future releases. Feedback and contributions are welcome.

* **Manage scannable directories**

  * View, remove, or edit directories that were previously added.
  * Useful when reorganizing a library or correcting mistakes.

* **Pause / pin a highlight**

  * Option to keep a specific quote or highlight persistent across sleep cycles.
  * Ideal for displaying a favorite quote long-term.

* **Skip existing quotes when importing**  
  Avoid importing duplicate quotes when re-importing text files.  
  **Current workaround:**  
  1. Go to your KOReader root directory.  
  2. Navigate to `onboard/highlights-screensaver/clippings`.  
  3. Delete the JSON files corresponding to your quotes (the filenames will match the source text file).  
     *Do not delete other files in this folder.*  
  4. Re-import your quotes from KOReader. This will import all quotes including any new entries without creating duplicates from old quotes.


* **Highlight / quote sequencing options**

  * Choose how highlights are displayed:

    * **Shuffle** (random)
    * **Sequential** (in order)

## Compatibility


### Tested devices
- **Kobo** – KOReader 2025.10  
  *(Tested by the original plugin author)*

- **Linux Mint** – KOReader nightly build  
  *(Tested with recent feature updates)*

- **Kindle Paperwhite 5** – KOReader 2025.10
  *(Tested with recent feature updates)*

The core plugin has been verified on Kobo devices, while the newer features and modifications were tested on Linux and Kindle devices only.

The plugin may work on other devices running KOReader, but compatibility has not been fully verified.  
If you test this plugin on a different device and encounter issues (or confirm it works), please open an issue or contribute to the project.


---

⭐ If you enjoy Highlights Screensaver, please consider leaving a star.
