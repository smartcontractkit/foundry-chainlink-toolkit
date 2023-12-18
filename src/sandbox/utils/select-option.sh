#!/bin/bash

items=("${@:2}")
COLUMNS=0
PS3="$1"
IFS=@
select item in "${items[@]}"
do
  case "@${items[*]}@" in
    (*"@$item@"*)
      break;;
    (*)
      echo "Invalid option. Please enter an option number from the list.";
      exit 1;;
  esac
done
echo "$item"
exit 0
