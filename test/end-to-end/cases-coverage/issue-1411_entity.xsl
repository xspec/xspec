<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">

   <xsl:template match="dummy" as="element(dummy)">
      <dummy>&nbsp;</dummy>
   </xsl:template>

</xsl:stylesheet>