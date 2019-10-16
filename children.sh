#!/usr/bin/env bash

PROJECT='github-markdown-child-pages'
EXT='.md'									# Markdown files
unwanted=" \[$( whoami )\] "				# " [username] "

# -----------------------------------------------------------------------------
# Read into an array a path listing of all the $EXT files below $1.
# -----------------------------------------------------------------------------
IFS=$'\n' read -d '' -r -a tree \
	< <( tree -ufF -I images -P "*$EXT" --prune -n --charset=ascii "${1:-.}" )

numBranches="$((${#path[@]}-1))"			# the last array element
unset "tree[$numBranches]"					# remove `path` summary line

echo "<!-- ${PROJECT}-start -->"			# an easy-to-find start marker
for branch in "${tree[@]}"					# for each line of output left
do
	# -------------------------------------------------------------------------
	# Output from path will look something like:
	#
	# (ASCII path branches) [username] /path/to/file/or/directory
	#
	# so we'll preserve the branch graphics and work on the filepath and then
	# put the parts together.
	# -------------------------------------------------------------------------
	branch="${branch//\`/\\}"				#
	branch="${branch//$unwanted/}"			# remove "[username]" from each line
 	path="${branch%%-- *}"					# grab left section including `-- `
 	if [ "$path" == "." ]; then continue ; fi # skip the top of the path
 	filepath="${branch##*-- }"				# grab right section after `-- `

	# convert ASCII path items to prettier HTML variants
	path="${path// /&nbsp;}"				# non-collapsing spaces
	path="${path//\|/&#9122;}"				# vertical lines
	path="${path//\\/&#9123;}"				# last item in list marker

	if [ "${filepath:(-${#EXT})}" == "$EXT" ]; then
		# ---------------------------------------------------------------------
		# If $filepath ends with the specified extension ($EXT) then grab the
		# first line of the file specified to use as a human-readable link part.
		# ---------------------------------------------------------------------
		read -r firstline<"$filepath"
		doctitle="${firstline#* }"
		branch="$path [$doctitle]($filepath)"
	else
		# ---------------------------------------------------------------------
		# Otherwise this line must be a directory element. Grab the leaf name.
		#
		# Special case: if you pass in '.' the first line will become '. .' :-/
		# ---------------------------------------------------------------------
		if [ "$filepath" == '.' ]; then
			leafname=''
		else
			x="${filepath%%/}"				# remove trailing slash
			leafname="${x##*/}"				# trailing directory name
			branch="$path $leafname"		# format the output
		fi
	fi

	echo "$branch<br>"
done
echo "<small><small><i>Generated by <a href=\"https://github.com/mickeys/${PROJECT}\">${PROJECT}</a></i>.</small></small>"

echo "<!-- ${PROJECT}-end -->"					# an easy-to-find start marker