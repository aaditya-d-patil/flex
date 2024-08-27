#!/usr/bin/bash

todo_file="todo.txt"

show_todo() {
    if [ -s "$todo_file" ]; then
        echo "To-Do List:"
        cat "$todo_file"
    else
        echo "To-Do list is empty."
    fi
}

create_todo() {
    local todo="$1"
    local todo_count=$(wc -l < "$todo_file")
    echo "$((todo_count + 1)). $todo" >> "$todo_file"
    echo "Todo Added: $todo"
}

create_todo_timer() {
    local todo="$1"
    local todo_count=$(wc -l < "$todo_file")
    echo "$((todo_count + 1)). $todo" >> "$todo_file"
    echo "Todo Added: $todo"

    local days="$2"
    local minutes="$3"

    # Calculate the total time in seconds
    total_seconds=$((days * 86400 + minutes * 60))

    (sleep $total_seconds && wt.exe bash ./open_terminal.sh "$todo") &
}


delete_todo() {
    local todo_number="$1"
    sed -i "${todo_number}d" "$todo_file"
    echo "Deleted to-do number $todo_number"
}

edit_todo() {
    local todo_number="$1"
    local new_todo="$2"
    sed -i "${todo_number}s/.*/${todo_number}. ${new_todo}/" "$todo_file"
    echo -e "~ Edited to-do number $todo_number\n"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c)
            if [[ $2 == "-t" ]]; then
                shift 2
                create_todo_timer "$1" "$2" "$3"
                shift
                exit
                
            else
                shift
                create_todo "$1"
                shift
                exit      
            fi
            ;;
        -s)
            show_todo
            exit
            ;;
        -e)
        show_todo
           read -p "Enter the number of the to-do to edit: " todo_number
           read -p "Enter the new value for the to-do: " new_value
           edit_todo "$todo_number" "$new_value" 
           exit
           ;;
        -d)
            shift
            show_todo
            read -p "Enter the number of the to-do to delete: " todo_number
            delete_todo "$todo_number" 
            exit
            ;;
        *)
            echo "Invalid option: $1"
            exit
            ;;
    esac
    shift
done

