#!/bin/bash

# Initialize counters
successful=0
failed=0

# Function to generate random string
generate_random_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-10} | head -n 1
}

# Total number of requests
total_requests=100

echo "Starting to send $total_requests POST requests..."

for i in $(seq 1 $total_requests); do
    # Generate random data
    name=$(generate_random_string 8)
    description=$(generate_random_string 15)

    # Create JSON payload
    json_data="{\"name\":\"$name\",\"description\":\"$description\"}"

    # Send POST request
    response=$(curl -s -w "%{http_code}" -X POST \
        'http://127.0.0.1:8000/items/' \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -d "$json_data")

    # Get HTTP status code
    http_code=${response: -3}
    
    # Calculate percentage for progress
    percentage=$((i * 100 / total_requests))
    
    # Progress bar
    printf "\rProgress: [%-50s] %d%%" $(printf "#%.0s" $(seq 1 $((percentage/2)))) $percentage

    # Check response
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        ((successful++))
    else
        ((failed++))
        echo -e "\nRequest $i failed with status code: $http_code"
    fi
done

echo -e "\n\nCompleted!"
echo "Successful requests: $successful"
echo "Failed requests: $failed"
echo "Total requests: $total_requests"

