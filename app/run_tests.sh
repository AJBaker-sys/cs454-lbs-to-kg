#!/bin/bash

BASE_URL=${1:-localhost}

echo "Running specific test cases against http://$BASE_URL/convert..."
echo

# List of test descriptions and query paths
declare -a TESTS=(
    "1 Happy path: /convert?lbs=0"
    "2 Typical: /convert?lbs=150"
    "3 Edge: /convert?lbs=0.1"
    "4 Error (missing param): /convert"
    "5 Error (negative): /convert?lbs=-5"
    "6 Error (NaN): /convert?lbs=NaN"
)

for test in "${TESTS[@]}"; do
    label=$(echo "$test" | cut -d':' -f1)
    path=$(echo "$test" | cut -d':' -f2- | xargs)

    echo "$label → $path"
    curl -s "http://$BASE_URL$path"
    echo -e "\n---"
done
