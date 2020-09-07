#!/bin/sh

#for case in *.lproj ; do
#find . -type f -name \*.swift -print0 | xargs -0 xcrun extractLocStrings -o $case
#done

find . -type f -name \*.swift -print0 | xargs -0 xcrun extractLocStrings -o .

#WorthwhilenessTutorialFirstScreenViewController