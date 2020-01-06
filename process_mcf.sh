#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: process_mcf.sh <path_to_mcf>"
  exit
fi
XSL_DIR="${0/process_mcf.sh/}"
MCF=$1
HTML=${MCF/.mcf/.html}
echo "Processing ${MCF} to ${HTML}..."
saxonb-xslt -s:${MCF} -xsl:${XSL_DIR}mcf2html.xsl -o:${HTML}
if [ $? -ne 0 ]; then
  echo "Failed XSL processing, stopping."
  exit
fi
echo "Starting Chrome with ${HTML}..."
export T=$(mktemp -d)
google-chrome --disable-web-security --user-data-dir=$T ${HTML}

echo "Removing temporary user profile..."
rm -rf ${T}
