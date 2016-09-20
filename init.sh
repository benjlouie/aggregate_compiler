#!/bin/bash
git submodule init
MYDIR="../aggregate_compiler"

DIRS=`ls --time-style="long-iso"  -l ../aggregate_compiler | egrep '^d' | awk '{print $8}'`

for DIR in $DIRS; do
	cd $DIR
	git checkout master && git pull
	cd ..
done

