<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:fork Coverage Test Case
  -->
   <xsl:template match="xsl-fork">
      <root>
        <xsl:fork>
            <xsl:sequence>
               <xsl:text>1</xsl:text>
            </xsl:sequence>
            <xsl:sequence>
               <xsl:text>2</xsl:text>
            </xsl:sequence>
         </xsl:fork>
      </root>
   </xsl:template>
</xsl:stylesheet>