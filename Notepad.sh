#!/usr/bin/bash

notes_folder="notes"

mkdir -p "$notes_folder"

create_note() {
    local note_name="$1"
    touch "$notes_folder/$note_name.txt"
    echo "Note created: $note_name"
    vi "$notes_folder/$note_name.txt"
}

view_note() {
    local note_name="$1"
    if [[ -e "$notes_folder/$note_name.txt" ]]; then
        vi "$notes_folder/$note_name.txt"
    else
        echo "Note not found."
    fi
}

delete_note() {
    local note_name="$1"
    if [[ -e "$notes_folder/$note_name.txt" ]]; then
        rm "$notes_folder/$note_name.txt"
        echo "Note '$note_name' deleted."
    else
        echo "Note not found."
    fi
}

# Function to list existing notes
list_notes() {
    echo "Existing Notes:"
    for note_file in "$notes_folder"/*.txt; do
        echo "$(basename "$note_file" .txt)"
    done
}

# Parse tags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c)
            shift
            create_note "$1"
            shift
            exit
            ;;
        -m)
            list_notes
            read -p "Enter the name of the note to view: " note_to_view
            view_note "$note_to_view"
            exit
            ;;
        -d)
            shift
            list_notes
            read -p "Enter the name of the note to delete: " note_to_delete
            delete_note "$note_to_delete" 
            exit
            ;;
        *)
            echo "Invalid option: $1"
            exit
            ;;
    esac
    shift
done

