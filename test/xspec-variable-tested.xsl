<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       test/xspec-variable-tested.xsl                           -->
<!--  Author:     Jeni Tennison                                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2010 Jeni Tennison (see end of file.)                -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:my="http://example.org/ns/my"
                exclude-result-prefixes="xs"
                version="2.0">

  <xsl:variable name="my:myspace" as="text()"><xsl:text>&#x09;&#x0A;&#x0D;&#x20;  </xsl:text></xsl:variable>

   <xsl:function name="my:square" as="xs:integer">
      <xsl:param name="n" as="xs:integer"/>
      <xsl:sequence select="$n * $n"/>
   </xsl:function>

   <xsl:template match="rule">
      <xsl:param name="p"/>
      <transformed/>
   </xsl:template>

   <xsl:template match="*:foo" name="foo" as="element(bar)">
      <xsl:param name="p" select="0"/>
      <xsl:param name="textnode" as="text()"><xsl:text/></xsl:param>
      <bar role="{@role}">
         <string>abc<xsl:value-of select="$textnode"/>def</string>
         <number>
            <xsl:value-of select="$p * $p"/>
         </number>
      </bar>
   </xsl:template>

  <xsl:function name="my:foo" as="element(bar)">
    <xsl:param name="elem" as="element()"/>
    <xsl:param name="p" as="xs:integer"/>
    <xsl:param name="textnode" as="text()?"/>
    <bar role="{$elem/@role}">
      <string>abc<xsl:value-of select="$textnode"/>def</string>
      <number>
        <xsl:value-of select="$p * $p"/>
      </number>
    </bar>
  </xsl:function>

</xsl:stylesheet>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.             -->
<!--                                                                       -->
<!-- Copyright (c) 2010 Jeni Tennison                                      -->
<!--                                                                       -->
<!-- The contents of this file are subject to the MIT License (see the URI -->
<!-- http://www.opensource.org/licenses/mit-license.php for details).      -->
<!--                                                                       -->
<!-- Permission is hereby granted, free of charge, to any person obtaining -->
<!-- a copy of this software and associated documentation files (the       -->
<!-- "Software"), to deal in the Software without restriction, including   -->
<!-- without limitation the rights to use, copy, modify, merge, publish,   -->
<!-- distribute, sublicense, and/or sell copies of the Software, and to    -->
<!-- permit persons to whom the Software is furnished to do so, subject to -->
<!-- the following conditions:                                             -->
<!--                                                                       -->
<!-- The above copyright notice and this permission notice shall be        -->
<!-- included in all copies or substantial portions of the Software.       -->
<!--                                                                       -->
<!-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       -->
<!-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    -->
<!-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.-->
<!-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  -->
<!-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  -->
<!-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     -->
<!-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
