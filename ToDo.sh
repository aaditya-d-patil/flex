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
        jq -c '.[]' "$todo_file" | while read -r todo; do
            local id=$(echo "$todo" | jq -r '.id')
            local task=$(echo "$todo" | jq -r '.task')
            local priority=$(echo "$todo" | jq -r '.priority')
            local due_date=$(echo "$todo" | jq -r '.due_day')

            # Get remaining time
            if [[ "$due_date" != "null" ]]; then
                local remaining_time=$(get_remaining_time "$due_date")
            else
                local remaining_time="No due date set"
            fi

            echo "$id] $task | Priority: $priority"
            echo -e "Due Date: \033[32m $due_date\033[0m, \033[31mRemaining Time: $remaining_time\033[0m"
            echo "-----------------------------------"
        done
    else
        echo "To-Do list is empty."
    fi
}

get_remaining_time() {
    local due_date="$1"
    local current_time=$(date '+%s')
    local due_time=$(date -d "$due_date" '+%s')

    if (( due_time > current_time )); then
        local remaining_seconds=$((due_time - current_time))
        local days=$((remaining_seconds / 86400))
        local hours=$(( (remaining_seconds % 86400) / 3600 ))
        local minutes=$(( (remaining_seconds % 3600) / 60 ))
        echo "$days days, $hours hours, $minutes minutes remaining"
    else
        echo "Time's up!"
    fi
}

create_todo() {
    check_and_create_json
    local task="$1"
    local priority="${2:-Low}"
    local due_day="${3:-null}"
    local created_at=$(date '+%Y-%m-%dT%H:%M:%S')
    
    id=$(jq '.[-1].id' "$todo_file")
    id=$((id + 1))

    echo "New Task JSON: $new_task" # Debug line

    tmp="tmp.json"
    cat $todo_file | head -n -1 > $tmp
    tmp_next=$(cat "$tmp")
    
    if [[ $tmp_next == "[" ]]; then
        id=1
        local new_task="{\"id\":$id,\"task\":\"$task\",\"priority\":\"$priority\",\"Created_At\":\"$created_at\",\"due_day\":\"$due_day\"}"
        to_add="$tmp_next$new_task"
        write_json $to_add
    else
        local new_task="{\"id\":$id,\"task\":\"$task\",\"priority\":\"$priority\",\"Created_At\":\"$created_at\",\"due_day\":\"$due_day\"}"
        to_add="$tmp_next,$new_task"
        write_json $to_add
    fi

    if [[ $due_day != "null" ]]; then
        todo_timer "$task" "$due_day" 
    fi
   
}

todo_timer() {
    local task="$1"
    local due_date="$2" # Format: YYYY-MM-DDTHH:MM:SS

    local current_time=$(date '+%s')
    local due_time=$(date -d "$due_date" '+%s')
    local remaining_seconds=$((due_time - current_time))
    if [ $? -ne 0 ]; then
        return 1 # Exit if the function encounters an error
    fi

    (
        sleep $remaining_seconds
        echo "Reminder: $task "
        wt.exe bash ./open_terminal.sh "$task"
    ) &
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
                create_todo "$1" "$2" "$3" 
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

