#!/bin/bash

# Configuration Installation Script
# This script copies configuration files to their appropriate locations
# with user choice and validation before writing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Available applications
APPS=("git" "npm" "pip" "helix" "claude")

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt="$1"
    local default="$2"

    while true; do
        if [ "$default" = "y" ]; then
            read -p "$prompt [Y/n] " yn
        else
            read -p "$prompt [y/N] " yn
        fi

        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) if [ "$default" = "y" ]; then return 0; else return 1; fi;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to show file diff and ask for confirmation
copy_with_confirmation() {
    local source_file="$1"
    local target_file="$2"
    local description="$3"

    if [ -f "$target_file" ]; then
        echo -e "${YELLOW}⚠️  $description already exists at: $target_file${NC}"

        if command -v diff >/dev/null 2>&1; then
            echo -e "${CYAN}📊 Showing differences:${NC}"
            diff -u "$target_file" "$source_file" 2>/dev/null || true
        else
            echo -e "${YELLOW}Note: 'diff' command not available, cannot show differences${NC}"
        fi

        if prompt_yes_no "Do you want to overwrite the existing file?" "n"; then
            echo -e "${GREEN}📋 Installing $description...${NC}"
            mkdir -p "$(dirname "$target_file")"
            cp "$source_file" "$target_file"
            echo -e "${GREEN}✅ Updated $description at $target_file${NC}"
        else
            echo -e "${YELLOW}⏭️  Skipped $description${NC}"
        fi
    else
        echo -e "${CYAN}📋 New file: $description${NC}"
        echo -e "${CYAN}Will be installed to: $target_file${NC}"

        if prompt_yes_no "Do you want to install this file?" "y"; then
            mkdir -p "$(dirname "$target_file")"
            cp "$source_file" "$target_file"
            echo -e "${GREEN}✅ Installed $description to $target_file${NC}"
        else
            echo -e "${YELLOW}⏭️  Skipped $description${NC}"
        fi
    fi
    echo
}

# Function to copy directory contents with confirmation
copy_dir_with_confirmation() {
    local source_dir="$1"
    local target_dir="$2"
    local description="$3"

    echo -e "${BLUE}📁 Processing $description...${NC}"

    if [ ! -d "$source_dir" ]; then
        echo -e "${YELLOW}⚠️  Source directory $source_dir not found${NC}"
        return
    fi

    mkdir -p "$target_dir"

    # Copy each file in the directory
    for file in "$source_dir"/*; do
        if [ -f "$file" ]; then
            local filename="$(basename "$file")"
            local target_file="$target_dir/$filename"
            copy_with_confirmation "$file" "$target_file" "$filename"
        fi
    done
}

# Main installation function
install_configs() {
    echo -e "${PURPLE}🎯 Configuration Installation Script${NC}"
    echo -e "${PURPLE}====================================${NC}"
    echo

    # Let user choose which apps to install
    echo -e "${CYAN}📋 Available applications:${NC}"
    for i in "${!APPS[@]}"; do
        echo -e "  $((i+1))) ${APPS[$i]}"
    done
    echo

    read -p "Enter the numbers of apps to install (comma-separated, or 'all' for all): " selection

    # Parse selection
    if [[ "$selection" == "all" ]]; then
        selected_apps=("${APPS[@]}")
    else
        IFS=',' read -ra selected_indices <<< "$selection"
        selected_apps=()
        for index in "${selected_indices[@]}"; do
            index=$((index-1))
            if [ $index -ge 0 ] && [ $index -lt ${#APPS[@]} ]; then
                selected_apps+=("${APPS[$index]}")
            fi
        done
    fi

    echo -e "${GREEN}Selected applications: ${selected_apps[*]}${NC}"
    echo

    # Install selected apps
    for app in "${selected_apps[@]}"; do
        case $app in
            "git")
                echo -e "${BLUE}📦 Git Configurations${NC}"
                copy_with_confirmation "$SCRIPT_DIR/git/.gitignore" "$HOME/.gitignore" "Git ignore file"
                copy_with_confirmation "$SCRIPT_DIR/git/.gitattribute" "$HOME/.gitattribute" "Git attributes file"

                if [ -d "$SCRIPT_DIR/git/hooks" ]; then
                    echo -e "${BLUE}📦 Git Hooks${NC}"
                    copy_dir_with_confirmation "$SCRIPT_DIR/git/hooks" "$HOME/.git/hooks" "Git hooks"
                fi
                ;;

            "npm")
                echo -e "${BLUE}📦 npm Configuration${NC}"
                copy_with_confirmation "$SCRIPT_DIR/npm/.npmrc" "$HOME/.npmrc" "npm configuration"
                ;;

            "pip")
                echo -e "${BLUE}📦 pip Configuration${NC}"
                copy_with_confirmation "$SCRIPT_DIR/pip/pip.ini" "$HOME/.pip/pip.ini" "pip configuration"
                ;;

            "helix")
                echo -e "${BLUE}📦 Helix Editor Configurations${NC}"
                copy_with_confirmation "$SCRIPT_DIR/helix/config.toml" "$HOME/.config/helix/config.toml" "Helix main configuration"
                copy_with_confirmation "$SCRIPT_DIR/helix/languages.toml" "$HOME/.config/helix/languages.toml" "Helix languages configuration"

                if [ -d "$SCRIPT_DIR/helix/themes" ]; then
                    echo -e "${BLUE}📦 Helix Themes${NC}"
                    copy_dir_with_confirmation "$SCRIPT_DIR/helix/themes" "$HOME/.config/helix/themes" "Helix themes"
                fi
                ;;

            "claude")
                echo -e "${BLUE}📦 Claude Configurations${NC}"
                echo -e "${YELLOW}⚠️  Claude configurations found in $SCRIPT_DIR/claude/${NC}"
                echo -e "${YELLOW}Please manually copy these files as needed for your Claude setup.${NC}"
                ;;
        esac
    done

    echo
    echo -e "${GREEN}🎉 Installation completed!${NC}"
    echo -e "${BLUE}Note: You were prompted for each file to ensure safety.${NC}"
}

# Run the installation
install_configs