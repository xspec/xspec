<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      mode="x:fixup-saxon-config"
      This mode resolves URI in Saxon configuration to work around https://saxonica.plan.io/issues/4471
      TODO: Cover more attributes/elements (only as needed basis).
      TODO: Retire this mode when no longer needed (probably when Oxygen picks up Saxon 9.9.1.7).
   -->
   <xsl:mode name="x:fixup-saxon-config" on-multiple-match="fail" on-no-match="shallow-copy" />
    
   <xsl:template match="configuration:package/@sourceLocation" as="attribute(sourceLocation)"
      mode="x:fixup-saxon-config" xmlns:configuration="http://saxon.sf.net/ns/configuration">
      <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}" select="resolve-uri(., base-uri())" />
   </xsl:template>

   <!-- Checks that the sequence appears to be a Saxon configuration -->
   <xsl:function name="x:is-saxon-config" as="xs:boolean">
      <xsl:param name="sequence" as="item()*" />

      <xsl:sequence xmlns:config="http://saxon.sf.net/ns/configuration"
         select="
            ($sequence instance of element(config:configuration))
            or
            ($sequence instance of document-node(element(config:configuration)))" />
   </xsl:function>

</xsl:stylesheet>