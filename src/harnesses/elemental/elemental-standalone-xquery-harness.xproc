<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:cx="http://xmlcalabash.com/ns/extensions"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:t="http://www.jenitennison.com/xslt/xspec"
            name="elemental-standalone-xquery-harness"
            type="t:elemental-standalone-xquery-harness"
            version="1.0">

   <p:documentation>
      <p>This pipeline executes an XSpec test suite with Elemental standalone.</p>
      <p><b>Primary input:</b> A XSpec test suite document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
      <p>The dir where you unzipped the XSpec archive on your filesystem is passed
        in the option 'xspec-home'.  The compiled test suite (the XQuery file to be
        actually evaluated) is saved on the filesystem to be passed to Elemental.  The
        name of this file is passed in the option 'compiled-file' (it defaults to a
        file in /tmp).  The Elemental directory is passed through 'elemental-home'.</p>
   </p:documentation>

   <p:serialization port="result" indent="true" method="xhtml"
                    encoding="UTF-8" include-content-type="true"
                    omit-xml-declaration="false" />

   <p:import href="../harness-lib.xpl"/>

   <t:parameters name="params"/>

   <p:group>
      <p:variable name="xspec-home" select="/c:param-set/c:param[@name eq 'xspec-home']/@value">
        <p:pipe step="params" port="parameters"/>
      </p:variable>
      <p:variable name="elemental-home" select="/c:param-set/c:param[@name eq 'elemental-home']/@value">
        <p:pipe step="params" port="parameters"/>
      </p:variable>

      <p:variable name="compiled-file"
         select="(
               /c:param-set/c:param[@name eq 'compiled-file']/@value,
               'file:/tmp/xspec-elemental-compiled-suite.xq'
            )[1]">
         <p:pipe step="params" port="parameters"/>
      </p:variable>

      <p:variable name="utils-library-at"
         select="/c:param-set/c:param[@name eq 'utils-library-at']/@value">
         <p:pipe step="params" port="parameters"/>
      </p:variable>

      <!-- compile the suite into a query -->
      <t:compile-xquery>
         <p:with-param name="utils-library-at" select="$utils-library-at" />
      </t:compile-xquery>

      <!-- escape the query as text -->
      <t:escape-markup name="escape" />

      <!-- store it on disk in order to pass it to Elemental -->
      <p:store method="text" name="store">
         <p:with-option name="href" select="$compiled-file"/>
      </p:store>

      <!-- run it on Elemental -->
      <p:exec command="${elemental-home}/bin/client.sh" cx:depends-on="store">
        <p:with-option name="args"
          select="string-join(
                ('--local', '--xpath', concat('util:eval(fn:unparsed-text(''file:/', $compiled-file, '''))'),
                ' '
             )"/>
       <p:input port="source">
          <p:empty/>
       </p:input>
    </p:exec>

      <!-- unwrap the exec step wrapper element -->
      <p:unwrap match="/c:result"/>

      <!-- format the report -->
      <t:format-report/>
   </p:group>

</p:pipeline>
