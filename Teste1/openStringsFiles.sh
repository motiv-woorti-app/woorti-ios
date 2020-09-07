#!/bin/sh

for case in *.lproj ; do
	open -a TextEdit $case/Localizable.strings
done