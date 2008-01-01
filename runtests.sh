#!/bin/sh

FOXHOME=/Users/tow/devel/FoX

ulimit -c 0

rm *.exe
(cd $FOXHOME/sax/test;
make clean sax_well_formed.ns.no.exe sax_well_formed.ns.yes.exe sax_valid.ns.no.exe sax_valid.ns.yes.exe)
cp $FOXHOME/sax/test/sax_well_formed.*.exe .
cp $FOXHOME/sax/test/sax_valid.*.exe .

if test ! -f sax_well_formed.ns.no.exe; then exit 1; fi

THISPWD=$(pwd)
XSL=$(mktemp -t FoX)
TESTS=$(mktemp -t FoX)
TMPFILE=$(mktemp -t FoX)
TEST=$THISPWD/test.sh
XMLCONF=$THISPWD/xmlconf.xml
SAX_WELL_FORMED=$THISPWD/sax_well_formed
SAX_VALID=$THISPWD/sax_valid

PASSED=$THISPWD/PASSED.out
FAILED=$THISPWD/FAILED.out
LEAKED=$THISPWD/LEAKED.out
CRASHED=$THISPWD/CRASHED.out
XFAIL=$THISPWD/XFAIL
XPASS=$THISPWD/XPASS.out

export TEST TMPFILE SAX_WELL_FORMED SAX_VALID
export PASSED FAILED LEAKED CRASHED XFAIL XPASS

if [ $# -eq 2 ]; then
  testDir=$1
  testFile=$2
  all=no
else
  testFiles=
  all=yes
  rm -f $FAILED; touch $FAILED
  rm -f $LEAKED; touch $LEAKED
  rm -f $CRASHED; touch $CRASHED
  rm -f $PASSED; touch $PASSED
  rm -f $XPASS; touch $XPASS
fi

cat <<EOF > $XSL
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text"/>
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
    <xsl:variable name="base">
      <xsl:call-template name="base"/>
    </xsl:variable>
    <xsl:variable name="ns" select="substring('yesno', 3*number(@NAMESPACE='no')+1, 3)"/>
    <xsl:if test="@ENTITIES='none' or @ENTITIES='general'">
      <xsl:value-of select="concat('(cd ', \$base,';')"/>
      <xsl:value-of select="concat('\$TEST ', @TYPE,' ', \$ns)"/>
      <xsl:value-of select="concat(' ',\$base,' ',@URI,')&#10;')"/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
EOF

xsltproc $XSL xmlconf.xml > $TESTS
if [ ! -z $testFile ]; then
  eval $(grep $testDir $TESTS | grep $testFile)
else
  . $TESTS
fi

if [ ! -z $testFile ]; then
  sort $PASSED | uniq > $TMPFILE; mv $TMPFILE $PASSED
  sort $FAILED | uniq > $TMPFILE; mv $TMPFILE $FAILED
  sort $LEAKED | uniq > $TMPFILE; mv $TMPFILE $LEAKED
  sort $XPASS | uniq > $TMPFILE; mv $TMPFILE $XPASS
fi

rm -f $XSL $TMPFILE $TESTS
