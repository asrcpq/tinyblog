#!/bin/bash
set -e
scriptdir="$(dirname $0)"
cd $scriptdir
if [ ! -d output ]; then
	mkdir output
fi

echo '<html><head>
<link href="style.css" rel="stylesheet" type="text/css" />
<meta http-equiv="content-type" content="text/html;charset=utf-8">
</head><body id="navibody"><div id="navidiv">' > output/navi.html

lastmonth="0000"
cat ./filelist | while read -r each_fullname; do
	filename="$(echo "$each_fullname" | sed -E 's/.*\/()/\1/g')"
	filehead="$(echo "$filename" | grep -o '^[^.]*')"
	suffix="$(echo "$filename" | grep -o '[^.]*$')"
	month=$(echo $filename | grep -o '^....') 
	if [ "$month" != "$lastmonth" ]; then
		echo '<hr>' >> output/navi.html
		echo "<h3>$month</h3>" >> output/navi.html
	fi
	lastmonth=$month
	if [ "$suffix" = 'md' ]; then
		# this works with nonexistent output file
		if [ ! "$each_fullname" -ot "./output/$filehead.html" ]; then
			echo -n "+"
			pandoc "$each_fullname" \
				-s \
				--metadata pagetitle="$filehead" \
				--css "../pandoc.css" \
				-o output/"$filehead".html
		else
			echo -n "."
		fi
		echo "<a draggable="false" href=\"$filehead.html\"" \
			"target=bodyinfo>$filehead<br></a>" >> output/navi.html
	elif [ "$suffix" = "mdproj" ]; then
		echo -n 'x'
		# in makefile use --css ../../pandoc.css
		make -C "$each_fullname" -j -s
		rm -rf output/"$filename"
		mkdir output/"$filename"
		ln -s "$each_fullname"/output.html output/"$filename"/output.html
		ln -s "$each_fullname"/resource output/"$filename"/resource
		echo "<a draggable="false" href=\"output/$filename/output.html\"" \
			"target=bodyinfo>$filehead<br></a>" >> output/navi.html
	fi
done
echo
