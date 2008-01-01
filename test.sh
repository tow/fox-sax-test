#!/bin/sh

if [ $# -ne 4 ]; then
  echo Usage: test.sh \$TYPE \$NAMESPACE \$BASE \$URI
  exit 1
fi

. filenames.sh

TYPE=$1
NAMESPACE=$2
BASE=$3
URI=$4

XMLFILE=$(basename $BASE$URI)
XMLDIR=$(dirname $BASE$URI)

cd $XMLDIR
ln -sf $XMLFILE test.xml
fail=no
leaked=no
echo -n "Checking $BASE$URI for $TYPE "

case $TYPE in
  not-wf)
    $SAX_WELL_FORMED.ns.$NAMESPACE.exe > test.out 2>&1
    if ! grep Error test.out > /dev/null; then
      fail=yes
    fi
    break
    ;;

  valid)
    $SAX_VALID.ns.$NAMESPACE.exe > test.out 2>&1
    if grep Error test.out > /dev/null; then
      fail=yes
    fi
    break
    ;;

  invalid)
    $SAX_WELL_FORMED.ns.$NAMESPACE.exe > test.out 2>&1
    if grep Error test.out > /dev/null; then
      fail=yes
    fi
    $SAX_VALID.ns.$NAMESPACE.exe > test.out 2>&1
    if ! grep Error test.out > /dev/null; then
      fail=yes
    fi
    break
    ;;

  error)
    $SAX_VALID.ns.$NAMESPACE.exe > test.out 2>&1
    if ! grep Error test.out > /dev/null; then
      fail=yes
    fi
    break
    ;;
esac

if ! grep Finished test.out > /dev/null; then
  echo $BASE $URI >> $CRASHED
  exit 0
else
  grep -v "$BASE $URI" $CRASHED > $TMPFILE; mv $TMPFILE $CRASHED
fi

if grep Remaining test.out > /dev/null; then
  leaked=yes
fi
rm -f test.xml test.out

if [ $fail = yes ]; then
  echo failed
  if grep "$BASE$URI" $XFAIL > /dev/null; then
    grep -v "$BASE $URI" $FAILED > $TMPFILE; mv $TMPFILE $FAILED
    echo $BASE$URI $TYPE >> $XFAIL.out
  else
    echo $BASE $URI $TYPE >> $FAILED
  fi
  grep -v "$BASE $URI" $PASSED > $TMPFILE; mv $TMPFILE $PASSED
else
  echo passed
  if grep "$BASE$URI" $XFAIL > /dev/null; then
    echo $BASE $URI $TYPE >> $XPASS
  else
  grep -v "$BASE $URI" $FAILED > $TMPFILE; mv $TMPFILE $FAILED
  echo $BASE $URI $TYPE >> $PASSED
  fi
fi

cd $THISPWD
