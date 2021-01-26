#!/bin/bash
set -e

TB_ROOT="$XDG_DATA_HOME/tinyblog"

if [ -z "$1" ]; then
	exit 1
fi

current_path="$(readlink -f $1)"
cd "$TB_ROOT"
cp index.html $current_path
cp pandoc.css $current_path
cp style.css $current_path

cd "$1"
if ! [ -d output ]; then
	mkdir output
fi

echo '<html><head>
<link href="../style.css" rel="stylesheet" type="text/css" />
<meta http-equiv="content-type" content="text/html;charset=utf-8">
</head><body id="navibody"><div id="navidiv">' > output/navi.html

lastmonth="0000"
find ./src -type f -regextype sed -regex '.*/[0-9]\{6\}[^/]*\.md' |\
	sed -E 's/(.*\/)([0-9]{6})(.*)/\2 \1\2\3/g' |\
	sort -r |\
	cut -d' ' -f2 |\
	while read -r each_fullname; do
	filename="${each_fullname##*/}"
	filehead="${filename%.*}"
	month=${filename:0:4}
	if [ "$month" != "$lastmonth" ]; then
		echo '<hr>' >> output/navi.html
		echo "<h3>$month</h3>" >> output/navi.html
	fi
	lastmonth=$month
	# this works with nonexistent output file
	if [ ! "$each_fullname" -ot "./output/$filehead.html" ]; then
		echo -n "+"
		pandoc "$each_fullname" \
			-s \
			--metadata pagetitle="$filehead" \
			--highlight-style=breezedark \
			--css "../pandoc.css" \
			-o output/"$filehead".html
	else
		echo -n "."
	fi
	echo "<a draggable="false" href=\"$filehead.html\"" \
		"target=bodyinfo>$filehead<br></a>" >> output/navi.html
done
echo '<hr>' >> output/navi.html
echo "</div></body></html>" >> output/navi.html
echo
