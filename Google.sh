#!/bin/bash

#wiki
output_file="search.txt"

# Default search mode is detailed
search_mode="brief"

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

query="$*"

user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"

webpage=$(curl -s -G https://www.google.com/search --user-agent "$user_agent" --data-urlencode "q=$query")

#autocorrect
res0=$(echo "$webpage" | pup 'a.gL9Hy text{}' | sed ':a;N;$!ba;s/\n/ /g'| awk '{$1=$1;print}' | recode html..utf8 )
[ -n "$res0" ] && echo "> u mean $res0?" ||  

#listing 1
list1=$(echo "$webpage" | pup 'div.B0jnne json{}' | jq -r '.[] | .children | .[] | .text' | sed ':a;N;$!ba;s/\n/ /g' | sed 's/null/\n/g' | awk '{$1=$1;print "* " $0}' | sed '/^* $/d')
[ -n "$list1" ] && echo "$list1" ||

#listing 2
list2=$(echo "$webpage" | pup 'div.dAassd text{}' | awk '{$1=$1;print "* " $0}' | sed '/^* $/d') #works
[ -n "$list2" ] && echo "$list2"  ||


#short result
res1=$(echo "$webpage" | pup 'div.vk_bk.dDoNo.FzvWSb span text{}' | tr -d '\n' | recode html..utf8)
[ -n "$res1" ] && echo "$res1"  ||


#wiki

#temporary search  
tmp=$(echo "$webpage" | pup 'div.kno-rdesc')
[ -z "$tmp" ] && echo "" || echo "$tmp" | pup 'span' | sed -n '2p' | recode html..utf8 | xargs -d ' ' -n10

