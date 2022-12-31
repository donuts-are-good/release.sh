#!/bin/bash

# MIT License 
# donuts-are-good

# Check for the --help flag
if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
    # Display the man page
    man ./doc/release.sh.1
    # Exit the script
    exit 0
fi

# Parse the command line arguments
while [[ $# -gt 0 ]]
do
    # Set the key variable to the first argument
    key="$1"

    # Check the value of the key variable
    case $key in
        # If the key is "--name", set the BINARY_NAME variable to the second argument
        --name)
        BINARY_NAME="$2"
        shift # past argument
        shift # past value
        ;;
        # If the key is "--version", set the VERSION variable to the second argument
        --version)
        VERSION="$2"
        shift # past argument
        shift # past value
        ;;
        # If the key is unknown, skip it
        *)    # unknown option
        shift # past argument
        ;;
    esac
done

# Build for Windows on AMD64
GOOS=windows GOARCH=amd64 go build -o "${BINARY_NAME}-${VERSION}-windows-amd64.exe"

# Build for macOS on Intel
GOOS=darwin GOARCH=amd64 go build -o "${BINARY_NAME}-${VERSION}-darwin-amd64"

# Build for macOS on Apple Silicon
GOOS=darwin GOARCH=arm64 go build -o "${BINARY_NAME}-${VERSION}-darwin-arm64"

# Build for Linux on AMD64
GOOS=linux GOARCH=amd64 go build -o "${BINARY_NAME}-${VERSION}-linux-amd64"
