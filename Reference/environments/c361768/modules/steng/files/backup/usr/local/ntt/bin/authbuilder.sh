#!/bin/sh

AUTHFILE=/usr/openv/java/auth.conf
TMPFILE=`mktemp /tmp/nbja.XXXXXXXXXX`
cat /dev/null > $TMPFILE
echo "root ADMIN=ALL JBP=ALL" >>$TMPFILE
getent passwd | awk -F: '{ if($3 > 9999) if ($3 < 40000) printf("%s ADMIN=ALL JBP=ALL\n", tolower($1)); }' >> $TMPFILE

NEW_COUNT=`wc -l $TMPFILE | awk '{ print $1 }'`
OLD_COUNT=`wc -l $AUTHFILE | awk '{ print $1 }'`

DIFF=`expr $NEW_COUNT - $OLD_COUNT | tr -d -- -`

if [ $DIFF -gt 100 ]; then
  echo "files differ by more than 100 lines"
  exit 1
fi

cp $AUTHFILE ${AUTHFILE}.bak
mv $TMPFILE $AUTHFILE
