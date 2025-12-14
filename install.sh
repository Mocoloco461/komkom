#!/bin/bash

# Komkom Installer - English Version
# Command line coffee maker tool installation

set -e

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="komkom"
CONFIG_DIR="$HOME/.komkom"

echo "☕ Starting Komkom installation..."

# Check permissions
if [[ $EUID -eq 0 ]]; then
    echo "❌ Don't run this script as root"
    exit 1
fi

# Create config directory
mkdir -p "$CONFIG_DIR"

# Create main komkom script
cat > "/tmp/$SCRIPT_NAME" << 'EOF'
#!/bin/bash

# Komkom - Command Line Coffee Maker Tool
# Version 2.0.0

CONFIG_DIR="$HOME/.komkom"
STATE_FILE="$CONFIG_DIR/state.json"

# Initialize state file
init_state() {
    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'JSON'
{
    "water_level": 0,
    "temperature": 20,
    "is_boiling": false,
    "last_sip": "",
    "daily_coffee_count": 0,
    "mood": "waiting"
}
JSON
    else
        # Migrate old tea_count to coffee_count for backward compatibility
        if grep -q "daily_tea_count" "$STATE_FILE" 2>/dev/null; then
            python3 -c "
import json
try:
    with open('$STATE_FILE', 'r') as f:
        data = json.load(f)
    if 'daily_tea_count' in data:
        data['daily_coffee_count'] = data.pop('daily_tea_count')
        with open('$STATE_FILE', 'w') as f:
            json.dump(data, f, indent=2)
except:
    pass
" 2>/dev/null || true
        fi
    fi
}

# Read current state
get_state() {
    local key="$1"
    python3 -c "
import json
with open('$STATE_FILE', 'r') as f:
    data = json.load(f)
print(data.get('$key', ''))
"
}

# Update state
update_state() {
    local key="$1"
    local value="$2"
    python3 -c "
import json
with open('$STATE_FILE', 'r') as f:
    data = json.load(f)
data['$key'] = '$value'
with open('$STATE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

# Water filling animation
animate_filling() {
    echo -e "\033[1;36m💧 Filling with water...\033[0m"
    local frames=(
        "┌─────────────────────────┐\n│                         │\n│                         │\n│                         │\n│                         │\n│                         │\n└─────────────────────────┘\n\033[2mFilling: 0%\033[0m"
        "┌─────────────────────────┐\n│                         │\n│                         │\n│                         │\n│                         │\n│ \033[1;34m💧💧💧💧💧💧💧\033[0m           │\n└─────────────────────────┘\n\033[2mFilling: 20%\033[0m"
        "┌─────────────────────────┐\n│                         │\n│                         │\n│                         │\n│ \033[1;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n└─────────────────────────┘\n\033[2mFilling: 40%\033[0m"
        "┌─────────────────────────┐\n│                         │\n│                         │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n└─────────────────────────┘\n\033[2mFilling: 60%\033[0m"
        "┌─────────────────────────┐\n│                         │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n└─────────────────────────┘\n\033[2mFilling: 80%\033[0m"
        "┌─────────────────────────┐\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n│ \033[1;36m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈\033[0m      │\n└─────────────────────────┘\n\033[2mFilling: 100%\033[0m"
    )
    
    for frame in "${frames[@]}"; do
        clear
        echo -e "☕ \033[1mCoffee Maker\033[0m\n"
        echo -e "$frame"
        sleep 0.25
    done
    
    echo ""
    echo -e "\033[1;32m✅ Water reservoir is full!\033[0m"
    update_state "water_level" "100"
    update_state "mood" "ready"
}

# Boiling animation
animate_boiling() {
    echo -e "\033[1;31m🔥 Heating water...\033[0m"
    local temp=20
    
    while [[ $temp -lt 100 ]]; do
        clear
        echo -e "☕ \033[1mCoffee Maker\033[0m"
        echo ""
        echo -e "\033[1;33m🔥 Heating up...\033[0m"
        
        # Progress bar
        local progress=$((temp * 40 / 100))
        local bar=""
        for ((i=0; i<progress; i++)); do bar+="█"; done
        for ((i=progress; i<40; i++)); do bar+="░"; done
        echo -e "[\033[1;31m$bar\033[0m]"
        
        echo -e "\033[1;36m🌡️  Temperature: ${temp}°C / 100°C\033[0m"
        echo ""
        
        # Enhanced bubble animation with colors
        case $((temp % 8)) in
            0) echo -e "          \033[2m.\033[0m  \033[2m.\033[0m  \033[2m.\033[0m     " ;;
            1) echo -e "        \033[2m.\033[0m  \033[1;36mo\033[0m  \033[2m.\033[0m  \033[1;36mo\033[0m    " ;;
            2) echo -e "       \033[1;36mo\033[0m  \033[2m.\033[0m  \033[1;37mO\033[0m  \033[2m.\033[0m  \033[1;36mo\033[0m  " ;;
            3) echo -e "      \033[2m.\033[0m  \033[1;37mO\033[0m  \033[2m.\033[0m  \033[1;37mO\033[0m  \033[2m.\033[0m   " ;;
            4) echo -e "     \033[1;36mo\033[0m  \033[2m.\033[0m  \033[1;37mO\033[0m  \033[2m.\033[0m  \033[1;36mo\033[0m  \033[2m.\033[0m" ;;
            5) echo -e "      \033[1;37mO\033[0m  \033[1;36mo\033[0m  \033[2m.\033[0m  \033[1;36mo\033[0m  \033[1;37mO\033[0m   " ;;
            6) echo -e "     \033[2m.\033[0m  \033[1;37mO\033[0m  \033[1;36mo\033[0m  \033[1;37mO\033[0m  \033[2m.\033[0m  \033[1;36mo\033[0m" ;;
            7) echo -e "      \033[1;36mo\033[0m  \033[2m.\033[0m  \033[1;37mO\033[0m  \033[2m.\033[0m  \033[1;36mo\033[0m   " ;;
        esac
        
        sleep 0.08
        temp=$((temp + 4))
        update_state "temperature" "$temp"
    done
    
    # Steam animation with colors
    clear
    echo -e "☕ \033[1mCoffee Maker\033[0m\n"
    echo -e "\033[1;32m💨 Water is boiling!\033[0m"
    for i in {1..6}; do
        case $((i % 3)) in
            0) echo -e "\n    \033[2m~~~ ~~~~ ~~~\033[0m" ;;
            1) echo -e "\n   \033[2m~~~~ ~~~ ~~~~\033[0m" ;;
            2) echo -e "\n    \033[2m~~ ~~~~ ~~\033[0m" ;;
        esac
        sleep 0.15
    done
    
    update_state "is_boiling" "true"
    update_state "mood" "excited"
}

