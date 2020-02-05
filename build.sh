#!/bin/bash
flattendir="flatten"
scriptdir="$(dirname $0)"
cd $scriptdir
rm -rf "$flattendir"
mkdir "$flattendir"
cd "$flattendir"
find ../src/ -type f -name "*.md" | egrep '.*/[0-9]{6}[^/]*\.md' | xargs -i ln -s {} ./
cd ..

filelist="$(ls -r "$flattendir" | egrep '^[0-9]{6}')"
ls output | egrep '^[0-9]{6}' | xargs -i rm output/{}
echo '<html><head>
<link href="style.css" rel="stylesheet" type="text/css" />
<meta http-equiv="content-type" content="text/html;charset=utf-8">
</head><body id="navibody"><div id="navidiv">' > output/navi.html
lastmonth="0000"
for file in "$filelist"; do
	filehead=$(echo "$file" | egrep -o '^[^.]*')
	title=$(cat "$flattendir"/"$file" | head -1 | sed 's/^# //g')
	month=$(echo $file | grep -o '^....') 
	if [ "$month" != "$lastmonth" ]; then
		echo '<hr>' >> output/navi.html
		echo "<h3>$month</h3>" >> output/navi.html
	fi
	lastmonth=$month
	echo "<a draggable="false" href=\"$filehead.html\"" \
			"target=bodyinfo>$title<br></a>" >> output/navi.html
	pandoc "$flattendir"/"$file" --css pandoc.css -o output/$filehead.html -s
done

echo '<hr></div></body></html>' >> output/navi.html
