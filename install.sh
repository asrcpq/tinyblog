current_path="$(readlink -f $1)"
parent_path=$( cd "$(dirname "$0")" ; pwd -P )
cd "$parent_path"
cp index.html $current_path
cp pandoc.css $current_path
cp style.css $current_path
cp generators.sh $current_path
