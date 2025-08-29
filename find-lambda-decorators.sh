#!/bin/bash

# Set the directory to search in. Defaults to the current directory.
SEARCH_DIR="${1:-.}"

# Function to recursively search for Lambda signatures
find_lambda_functions() {
  find "$SEARCH_DIR" -name "*.py" -print0 | while IFS= read -r -d $'\0' file; do
    while IFS= read -r line; do
      # Look for function definitions with (event, context)
      if [[ "$line" =~ ^[[:space:]]*def[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]*\([[:space:]]*event[[:space:]]*,[[:space:]]*context[[:space:]]*\)[[:space:]]*: ]]; then
        function_name="${BASH_REMATCH[1]}"

        # Find decorators associated with the function
        decorators=""
        decorator_line_num=$(grep -n -B 1000000 "^[[:space:]]*def[[:space:]]+${function_name}[[:space:]]*(" "$file" | head -n 1 | cut -d ":" -f 1)

        if [[ ! -z "$decorator_line_num" ]]; then
          current_line_num=$((decorator_line_num - 1))
          while [[ "$current_line_num" -gt 0 ]]; do
            decorator_line=$(sed -n "${current_line_num}p" "$file")

            # Check if the line is a decorator
            if [[ "$decorator_line" =~ ^[[:space:]]*@ ]]; then
              decorators="$decorators $(echo "$decorator_line" | sed 's/^[[:space:]]*@//')"
              current_line_num=$((current_line_num - 1))
            else
              break # Stop when we encounter a non-decorator line
            fi
          done
        fi

        # Print the function name, file, and decorators
        echo "File: $file"
        echo "Function: $function_name"
        echo "Decorators: $decorators"
        echo "---"
      fi
    done < "$file"
  done
}

# Run the search
find_lambda_functions

exit 0
