#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: process_mcf.sh <path_to_mcf>"
  exit
fi
XSL_DIR="${0/process_mcf.sh/}"
MCF="$1"
HTMLOUT="${MCF/.mcf/.html}"
if [ "${MSYSTEM}" == "MINGW64" ]; then
  # We're running on Windows (probably in the Git shell)
  CHROME="/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
  SAXON=$(find /c/Program\ Files/Sax* -name Transform.exe)
  HTML="file:///$(cygpath -ma ${HTMLOUT})"
else
  # These values work on my install of Debian Linux
  CHROME="google-chrome"
  SAXON="saxonb-xslt"
  HTML="${HTMLOUT}"
fi
echo "Processing ${MCF} to ${HTML}..."
"${SAXON}" -s:${MCF} -xsl:${XSL_DIR}mcf2html.xsl -o:${HTMLOUT}
if [ $? -ne 0 ]; then
  echo "Failed XSL processing, stopping."
  exit
fi
echo "Starting Chrome with ${HTML}..."
export T=$(mktemp -d)
"${CHROME}" --disable-web-security --user-data-dir=$T ${HTML}

echo "Removing temporary user profile..."
rm -rf ${T}
