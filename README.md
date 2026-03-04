# E-Paper Dashboard & Live Console Switch

> **Disclaimer:** I have no prior coding experience. All scripts and instructions in this project were created with the help of Gemini. Please review the code and use it at your own risk!

This project transforms a **Raspberry Pi Zero 2W** and a **Waveshare 2.13-inch e-Paper HAT+ (V3)** into a dual-purpose device. It functions as a system monitoring dashboard (featuring a dynamic ASCII cat!) and a live hardware Linux terminal. You can seamlessly toggle between the two modes using a physical GPIO push button.

## 🛠️ Hardware & Wiring Instructions

* **Raspberry Pi:** Zero 2W (running standard Raspberry Pi OS).
* **Display:** Waveshare 2.13-inch e-Paper HAT+ (V3). Plugs directly into the top of the Pi's GPIO header.
* **Push Button:** Any standard tactile push button.
    * **Wire 1:** Connect to **Physical Pin 13 (GPIO 27)**.
    * **Wire 2:** Connect to **Physical Pin 14 (Ground)**.
    * *Note: No external resistor is needed. The software utilizes the Pi's internal pull-up resistor.*

## 🚀 Installation

These scripts will automatically enable the SPI interface, download the Waveshare drivers, test your screen, and install the required background services (`epaper_dash.service` and `epaper_console.service`).

1. Download `install_dash.sh` and `install_button.sh` to your Pi.
2. Grant execute permissions to the scripts:
   ```bash
   chmod +x install_dash.sh install_button.sh
3. Run the scripts sequentially:
```bash
./install_dash.sh
./install_button.sh

