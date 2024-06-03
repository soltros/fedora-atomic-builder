#!/bin/bash

# Function to display the menu
show_menu() {
    echo "Select an Option:"
    echo "1) Install Kopia and KopiaUI"
    echo "2) Setup Nvidia GPU drivers"
    echo "3) Setup RPM Fusion Free and Non-free"
    echo "4) Setup Docker"
    echo "5) Rebase to Silverblue (WARNING: Potentially destructive)"
    echo "6) Rebase to Fedora Kinoite (WARNING: Potentially destructive)"
    echo "7) Setup Flatpak"
    echo "8) Install Essential Flatpak Apps"
    echo "9) Install Additional Flatpak Apps"
    echo "10) Setup Bluetooth"
    echo "11) Setup Tailscale"
    echo "12) Install Nix (Experimental)"
    echo "13) Exit"
}

# Function to execute the selected command
execute_command() {
    case $choice in
        1)
            sudo rpm-ostree install kopia kopia-ui --apply-live
            ;;
        2)
            sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia --apply-live
            sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau \
                --append=modprobe.blacklist=nouveau \
                --append=nvidia-drm.modeset=1
            ;;
        3)
            sudo rpm-ostree install \
                https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm \
                https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-stable.noarch.rpm --apply-live
            ;;
        4)
            sudo rpm-ostree install moby-engine docker-compose --apply-live
            sudo systemctl enable --now docker
            sudo usermod -aG docker $USER
            ;;
        5)
            read -rp "WARNING: This will rebase your system to Silverblue. Are you sure? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                sudo rpm-ostree rebase fedora:fedora/40/x86_64/silverblue
                echo "Rebasing to Silverblue..."
            else
                echo "Rebase cancelled."
            fi
            ;;
        6)
            read -rp "WARNING: This will rebase your system to Kinoite. Are you sure? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                sudo rpm-ostree rebase fedora:fedora/40/x86_64/kinoite
                echo "Rebasing to Fedora Kinoite..."
            else
                echo "Rebase cancelled."
            fi
            ;;
        7)
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            ;;
        8)
            flatpak install -y org.gimp.GIMP org.videolan.VLC org.mozilla.firefox \
                org.mozilla.Thunderbird org.gnome.gitg 
            ;;
        9)
            flatpak install -y com.discordapp.Discord io.kopia.KopiaUI com.spotify.Client \
                com.valvesoftware.Steam org.telegram.desktop tv.plex.PlexDesktop \
                com.nextcloud.desktopclient.nextcloud im.riot.Riot
            ;;
        10)
            sudo rpm-ostree install bluez --apply-live
            sudo modprobe btusb
            sudo systemctl enable --now bluetooth
            ;;
        11)  # Tailscale setup
            read -rp "WARNING: This will install Tailscale. Are you sure? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                sudo rpm-ostree install curl --apply-live
                sudo curl -s https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo > /dev/null
                sudo wget https://pkgs.tailscale.com/stable/fedora/repo.gpg -O /etc/pki/rpm-gpg/tailscale.gpg
                sudo sed -i 's"https://pkgs.tailscale.com/stable/fedora/repo.gpg"file:///etc/pki/rpm-gpg/tailscale.gpg' /etc/yum.repos.d/tailscale.repo
                sudo rpm-ostree install --apply-live tailscale
                sudo systemctl enable --now tailscaled
                sudo tailscale up
            else
                echo "Tailscale installation cancelled."
            fi
            ;;
        12)
            echo "WARNING: Nix installation on Fedora Atomic is experimental."
            read -rp "Do you want to proceed? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                curl -L https://raw.githubusercontent.com/dnkmmr69420/nix-installer-scripts/ffff9f35692f753f09c472c9c98e21b76b29709c/installer-scripts/silverblue-nix-installer.sh | sudo bash
            else
                echo "Nix installation cancelled."
            fi
            ;;
        13)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid selection. Please try again."
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    read -rp "Enter your choice: " choice
    execute_command
done
