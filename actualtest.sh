#!/bin/sh

$TESTEXEC > test.out 2>&1

if test $TYPE != dom; then
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
fi

if ! grep Finished test.out > /dev/null; then
  if test $TYPE != dom || ! grep "$BASE$URI" $XFAIL > /dev/null; then
    echo  $BASE $URI $TYPE >> $CRASHED
  fi
  exit 0
else
  grep -v "$BASE $URI" $CRASHED > $TMPFILE; mv $TMPFILE $CRASHED
fi

if grep Remaining test.out > /dev/null; then
  echo $BASE$URI $TYPE >> $LEAKED
fi
rm -f test.out

if test x$OUTPUT != x && test $TYPE = dom; then
  if ! grep "$BASE$URI" $XFAIL > /dev/null  && ! grep "$BASE$URI" $NONASCII > /dev/null; then
    cat $OUTPUT > out.xml.orig
    echo >> out.xml.orig
    echo diff
    if diff out.xml.orig out.xml > test.out; then
      echo $BASE $URI diff >> $PASSED
    else
      echo $BASE $URI diff >> $FAILED
      echo $BASE $URI diff >> $DIFF
      cat test.out >> $DIFF
      echo >> $DIFF
      echo diffdone >> $DIFF
    fi
    rm -f out.xml out.xml.orig test.out
  fi
fi

if test $TYPE = dom; then
  echo $BASE $URI $TYPE >> $PASSED
else
  if test $fail = yes; then
    echo failed
    if grep "$BASE$URI" $XFAIL > /dev/null || grep "$BASE$URI" $NONASCII > /dev/null; then
      grep -v "$BASE $URI" $FAILED > $TMPFILE; mv $TMPFILE $FAILED
      echo $BASE$URI $TYPE >> $XFAIL.out
    else
      echo $BASE $URI $TYPE >> $FAILED
    fi
    grep -v "$BASE $URI $TYPE" $PASSED > $TMPFILE; mv $TMPFILE $PASSED
  else
    echo passed
    if grep "$BASE$URI" $XFAIL > /dev/null || grep "$BASE$URI" $NONASCII; then
      echo XPASS
      echo $BASE $URI $TYPE >> $XPASS
    else
      grep -v "$BASE $URI $TYPE" $FAILED > $TMPFILE; mv $TMPFILE $FAILED
      echo $BASE $URI $TYPE >> $PASSED
    fi
  fi
fi
