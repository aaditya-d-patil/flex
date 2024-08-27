#!/usr/bin/bash

#This is the main file of the CLI assistant
# Tasks:
# ----------
# notepad
# todo list 
# weather update
# google search: web scrapping
# ----------

# Login
# Define the valid username and password
valid_username="aaditya"
valid_password="1234"

last_login_file="last_login.txt"

has_24_hours_passed() {
    if [ ! -f "$last_login_file" ]; then
        return 0  # File doesn't exist, indicating first login
    fi

    last_login_timestamp=$(cat "$last_login_file")
    current_timestamp=$(date +%s)
    diff=$((current_timestamp - last_login_timestamp))
    if [ $((diff)) -ge 86400 ]; then
        return 0  # More than 24 hours have passed
    else
        return 1  # Less than 24 hours have passed
    fi
}

login() {
    has_24_hours_passed
    if [ $? -eq 0 ]; then
        read -p "Username: " username
        read -sp "Password: " password
        echo

        if [ "$username" = "$valid_username" ] && [ "$password" = "$valid_password" ]; then
            logo #login success
            date +%s > "$last_login_file"            
        else
            echo "Login failed. Access denied  :("
            exit
        fi
    else
        echo "I'm Flex  :)"
        echo "try 'flex --help' to know more"
        echo ""

    fi
}

# Function to display help
show_help() {
    
    echo "Usage: flex [options]"
    echo "Options:"
    echo "  --help              Show this help message"
    echo -e
    echo "  --todo              To-Do Functionalities"
    echo "      -c  <new_todo>   create a To-Do[append]"
    echo "      -c -t <new_todo> create a To-Do[append] with a timer"
    echo "      -s               show all To-Do"
    echo "      -e               edit a To-Do"
    echo "      -rm              remove a To-Do"
    echo -e
    echo "  --notepad           Open Notepad"
    echo "      -c  <new_note>   create a Note[append]"
    echo "      -m               manipulate a Note"
    echo "      -rm              remove a Note"
    echo -e
    echo "  --weather <city_name>    check weather"
    echo -e
    echo "  --search [tag] <query>    Gets a detailed search[default]"
    echo "      -wb                     Gets brief results from wiki"
    echo "      -wd                     Gets detailed results from wiki"
    echo "      -w                      Gets brief results from wiki"
    echo "    [no tag]                  Gets quick results from Google"
    exit

}

# Logo function:
logo(){
    echo -e ""
echo -e "\033[34m             **********                 "
echo -e "\033[34m            **********                  "
echo -e "\033[34m           **********                   "
echo -e "\033[34m          **                            "
echo -e "\033[34m         **                             "
echo -e "\033[34m        ******                             "
echo -e "\033[33m       ******  *       *****   *   *          "
echo -e "\033[33m      **       |       [        \ /        "
echo -e "\033[33m     **        |       ***       *         "
echo -e "\033[33m    **         |       [        / \        "
echo -e "\033[33m   **          *****   *****   *   *       "
echo -e "\033[33m             "
echo -e ""
}

while [[ $# -gt 0 ]]; do
    has_24_hours_passed
    if [ $? -eq 0 ]; then
        login
    fi

    case "$1" in
    
        --help)
            show_help
            ;;

        --todo)
            if [[ $2 == "-c" ]]; then
                if [[ $3  == "-t" ]]; then
                    shift 
                    create_todo_timer="./ToDo.sh -c -t \"$1 $2 $3\""   
                    eval "$create_todo_cmd_timer"
                    exit
                else
                    shift          
                    create_todo_cmd="./ToDo.sh -c \"$2\""
                    eval "$create_todo_cmd"
                    exit
                fi
            elif [[ "$2" == "-s" ]]; then
                bash ToDo.sh -s
                exit
            elif [[ "$2" == "-e" ]]; then
                bash ToDo.sh -e
                exit
            elif [[ "$2" == "-rm" ]]; then
                bash ToDo.sh -d
                exit
            else
                echo "Invalid usage."
                show_help
                exit
                
            fi
            ;;


        --notepad)
            if [[ $2 == "-c" ]]; then
                shift          
                create_todo_cmd="./Notepad.sh -c \"$2\""
                eval "$create_todo_cmd"
                exit
            elif [[ "$2" == "-m" ]]; then
                bash Notepad.sh -m
                exit
            elif [[ "$2" == "-rm" ]]; then
                bash Notepad.sh -d
                exit
            else
                echo "Invalid usage."
                show_help
                exit
                
            fi
            ;;
        
        --weather)
            weather_cmd="./weather.sh \"$2\""
            eval "$weather_cmd"
            exit
            ;;
        
        --search)
            if [[ $2 == "-wd" ]]; then
                shift          
                search_detail_cmd="./wiki.sh -d \"$2\""
                eval "$search_detail_cmd"
                exit
            elif [[ "$2" == "-wb" ]]; then
                shift          
                search_brief_cmd="./wiki.sh -b \"$2\""
                eval "$search_brief_cmd"
                exit
            elif [[ "$2" == "-w" ]]; then
                shift          
                search_brief_cmd="./wiki.sh -b \"$2\""
                eval "$search_brief_cmd"
                exit
            else
                shift          
                search_detail_cmd="./Google.sh \"$*\""
                eval "$search_detail_cmd "
                exit
            fi
            exit
            ;;
            
        *)
            echo "Invalid option: $1"
            show_help ;;
    esac
    shift
done

login