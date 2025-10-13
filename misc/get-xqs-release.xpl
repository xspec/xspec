<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

  <p:documentation>
    <p>This pipeline deletes the existing lib/XQS subdirectory of XSpec,
      downloads a released ZIP-file for XQS from GitHub, stores the      
      unzipped files needed by XSpec under lib/XQS, and stages them in Git.</p>
    <p>Input ports: None.</p>
    <p>Output ports: None.</p>
    <p>'version' option: The XQS version to download.</p>
    <p>Example: <code>java -jar %XMLCALABASH3_JAR% misc/get-xqs-release.xpl version=1.1.4</code></p>
  </p:documentation>

  <p:option name="version" as="xs:string" select="'1.1.4'"/>

  <p:variable name="xqs-release-url" as="xs:string"
    select="'https://github.com/AndrewSales/XQS/archive/refs/tags/v' || $version || '.zip'"/>
  <p:variable name="destination-dir" as="xs:string" select="resolve-uri('../lib/XQS')"/>

  <p:file-delete href="{$destination-dir}" recursive="true"/>
  <p:load href="{ $xqs-release-url }" message="Downloading {$xqs-release-url}"/>
  <p:unarchive message="Unzipping all except examples, presentations, and test dirs" format="zip">
    <p:with-option name="override-content-types" select="[ ['.*', 'text/plain'] ]"/>
    <p:with-option name="exclude-filter" select="('/examples/', '/presentations/', '/test/')"/>
  </p:unarchive>

  <p:for-each name="store-files">
    <p:variable name="path-within-zip" select="p:document-property(., 'base-uri')"/>
    <p:variable name="path-to-store" as="xs:string" select="replace(
      $path-within-zip,
      '^.*\.zip/XQS-' || $version || '/',
      $destination-dir || '/'
      )"/>
    <p:store href="{ $path-to-store }" message="Saving { $path-to-store }"/>
  </p:for-each>

  <p:os-exec command="git" args="add lib/XQS/*" message="Staging XQS files" depends="store-files">
    <p:with-input>
      <p:empty/>
    </p:with-input>
  </p:os-exec>
  <p:identity message="Commit with message feat(schematron): bump built-in XQS from v... to v{ $version }"/>

</p:declare-step>
