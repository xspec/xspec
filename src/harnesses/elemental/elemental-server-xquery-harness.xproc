<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:t="http://www.jenitennison.com/xslt/xspec"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            name="elemental-server-xquery-harness"
            type="t:elemental-server-xquery-harness"
            version="1.0">

   <p:documentation>
      <p>This pipeline executes an XSpec test suite on a Elemental server instance.</p>
      <p><b>Primary input:</b> A XSpec test suite document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
      <p>The XQuery library module to test must already be on the Elemental instance
        (its URI is passed through the option 'query-at').  The instance endpoint
        is passed in the option 'endpoint'.  The runtime utils library must also
        be on the instance (its location hint, that is the 'at' clause to use) is
        controlled by the option 'utils-library-at'.
        The dir where you unzipped the XSpec archive on your filesystem is passed
        in the option 'xspec-home'.  User credentials are passed through options
        'username' and 'password'.</p>
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
      <p:variable name="query-at" select="/c:param-set/c:param[@name eq 'query-at']/@value">
         <p:pipe step="params" port="parameters"/>
      </p:variable>
      <p:variable name="endpoint" select="/c:param-set/c:param[@name eq 'endpoint']/@value">
         <p:pipe step="params" port="parameters"/>
      </p:variable>
      <p:variable name="username" select="/c:param-set/c:param[@name eq 'username']/@value">
         <p:pipe step="params" port="parameters"/>
      </p:variable>
      <p:variable name="password" select="/c:param-set/c:param[@name eq 'password']/@value">
         <p:pipe step="params" port="parameters"/>
      </p:variable>
      <p:variable name="auth-method" select="/c:param-set/c:param[@name eq 'auth-method']/@value">
         <p:pipe step="params" port="parameters"/>
      </p:variable>

      <!-- compile the suite into a query -->
      <t:compile-xquery/>

      <!-- escape the query as text -->
      <t:escape-markup />

      <!-- construct the Elemental REST query element around the query itself -->
      <p:rename new-name="exist:text" match="/*"/>
      <p:wrap wrapper="exist:query" match="/*"/>

      <!-- construct the HTTP request following Elemental REST interface -->
      <p:wrap wrapper="c:body" match="/*"/>
      <p:add-attribute attribute-name="content-type" attribute-value="application/xml" match="/*"/>
      <p:wrap wrapper="c:request" match="/*"/>
      <p:add-attribute attribute-name="method" attribute-value="POST" match="/*"/>

      <!-- inject variable values -->
      <p:add-attribute attribute-name="href" match="/*">
         <p:with-option name="attribute-value" select="concat($endpoint, '/db')"/>
      </p:add-attribute>
      <p:add-attribute attribute-name="username" match="/*">
         <p:with-option name="attribute-value" select="$username"/>
      </p:add-attribute>
      <p:add-attribute attribute-name="password" match="/*">
         <p:with-option name="attribute-value" select="$password"/>
      </p:add-attribute>
      <p:add-attribute attribute-name="auth-method" match="/*">
         <p:with-option name="attribute-value" select="$auth-method"/>
      </p:add-attribute>

      <!-- log the HTTP request ? -->
      <t:log if-set="log-http-request">
         <p:input port="parameters">
            <p:pipe step="params" port="parameters"/>
         </p:input>
      </t:log>

      <p:http-request name="run"/>

      <!-- log the HTTP response ? -->
      <t:log if-set="log-http-response">
         <p:input port="parameters">
            <p:pipe step="params" port="parameters"/>
         </p:input>
      </t:log>

      <!-- format the report -->
      <t:format-report/>
   </p:group>

</p:pipeline>
