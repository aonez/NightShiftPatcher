#! /bin/bash

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
YELLOW='\033[1;31m'
WHITE='\033[1;97m'
LIGHTGRAY='\033[1;37m'
DARKGRAY='\033[1;90m'
NC='\033[0m' # No Color

cd "${0%/*}"
clear

FRAMEWORK='/System/Library/PrivateFrameworks/CoreBrightness.framework'
if [ $1 == "-t" ]; then
	FRAMEWORK='CoreBrightness.framework'
	echo -e "${RED}Running test on script's nearby $FRAMEWORK...${NC}"
fi
CORE="${FRAMEWORK}/Versions/A/CoreBrightness"

echo -e "${ORANGE}\nNightShiftPatcher by aONe ® 2017 (https://github.com/aonez/NightShiftPatcher)${NC}"
echo -e "Original idea by ${ORANGE}Pike${NC} (https://pikeralpha.wordpress.com/2017/01/30/4398)${NC}"
echo -e "Motivated by ${ORANGE}NightPatch${NC} (https://github.com/pookjw/NightPatch)\n\n${NC}"

echo "Checking for requirements..."
function check_nm_xcode {
	NMOUTPUT="$(nm -help  2>&1)"
	if [[ $NMOUTPUT == "xcode-select: note: no developer tools were found"* ]]; then
		return 1
	else
		return 0
	fi
}
if check_nm_xcode; then
	echo -e "${GREEN}nm ok${NC}"
else
	echo -e -n "${ORANGE}Install the Command Line Developer Tools when prompted to continue${NC}"
	while ! check_nm_xcode
	do
		echo -n '.'
		sleep 2
	done
	echo
fi

if [ ${EUID} != 0 ]; then
    echo 'This script needs elevated privileges...'
    sudo "$0" "$@"
    exit $?
fi

echo 'Cloning CoreBrightness...'
CORETEMP="${CORE}.temp"
cp "${CORE}" "${CORETEMP}"

echo 'Looking for minimum requirements check offset...'
OFFSETRAW="$(nm "${CORETEMP}" | grep _ModelMinVersion | cut -d' ' -f 1 | sed -e 's/^0*//g' | head -1)"
OFFSET="0x${OFFSETRAW}"
echo -e "${ORANGE}Offset: ${GREEN}${OFFSET}${NC}"

echo 'Getting offset hex data...'
OFFSETDATARAW="$(xxd -s ${OFFSET} -c 24 -l 24 "${CORETEMP}")"
echo -e "${ORANGE}Original hex: ${GREEN}${OFFSETDATARAW}${NC}"

echo 'Replacing offset hex data...'
printf "\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00" | dd count=24 bs=1 seek=$((${OFFSET})) of="${CORETEMP}" conv=notrunc > /dev/null 

echo 'Checking offset hex replaced...'
CHECK="$(xxd -s ${OFFSET} -c 24 -l 24 "${CORETEMP}")"
echo -e "${ORANGE}Replaced hex: ${GREEN}${CHECK}${NC}"

echo 'Creating a backup...'
cp -R "${FRAMEWORK}" "${FRAMEWORK}.bak"

echo 'Replacing CoreBrightness with patched one...'
mv "${CORETEMP}" "${CORE}"

echo 'Resigning kext...'
sudo codesign -f -s - "${CORE}"

echo
echo
echo -e "${GREEN}All done now :)${NC}"
echo
exit