# Function to show progress with bold, italic, and purple text

function info_msg() {
    echo -e "\033[1;3;94m$1\033[0m" 
}

# Function to provide success feedback with  bold, italic, and green text
function success_feedback() {
    echo -e "\n\033[1;3;92m$1\033[0m" 
}

# Function to provide error feedback with bold, italic, and red text
function error_feedback() {
    echo -e "\n\033[1;3;91mError: $1\033[0m"
}

confirm() {
    while true; do
        read -p "$1 (yes/no): " -r
        case "$REPLY" in
            yes ) return 0 ;;
            no ) return 1 ;;
            * ) echo "Please answer yes or no." ;;
        esac
    done
}


# Function to install necessary packages from specified files in the packages directory
install_packages() {
    local package_files=("$@")
    local filenames=()

    for package_file in "${package_files[@]}"; do
        filenames+=("$(basename "$package_file")")
    done
    info_msg "Preparing to process files: ${filenames[*]}"

    # User confirmation to proceed
    if ! confirm "Do you want to proceed with installing packages from these files?"; then
        error_feedback "User aborted the installation."
        return 1
    fi

    # Determine package manager
    if command -v yay &> /dev/null; then
        package_manager="yay"
    else
        package_manager="pacman"
    fi

    for package_file in "${package_files[@]}"; do
        if [[ ! -f $package_file ]]; then
            error_feedback "Package file $package_file does not exist."
            continue
        fi

        while IFS= read -r package; do
            if ! command -v "$package" &> /dev/null; then
                info_msg "Installing $package with $package_manager..."
                if [[ $package_manager == "yay" ]]; then
                    yay -Sy --needed --noconfirm "$package"
                else
                    pacman -Sy --needed --noconfirm "$package"
                fi
            else
                info_msg "$package is already installed"
            fi
        done < "$package_file"
    done
}

# Function to run multiple scripted installations
install_packages_scripted() {
    local script_files=("$@")
    local filenames=()

    # Validate all script files
    for script_file in "${script_files[@]}"; do
        filenames+=("$(basename "$script_file")")
        if [[ ! -f $script_file ]]; then
            error_feedback "Script file $script_file does not exist."
            return 1
        fi
    done

    # User confirmation to proceed
    info_msg "Preparing to run all installation scripts from: ${filenames[*]}"
    if ! confirm "Do you want to proceed with running the scripts from these files?"; then
        error_feedback "User aborted the installation."
        return 1
    fi

    for script_file in "${script_files[@]}"; do
        while IFS= read -r script_name; do
            # Skip empty lines
            [[ -z "$script_name" ]] && continue

            script_command=""
            
            # Read the script command until we hit an empty line
            while IFS= read -r line; do
                # Break if we hit an empty line and stop appending to script_command
                [[ -z "$line" ]] && break
                script_command+="$line"$'\n'
            done

            # Skip if script_command is empty (handling cases where there are multiple empty lines)
            [[ -z "$script_command" ]] && continue

            info_msg "Running installation script: $script_name"

            # Execute the script in a subshell
            bash -c "$script_command"

            info_msg "Installation completed for $script_name."
        done < "$script_file"
    done
}
