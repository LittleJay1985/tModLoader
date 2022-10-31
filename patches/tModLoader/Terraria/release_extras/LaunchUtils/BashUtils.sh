#!/usr/bin/env bash

# Get root folder
root_dir="$(dirname "$(pwd -P)")"

# Read uname into a variable used in various places
_uname=$(uname)

# Sourced from dotnet-install.sh
# Check if a program is present or not
machine_has() {
	command -v "$1" > /dev/null 2>&1
	return $?
}

file_download() {
	if machine_has "curl"; then
		echo
		responseCode=$(curl -w '%{response_code}' -Lo "$1" "$2")
		echo "HTTP Response: $responseCode"
		if [ "$responseCode" != "200" ] ; then
			if [[ -d "$dotnet_dir" ]] ; then
				rm -rf "$dotnet_dir"
			fi
			return 1
		fi
	elif machine_has "wget"; then
		wget -O "$1" "$2"
	else
		echo "Missing dependency: neither curl nor wget was found."
		return 1 # @TODO: Should hard fail?
	fi
	return 0
}

# Call a script setting its permission right for execution
run_script() {
	chmod a+x "$1"

	# LD_PRELOAD="" fixes error messages from steams library linking polluting the stdout of all programs(in tree) run by run_script
	LD_PRELOAD="" "$@"
}
