#!/bin/sh

# Get the Github Token and Giphy API Key from Github Action Inputs
GITHUB_TOKEN=$1
GIPHY_API_KEY=$2

# Get the pull request number from the Github event payload
pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
echo PR number - $pull_request_number

# Use the Giphy API to fetch a random Thank You GIF
giphy_response=$(curl -s "https://api-giphy.com/v1/gifs/random?api_key=$GIPHY_API_KEY&tag=thank%20you&rating=g")
echo Giphy response - $giphy_response

# Extract the GIF URL from the Giphy response
gif_url=$(echo "$giphy_response" | jq --raw-output .data.images.downsized.url)
#gif_url=$(echo "$giphy_response" | jq --raw-output .data.images.original.url)
echo GIPHY_URL - $gif_url

# Create a comment with the GIF on the pull request 
comment_response=$(curl -sX POST -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{\"body\": \"### PR - #$pull_request_number. \n ### Thank you for this contribution! \n ![GIF Description](GIF_URL) \"}" \
    #-d "{\"body\": \"### PR - #$pull_request_number. \n ### Thank you for this contribution! \n ![GIF]($gif_url) \"}"
    "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$pull_request_number/comments")

# Extract and print the comment URL from the comment response
comment_url=$(echo "$comment_response" | jq --raw-output .html_url)

# Debugging entrypoint script
echo "Pull Request Number: $pull_request_number"
echo "Giphy API Response: $giphy_response"
echo "Extracted GIF URL: $gif_url"
echo "GitHub Comment Response: $comment_response"