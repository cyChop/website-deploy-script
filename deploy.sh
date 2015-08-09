#!/bin/bash
#
# This script minifies HTML, CSS and JS in a copy version of the original directory
# and makes sure RCS information (typically .git repository) is not copied along


## Constant: subdirectory if no target is supplied
DEFAULT_TARGET_SUBDIR="_deploy"
## Constant: regex to find files to minify
MINIFIABLE_FILE_REGEX=.*\.\(html?\|php\|css\|js\)$
MINIFIABLE_FIND_REGEX=".*\.\(html?\|php\|css\|js\)$"
RCS_FIND_REGEX=".*/\.\(git\|svn\)[^/]*"


## Functions
convert_to_full_path() {
	if [ -d $1 ]; then
		local abs_path="`cd \"$1\"; pwd`"
		echo "$abs_path"
	else
		echo "$1"
	fi
}

read_source() {
	source=$(convert_to_full_path $source)
}
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
	target=$(convert_to_full_path $target)
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
		echo "# Removing $target ..."
		rm -rf $target
	fi
	echo "# Copy original version to target"
	cp -pr $source $target
}

remove_versioning() {
	echo "Removing any GIT or SVN information"
	find $1 -regex $RCS_FIND_REGEX -exec echo "Remove {}" \; -prune -exec rm -rf {} \;
}

minify_file() {
	echo "Minify file $1"
	perl -pi -e 's#^[ \t]*##g; s/[ \t]*$//g;' "$1" # leading & trailing spaces
	perl -pi -e 's#//.*##g' "$1" # remove //-style comments # TODO not when in string
	perl -pi -e 's#\r?\n# #g' "$1" # new lines
	perl -pi -e 's#/\*.*?\*/##g' "$1" # multiline JS/CSS comments # TODO not when in string
	perl -pi -e 's#<!-- .*?-->##g' "$1" # multiline HTML comments # TODO not when in string
	perl -pi -e 's#[ \t]\+# #g' "$1" # multiple spaces # TODO not when in string
	# avoid matching when in string: https://stackoverflow.com/questions/6462578/alternative-to-regex-match-all-instances-not-inside-quotes
}

## Now to work
source=${1:-"`dirname \"$0\"`"}
target=$2

read_source
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
	remove_versioning $target
	echo "# Minifying all files where minification is applicable"
	find $target -regex $MINIFIABLE_FIND_REGEX | while read file; do minify_file "$file"; done
elif [[ $target =~ $MINIFIABLE_FILE_REGEX ]]; then
	echo "# Minifying target file"
	minify_file $target
fi

echo -e "\n### Done!"
