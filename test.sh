#!/bin/sh

set -e

for all in $(find "$(dirname $(readlink -f $0))/test" -type f -name '*sh'); do 
	echo "INFO: run test $all"
	sh $all
done
