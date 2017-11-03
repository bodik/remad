#!/bin/sh

set -e

for all in $(find "$(dirname $(readlink -f $0))/test" -type f -name '*sh'); do 
	sh $all
done
