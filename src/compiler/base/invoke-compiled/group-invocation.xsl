<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      mode="x:group-invocation"
      This mode groups the invocation instructions of compiled x:scenario or x:expect. Actual
      implementation depends on language (XSLT or XQuery).
   -->
   <xsl:mode name="x:group-invocation" on-multiple-match="fail" on-no-match="shallow-copy" />

</xsl:stylesheet>