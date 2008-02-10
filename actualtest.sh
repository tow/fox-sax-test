#!/bin/sh

$TESTEXEC > test.out 2>&1

fail=no

if test $POSITIVE = yes; then
  if grep "Fatal error" test.out > /dev/null; then
    fail=yes
  fi
else
  if ! grep "Fatal error" test.out > /dev/null; then
    fail=yes
  fi
fi

if ! grep Finished test.out > /dev/null; then
  echo  $BASE $URI $TYPE >> $CRASHED
  exit 0
else
  grep -v "$BASE $URI" $CRASHED > $TMPFILE; mv $TMPFILE $CRASHED
fi

if grep Remaining test.out > /dev/null; then
  echo $BASE$URI $TYPE >> $LEAKED
fi
rm -f test.out

if test x$OUTPUT != x && test $TYPE = dom; then
  echo DO COMPARISON HERE
  # crlfdiff $OUTPUT out.xml
fi

if test $fail = yes; then
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
    echo XPASS
    echo $BASE $URI $TYPE >> $XPASS
  else
  grep -v "$BASE $URI" $FAILED > $TMPFILE; mv $TMPFILE $FAILED
  echo $BASE $URI $TYPE >> $PASSED
  fi
fi