# Pouring animation
animate_pouring() {
    local container="$1"
    echo -e "\033[1;33m☕ Pouring coffee into $container...\033[0m"
    
    local frames=(
        "      ☕\n                  \n                  \n                  \n        $container"
        "      ☕\n       \\\\          \n                  \n                  \n        $container"
        "      ☕\n        \\\\         \n         \\\\        \n                  \n        $container"
        "      ☕\n         \\\\        \n          \\\\       \n           \\\\      \n        ▓ $container"
        "      ☕\n          \\\\       \n           \\\\      \n            \\\\     \n        ▓▓ $container"
        "      ☕\n           \\\\      \n            \\\\     \n                  \n        ▓▓▓ $container"
        "      ☕\n                  \n                  \n                  \n        ▓▓▓▓ $container"
    )
    
    for frame in "${frames[@]}"; do
        clear
        echo -e "☕ \033[1mCoffee Maker → Your $container\033[0m\n"
        echo -e "$frame"
        sleep 0.2
    done
    
    echo ""
    echo -e "\033[1;32m✅ Successfully poured fresh coffee into $container!\033[0m"
    echo -e "\033[2m(Smells amazing!)\033[0m"
    update_state "mood" "satisfied"
}

# Status display with ASCII art
show_status() {
    local water_level=$(get_state "water_level")
    local temperature=$(get_state "temperature")
    local mood=$(get_state "mood")
    local daily_count=$(get_state "daily_coffee_count")
    
    clear
    echo -e "\033[1;36m╔═════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;36m║\033[0m      \033[1mCoffee Maker Status\033[0m             \033[1;36m║\033[0m"
    echo -e "\033[1;36m╠═════════════════════════════════════════╣\033[0m"
    
    # Water level with color
    local water_color="\033[1;31m"
    if [ "$water_level" -gt 50 ]; then
        water_color="\033[1;32m"
    elif [ "$water_level" -gt 20 ]; then
        water_color="\033[1;33m"
    fi
    echo -e "\033[1;36m║\033[0m 💧 Water Level: ${water_color}${water_level}%\033[0m                  \033[1;36m║\033[0m"
    
    # Temperature with color
    local temp_color="\033[1;34m"
    if [ "$temperature" -gt 80 ]; then
        temp_color="\033[1;31m"
    elif [ "$temperature" -gt 50 ]; then
        temp_color="\033[1;33m"
    fi
    echo -e "\033[1;36m║\033[0m 🌡️  Temperature: ${temp_color}${temperature}°C\033[0m                \033[1;36m║\033[0m"
    
    echo -e "\033[1;36m║\033[0m ☕ Cups of coffee today: \033[1;35m${daily_count}\033[0m           \033[1;36m║\033[0m"
    echo -e "\033[1;36m║\033[0m 😊 Mood: \033[1;33m${mood}\033[0m                        \033[1;36m║\033[0m"
    echo -e "\033[1;36m╠═════════════════════════════════════════╣\033[0m"
    
    # ASCII art coffee maker based on mood
    case "$mood" in
        "waiting")
            echo -e "\033[1;36m║\033[0m           ☕                          \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m         ( -.- )                       \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m    \033[2mWaiting for water...\033[0m            \033[1;36m║\033[0m"
            ;;
        "ready")
            echo -e "\033[1;36m║\033[0m           ☕                          \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m         \033[1;32m( ^_^ )\033[0m                      \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m    \033[1;32mReady to brew!\033[0m                  \033[1;36m║\033[0m"
            ;;
        "excited")
            echo -e "\033[1;36m║\033[0m           ☕💨                        \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m         \033[1;33m( ≧∇≦ )\033[0m                     \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m    \033[1;33mBrewing hot coffee!\033[0m             \033[1;36m║\033[0m"
            ;;
        "satisfied")
            echo -e "\033[1;36m║\033[0m           ☕                          \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m         \033[1;35m( ◡ ‿ ◡ )\033[0m                    \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m    \033[1;35mCoffee served!\033[0m                  \033[1;36m║\033[0m"
            ;;
        "zen")
            echo -e "\033[1;36m║\033[0m           ☕                          \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m         \033[1;32m( ˘ ³˘)\033[0m                      \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m    \033[1;32mEnjoy your coffee!\033[0m              \033[1;36m║\033[0m"
            ;;
        "empty")
            echo -e "\033[1;36m║\033[0m           ☕                          \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m         \033[2m( ._. )\033[0m                      \033[1;36m║\033[0m"
            echo -e "\033[1;36m║\033[0m    \033[2mEmpty... needs water\033[0m            \033[1;36m║\033[0m"
            ;;
    esac
    
    echo -e "\033[1;36m╚═════════════════════════════════════════╝\033[0m"
}

