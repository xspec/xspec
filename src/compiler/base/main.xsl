<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:compiler:base:main:local"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Global params
   -->

   <xsl:param name="force-focus" as="xs:string?" />
   <xsl:param name="is-external" as="xs:boolean"
      select="$initial-document/x:description/@run-as = 'external'" />

   <!--
      Global variables
   -->

   <!-- The initial XSpec document (the source document of the whole transformation).
      Note that this initial document is different from the document node generated within the
      default mode template. The latter document is a restructured copy of the initial document.
      Usually the compiler templates should handle the restructured one, but in rare cases some of
      the compiler templates may need to access the initial document. -->
   <xsl:variable name="initial-document" as="document-node(element(x:description))" select="/" />

   <xsl:variable name="initial-document-actual-uri" as="xs:anyURI"
      select="x:document-actual-uri($initial-document)" />

   <!--
      Accumulators for non-global x:variable
   -->

   <!-- Push and pop x:variable based on node identity -->
   <xsl:accumulator name="local:stacked-variables" as="element(x:variable)*" initial-value="()">
      <xsl:accumulator-rule match="x:scenario/x:variable"
         select="
            (: Append this local variable :)
            $value, self::x:variable" />
      <xsl:accumulator-rule match="x:scenario" phase="end"
         select="
            (: Remove variables declared as children of this scenario :)
            $value except child::x:variable" />
   </xsl:accumulator>

   <!-- Push and pop distinct URIQualifiedName of x:variable -->
   <xsl:accumulator name="stacked-variables-distinct-uqnames" as="xs:string*" initial-value="()">
      <!-- Use x:distinct-strings-stable() instead of fn:distinct-values(). The x:compile-scenario
         template for XQuery requires the order to be stable. -->
      <xsl:accumulator-rule match="x:scenario/x:variable"
         select="
            x:distinct-strings-stable(
               accumulator-before('local:stacked-variables') ! x:variable-UQName(.)
            )" />
      <xsl:accumulator-rule match="x:scenario" phase="end"
         select="
            x:distinct-strings-stable(
               accumulator-after('local:stacked-variables') ! x:variable-UQName(.)
            )" />
   </xsl:accumulator>

   <!--
      mode="#default"
   -->
   <xsl:mode on-multiple-match="fail" on-no-match="fail" />

   <!-- Actually, xsl:template/@match is "document-node(element(x:description))".
      "element(x:description)" is omitted in order to accept any source document and then reject it
      with a proper error message if it's broken. -->
   <xsl:template match="document-node()" as="node()+">
      <xsl:call-template name="x:perform-initial-check" />

      <!-- Resolve x:import and gather all the children of x:description -->
      <xsl:variable name="specs" as="node()+" select="x:resolve-import(x:description)" />

      <!-- Combine all the children of x:description into a single document so that the following
         language-specific transformation can handle them as a document. -->
      <xsl:variable name="combined-doc" as="document-node(element(x:description))"
         select="x:combine($specs)" />

      <!-- Switch the context to the x:description and dispatch it to the language-specific
         transformation (XSLT or XQuery) -->
      <xsl:for-each select="$combined-doc/x:description">
         <xsl:call-template name="x:main" />
      </xsl:for-each>
   </xsl:template>

   <!--
      Sub modules
         '../base/' prefix in @href is a workaround for https://saxonica.plan.io/issues/4706
   -->
   <xsl:include href="../base/catch/enter-sut.xsl" />
   <xsl:include href="../base/combine/combine.xsl" />
   <xsl:include href="../base/compile/compile-child-scenarios-or-expects.xsl" />
   <xsl:include href="../base/compile/compile-expect.xsl" />
   <xsl:include href="../base/compile/compile-global-params-and-variables.xsl" />
   <xsl:include href="../base/compile/compile-scenario.xsl" />
   <xsl:include href="../base/declare-variable/variable-uqname.xsl" />
   <xsl:include href="../base/initial-check/perform-initial-check.xsl" />
   <xsl:include href="../base/invoke-compiled/invoke-compiled-child-scenarios-or-expects.xsl" />
   <xsl:include href="../base/report/report-test-attribute.xsl" />
   <xsl:include href="../base/resolve-import/resolve-import.xsl" />
   <xsl:include href="../base/util/compiler-eqname-utils.xsl" />
   <xsl:include href="../base/util/compiler-misc-utils.xsl" />
   <xsl:include href="../base/util/compiler-yes-no-utils.xsl" />

</xsl:stylesheet>