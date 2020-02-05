#!/bin/bash
set -e
scriptdir="$(dirname $0)"
cd $scriptdir
filelist="$(find ./src -type f -name "*.md" | egrep '.*/[0-9]{6}[^/]*\.md' | sed -E 's/(.*\/)([0-9]{6})(.*)/\2 \1\2\3/g' | sort -r | cut -d' ' -f2)"
if [ ! -d output ]; then
	mkdir output
fi
ls output | egrep '^[0-9]{6}' | xargs -i rm output/{}
echo '<html><head>
<link href="style.css" rel="stylesheet" type="text/css" />
<meta http-equiv="content-type" content="text/html;charset=utf-8">
</head><body id="navibody"><div id="navidiv">' > output/navi.html
lastmonth="0000"
echo "$filelist" | while read -r each_fullname; do
	echo "$each_fullname"
	filename=$(echo "$each_fullname" | sed -E 's/.*\/()/\1/g')
	filehead=$(echo "$filename" | egrep -o '^[^.]*')
	title=$(cat "$each_fullname" | head -1 | sed 's/^# //g')
	month=$(echo $filename | grep -o '^....') 
	if [ "$month" != "$lastmonth" ]; then
		echo '<hr>' >> output/navi.html
		echo "<h3>$month</h3>" >> output/navi.html
	fi
	lastmonth=$month
	echo "<a draggable="false" href=\"$filehead.html\"" \
			"target=bodyinfo>$title<br></a>" >> output/navi.html
	pandoc "$each_fullname" --metadata pagetitle="$title" --css pandoc.css -o output/$filehead.html -s
done

echo '<hr></div></body></html>' >> output/navi.html
