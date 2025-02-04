#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No color

# ASCII Art Header
header() {
    echo -e "${CYAN}
       
 ██████╗███████╗ █████╗ ███████╗ █████╗ ██████╗      ██╗ █████╗ ██╗    ██╗
██╔════╝██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗     ██║██╔══██╗██║    ██║
██║     █████╗  ███████║███████╗███████║██████╔╝     ██║███████║██║ █╗ ██║
██║     ██╔══╝  ██╔══██║╚════██║██╔══██║██╔══██╗██   ██║██╔══██║██║███╗██║
╚██████╗███████╗██║  ██║███████║██║  ██║██║  ██║╚█████╔╝██║  ██║╚███╔███╔╝
 ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚════╝ ╚═╝  ╚═╝ ╚══╝╚══╝ 
                                                                          

                         by Mohammed Mehdi Boudir & Salah Eddine Rhazouni
${NC}"
}

# Caesar Cipher Functions (same as before)
encrypt() {
    local text="$1"
    local key="$2"
    local result=""
    
    for ((i = 0; i < ${#text}; i++)); do
        char="${text:$i:1}"
        if [[ "$char" =~ [a-zA-Z] ]]; then
            if [[ "$char" =~ [a-z] ]]; then
                alphabet="abcdefghijklmnopqrstuvwxyz"
            else
                alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            fi
            index=$(expr index "$alphabet" "$char")
            new_index=$(( ( (index + key - 1) % 26 + 26 ) % 26 ))
            result+="${alphabet:new_index:1}"
        elif [[ "$char" =~ [0-9] ]]; then
            new_char=$(( ( (char + key) % 10 + 10 ) % 10 ))
            result+="$new_char"
        else
            result+="$char"
        fi
    done
    echo "$result"
}

decrypt() {
    encrypt "$1" $((-$2))
}

find_key() {
    local crypt_text="$1"
    local uncrypt_text="$2"
    
    if [[ ${#crypt_text} -ne ${#uncrypt_text} ]]; then
        echo -e "${RED}NOT VALID: Lengths of the words don't match!${NC}"
        return -1
    fi

    for ((i = 0; i < ${#crypt_text}; i++)); do
        c="${crypt_text:$i:1}"
        u="${uncrypt_text:$i:1}"
        
        if [[ "$c" =~ [a-zA-Z] && "$u" =~ [a-zA-Z] ]]; then
            if [[ "$c" =~ [a-z] && ! "$u" =~ [a-z ]] || [[ "$c" =~ [A-Z] && ! "$u" =~ [A-Z] ]]; then
                echo -e "${RED}NOT VALID: Case mismatch!${NC}"
                return -1
            fi
            if [[ "$c" =~ [a-z] ]]; then
                alphabet="abcdefghijklmnopqrstuvwxyz"
            else
                alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            fi
            index_crypt=$(expr index "$alphabet" "$c")
            index_uncrypt=$(expr index "$alphabet" "$u")
            key=$(( (index_crypt - index_uncrypt + 26) % 26 ))
            echo "$key"
            return
        elif [[ "$c" =~ [0-9] && "$u" =~ [0-9] ]]; then
            key=$(( (c - u + 10) % 10 ))
            echo "$key"
            return
        elif [[ "$c" != "$u" ]]; then
            echo -e "${RED}NOT VALID: Mismatch between letters and numbers!${NC}"
            return -1
        fi
    done
    echo "0"
}

decrypt_without_key() {
    local text="$1"
    for key in {1..25}; do
        echo -e "${YELLOW}Trying key $key:${NC} $(decrypt "$text" $key)"
    done
}

main() {
    while true; do
        clear
        header
        echo -e "Do you want to Encrypt(1), Decrypt(2), Find Key(3), or Decrypt without key(4)?"
        read -p $'\n[*] Enter Option (1,2,3 or 4) : ' choice

        case $choice in
            1|2)
                while true; do
                    read -p "[*] Enter Shift Key (an integer): " key
                    if [[ "$key" =~ ^[0-9]+$ ]] && [ "$key" -ge 0 ]; then
                        break
                    else
                        echo -e "${RED}ERROR: Invalid Switch Key! Please enter a positive key !${NC}"
                    fi
                done
                read -p "[*] Please enter text: " text
                echo -e "\n${GREEN}==> Output Result :${NC}"
                if [ "$choice" == "1" ]; then
                    encrypt "$text" "$key"
                else
                    decrypt "$text" "$key"
                fi
                ;;

            3)
                read -p "[*] Please enter encrypted text: " crypt_text
                read -p "[*] Please enter decrypted text: " uncrypt_text
                key=$(find_key "$crypt_text" "$uncrypt_text")
                if [ "$key" -ne -1 ]; then
                    echo -e "\n${GREEN}Shift Key: $key${NC}"
                fi
                ;;

            4)
                read -p "[*] Please enter text to decrypt without a key: " text
                decrypt_without_key "$text"
                ;;

            *)
                echo -e "${RED}ERROR: Invalid choice ! Please enter 1, 2, 3, or 4 !${NC}"
                sleep 2
                continue
                ;;
        esac

        read -p $'\nDo you want to try again? (Y/N): ' repeat
        if [[ ! "$repeat" =~ ^[Yy](es)?$ ]]; then
            echo -e "${GREEN}Thank you for using the program.${NC}"
            break
        fi
    done
}

# Start program
main
