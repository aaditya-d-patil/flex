#!/usr/bin/bash

#todo file
todo_file="todo.json"
declare -i id=10
#check if json file exists
check_and_create_json() {
    if [ ! -f "$todo_file" ]; then
        echo -e "[\n]" > "$todo_file"
    fi
}

#read content from json file
read_json() {
    tr -d '\n' < "$todo_file" # Remove newlines to ensure JSON stays compact
}

#write content to json file
write_json() {
    echo -e "$1\n]" > "$todo_file" # Reformat and save
}

show_todo() {
    if [ -s "$todo_file" ]; then
        echo "To-Do List:"
        cat "$todo_file"
    else
        echo "To-Do list is empty."
    fi
}

create_todo() {
    check_and_create_json
    local task="$1"
    local priority="${2:-Low}"
    local due_date="${3:-null}"
    
    id=$(jq '.[-1].id' "$todo_file")
    id=$((id + 1))

    echo "New Task JSON: $new_task" # Debug line

    tmp="tmp.json"
    cat $todo_file | head -n -1 > $tmp
    tmp_next=$(cat "$tmp")
    
    if [[ $tmp_next == "[" ]]; then
        id=1
        local new_task="{\"id\":$id,\"task\":\"$task\",\"priority\":\"$priority\",\"due_date\":\"$due_date\",\"status\":\"Pending\"}"
        to_add="$tmp_next$new_task"
        write_json $to_add
    else
        local new_task="{\"id\":$id,\"task\":\"$task\",\"priority\":\"$priority\",\"due_date\":\"$due_date\",\"status\":\"Pending\"}"
        to_add="$tmp_next,$new_task"
        write_json $to_add
    fi
   
}

create_todo_timer() {
    local todo="$1"
    local days="$2"
    local minutes="$3"
    local todo_count=$(wc -l < "$todo_file")
    echo "$((todo_count + 1)). $todo" >> "$todo_file"
    echo "Todo Added: $todo"

    # Calculate the total time in seconds
    local total_seconds=$((days * 86400 + minutes * 60))

    # Execute the reminder after the timer ends
    (sleep $total_seconds && echo "Reminder: $todo" && wt.exe bash ./open_terminal.sh "$todo") &
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
                create_todo "$1" 
                shift
                exit
                
            else
                shift
                create_todo "$1" "$2" "$3" "$4"
                echo "todo it is"
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

