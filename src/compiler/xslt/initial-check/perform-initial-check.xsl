<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:template name="x:perform-initial-check-for-lang" as="empty-sequence()">
      <xsl:context-item as="document-node(element(x:description))" use="required" />

      <xsl:if test="x:description/@stylesheet => empty()">
         <xsl:message terminate="yes">
            <xsl:text>ERROR: Missing /x:description/@stylesheet.</xsl:text>
         </xsl:message>
      </xsl:if>
   </xsl:template>

</xsl:stylesheet>