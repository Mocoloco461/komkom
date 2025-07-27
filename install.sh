#!/bin/bash

# Komkom Installer - English Version
# Command line kettle tool installation

set -e

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="komkom"
CONFIG_DIR="$HOME/.komkom"

echo "🫖 Starting Komkom installation..."

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

# Komkom - Command Line Kettle Tool
# Version 1.0.0

CONFIG_DIR="$HOME/.komkom"
STATE_FILE="$CONFIG_DIR/state.json"

# Initialize state file
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'JSON'
{
    "water_level": 0,
    "temperature": 20,
    "is_boiling": false,
    "last_sip": "",
    "daily_tea_count": 0,
    "mood": "waiting"
}
JSON
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
    echo "💧 Filling with water..."
    local frames=(
        "┌─────────────────────────┐\n│                         │\n│                         │\n│                         │\n│                         │\n└─────────────────────────┘"
        "┌─────────────────────────┐\n│                         │\n│                         │\n│                         │\n│ ~~~~~~~~~~~~~~~~~~~     │\n└─────────────────────────┘"
        "┌─────────────────────────┐\n│                         │\n│                         │\n│ ~~~~~~~~~~~~~~~~~~~     │\n│ ~~~~~~~~~~~~~~~~~~~     │\n└─────────────────────────┘"
        "┌─────────────────────────┐\n│                         │\n│ ~~~~~~~~~~~~~~~~~~~     │\n│ ~~~~~~~~~~~~~~~~~~~     │\n│ ~~~~~~~~~~~~~~~~~~~     │\n└─────────────────────────┘"
        "┌─────────────────────────┐\n│ ~~~~~~~~~~~~~~~~~~~     │\n│ ~~~~~~~~~~~~~~~~~~~     │\n│ ~~~~~~~~~~~~~~~~~~~     │\n│ ~~~~~~~~~~~~~~~~~~~     │\n└─────────────────────────┘"
    )
    
    for frame in "${frames[@]}"; do
        clear
        echo -e "$frame"
        sleep 0.3
    done
    
    echo "✅ Kettle is full!"
    update_state "water_level" "100"
    update_state "mood" "ready"
}

# Boiling animation
animate_boiling() {
    echo "🔥 Boiling water..."
    local temp=20
    
    while [[ $temp -lt 100 ]]; do
        clear
        echo "🫖 Kettle heating up..."
        echo "🌡️  Temperature: ${temp}°C"
        
        # Bubble animation
        case $((temp % 4)) in
            0) echo "     .  .  .     " ;;
            1) echo "   .  o  .  o    " ;;
            2) echo "  o  .  O  .  o  " ;;
            3) echo " .  O  .  O  .   " ;;
        esac
        
        sleep 0.1
        temp=$((temp + 5))
        update_state "temperature" "$temp"
    done
    
    # Steam animation
    clear
    echo "💨 Water is boiling!"
    for i in {1..5}; do
        echo -e "\n    ~~~ ~~~~ ~~~"
        sleep 0.2
    done
    
    update_state "is_boiling" "true"
    update_state "mood" "excited"
}

# Pouring animation
animate_pouring() {
    local container="$1"
    echo "🫗 Pouring into $container..."
    
    local frames=(
        "🫖     "
        "🫖 \\   "
        "🫖  \\  "
        "🫖   \\ "
        "🫖    \\"
    )
    
    for frame in "${frames[@]}"; do
        clear
        echo "$frame"
        echo "     ☕"
        sleep 0.3
    done
    
    echo "✅ Successfully poured into $container!"
    update_state "mood" "satisfied"
}

