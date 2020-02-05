#!/bin/bash

APT_PACKAGES="
i3 ubuntu-drivers-common mesa-utils mesa-utils-extra gnupg numlockx xautolock\
 scrot xorg xserver-xorg wget unzip wpasupplicant bluez net-tools perl\
 microcode.ctl intel-microcode tlp rxvt-unicode git vim fonts-font-awesome\
 fonts-hack xsel xdg-open fonts-symbola xinit"

CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

TEXT_STARTX="
# Setup startx
if [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then
  startx
fi"

TEXT_XINIT='
# Setup i3
alias open="xdg-open"
i3'

TEXT_AUTOLOGIN="
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I 38400 linux
"

# Install packages
sudo apt -y install "$APT_PACKAGES"

# Add startx to ~/.bashrc if not existing
case `grep -Fx "# Setup startx" "$HOME/.bashrc" >/dev/null; echo $?` in
  0)
    echo "startx already setup, skipping"
    ;;
  1)
    echo "$TEXT_STARTX" >> $HOME/.bashrc
    ;;
  *)
    # code if an error occurred
    ;;
esac

# Setup ~/.xinitrc
case `grep -Fx "# Setup i3" "$HOME/.xinitrc" >/dev/null; echo $?` in
  0)
	echo "xinitrc already setup, skipping"
	;;

  *)
	echo "$TEXT_XINIT" >> $HOME/.xinitrc
	;;
esac

# Setup autologin
if [ ! -f "/etc/systemd/system/getty@tty1.service.d/autologin.conf" ]; then
	sudo mkdir -pv /etc/systemd/system/getty@tty1.service.d/
	echo "$TEXT_AUTOLOGIN" | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf
	sudo systemctl enable getty@tty1.service
else
	echo "Autologin already enabled, skipping"
fi

# Setup urxvt selection
if [ ! -f "$HOME/.urxvt/ext/keyboard-select" ]; then
	mkdir -pv $HOME/.urxvt/ext
	git clone https://github.com/muennich/urxvt-perls
	cp urxvt-perls/keyboard-select $HOME/.urxvt/ext/keyboard-select
	rm -rf urxvt-perls
else
	echo "urxvt select already setup, skipping"
fi

# Copy Xresources
if [ ! -f "$HOME/.Xresources" ]; then
	cp Xresources $HOME/.Xresources
else
	echo "Xresources setup already, skipping"
fi

# Setup Google Chrome if not installed
if [ ! -f "/usr/bin/google-chrome" ]; then
	rm /tmp/chrome.deb
	wget --show-progress -O /tmp/chrome.deb "$CHROME_URL"
	sudo dpkg -i /tmp/chrome.deb
	sudo apt install -f -y
else
	echo "Google Chrome already setup, skipping"
fi
