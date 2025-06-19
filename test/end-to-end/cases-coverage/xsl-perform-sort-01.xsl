<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <!--
      xsl:perform-sort Coverage Test Case
  -->
  <xsl:template match="xsl-perform-sort">
    <root>
      <!-- Using select attribute -->
      <xsl:variable name="sortedSet1">                                         <!-- Expected miss (optim inlined) -->
        <xsl:perform-sort select="node">                                       <!-- Expected unknown -->
          <xsl:sort />                                                         <!-- Expected unknown -->
        </xsl:perform-sort>                                                    <!-- Expected unknown -->
      </xsl:variable>                                                          <!-- Expected miss (optim inlined) -->
      <xsl:for-each select="$sortedSet1/*">
        <node type="perform-sort">
          <xsl:value-of select="." />
        </node>
      </xsl:for-each>
      <!-- Using sequence constructor (Didn't use xsl:sequence as it isn't traced so used xsl:copy-of.) -->
      <xsl:variable name="sortedSet2" as="xs:string*">                         <!-- Expected miss (optim inlined) -->
        <xsl:perform-sort>
          <xsl:sort select="." />
          <xsl:copy-of select="node" />
        </xsl:perform-sort>
      </xsl:variable>                                                          <!-- Expected miss (optim inlined) -->
      <node type="perform-sort">
        <xsl:value-of select="$sortedSet2" separator=" " />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>