# Status display with ASCII art
show_status() {
    local water_level=$(get_state "water_level")
    local temperature=$(get_state "temperature")
    local mood=$(get_state "mood")
    local daily_count=$(get_state "daily_tea_count")
    
    clear
    echo "┌─────────────────────────────────────┐"
    echo "│           🫖 Kettle Status           │"
    echo "├─────────────────────────────────────┤"
    echo "│ Water Level: ${water_level}%                    │"
    echo "│ Temperature: ${temperature}°C                   │"
    echo "│ Cups of tea today: ${daily_count}              │"
    echo "│ Mood: ${mood}                         │"
    echo "├─────────────────────────────────────┤"
    
    # ASCII art kettle based on mood
    case "$mood" in
        "waiting")
            echo "│      🫖                             │"
            echo "│    ( -.- )                          │"
            ;;
        "ready")
            echo "│      🫖                             │"
            echo "│    ( ^_^ )                          │"
            ;;
        "excited")
            echo "│      🫖💨                           │"
            echo "│    ( ≧∇≦ )                          │"
            ;;
        "satisfied")
            echo "│      🫖                             │"
            echo "│    ( ◡ ‿ ◡ )                        │"
            ;;
        "zen")
            echo "│      🫖                             │"
            echo "│    ( ˘ ³˘)                          │"
            ;;
        "empty")
            echo "│      🫖                             │"
            echo "│    ( ._. )                          │"
            ;;
    esac
    
    echo "└─────────────────────────────────────┘"
}

# Tea sipping with inspirational quotes
sip_tea() {
    local quotes=(
        "Tea is liquid wisdom."
        "A cup of tea is a cup of peace."
        "Tea time is me time."
        "Keep calm and drink tea."
        "Good tea = good code."
        "In tea we trust."
        "Tea: because it's always five o'clock somewhere."
        "Life is like tea - it's all about how you make it."
    )
    
    local random_quote=${quotes[$RANDOM % ${#quotes[@]}]}
    
    echo "☕ Sipping gently..."
    sleep 1
    echo "💭 \"$random_quote\""
    sleep 2
    
    local current_count=$(get_state "daily_tea_count")
    update_state "daily_tea_count" "$((current_count + 1))"
    update_state "mood" "zen"
    
    echo "😌 Ahh... exactly what I needed."
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
                echo "❌ No water in kettle! Run: komkom pull water"
                exit 1
            fi
            animate_boiling
            ;;
        "pour")
            local container="${2:-cup}"
            local is_boiling=$(get_state "is_boiling")
            if [[ "$is_boiling" != "true" ]]; then
                echo "❌ Water is not boiling! Run: komkom boil"
                exit 1
            fi
            
            case "$container" in
                "cup"|"mug"|"thermos")
                    animate_pouring "$container"
                    ;;
                "bathtub")
                    echo "🚫 Management has decided to suspend you temporarily."
                    echo "Reason: Attempted tea pouring into bathtub."
                    exit 1
                    ;;
                *)
                    echo "❌ Unsupported container. Try: cup, mug, or thermos"
                    exit 1
                    ;;
            esac
            ;;
        "status")
            show_status
            ;;
        "empty")
            echo "🚰 Emptying all water..."
            sleep 1
            update_state "water_level" "0"
            update_state "temperature" "20"
            update_state "is_boiling" "false"
            update_state "mood" "empty"
            echo "✅ Kettle is empty."
            ;;
        "sip")
            sip_tea
            ;;
        "help"|"--help"|"-h")
            echo "🫖 Komkom - Command Line Kettle Tool"
            echo ""
            echo "Usage:"
            echo "  komkom pull water     - Fill with water"
            echo "  komkom boil          - Boil water"
            echo "  komkom pour [vessel] - Pour into vessel (cup/mug/thermos)"
            echo "  komkom status        - Show current status"
            echo "  komkom empty         - Empty kettle"
            echo "  komkom sip           - Sip tea"
            echo "  komkom help          - Show help"
            ;;
        *)
            echo "❌ Unknown command. Run: komkom help"
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

echo "✅ Komkom updated to English successfully!"
echo ""
echo "🚀 Start with:"
echo "  komkom help"
echo "  komkom pull water"
echo "  komkom boil"
echo "  komkom pour mug"
echo "  komkom sip"
echo ""
echo "☕ Enjoy your tea!"
