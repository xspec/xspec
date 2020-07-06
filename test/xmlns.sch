<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <sch:ns uri="http://example.org/ns/default" prefix="d"/>
   <sch:ns uri="http://example.org/ns/default/description" prefix="dd"/>
   <sch:ns uri="http://example.org/ns/my" prefix="my"/>
   <sch:pattern>
      <sch:rule context="*:root">
         <sch:report id="prefixed" test="my:element">element in my namespace</sch:report>
         <sch:report id="default-description" test="dd:element">element in what XSpec x:description will declare as default element namespace</sch:report>
         <sch:report id="default" test="d:element">element in what XSpec x:description descendant will declare as default element namespace</sch:report>
      </sch:rule>
   </sch:pattern>

</sch:schema>
