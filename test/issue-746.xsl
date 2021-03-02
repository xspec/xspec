<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mf="helper-function"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="3.0">

  <xsl:template name="template-to-call">
    <output-element/>
  </xsl:template>

  <xsl:function name="mf:call-some-template" as="document-node(element(output-element))">
    <xsl:param name="context" as="element()?"/>

    <xsl:sequence select="
      transform(map{
      'stylesheet-location': static-base-uri(),
      'source-node': $context,
      'initial-template': QName('','template-to-call')
      })?output
      "/>
  </xsl:function>

</xsl:transform>