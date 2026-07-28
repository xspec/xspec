<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:x="http://www.jenitennison.com/xslt/xspec"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:map="http://www.w3.org/2005/xpath-functions/map"
            name="run-schematron-xslt"
            type="x:run-schematron-xslt"
            version="3.1">

   <p:documentation>
      <p>This pipeline executes an XSpec test suite for Schematron using the XSLT implementation of Schematron.</p>
      <p><b>Primary input:</b> An XSpec test suite document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
      <p><b>Secondary output:</b> An optional formatted JUnit XSpec report.</p>
      <p>'xspec-home' option: The directory where you unzipped the XSpec archive on your filesystem.</p>
      <p>'force-focus' option: The value `#none` (case sensitive) removes focus from all the scenarios.</p>
      <p>'html-report-theme' option: Color palette for HTML report, such as `blackwhite` (black on white),
         `whiteblack` (white on black), or `classic` (earlier green/pink design). Defaults to `blackwhite`.</p>
      <p>'inline-css' option: If 'true', the HTML report embeds CSS. Use 'true' when serializing to a file
         that you want to be self-contained. If 'false', the HTML report links to external CSS files.
         Use 'false' when you are processing the unserialized document within XProc or want a smaller file.
         Defaults to 'true'.</p>
      <p>'junit-enabled' option: Whether to output a JUnit report. Values are 'true' and 'false'. Defaults to 'false'.</p>
      <p>'schxslt2-transpiler' option: Location of the SchXslt2 transpile.xsl stylesheet to use instead of the one packaged with XSpec.</p>
   </p:documentation>

   <p:import href="harness-lib.xpl"/>

   <p:input port="source" primary="true" sequence="false" content-types="application/xml"/>
   <p:output port="result"
      serialization="map{
         'indent':true(),
         'method':'xhtml',
         'encoding':'UTF-8',
         'include-content-type':true(),
         'omit-xml-declaration':false()
      }"
      primary="true"
      pipe="result@format-report"/>
   <p:output port="junit"
      content-types="xml"
      serialization="map{
         'method':'xml'
      }"
      primary="false"
      sequence="true"
      pipe="result@junit-report"/>
   <p:option name="xspec-home" as="xs:string?"/>
   <p:option name="force-focus" as="xs:string?"/>
   <p:option name="html-report-theme" as="xs:string" select="'default'"/>
   <p:option name="inline-css" as="xs:string" values="('true','false')" select="'true'"/>
   <p:option name="junit-enabled" as="xs:string" values="('true','false')" select="'false'"/>
   <p:option name="schxslt2-transpiler" as="xs:string?"/>

   <!--
        Convert Schematron into XSLT.
   -->
   <p:declare-step type="x:convert-sch-to-xslt" name="convert-sch-to-xslt">
      <!-- the port declarations -->
      <p:input port="source" primary="true" content-types="application/xml" />
      <p:output port="result" primary="true" content-types="application/xslt+xml"/>

      <p:option name="xspec-home" as="xs:string?"/>
      <p:option name="schxslt2-transpiler" as="xs:string?"/>

      <p:variable name="stylesheet-parameters" as="map(*)"
                  select="if (empty($schxslt2-transpiler))
                          then map{}
                          else map{'STEP1-PREPROCESSOR-URI':'#none',
                          'STEP2-PREPROCESSOR-URI':'#none',
                          'STEP3-PREPROCESSOR-URI':$schxslt2-transpiler}" />

      <!-- if xspec-home is not passed, then use the packaging public URI -->
      <p:variable name="compiler"
                  select="if ( $xspec-home != '') then
                          resolve-uri('src/schematron/schut-to-xslt.xsl', $xspec-home)
                          else
                          'http://www.jenitennison.com/xslt/xspec/schut-to-xslt.xsl'"/>

      <!-- actually compile the suite in a stylesheet -->
      <p:xslt>
         <p:with-input port="source" pipe="source@convert-sch-to-xslt"/>
         <p:with-input port="stylesheet" href="{$compiler}"/>
         <p:with-option name="parameters" select="$stylesheet-parameters"/>
      </p:xslt>
      <p:cast-content-type content-type="application/xslt+xml" />
   </p:declare-step>


   <!-- Convert Schematron XSpec into XSLT XSpec -->
   <p:declare-step type="x:schut-to-xspec" name="schut-to-xspec">
      <!-- the port declarations -->
      <p:input port="source" primary="true" content-types="application/xml" />
      <p:output port="result" primary="true" content-types="application/xslt+xml" />

      <p:option name="xspec-home" as="xs:string?"/>
      <p:option name="stylesheet-uri" as="xs:string?"/>

      <!-- if xspec-home is not passed, then use the packaging public URI -->
      <p:variable name="compiler"
                  select="if ( $xspec-home != '') then
                          resolve-uri('src/schematron/schut-to-xspec.xsl', $xspec-home)
                          else
                          'http://www.jenitennison.com/xslt/xspec/schut-to-xspec.xsl'"/>

      <!-- actually compile the suite in a stylesheet -->
      <p:xslt>
         <p:with-input port="source" pipe="source@schut-to-xspec"/>
         <p:with-input port="stylesheet" href="{$compiler}"/>
         <p:with-option name="parameters" select="map{
                           'stylesheet-uri':$stylesheet-uri
                           }"/>
      </p:xslt>
      <p:cast-content-type content-type="application/xslt+xml" />
   </p:declare-step>


   <x:check-xspec-home>
      <p:with-option name="xspec-home" select="$xspec-home"/>
   </x:check-xspec-home>

   <!-- Converting Schematron into XSLT... -->
   <x:convert-sch-to-xslt name="schematron-xslt">
      <p:with-option name="xspec-home" select="$xspec-home"/>
      <p:with-option name="schxslt2-transpiler" select="$schxslt2-transpiler" />
   </x:convert-sch-to-xslt>

   <!-- Currently need to store the document so that schut-to-xspec.xsl gets the file name
        because it wants to xsl:import it from filestore -->
   <p:file-create-tempfile delete-on-exit="true" />
   <p:variable name="href-tempfile-uri" as="xs:anyURI" select="string(.)"/>
   <p:store href="{string(.)}">
      <p:with-input pipe="result@schematron-xslt"/>
   </p:store>
   <p:identity>
      <p:with-input port="source" pipe="result-uri" />
   </p:identity>
   <p:variable name="sch_preprocessed_xsl" as="xs:string" select="." />

   <!-- Converting Schematron XSpec into XSLT XSpec... -->
   <x:schut-to-xspec name="schematron-xspec">
      <p:with-input port="source" pipe="@run-schematron-xslt" />
      <p:with-option name="xspec-home" select="$xspec-home"/>
      <p:with-option name="stylesheet-uri" select="$sch_preprocessed_xsl"/>
   </x:schut-to-xspec>

   <!-- compile the suite into a stylesheet -->
   <x:compile-xslt name="compile" p:message="Creating Test Runner...">
      <p:with-option name="xspec-home" select="$xspec-home"/>
      <p:with-option name="force-focus" select="$force-focus"/>
   </x:compile-xslt>
   <p:cast-content-type content-type="application/xslt+xml" />

   <!-- run it -->
   <p:xslt name="run" template-name="x:main" message="&#10;Running Tests...">
      <p:with-input port="source">
         <p:empty/>
      </p:with-input>
      <p:with-input port="stylesheet" pipe="@compile"/>
   </p:xslt>

   <!-- format the report -->
   <x:format-report p:message="&#10;Formatting Report..." name="format-report">
      <p:with-option name="xspec-home" select="$xspec-home"/>
      <p:with-option name="force-focus" select="$force-focus"/>
      <p:with-option name="html-report-theme" select="$html-report-theme"/>
      <p:with-option name="inline-css" select="$inline-css"/>
   </x:format-report>

   <!-- produce the JUnit report if requested -->
   <x:maybe-format-junit-report name="junit-report" p:depends="format-report">
      <p:with-input port="source" pipe="result@run"/>
      <p:with-option name="xspec-home" select="$xspec-home" />
      <p:with-option name="junit-enabled" select="$junit-enabled" />
   </x:maybe-format-junit-report>
</p:declare-step>