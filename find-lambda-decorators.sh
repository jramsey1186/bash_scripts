#!/bin/bash

# Define the directory to search (default is the current directory)
SEARCH_DIR="${1:-.}"

# Find all Python files recursively
find "$SEARCH_DIR" -type f -name "*.py" | while read -r file; do
    # Extract function names and decorators for functions with (event, context) signature
    awk '
    /^@/ { decorator = decorator $0 "\n" }  # Capture decorators
    /^def [^(]*\(event, context\):/ {
        if (decorator != "") {
            print "File:", FILENAME
            print "Decorators:", decorator
            print "Function:", $2
            print "--------------------------"
        }
        decorator = ""  # Reset decorator for the next function
    }
    ' "$file"
done
