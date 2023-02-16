#!/usr/bin/env bash

# MIT License 
# donuts-are-good

# check for the --help flag
if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
    # Display the man page
    man ./doc/release.sh.1
    # Exit the script
    exit 0
fi

# get command line args
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -n|--name)
      name="$2"
      shift 2
      ;;
    -v|--version)
      version="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ -z "$name" ] || [ -z "$version" ]; then
  echo "Usage: $0 --name NAME --version VERSION"
  exit 1
fi

# make the build folder
output_dir="BUILDS"
mkdir -p $output_dir

# get the list of all build targets
os_list=$(go tool dist list | cut -f1 -d'/')
arch_list=$(go tool dist list | cut -f2 -d'/')

# split the os and arch lists into arrays
IFS=$'\n' read -d '' -r -a os_array <<<"$os_list"
IFS=$'\n' read -d '' -r -a arch_array <<<"$arch_list"

# loop through and build all possible types
for os in "${os_array[@]}"; do
  for arch in "${arch_array[@]}"; do
    
    # set the scene for the current build
    export GOOS=$os
    export GOARCH=$arch

    # build and check
    binary_name="$name-$version-$GOOS-$GOARCH"
    if [[ "$GOOS" == "windows" ]]; then
      binary_name="$binary_name.exe"
    fi
    build_dir="$output_dir/$GOOS/$GOARCH"
    mkdir -p "$build_dir"
    output_file="$build_dir/$binary_name"
    if go build -o "$output_file" . > /dev/null 2>&1; then
      echo "pass - $GOOS - $GOARCH"
    else
      echo "fail - $GOOS - $GOARCH"
      rm -f "$output_file"
    fi

    # cleanup for next cycle
    # todo check if this is unsetting systemwide
    unset GOOS
    unset GOARCH
  done
done
