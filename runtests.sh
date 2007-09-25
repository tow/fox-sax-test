#!/bin/sh

THISPWD=$(pwd)
XSL=$(tempfile)
TMPFILE=$(tempfile)
SAX_WELL_FORMED=$(pwd)/sax_well_formed.exe
SAX_VALID=$(pwd)/sax_valid.exe

PASSED=$THISPWD/PASSED.out
FAILED=$THISPWD/FAILED.out
LEAKED=$THISPWD/LEAKED.out
XFAIL=$THISPWD/XFAIL
XPASS=$THISPWD/XPASS.out

if [ $# -eq 1 ]; then
  testFiles=$1
  all=no
else
  testFiles=
  all=yes
  rm -f $FAILED; touch $FAILED
  rm -f $PASSED; touch $PASSED
  rm -f $LEAKED; touch $LEAKED
  rm -f $XPASS; touch $XPASS
fi

cat <<EOF > $XSL
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text"/>
  <xsl:param name="type"/>
  <xsl:template match="text()"/>
  <xsl:template name="base">
    <xsl:choose>
      <xsl:when test="not(../node())">
        <xsl:text>./</xsl:text>
      </xsl:when>
      <xsl:when test="@xml:base">
        <xsl:value-of select="@xml:base"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="..">
          <xsl:call-template name="base"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  
  <xsl:template match="TEST">
    <xsl:if test="@TYPE=\$type">
      <xsl:call-template name="base"/>
      <xsl:value-of select="@URI"/>
      <xsl:text>
</xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
EOF

for i in $(xsltproc --param type "'not-wf'" $XSL xmlconf.xml); do
  if [ ! -z $testFiles ] && [ ! $testFiles = $i ]; then
    continue
  fi
  echo Checking that we detect not-well-formedness: $i
  DIR=$(echo $i | sed -e 's/\(.*\)\/.*/\1/')
  FILE=$(echo $i | sed -e 's/.*\/\(.*\)/\1/')
  cd $DIR
  if [ -f test.xml ]; then
    echo "Problem! Found a pre-existing file called test.xml"
    echo "Stopping now before I overwrite it."
    exit 1
  fi
  ln -s $FILE test.xml
  ($SAX_WELL_FORMED > test.out 2>&1)
  if grep Error test.out > /dev/null
  then
    if grep $i $XFAIL > /dev/null; then
      echo $i >> $XPASS
    fi
    echo $i >> $PASSED
    grep -v $i $FAILED > $TMPFILE; mv $TMPFILE $FAILED
  else
    if ! grep $i $XFAIL > /dev/null; then
      echo Couldnt find this in XFAIL
      echo $i >> $FAILED
    else
      grep -v $i $FAILED > $TMPFILE; mv $TMPFILE $FAILED
    fi
    grep -v $i $PASSED > $TMPFILE; mv $TMPFILE $PASSED
  fi
  if grep Remaining test.out > /dev/null; then
    echo $i >> LEAKED.out
  fi
  rm test.xml
  rm test.out
  cd $THISPWD
done

 # for i in $(xsltproc --param type "'invalid'" $XSL xmlconf.xml); do
#   if [ ! -z $testFiles ] && [ ! $testFiles = $i ]; then
#     continue
#   fi
#   echo Checking that we detect invalidity: $i
#   THISPWD=$(pwd)
#   DIR=$(echo $i | sed -e 's/\(.*\)\/.*/\1/')
#   FILE=$(echo $i | sed -e 's/.*\/\(.*\)/\1/')
#   cd $DIR
#   if [ -f test.xml ]; then
#     echo "Problem! Found a pre-existing file called test.xml"
#     echo "Stopping now before I overwrite it."
#     exit 1
#   fi
#   ln -s $FILE test.xml
# # Check passes well-formedness if we don't check validity
#   if $SAX_WELL_FORMED | grep Error > /dev/null
#   then
#     echo $i >> $PASSED
#   else 
#     echo $i >> $FAILED
#   fi
# # Check fails validity if we do.
#   if $SAX_VALID | grep Error > /dev/null
#   then
#     echo $i >> $FAILED
#   else 
#     echo $i >> $PASSED
#   fi
#   rm test.xml
#   cd $THISPWD
# done

for i in $(xsltproc --param type "'valid'" $XSL xmlconf.xml); do
  if [ ! -z $testFiles ] && [ ! $testFiles = $i ]; then
    continue
  fi
  echo Checking that we detect validity: $i
  THISPWD=$(pwd)
  DIR=$(echo $i | sed -e 's/\(.*\)\/.*/\1/')
  FILE=$(echo $i | sed -e 's/.*\/\(.*\)/\1/')
  cd $DIR
  if [ -f test.xml ]; then
    echo "Problem! Found a pre-existing file called test.xml"
    echo "Stopping now before I overwrite it."
    exit 1
  fi
  ln -s $FILE test.xml
  ($SAX_VALID > test.out 2>&1)
  if grep Error test.out > /dev/null
  then
    if ! grep $i $XFAIL > /dev/null; then
      echo Couldnt find this in XFAIL
      echo $i >> $FAILED
    else
      grep -v $i $FAILED > $TMPFILE; mv $TMPFILE $FAILED
    fi
    grep -v $i $PASSED > $TMPFILE; mv $TMPFILE $PASSED
  else 
    if grep $i $XFAIL > /dev/null; then
      echo $i >> $XPASS
    fi
    echo $i >> $PASSED
    grep -v $i $FAILED > $TMPFILE; mv $TMPFILE $FAILED
  fi
  if grep Remaining test.out > /dev/null; then
    echo $i >> LEAKED.out
  fi
  rm test.xml
  cd $THISPWD
done

if [ ! -z $testFiles ]; then
  sort $PASSED | uniq > $TMPFILE; mv $TMPFILE $PASSED
  sort $FAILED | uniq > $TMPFILE; mv $TMPFILE $FAILED
  sort $LEAKED | uniq > $TMPFILE; mv $TMPFILE $LEAKED
  sort $XPASS | uniq > $TMPFILE; mv $TMPFILE $XPASS
fi

rm -f $XSL $TMPFILE
