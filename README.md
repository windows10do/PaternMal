# 🚀 PaternMal Installer 🎉

![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)

This repository contains the installer script for **PaternMal** 🛡️, a local proxy-bound shell app.  
It sets up the project under `~/.paternmal`, compiles the C++ server (`paternmal.cpp` → `paternmal.bin` ⚙️), and installs a CLI wrapper with custom commands 🖥️.

---

## ⚠️ Requirements 📋

Before running the installer, make sure you have:

- 🐧 Unix-like environment (Linux, macOS, Termux on Android)  
- 🛠️ C++ compiler (`g++` with C++17 support)  
- 🐚 Shell (`bash` or `sh`)  
- 🌐 Git (if cloning from GitHub)  
- 🏠 Write access to your home directory (`~`)  

---

## ⚡ Quick Start 🚦

1. 📥 Clone and install:  
   `git clone https://github.com/windows10do/PaternMal.git`  
   `cd PaternMal`  
   `sh paternmal-setup.sh`

2. ▶️ Run server:  
   `paternmal ~/your-server-dir/`

3. 🗑️ Uninstall:  
   `sh paternmal-setup.sh uninstall`

---

## 🕹️ Usage 🎮

After installation, restart your shell 🔄 or run `source ~/.bashrc` (or `~/.zshrc`).

### 📊 Command Table

| Command                          | Description                                                                 |
|----------------------------------|-----------------------------------------------------------------------------|
| ⏸️ `paternmal`                   | Hangs (idle mode)                                                           |
| 🌍 `paternmal ~/your-server/`    | Run server on localhost with given directory                                |
| 📚 `paternmal --educational --on`| Enable educational mode (runs all `.sh` files in the last used server dir)  |
| 🚫 `paternmal --educational --off`| Disable educational mode                                                   |
| 🛠️ `paternmal --settings`        | Show current settings (educational mode, last server used)                  |
| ❓ `paternmal --help`             | Show help                                                                   |

---

## 📂 Project Structure 🏗️

~/.paternmal/  
├── 📦 bin/  
│   └── ⚙️ paternmal.bin (compiled C++ server)  
├── 🌐 public/  
│   ├── 📄 index.html  
│   ├── 🎨 style.css  
│   └── 📜 script.js  
├── 🔒 .csp (Content Security Policy file)  
├── 📝 paternmal.cpp (auto-generated C++ source)  
├── 🖥️ paternmal-cli.sh (CLI wrapper)  
└── 📑 settings.conf (stores mode and last server info)  

> ⚠ Note: Some files may fail to create, depending on your OS.
---

## 📝 Notes ✨

- 📚 Educational mode executes all `.sh` files in the last used server directory.  
  ⚠️ **Not recommended for beginners**.  
- 🔌 Default server port: `8080`  
- 🔗 Proxy route: `/api=localhost:5000`  

---

## 📜 License 📅

This project is licensed under the **GNU General Public License v3.0 (GPLv3)**.  
Copyright © December 30, 2025 **windows10do**

You may copy, distribute, and modify this software under the terms of the GPLv3.  
See the LICENSE file for the full text of the license, including **Terms and Conditions**, Disclaimer of Warranty, and Limitation of Liability.
