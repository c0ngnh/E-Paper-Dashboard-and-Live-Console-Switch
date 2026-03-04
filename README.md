# E-Paper Dashboard & Live Console Switch

> **Disclaimer:** I have no prior coding experience. All scripts and instructions in this project were created with the help of Gemini. Please review the code and use it at your own risk!

This project transforms a **Raspberry Pi Zero 2W** and a **Waveshare 2.13-inch e-Paper HAT+ (V3)** into a dual-purpose device. It functions as a system monitoring dashboard (featuring a dynamic ASCII cat!) and a live hardware Linux terminal. You can seamlessly toggle between the two modes using a physical GPIO push button, and even use the button to safely shut down the system.

## 🛠️ Hardware & Wiring Instructions

* **Raspberry Pi:** Zero 2W (running standard Raspberry Pi OS).
* **Display:** Waveshare 2.13-inch e-Paper HAT+ (V3). Plugs directly into the top of the Pi's GPIO header.
* **Push Button:** Any standard tactile push button.
    * **Wire 1:** Connect to **Physical Pin 13 (GPIO 27)**.
    * **Wire 2:** Connect to **Physical Pin 14 (Ground)**.
    * *Note: No external resistor is needed. The software utilizes the Pi's internal pull-up resistor.*

## 🚀 Installation

These scripts will automatically enable the SPI interface, download the Waveshare drivers, test your screen, and install the required background services (`epaper_dash.service`, `epaper_console.service`, and `epaper_button.service`).

1. Download `install_dash.sh` and `install_button.sh` to your Pi.
2. Grant execute permissions to the scripts:
   ```bash
   chmod +x install_dash.sh install_button.sh
3. Run the scripts sequentially:
   ```bash
   ./install_dash.sh
   ./install_button.sh


Gemini said
Here is the fully updated README.md. I have fixed a few broken formatting tags from your pasted text, added the new 5-second shutdown feature to the intro, and updated the button instructions to explain the safe shutdown process.

You can copy this entire block and paste it directly into your GitHub repository:

Markdown
# E-Paper Dashboard & Live Console Switch

> **Disclaimer:** I have no prior coding experience. All scripts and instructions in this project were created with the help of Gemini. Please review the code and use it at your own risk!

This project transforms a **Raspberry Pi Zero 2W** and a **Waveshare 2.13-inch e-Paper HAT+ (V3)** into a dual-purpose device. It functions as a system monitoring dashboard (featuring a dynamic ASCII cat!) and a live hardware Linux terminal. You can seamlessly toggle between the two modes using a physical GPIO push button, and even use the button to safely shut down the system.

## 🛠️ Hardware & Wiring Instructions

* **Raspberry Pi:** Zero 2W (running standard Raspberry Pi OS).
* **Display:** Waveshare 2.13-inch e-Paper HAT+ (V3). Plugs directly into the top of the Pi's GPIO header.
* **Push Button:** Any standard tactile push button.
    * **Wire 1:** Connect to **Physical Pin 13 (GPIO 27)**.
    * **Wire 2:** Connect to **Physical Pin 14 (Ground)**.
    * *Note: No external resistor is needed. The software utilizes the Pi's internal pull-up resistor.*

## 🚀 Installation

These scripts will automatically enable the SPI interface, download the Waveshare drivers, test your screen, and install the required background services (`epaper_dash.service`, `epaper_console.service`, and `epaper_button.service`).

1. Download `install_dash.sh` and `install_button.sh` to your Pi.
2. Grant execute permissions to the scripts:
   ```bash
   chmod +x install_dash.sh install_button.sh
Run the scripts sequentially:

Bash
./install_dash.sh
./install_button.sh
🕹️ How to Use the System
Method A: Using the Physical Button (Automatic)
Quick Press (Toggle Mode): The system will safely freeze the current display, clear the SPI bus, and seamlessly switch to the other mode.

Hold for 5 Seconds (Safe Shutdown): The system will stop the active displays, draw a final "SYSTEM OFFLINE" message to the e-Paper screen, and safely shut down the Raspberry Pi OS. Once the Pi's green LED stops blinking, it is safe to unplug the power.

Note: The Live Console mirrors the Pi's primary HDMI output (/dev/tty1). To type on it, plug a USB keyboard directly into the Pi.

Method B: Standalone/Manual Control (No Button Needed)
If you don't want to wire a physical button, or if you prefer to control the screens remotely via SSH, you can use standard systemctl commands.

⚠️ CRITICAL RULE: E-Paper displays do not handle concurrent connections well. You must stop one service before starting the other, otherwise they will fight over the SPI bus and crash.

To run the Dashboard independently:

Bash
sudo systemctl stop epaper_console.service
sudo systemctl start epaper_dash.service
To run the Live Console independently:

Bash
sudo systemctl stop epaper_dash.service
sudo systemctl start epaper_console.service
To stop all displays (put the screen to sleep):

Bash
sudo systemctl stop epaper_dash.service
sudo systemctl stop epaper_console.service
🐛 Useful Debugging Commands
If a screen gets stuck or isn't updating, check the system logs to see what went wrong:

Dashboard logs: journalctl -u epaper_dash.service -f

Console logs: journalctl -u epaper_console.service -f

Button listener logs: journalctl -u epaper_button.service -f
