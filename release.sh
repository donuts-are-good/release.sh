#!/usr/bin/env bash

# MIT License
# donuts-are-good 🍩👌

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
      echo "Unknown option: $1 ❌"
      exit 1
      ;;
  esac
done

if [ -z "$name" ] || [ -z "$version" ]; then
  echo "Usage: $0 --name NAME --version VERSION ❗"
  exit 1
fi

# make the build folder 📂
output_dir="BUILDS"
mkdir -p $output_dir

# get the list of all unique build targets
os_arch_list=$(go tool dist list)

# split the os-arch list into an array
IFS=$'\n' read -d '' -r -a os_arch_array <<<"$os_arch_list"

# loop through and build all possible types
for os_arch in "${os_arch_array[@]}"; do

  # extract the OS and architecture from the pair
  os=$(echo "$os_arch" | cut -f1 -d'/')
  arch=$(echo "$os_arch" | cut -f2 -d'/')

  # set the scene for the current build 🎬
  export GOOS=$os
  export GOARCH=$arch

  # build and check
  binary_name="$name-$version-$GOOS-$GOARCH$(go env GOEXE)"
  build_dir="$output_dir/$GOOS/$GOARCH"
  mkdir -p "$build_dir"
  output_file="$build_dir/$binary_name"
  if go build -ldflags="-w -s" -o "$output_file" . > /dev/null 2>&1; then
    echo "✅ pass - $GOOS - $GOARCH"
  else
    echo "❌ fail - $GOOS - $GOARCH"
    rm -f "$output_file"
  fi

  # cleanup for next cycle
  # todo check if this is unsetting systemwide
  unset GOOS
  unset GOARCH
done
