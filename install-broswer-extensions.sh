#!/bin/zsh
echo "\nInstalling Brave extensions..."
BRAVE_EXTENSIONS=~/Library/Application\ Support/BraveSoftware/Brave-Browser/External\ Extensions

mkdir -p ${BRAVE_EXTENSIONS}
# Google Translate
echo "{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}" > ${BRAVE_EXTENSIONS}/aapbdbdomjkkjkaonfhkkikfgjllcleb.json
# Grammarly
echo "{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}" > ${BRAVE_EXTENSIONS}/kbfnbcaeplbcioakkpcpgfkobkghlhen.json
# ModHeader
echo "{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}" > ${BRAVE_EXTENSIONS}/idgpnmonknjnojddfkpgkljpfnnfcklj.json
# JSON Formatter
echo "{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}" > ${BRAVE_EXTENSIONS}/bcjindcccaagfpapjjmafapmmgkkhgoa.json

echo "\nInstalling Chrome extensions..."
CHROME_EXTENSIONS=~/Library/Application\ Support/Google/Chrome\ Canary/External\ Extensions/

mkdir -p ${CHROME_EXTENSIONS}
# Google Translate
echo "{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}" > ${CHROME_EXTENSIONS}/aapbdbdomjkkjkaonfhkkikfgjllcleb.json
# Grammarly
echo "{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}" > ${CHROME_EXTENSIONS}/kbfnbcaeplbcioakkpcpgfkobkghlhen.json
# ModHeader
echo "{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}" > ${CHROME_EXTENSIONS}/idgpnmonknjnojddfkpgkljpfnnfcklj.json
# JSON Formatter
echo "{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}" > ${CHROME_EXTENSIONS}/bcjindcccaagfpapjjmafapmmgkkhgoa.json

echo "\nInstalling Firefox extensions..."
