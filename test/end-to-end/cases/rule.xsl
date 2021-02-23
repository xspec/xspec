<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:my="http://example.org/ns/my"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:mode on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="rule">
      <!-- TODO: Test x:apply with $p parameter -->
      <!--<xsl:param name="p" as="xs:integer?" />-->

      <transformed/>
   </xsl:template>

</xsl:stylesheet>
