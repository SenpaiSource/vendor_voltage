#!/bin/bash
#
# Copyright (C) 2019 crDroid Android Project
# Copyright (C) 2026 VoltageOS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

target_device="$1"
product_out="$2"
filename="$3"
maintainer_arg="${4:-$5}"

output_dir="./vendor/ota"
output="$output_dir/$target_device.json"
mkdir -p "$output_dir"

find_prop() {
	for propfile in \
		"$product_out/system/build.prop" \
		"$product_out/system/etc/build.prop" \
		"$product_out/product/etc/build.prop" \
		"$product_out/product/build.prop" \
		"$product_out/system_ext/etc/build.prop" \
		"$product_out/vendor/build.prop" \
		"$product_out/vendor/etc/build.prop"; do
		if [ -f "$propfile" ]; then
			val=$(grep -E "^$1=" "$propfile" 2>/dev/null | head -n1 | cut -d'=' -f2)
			if [ -n "$val" ]; then
				echo "$val"
				return
			fi
		fi
	done
}

maintainer="$maintainer_arg"

if [ -z "$maintainer" ]; then
	maintainer=$(grep -rohE '^(VOLTAGE_MAINTAINER|PRODUCT_MAINTAINER|MAINTAINER)[[:space:]]*:?=[[:space:]]*[^#]+' device/ 2>/dev/null | head -n1 | cut -d'=' -f2 | xargs)
fi

if [ -z "$maintainer" ]; then
	maintainer=$(grep -rohE '<string name="(voltage_maintainer|maintainer)">[^<]+' device/ 2>/dev/null | head -n1 | sed -E 's/.*>([^<]+)/\1/' | xargs)
fi

if [ -z "$maintainer" ]; then
	maintainer=$(find_prop "ro.voltage.maintainer")
fi

if [ -z "$maintainer" ] && [ -f "$output" ] && grep -q "\"maintainer\"" "$output" 2>/dev/null; then
	extracted_maintainer=$(sed -n 's/.*"maintainer"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$output" | head -n1)
	if [ "$extracted_maintainer" != "android-build" ] && [ "$extracted_maintainer" != "Unofficial Maintainer" ]; then
		maintainer="$extracted_maintainer"
	fi
fi

if [ -z "$maintainer" ] || [ "$maintainer" = "android-build" ]; then
	maintainer=$(git config user.name 2>/dev/null)
fi

oem=""
if [ -f "$output" ] && grep -q "\"oem\"" "$output" 2>/dev/null; then
	oem=$(sed -n 's/.*"oem"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$output" | head -n1)
fi

if [ -z "$oem" ]; then
	oem=$(find_prop "ro.product.system.manufacturer")
	[ -z "$oem" ] && oem=$(find_prop "ro.product.manufacturer")
	[ -z "$oem" ] && oem=$(find_prop "ro.product.vendor.manufacturer")
	[ -z "$oem" ] && oem=$(find_prop "ro.product.odm.manufacturer")
fi

device=""
if [ -f "$output" ] && grep -q "\"device\"" "$output" 2>/dev/null; then
	device=$(sed -n 's/.*"device"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$output" | head -n1)
fi

if [ -z "$device" ]; then
	device=$(find_prop "ro.voltage.device")
	[ -z "$device" ] && device=$(find_prop "ro.product.device")
	[ -z "$device" ] && device="$target_device"
fi

version=$(echo "$filename" | cut -d'-' -f2)
download="https://sourceforge.net/projects/voltage-os/files/$target_device/$filename/download"

timestamp=$(find_prop "ro.system.build.date.utc")
[ -z "$timestamp" ] && timestamp=$(find_prop "ro.build.date.utc")
[ -z "$timestamp" ] && timestamp=$(date +%s)

zip_path="$product_out/$filename"
if [ -f "$zip_path" ]; then
	md5=$(md5sum "$zip_path" | cut -d' ' -f1)
	size=$(stat -c "%s" "$zip_path")
else
	md5=""
	size="0"
fi

cat <<EOF > "$output"
{
  "response": [
    {
        "maintainer": "$maintainer",
        "oem": "$oem",
        "device": "$device",
        "filename": "$filename",
        "download": "$download",
        "timestamp": $timestamp,
        "md5": "$md5",
        "size": $size,
        "version": "$version"
    }
  ]
}
EOF

echo "$output"
