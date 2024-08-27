#!/bin/bash


output_file="search.txt"

# Default search mode is detailed
search_mode="detailed"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--detailed)
      search_mode="detailed"
      shift
      ;;
    -b|--brief)
      search_mode="brief"
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Check if the user provided a search term
if [ $# -eq 0 ]; then
  usage
fi

# Join command line arguments into a single search query
query="$*"

# Use the curl command to fetch data from Wikipedia
# You can replace this with the API of your choice
url="https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro=true&explaintext=true&titles=$query"
result=$(curl -s "$url")

# Check if the page exists in the response
if [[ "$result" == *"missing\"":true* ]]; then
  echo "No information found for '$query'."
else
  # Parse the JSON response to extract the page content
  extract=$(echo "$result" | jq -r '.query.pages | .[] | .extract')

  if [ "$search_mode" == "brief" ]; then
    sed 's/\([.!?]\) \([^ ]\)/\1\n\2/g' <<< "$extract" > "$output_file"
    sed -n '1,4p' "$output_file" | xargs -d ' ' -n10
    
    truncate -s 0 search.txt
  else
    echo "$extract"
  fi
fi

#awk -v RS='[.!?]' '{gsub(/^[ \t]+|[ \t]+$/, "", $0); if (length($0) > 0) { print $0 >> "'"$output_file"'" }}' <<< "$extract"
#     head -n 4 search.txt
#    truncate -s 0 search.txt