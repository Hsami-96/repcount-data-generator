#!/bin/bash

output_file="$1"
# Initialize JSON structure
json_data='{"workouts": []}'
exercises_json='[]'
current_date=""
sets_json='[]'
date_json=''
current_workout_index=-1
current_exercise_index=-1
# Read the input file line by line
while IFS= read -r line; do    
    trimmed_line=$(echo "$line" | tr -d ' ')

if [[ "$trimmed_line" =~ ^[0-9]{2}\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s*[0-9]{4}$ ]]; then
    current_date="$line"

    current_workout_index=$((current_workout_index + 1))
    current_exercise_index=-1
elif [[ "$line" =~ ^([0-9]+x[0-9]+) ]]; then

    weight_reps="${BASH_REMATCH[1]}"
    IFS='x' read -ra split <<< "$weight_reps"
    weight="${split[0]}"
    reps="${split[1]}"
    # Extract the remaining description
    description="${line#"${weight_reps} "}"

    # Create a JSON object for the set and add it to the sets array
    set_json="{\"weight\":\"$weight\",\"reps\":\"$reps\",\"description\":\"$description\"}"
    sets_json=$(echo "$sets_json" | jq --argjson set "$set_json" '. += [$set]')
    
    json_data=$(echo "$json_data" | jq --argjson sets "$sets_json" '.workouts['"$current_workout_index"'].exercises['"$current_exercise_index"'].sets += [$sets]')

    date_json=''
    sets_json='[]'
elif ! [[ "$line" =~ ^([0-9]+x[0-9]+) ]] && [[ -n "$line" && "$line" != "Logged using RepCount" ]]; then
    # Add exercise data to the exercises array
    current_exercise_index=$((current_exercise_index + 1))
    exercises_json=$(echo "$exercises_json" | jq --arg description "$line" '. += [{"name":$description,"sets":'[]'}]')
    date_json="{\"date\":\"$current_date\",\"exercises\":$exercises_json}"
    json_data=$(echo "$json_data" | jq --argjson date "$date_json" '.workouts += [$date]')
    exercises_json='[]'
fi
done < data/workoutData.txt

echo "$json_data" > "$output_file"

echo "JSON data has been saved to $output_file"

echo $?
