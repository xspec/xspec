<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:csv="http://example.com/csv"
   exclude-result-prefixes="xs csv"
   version="3.0">
    <!--
        xsl:accept Coverage Test Case
        Package is https://www.w3.org/TR/xslt-30/#packages-csv-library-example
    -->
   <xsl:use-package name="http://example.com/csv-parser"
                    package-version="*">                                       <!-- Expected ignored -->
       <xsl:accept component="function" names="csv:preprocess-field#1"
                   visibility="private" />                                     <!-- Expected ignored -->
   </xsl:use-package>

   <!-- example input "file"  -->
   <xsl:variable name="input" as="xs:string">
       name,id,postal code
       "Braaksma Abel",34291,1210 KA
       "Berglund Anders",473892,9843 ZD
   </xsl:variable>

   <!-- entry point -->
   <xsl:template name="xsl:initial-template">
       <xsl:copy-of select="csv:parse($input)"/>
   </xsl:template>

</xsl:stylesheet>