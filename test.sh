#!/bin/sh

if [ $# -lt 4 ]; then
  echo Usage: test.sh \$TYPE \$NAMESPACE \$BASE \$URI \$OUTPUT
  exit 1
fi

. filenames.sh

TYPE=$1
NAMESPACE=$2
BASE=$3
URI=$4
OUTPUT=$5

export TYPE NAMESPACE BASE URI OUTPUT

XMLFILE=$(basename $BASE$URI)
XMLDIR=$(dirname $BASE$URI)

cd $XMLDIR
ln -sf $XMLFILE test.xml
echo -n "Checking $BASE$URI for $TYPE "

case $TYPE in
  not-wf)
    POSITIVE=no
    TESTEXEC=$SAX_WELL_FORMED.ns.$NAMESPACE.exe
    export POSITIVE TESTEXEC
    $ACTUALTEST
    ;;

  valid)
    POSITIVE=yes
    TESTEXEC=$SAX_VALID.ns.$NAMESPACE.exe
    export POSITIVE TESTEXEC
    $ACTUALTEST
    if test $NAMESPACE = yes; then
      TYPE=dom
      TESTEXEC=$DOM.ns.$NAMESPACE.exe
      export TESTEXEC
      $ACTUALTEST
    fi
    ;;

  invalid)
    POSITIVE=yes
    TESTEXEC=$SAX_WELL_FORMED.ns.$NAMESPACE.exe
    export POSITIVE TESTEXEC
    $ACTUALTEST
    POSITIVE=no
    TESTEXEC=$SAX_VALID.ns.$NAMESPACE.exe
    export POSITIVE TESTEXEC
    $ACTUALTEST
    if test $NAMESPACE = yes; then
      TYPE=dom
      TESTEXEC=$DOM.ns.$NAMESPACE.exe
      export TESTEXEC
      $ACTUALTEST
    fi
    ;;

  error)
    POSITIVE=no
# FIXME should test only for error here
    TESTEXEC=$SAX_WELL_FORMED.ns.$NAMESPACE.exe
    export POSITIVE TESTEXEC
    $ACTUALTEST
    break
    ;;
esac
rm -f test.out out.xml test.xml
