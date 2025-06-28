#!/data/data/com.termux/files/usr/bin/bash

# Rənglər
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No color

# ASCII Banner
clear
echo -e "${GREEN}"
cat << "EOF"
 _   _ _     _   _      _     
| | | (_)   | | | |    | |    
| | | |_  __| | | |__  | |__  
| | | | |/ _\` | | '_ \ | '_ \ 
| |_| | | (_| | | | | || | | |
 \___/|_|\__,_| |_| |_||_| |_|

          Ubuntu VNC XFCE
         Made for Termux
EOF
echo -e "${NC}"
sleep 2

# Step 1: proot-distro yüklə
echo -e "${GREEN}[1/6] proot-distro yüklənir...${NC}"
pkg update -y && pkg install proot-distro -y

# Step 2: Əgər ubuntu artıq varsa sil
if proot-distro list | grep -q "ubuntu"; then
    echo -e "${RED}[!] Mövcud Ubuntu aşkarlandı, silinir...${NC}"
    proot-distro remove ubuntu
fi

# Step 3: Ubuntu təmiz şəkildə yüklənir
echo -e "${GREEN}[2/6] Ubuntu təmiz şəkildə quraşdırılır...${NC}"
proot-distro install ubuntu

# Step 4: Paketləri quraşdır
echo -e "${GREEN}[3/6] Ubuntu içində paketlər yenilənir və XFCE, VNC, Firefox quraşdırılır...${NC}"
proot-distro login ubuntu -- bash -c "
apt update -y && apt upgrade -y

# Əvvəlki quraşdırmalar varsa sil
apt purge -y xfce4 xfce4-goodies tightvncserver autocutsel firefox
apt autoremove -y
apt clean

# Yenidən quraşdır
DEBIAN_FRONTEND=noninteractive apt install -y xfce4 xfce4-goodies tightvncserver autocutsel firefox
"

# Step 5: VNC konfiqurasiyası və başladılması
echo -e "${GREEN}[4/6] VNC konfiqurasiyası aparılır...${NC}"
proot-distro login ubuntu -- bash -c "
mkdir -p ~/.vnc
echo 'yourvncpassword' | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

cat > ~/.vnc/xstartup <<- EOM
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
EOM

chmod +x ~/.vnc/xstartup
"

# Step 6: VNC Serveri başladılır
echo -e "${GREEN}[5/6] VNC server başladılır...${NC}"
proot-distro login ubuntu -- bash -c "vncserver :1"

# Step 7: Status yoxlanılır
VNC_STATUS=$(proot-distro login ubuntu -- bash -c "pgrep Xtightvnc")
if [ -n \"$VNC_STATUS\" ]; then
    echo -e "${GREEN}[✓] VNC server uğurla başladı.${NC}"
else
    echo -e "${RED}[X] VNC server başlatmaqda problem yarandı.${NC}"
fi

# Final mesaj
echo -e "${GREEN}[6/6] Quraşdırma tamamlandı.${NC}"
echo -e "${GREEN}Ubuntu, XFCE və VNC uğurla quruldu.${NC}"
echo -e "${GREEN}Ubuntu-ya daxil olmaq üçün:${NC} ${RED}proot-distro login ubuntu${NC}"
echo -e "${GREEN}Ubuntu içində VNC serveri başlatmaq üçün:${NC} ${RED}vncserver :1${NC}"
echo -e "${GREEN}Dayandırmaq üçün:${NC} ${RED}vncserver -kill :1${NC}"
echo -e "${GREEN}VNC Viewer-dən qoşulmaq üçün: ${NC}${RED}localhost:1${NC}"
