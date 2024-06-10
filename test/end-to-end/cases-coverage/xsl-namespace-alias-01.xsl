<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:myxslt="file://namespace.alias">
  <!--
      xsl:namespace-alias Coverage Test Case
  -->
  <xsl:namespace-alias stylesheet-prefix="myxslt" result-prefix="xsl" />

  <xsl:template match="xsl-namespace-alias">
    <root>
      <!-- See myxslt namespace defined above. Also xsl namespace defined in xspec. -->
      <myxslt:node type="namespace-alias">
        <xsl:text>100</xsl:text>
      </myxslt:node>
    </root>
  </xsl:template>
</xsl:stylesheet>