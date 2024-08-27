#!/usr/bin/bash

api_key="/*Enter an API key from openweathermap.org*/"

get_weather() {
    local city="$1"
    local url="https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$api_key"
    curl -s "$url"
}

city="$1"
weather_data=$(get_weather "$city")
echo "Weather for $city:-"

temperature_k=$(echo "$weather_data" | jq -r '.main.temp')

temperature_c=$(echo "scale=2; $temperature_k - 273.15" | bc)

echo "Nature: $(echo "$weather_data" | jq -r '.weather[0].main')"
echo "Temperature: $temperature_c °C"
echo "Humidity: $(echo "$weather_data" | jq -r '.main.humidity')"
echo "Description: $(echo "$weather_data" | jq -r '.weather[0].description')"
exit