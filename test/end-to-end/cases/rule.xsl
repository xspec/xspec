<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:mode on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="rule" as="element(transformed)">
      <xsl:param name="p" as="xs:integer?" />

      <transformed>
         <xsl:if test="exists($p)">
            <xsl:value-of select="$p" />
         </xsl:if>
      </transformed>
   </xsl:template>

</xsl:stylesheet>
