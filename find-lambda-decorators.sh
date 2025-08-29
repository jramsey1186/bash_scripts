#!/bin/bash

# Set the decorator pattern to search for.  Make sure to escape special characters.
decorator="@my_custom_decorator"

# Set the project directory to search within.  Defaults to the current directory.
project_dir="."

# Use grep to find all lines containing the decorator pattern.
grep -rn "$decorator" "$project_dir" | while IFS=: read -r file line_number line; do

  # Extract the function or class name using grep and awk.
  # This assumes the function/class definition is on a line preceding the decorator.
  function_or_class_line=$(sed -n "$((line_number - 1))p" "$file")

  # Use grep to check if the line contains 'def' or 'class'.
  if [[ "$function_or_class_line" =~ "def " ]]; then
    function_or_class_name=$(echo "$function_or_class_line" | awk '{print $2}' | cut -d'(' -f1)  # Extract function name
    type="function"
  elif [[ "$function_or_class_line" =~ "class " ]]; then
    function_or_class_name=$(echo "$function_or_class_line" | awk '{print $2}' | cut -d'(' -f1)  # Extract class name
    type="class"
  else
    function_or_class_name="N/A"
    type="N/A"
  fi

  # Print the results.
  echo "File: $file"
  echo "Type: $type"
  echo "Name: $function_or_class_name"
  echo "Decorator: $decorator"
  echo "-------------------------"
done
