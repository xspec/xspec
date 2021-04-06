<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [

<!-- Taken from https://www.w3.org/TR/xml/#sec-entexpand -->

<!ENTITY example "<p>An ampersand (&#38;#38;) may be escaped
numerically (&#38;#38;#38;) or with a general entity
(&amp;amp;).</p>" >

]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">

   <xsl:template match="dummy" as="element(dummy)">
      <dummy>&example;</dummy>
   </xsl:template>

</xsl:stylesheet>