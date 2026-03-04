#!/bin/bash

echo "=========================================="
echo "  E-Paper Dashboard Automated Installer   "
echo "=========================================="

# Step 1: Automatically enable SPI
echo "[1/7] Enabling SPI Interface..."
sudo raspi-config nonint do_spi 0
echo "SPI enabled."

# Step 2: Install required packages
echo "[2/7] Installing APT Dependencies..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-pil python3-numpy python3-smbus python3-spidev python3-psutil fonts-dejavu-core unzip wget

# Step 3: Download and Extract Waveshare code
echo "[3/7] Downloading Waveshare E-Paper Libraries..."
cd ~
wget -O E-Paper_code.zip https://files.waveshare.com/wiki/common/E-Paper_code.zip
unzip -o E-Paper_code.zip -d ~/e-Paper
rm E-Paper_code.zip

# Step 4: Run the official test script
echo "[4/7] Running Waveshare V3 Test Script..."
echo "Please watch your e-Paper screen!"
python3 ~/e-Paper/RaspberryPi_JetsonNano/python/examples/epd_2in13_V3_test.py

# Step 5: Verification Prompt
echo "=========================================="
read -p "Did the screen display the Waveshare test graphics correctly? (y/n): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo "[5/7] Generating cat_dash_v3.py..."
    
    # Use 'EOF' in quotes to prevent bash from interpreting Python variables
    cat << 'EOF' > ~/e-Paper/RaspberryPi_JetsonNano/python/examples/cat_dash_v3.py
import os, sys, time, socket, psutil
from PIL import Image, ImageDraw, ImageFont

base_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
lib_dir = os.path.join(base_dir, 'lib')
if os.path.exists(lib_dir): sys.path.append(lib_dir)

from waveshare_epd import epd2in13_V3

cpu_history = [0] * 20 

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 1))
        IP = s.getsockname()[0]
    except Exception:
        try: IP = socket.gethostbyname(socket.gethostname())
        except: IP = 'OFFLINE'
    finally: s.close()
    return IP

def draw_graph(draw, data, x_start, y_bottom, width, height):
    x_step = width / (len(data) - 1)
    points = []
    for i, value in enumerate(data):
        y_val = y_bottom - (value / 100.0 * height)
        points.append((x_start + (i * x_step), y_val))
    draw.line(points, fill=0, width=1)
    draw.rectangle([x_start, y_bottom - height, x_start + width, y_bottom], outline=0)

def draw_cat(draw, x, y, cpu):
    face = "^ . ^" if cpu < 70 else "O _ O"
    draw.polygon([(x+5,y), (x+10,y-5), (x+15,y)], fill=0)
    draw.polygon([(x+20,y), (x+25,y-5), (x+30,y)], fill=0)
    draw.rectangle([x+5, y, x+30, y+15], outline=0, fill=255)
    draw.rectangle([x+5, y, x+30, y+15], outline=0)
    font_cat = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 10)
    draw.text((x+7, y+2), face, font=font_cat, fill=0)

def main():
    try:
        epd = epd2in13_V3.EPD()
        epd.init()
        epd.Clear(0xFF)
        epd.displayPartBaseImage(epd.getbuffer(Image.new('1', (epd.height, epd.width), 255)))
        
        hostname = socket.gethostname()
        font_sm = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 13)
        font_ip = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 14) 
        font_lg_bold = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 26)

        refresh_count = 0
        while True:
            if refresh_count % 36 == 0 and refresh_count != 0:
                epd.init()
                epd.displayPartBaseImage(epd.getbuffer(Image.new('1', (epd.height, epd.width), 255)))
            
            image = Image.new('1', (epd.height, epd.width), 255) 
            draw = ImageDraw.Draw(image)

            cpu = psutil.cpu_percent()
            cpu_history.pop(0)
            cpu_history.append(cpu)

            draw.text((5, 5), time.strftime('%b %d, %y'), font=font_sm, fill=0)
            draw.text((5, 20), time.strftime('%H:%M:%S'), font=font_lg_bold, fill=0)
            draw.line([(5, 55), (120, 55)], fill=0, width=1)

            draw.text((5, 65), f"CPU usage: {cpu}%", font=font_sm, fill=0)
            temp = os.popen("vcgencmd measure_temp").readline().replace("temp=","").replace("'C\n","")
            draw.text((5, 82), f"CPU Tem: {temp}°C", font=font_sm, fill=0)
            draw.text((5, 100), f"IP: {get_ip()}", font=font_ip, fill=0)

            draw_cat(draw, 170, 25, cpu)
            draw.text((160, 45), hostname, font=font_sm, fill=0)
            draw_graph(draw, cpu_history, 135, 115, 105, 50)

            epd.displayPartial(epd.getbuffer(image))
            refresh_count += 1
            time.sleep(5)
    except KeyboardInterrupt:
        epd2in13_V3.epdconfig.module_exit()
        exit()

if __name__ == "__main__":
    main()
EOF

    echo "[6/7] Creating Systemd Service..."
    USER_NAME=$(whoami)
    SCRIPT_DIR="/home/$USER_NAME/e-Paper/RaspberryPi_JetsonNano/python/examples"
    
    # Create service file, dynamically injecting the current user and paths
    sudo bash -c "cat << EOF_SERVICE > /etc/systemd/system/epaper_dash.service
[Unit]
Description=E-Paper Cat Dashboard Service
After=network.target

[Service]
WorkingDirectory=$SCRIPT_DIR
ExecStart=/usr/bin/python3 $SCRIPT_DIR/cat_dash_v3.py
Restart=always
RestartSec=10
User=$USER_NAME
StandardOutput=inherit
StandardError=inherit

[Install]
WantedBy=multi-user.target
EOF_SERVICE"

    echo "[7/7] Enabling and Starting Service..."
    sudo systemctl daemon-reload
    sudo systemctl enable epaper_dash.service
    sudo systemctl start epaper_dash.service

    echo "=========================================="
    echo "  Success! Your Pi Pal is now running.    "
    echo "=========================================="
else
    echo "=========================================="
    echo "  Setup aborted. Please check your wiring "
    echo "  and ensure you have the V3 HAT model.   "
    echo "=========================================="
fi
