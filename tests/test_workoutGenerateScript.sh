#!/bin/bash
 
 # Test case 1: Ensure script runs successfully
./workoutGenerateScript.sh output.json
if [ $? -eq 0 ]; then 
    echo "Test Case 1: Passed"
else
    echo "Test Case 1: Failed"
fi

# Test case 1.1: Ensure script generates output file with workouts data
./workoutGenerateScript.sh output.json
if [ -f "output.json" ]; then
    if jq -e '.workouts' "output.json" >/dev/null; then 
        echo "Test Case 1.1: Passed"
    else 
        echo "Test Case 1.1: Failed"
    fi
else
  echo "Test Case 1: Failed"
fi
rm -f output.json