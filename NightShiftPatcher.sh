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
FRAMEWORKBAK="${FRAMEWORK}.bak"
if [[ $1 == "-t" ]]; then
	FRAMEWORK='CoreBrightness.framework'
	echo -e "${RED}Running test on script's nearby $FRAMEWORK...${NC}"
fi
CORE="${FRAMEWORK}/Versions/A/CoreBrightness"

echo -e "${ORANGE}\nNightShiftPatcher 1.0.1 by aONe ® 2017-2019 (https://github.com/aonez/NightShiftPatcher)${NC}"
echo -e "Original idea by ${ORANGE}Pike${NC} (https://pikeralpha.wordpress.com/2017/01/30/4398)${NC}"
echo -e "Motivated by ${ORANGE}NightPatch${NC} (https://github.com/pookjw/NightPatch)\n${NC}"

if [ ${EUID} != 0 ]; then
    echo -e "${ORANGE}\nThis script needs elevated privileges...${NC}"
    sudo "$0" "$@"
    exit $?
fi

if [[ $1 == "-r" ]] || [[ $2 == "-r" ]]; then
	echo 'Restoring the backup...'
	if [ ! -d "${FRAMEWORKBAK}" ]; then
		echo -e "${RED}The backup can't be found at ${FRAMEWORKBAK}${NC}"
		exit 1
	fi
	if [ -f "${FRAMEWORKBAK}/Versions/Current/CoreBrightness.temp" ]; then
		echo -e "${ORANGE}Removing obsolete file \"CoreBrightness.temp\" from the backup...${NC}"
		rm "${FRAMEWORKBAK}/Versions/Current/CoreBrightness.temp"
	fi
	if [ -f "${FRAMEWORKBAK}/Versions/Current/CoreBrightness.tbd" ]; then
		echo -e "${ORANGE}Removing obsolete file \"CoreBrightness.tbd\" from the backup...${NC}"
		rm "${FRAMEWORKBAK}/Versions/Current/CoreBrightness.tbd"
	fi
	
	sudo mv "${FRAMEWORK}" "${FRAMEWORK}.hack";
	mv "${FRAMEWORKBAK}" "${FRAMEWORK}";
	
	if [ -d "${FRAMEWORK}" ]; then
		rm -R "${FRAMEWORK}.hack"
		echo -e "${GREEN}The backup is now restored. Restart your system now :)${NC}"
	else
		echo -e "${RED}The backup might be not restored. Do it manually.${NC}"
	fi
	exit 0
fi

echo "Checking for requirements..."

SIPSTATUS="$(csrutil status)"
if [[ $SIPSTATUS == *'enabled'* ]]; then
	echo -e "${RED}\nSIP needs to be disabled. Restart in rescue mode and disable it with \"csrutil disable\"\n${NC}"
	exit 1
elif [[ $SIPSTATUS == *'disabled'* ]]; then
	echo -e "${GREEN}SIP is disabled${NC}"
fi

function check_nm_xcode {
	NMOUTPUT="$(nm -help  2>&1)"
	NMCHECK=$?
	if [ $NMCHECK -eq 0 ]; then
		return 0
	elif [[ $NMOUTPUT == 'xcode-select: note: no developer tools were found'* ]]; then
		return 1
	else
		xcode-select --install
		return 1
	fi
}

if check_nm_xcode; then
	echo -e "${GREEN}Binary nm is functional${NC}"
else
	echo -e "${ORANGE}Install the Command Line Developer Tools when prompted to continue${NC}"
	while ! check_nm_xcode
	do
		echo -n '.'
		sleep 2
	done
	echo
fi

echo 'Looking for minimum requirements check offset...'
OFFSETRAW="$(nm "${CORE}" | grep _ModelMinVersion | cut -d' ' -f 1 | sed -e 's/^0*//g' | head -1)"
OFFSET="0x${OFFSETRAW}"

if [ -z ${OFFSETRAW} ]; then
	echo -e "${RED}Can't find the offset to patch, get in contact with the developer. No patch applied.${NC}"
	exit 1
fi
echo -e "${ORANGE}Offset: ${GREEN}${OFFSET}${NC}"

echo 'Getting offset hex data...'
OFFSETDATARAW="$(xxd -s ${OFFSET} -c 24 -l 24 "${CORE}")"
echo -e "${ORANGE}Original hex: ${GREEN}${OFFSETDATARAW}${NC}"

if [[ $OFFSETDATARAW == *'0100 0000 0100 0000 0100 0000 0100 0000 0100 0000 0100 0000'* ]]; then
	echo -e "${ORANGE}\nThe patch is already applied on \"${FRAMEWORK}\". Nothing to do here.\n${NC}"
	exit 2
fi

if [ -f "${FRAMEWORK}/Versions/Current/CoreBrightness.temp" ]; then
	echo -e "${ORANGE}Removing obsolete file \"CoreBrightness.temp\" from the backup...${NC}"
	rm "${FRAMEWORK}/Versions/Current/CoreBrightness.temp"
fi
if [ -f "${FRAMEWORK}/Versions/Current/CoreBrightness.tbd" ]; then
	echo -e "${ORANGE}Removing obsolete file \"CoreBrightness.tbd\" from the backup...${NC}"
	rm "${FRAMEWORK}/Versions/Current/CoreBrightness.tbd"
fi

echo 'Cloning the framework...'
FRAMEWORKHACK="${FRAMEWORK}.hack"
echo ${FRAMEWORKHACK}
if [ -d "${FRAMEWORKHACK}" ]; then
	rm -R "${FRAMEWORKHACK}"
fi
cp -R "${FRAMEWORK}" "${FRAMEWORKHACK}"
COREHACK="${FRAMEWORKHACK}/Versions/A/CoreBrightness"

echo ${COREHACK}

echo 'Replacing offset hex data...'
printf "\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00" | dd count=24 bs=1 seek=$((${OFFSET})) of="${COREHACK}" conv=notrunc > /dev/null 

echo 'Checking offset hex replaced...'
CHECK="$(xxd -s ${OFFSET} -c 24 -l 24 "${COREHACK}")"
echo -e "${ORANGE}Replaced hex: ${GREEN}${CHECK}${NC}"

echo 'Resigning the framework...'
sudo codesign -f -s - "${FRAMEWORKHACK}"

echo 'Checking new signature...'
SIGNCHECK="$(codesign --verify --deep --verbose=2 --strict "${FRAMEWORKHACK}" 2>&1 >/dev/null)"
if [[ ${SIGNCHECK} = *"valid on disk"*"satisfies its Designated Requirement"* ]]; then
	echo -e "${GREEN}New signature checked${NC}"
else
	rm -R "${FRAMEWORKHACK}"
	echo -e "${RED}\nThe new signature is invalid or can't be applied. Check the original framework sigature is valid and try again. No patch applied.\n${ORANGE}${SIGNCHECK}\n\n${NC}"
	exit 1
fi

echo "Creating a backup at \"${FRAMEWORKBAK}\"..."
if [ -d "${FRAMEWORKBAK}" ]; then
	rm -R "${FRAMEWORKBAK}"
fi
mv "${FRAMEWORK}" "${FRAMEWORKBAK}"

echo "Using the patched version..."
mv "${FRAMEWORKHACK}" "${FRAMEWORK}"

echo -e "\n\n${GREEN}All done now :)\n${NC}"

exit 0
