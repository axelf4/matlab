#!/bin/sh

shortNames='An Ax Da Ra Ru To ()'

for name in $shortNames; do
	echo "'$name'"
	gradle run --args="$name"
	mv output.ical "schema_$name.ical"
done

tar -cvf schemas.tar schema_*
