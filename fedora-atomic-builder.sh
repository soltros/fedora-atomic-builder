#!/bin/bash

# Function to display the menu
show_menu() {
    echo "Select an Option:"
    echo "1) Install Kopia and KopiaUI"
    echo "2) Setup Nvidia GPU drivers"
    echo "3) Setup RPM Fusion Free and Non-free"
    echo "4) Configure Dbus"
    echo "5) Configure Plugdev"
    echo "6) Configure Udev"
    echo "7) Setup Docker"
    echo "8) Rebase on Silverblue"
    echo "9) Rebase on Fedora Kinoite"
    echo "10) Setup Flatpak"
    echo "11) Setup Derrik's Flatpak packages"
    echo "12) Setup Derrik's additional Flatpak packages"
    echo "13) Setup Bluetooth"
    echo "14) Setup Tailscale"
    echo "15) Install Nix"
    echo "16) Exit"
}

# Function to execute the selected command
execute_command() {
    case $choice in
        1)
            sudo rpm --import https://kopia.io/signing-key
            cat <<EOF | sudo tee /etc/yum.repos.d/kopia.repo
[Kopia]
name=Kopia
baseurl=http://packages.kopia.io/rpm/stable/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://kopia.io/signing-key
EOF
            sudo yum install kopia
            sudo yum install kopia-ui
            echo "Installing Kopia and KopiaUI..."
            ;;
        2)
            sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia --apply-live
            sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia-cuda --apply-live
            sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
            echo "Setting up Nvidia GPU drivers..."
            ;;
        3)
            sudo rpm-ostree install \
                https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm --apply-live
            echo "Setting up RPM Fusion Free and Non-free repositories..."
            ;;
        4)
            sudo rpm-ostree install dbus dbus-x11 --apply-live
            sudo systemctl enable dbus
            sudo systemctl start dbus
            echo "Configuring Dbus..."
            ;;
        5)
            sudo groupadd plugdev
            sudo usermod -a -G plugdev derrik
            echo "Configuring Plugdev..."
            ;;
        6)
            sudo rpm-ostree install eudev --apply-live
            echo "Configuring Udev..."
            ;;
        7)
            sudo rpm-ostree install docker docker-compose --apply-live
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo usermod -aG docker derrik
            echo "Setting up Docker..."
            ;;
        8)
            sudo rpm-ostree rebase fedora:fedora/38/x86_64/silverblue
            echo "Rebasing on Silverblue..."
            ;;
        9)
            sudo rpm-ostree rebase fedora:fedora/38/x86_64/kinoite
            echo "Rebasing on Fedora Kinoite..."
            ;;
        10)
            sudo rpm-ostree install flatpak --apply-live
            flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            echo "Setting up Flatpak..."
            ;;
        11)
            flatpak install org.gimp.GIMP org.videolan.VLC org.mozilla.firefox org.mozilla.Thunderbird org.gnome.gitg org.gnome.Extensions org.kde.kdenlive org.winehq.Wine com.github.tchx84.Flatseal com.ultimaker.cura org.blender.Blender -y
            echo "Setting up Derrik's Flatpak packages..."
            ;;
        12)
            flatpak install com.mattjakeman.ExtensionManager com.discordapp.Discord io.kopia.KopiaUI com.spotify.Client com.valvesoftware.Steam org.telegram.desktop tv.plex.PlexDesktop com.nextcloud.desktopclient.nextcloud im.riot.Riot -y
            echo "Setting up Derrik's additional Flatpak packages... - Don't run as root"
            ;;
        13)
            sudo rpm-ostree install bluez --apply-live
            sudo modprobe btusb
            sudo usermod -aG lp $USER
            sudo systemctl enable bluetooth
            sudo systemctl start bluetooth
            echo "Setting up Bluetooth..."
            ;;
        14)
            sudo systemctl enable tailscale
            sudo systemctl start tailscale
            sudo tailscale up --qr
            echo "Configuring Tailscale..."
            ;;
        15)
            curl -L https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/ffff9f35692f753f09c472c9c98e21b76b29709c/installer-scripts/silverblue-nix-installer.sh | sudo bash
            echo "Installing Nix..."
            ;;
        16)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid selection. Please try again."
            ;;
    esac
}

# Main loop to display the menu and execute commands
while true; do
    show_menu
    read -rp "Enter your choice: " choice
    execute_command
done
