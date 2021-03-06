#!/bin/sh

# The following command finds files with non-ASCII chars in:
# hexdump -e '8/1 " %02x "' E50.xml | grep " [89abcdef]"

./maketests.sh 

if test ! -f sax_well_formed.ns.no.exe; then exit 1; fi

ulimit -c 0

. filenames.sh

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
  rm -f $DIFF; touch $DIFF
  rm -f XFAIL.out; touch XFAIL.out
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
    <xsl:value-of select="concat('\$TEST ', @TYPE,' ', \$ns)"/>
    <xsl:value-of select="concat(' ',\$base,' ',@URI)"/>
    <xsl:value-of select="concat(' ',@OUTPUT)"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
</xsl:stylesheet>
EOF

xsltproc $XSL xmlconf.xml > $TESTS
echo $TESTS

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
