#! /bin/bash

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
YELLOW='\033[1;31m'
WHITE='\033[1;97m'
LIGHTGRAY='\033[1;37m'
DARKGRAY='\033[1;90m'
NC='\033[0m' # No Color



CORE='/System/Library/PrivateFrameworks/CoreBrightness.framework/Versions/A/CoreBrightness'

cd "${0%/*}"
clear

echo
echo -e "${WHITE}NightShiftPatcher by aONe ® 2017 (https://github.com/aonez/NightShiftPatcher)${NC}"
echo -e "${DARKGRAY}Original idea by ${WHITE}Pike${DARKGRAY} (https://pikeralpha.wordpress.com/2017/01/30/4398)${NC}"
echo -e "${DARKGRAY}Motivated by ${WHITE}NightPatch${DARKGRAY} (https://github.com/pookjw/NightPatch)${NC}"
echo
echo

echo "Cloning CoreBrightness..."
CORETEMP=$CORE.temp
cp $CORE $CORE.temp

echo 'Looking for minimum requirements check offset...'
OFFSETRAW="$(nm $CORETEMP | grep _ModelMinVersion | cut -d' ' -f 1 | sed -e 's/^0*//g')"
OFFSET="0x$OFFSETRAW"
echo -e "${ORANGE}Offset: ${GREEN}$OFFSET${NC}"

echo 'Getting offset hex data...'
OFFSETDATARAW="$(xxd -s $OFFSET -c 24 -l 24 $CORETEMP)"
echo -e "${ORANGE}Original hex: ${GREEN}$OFFSETDATARAW${NC}"

echo 'Replacing offset hex data...'
printf "\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00" | dd count=24 bs=1 seek=$(($OFFSET)) of="$CORETEMP" conv=notrunc > /dev/null 

echo 'Checking offset hex replaced...'
CHECK="$(xxd -s $OFFSET -c 24 -l 24 $CORETEMP)"
echo -e "${ORANGE}Replaced hex: ${GREEN}$CHECK${NC}"

echo 'Creating a backup...'
cp $CORE $HOME/Desktop/CoreBrightness.bak

echo 'Replacing CoreBrightness with patched one...'
mv $CORETEMP $CORE

echo 'Resigning kext...'
sudo codesign -f -s - $CORE

echo
echo
echo -e "${GREEN}All done now :)${NC}"
echo
exit
