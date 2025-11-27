# git-clean-gone

> **Disclaimer:** This tool was created as part of my Rust learning journey.  
> While it aims to be useful, the main purpose of this project is experimentation and skill development.


A simple CLI tool written in **Rust** to remove local Git branches that are marked as **[gone]**.  
It integrates directly with Git as a native subcommand:

---

## ✨ Features

- Automatically detects branches with `[gone]`
- Skips the current branch for safety
- Prompts for confirmation before deleting
- Shows a clean operation summary:
  - deleted branches  
  - skipped branches  
  - failed deletions  

---

## 📦 Installation

### **Windows**
Download the installer from the **Releases** page.

The installer:
- creates a local program directory  
- adds it to your **PATH** automatically  
- lets you run:

```powershell
git clean-gone

