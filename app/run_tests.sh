#!/bin/sh

# Usage: ./run_tests.sh <PUBLIC_IP>
if [ -z "$1" ]; then
  echo "Usage: $0 <PUBLIC_IP>"
  exit 1
fi

IP=$1

echo "Running Pounds-to-Kilograms API tests against https://$IP"

echo -e "\nTest: Normal"
curl -s "https://$IP/convert?lbs=150"
echo -e "\n"

echo "Test: Zero"
curl -s "https://$IP/convert?lbs=0"
echo -e "\n"

echo "Test: Edge"
curl -s "https://$IP/convert?lbs=0.1"
echo -e "\n"

echo "Test: Error missing lbs parameter"
curl -s -w "\nHTTP Status: %{http_code}\n" "https://$IP/convert"
echo -e "\n"

echo "Test: Error negative lbs"
curl -s -w "\nHTTP Status: %{http_code}\n" "https://$IP/convert?lbs=-5"
echo -e "\n"

echo "Test: Error NaN lbs"
curl -s -w "\nHTTP Status: %{http_code}\n" "https://$IP/convert?lbs=NaN"
echo -e "\n"
