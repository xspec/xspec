<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [

<!-- Taken from https://www.w3.org/TR/xml/#sec-entexpand -->

<!ENTITY % xx '&#37;zz;'>
<!ENTITY % zz '&#60;!ENTITY tricky "error-prone" >' >
%xx;

]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">

   <xsl:template match="dummy" as="element(dummy)">
      <dummy>&tricky;</dummy>
   </xsl:template>

</xsl:stylesheet>