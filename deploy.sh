#!/bin/bash
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# This script minifies HTML, CSS and JS in a copy version of the original directory
# and makes sure RCS information (typically .git repository is not copied along)


## Constant: subdirectory if no target is supplied
DEFAULT_TARGET_SUBDIR="_deploy"
## Constant: regex to find files to minify
MINIFIABLE_FILE_REGEX=.*\.\(html?\|php\|css\|js\)$


## Functions
check_source() {
	if [ -z source ]; then
		echo "Source could not be determined"
		exit 1; # fail
	elif [ ! -e $source ]; then
		echof "Source $source does not exist"
		exit 1; # fail
	fi
}

read_target() {
	if [ -z $target ]; then
		if [ -d $source ]; then
			target="${source%/}$DEFAULT_TARGET_SUBDIR"
		else
			target="`dirname \"$source\"`$DEFAULT_TARGET_SUBDIR/`basename \"$source\"`"
		fi
	fi
}
check_target() {
	abort=false
	if [ -e $target ]; then
		confirm_erase_target
        fi
	if $abort; then
		echo "Aborting";
		exit 0; # no error
	fi;
}
confirm_erase_target() {
	read -p "Target $target already exists and will be erased. Do you confirm? [Y/n] " confirm
	case ${confirm:-y} in
		[nN] )	abort=true
			;;
		[yY] )	;;
		* )	echo "Incorrect input."
			confirm_erase_target
	esac
}

copy_to_target() {
	if [ -e $target ]; then
		echo "Removing $target ..."
		rm -rf $target
	fi
	cp -pr $source $target
}

remove_versioning() {
	# TODO remove versioning info
	echo "TODO remove versioning info $target"
}
minify_file() {
	# TODO minify file
	echo "TODO minify file $1"
}

## Now to work
source=${1:-"`dirname \"$0\"`"}
target=$2

echo "### Source is: $source"
check_source
read_target
echo "### Target is: $target"
check_target

echo -e "\n### Executing"
## copy
copy_to_target
## clean target
if [ -d $target ]; then
	remove_versioning
	find $target -regex "$MINIFIABLE_FILE_REGEX" -exec minify_file {} \;
elif [[ $target =~ $MINIFIABLE_FILE_REGEX ]]; then
	minify_file $target
fi

echo -e "\n### Done!"

