<?xml version="1.0" encoding="UTF-8"?>
<p:library version="3.1" xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc">
  <p:declare-step type="s:default-to-child-element">
    <p:input port="source" select="//child">
      <parent>
        <child>
          <grandchild/>
        </child>
      </parent>
    </p:input>
    <p:output port="xproc-result"/>
    <p:identity/>
  </p:declare-step>
</p:library>
