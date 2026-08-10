#!/bin/bash
#		VeriGood waveforms viewer script
#		Copyright (C) 2026  Pietro Alberto Levo
#
#		This program is free software: you can redistribute it and/or modify
#		it under the terms of the GNU General Public License as published by
#		the Free Software Foundation, either version 3 of the License, or
#		(at your option) any later version.
#
#		This program is distributed in the hope that it will be useful,
#		but WITHOUT ANY WARRANTY; without even the implied warranty of
#		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#		GNU General Public License for more details.

#		You should have received a copy of the GNU General Public License
#		along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -e

WAVEFORM_DIR="build/tb"

if [ ! -d "$WAVEFORM_DIR" ]; then
  echo "Error: Directory '$WAVEFORM_DIR' not found."
  exit 1
fi

mapfile -t VCD_FILES < <(find "$WAVEFORM_DIR" -maxdepth 1 -name "*.vcd" | sort)

if [ ${#VCD_FILES[@]} -eq 0 ]; then
  echo "No .vcd files found in '$WAVEFORM_DIR'."
  exit 0
fi

echo "Available Waveforms:"
for i in "${!VCD_FILES[@]}"; do
  echo "  [$((i + 1))] $(basename "${VCD_FILES[$i]}")"
done

read -p "Select waveform number (1-${#VCD_FILES[@]}): " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#VCD_FILES[@]}" ]; then
  echo "Invalid choice."
  exit 1
fi

SELECTED_FILE="${VCD_FILES[$((choice - 1))]}"
echo "Opening $SELECTED_FILE..."

gtkwave "$SELECTED_FILE" > /dev/null 2>&1 &