#!/bin/bash

set -e
set -v

export KEYNAME=vpad@responsivetech.ca

(
	set -e
	set -v

	cd ./ubuntu/

	dpkg-scanpackages --multiversion . > Packages
	gzip -k -f Packages

	apt-ftparchive release . > Release
	gpg --default-key "${KEYNAME}" -abs -o - Release > Release.gpg
	gpg --default-key "${KEYNAME}" --clearsign -o - Release > InRelease

)