# Coffee sipping with inspirational quotes
sip_coffee() {
    local quotes=(
        "Coffee is liquid creativity."
        "A cup of coffee is a cup of productivity."
        "Coffee time is code time."
        "Keep calm and drink coffee."
        "Good coffee = good code."
        "In coffee we trust."
        "Coffee: because adulting is hard."
        "Life is like coffee - it's all about how you brew it."
        "Coffee: the most important meal of the day."
        "Behind every successful person is a substantial amount of coffee."
        "Espresso yourself!"
        "Decaf? Never heard of it."
    )
    
    local random_quote=${quotes[$RANDOM % ${#quotes[@]}]}
    
    echo -e "\033[1;33m☕ Sipping gently...\033[0m"
    sleep 0.5
    
    # Animated sipping
    for i in {1..3}; do
        echo -ne "\r  \033[1;36m◠◡◠\033[0m  "
        sleep 0.3
        echo -ne "\r  \033[1;36m◡◠◡\033[0m  "
        sleep 0.3
    done
    echo ""
    
    sleep 0.5
    echo -e "\n\033[1;35m💭 \"$random_quote\"\033[0m"
    sleep 1.5
    
    local current_count=$(get_state "daily_coffee_count")
    update_state "daily_coffee_count" "$((current_count + 1))"
    update_state "mood" "zen"
    
    echo -e "\n\033[1;32m😌 Ahh... exactly what I needed.\033[0m"
    echo -e "\033[2mEnergy level: ████████░░ 80%\033[0m"
}

# Main function
main() {
    init_state
    
    case "$1" in
        "pull")
            if [[ "$2" == "water" ]]; then
                animate_filling
            else
                echo "❌ Usage: komkom pull water"
            fi
            ;;
        "boil")
            local water_level=$(get_state "water_level")
            if [[ "$water_level" -eq 0 ]]; then
                echo -e "\033[1;31m❌ No water in coffee maker! Run: komkom pull water\033[0m"
                exit 1
            fi
            animate_boiling
            ;;
        "pour")
            local container="${2:-cup}"
            local is_boiling=$(get_state "is_boiling")
            if [[ "$is_boiling" != "true" ]]; then
                echo -e "\033[1;31m❌ Water is not hot enough! Run: komkom boil\033[0m"
                exit 1
            fi
            
            case "$container" in
                "cup"|"mug"|"thermos")
                    animate_pouring "$container"
                    ;;
                "bathtub")
                    echo -e "\033[1;31m🚫 Management has decided to suspend you temporarily.\033[0m"
                    echo -e "\033[1;31mReason: Attempted coffee pouring into bathtub.\033[0m"
                    echo -e "\033[1;31mCoffee is precious, don't waste it!\033[0m"
                    exit 1
                    ;;
                *)
                    echo -e "\033[1;31m❌ Unsupported container. Try: cup, mug, or thermos\033[0m"
                    exit 1
                    ;;
            esac
            ;;
        "status")
            show_status
            ;;
        "empty")
            echo -e "\033[1;33m🚰 Emptying water reservoir...\033[0m"
            sleep 0.5
            for i in {1..3}; do
                echo -ne "\r  [\033[2m███░░░░░░░\033[0m] Draining...  "
                sleep 0.2
                echo -ne "\r  [\033[2m██████░░░░\033[0m] Draining...  "
                sleep 0.2
                echo -ne "\r  [\033[2m█████████░\033[0m] Draining...  "
                sleep 0.2
            done
            echo -e "\r  [\033[1;32m██████████\033[0m] Complete!    "
            update_state "water_level" "0"
            update_state "temperature" "20"
            update_state "is_boiling" "false"
            update_state "mood" "empty"
            echo -e "\033[1;32m✅ Coffee maker is empty and clean.\033[0m"
            ;;
        "sip")
            sip_coffee
            ;;
        "help"|"--help"|"-h")
            echo -e "\033[1;36m╔════════════════════════════════════════╗\033[0m"
            echo -e "\033[1;36m║\033[0m  ☕ \033[1mKomkom - Coffee Maker Tool\033[0m      \033[1;36m║\033[0m"
            echo -e "\033[1;36m╚════════════════════════════════════════╝\033[0m"
            echo ""
            echo -e "\033[1mUsage:\033[0m"
            echo -e "  \033[1;33mkomkom pull water\033[0m      - Fill with water"
            echo -e "  \033[1;33mkomkom boil\033[0m           - Heat water for coffee"
            echo -e "  \033[1;33mkomkom pour [vessel]\033[0m  - Pour coffee (cup/mug/thermos)"
            echo -e "  \033[1;33mkomkom status\033[0m         - Show current status"
            echo -e "  \033[1;33mkomkom empty\033[0m          - Empty coffee maker"
            echo -e "  \033[1;33mkomkom sip\033[0m            - Sip your coffee ☕"
            echo -e "  \033[1;33mkomkom help\033[0m           - Show this help"
            echo ""
            echo -e "\033[2mExample workflow:\033[0m"
            echo -e "\033[2m  komkom pull water → komkom boil → komkom pour mug → komkom sip\033[0m"
            ;;
        *)
            echo -e "\033[1;31m❌ Unknown command.\033[0m Run: \033[1;33mkomkom help\033[0m"
            exit 1
            ;;
    esac
}

main "$@"
EOF

# Copy file to final location
echo "📋 Copying files..."
sudo cp "/tmp/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "✅ Komkom coffee maker installed successfully!"
echo ""
echo "🚀 Start brewing with:"
echo "  komkom help"
echo "  komkom pull water"
echo "  komkom boil"
echo "  komkom pour mug"
echo "  komkom sip"
echo ""
echo "☕ Enjoy your virtual coffee!"
