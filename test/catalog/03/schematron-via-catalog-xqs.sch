<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xquery31" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:rule context="element()">
			<sch:report id="element-fired" test="true()" />
		</sch:rule>
	</sch:pattern>

  <sch:pattern>
    <sch:rule context="root">
      <sch:report id="report-dtd-version-1-0" test="@dtd-version eq '1.0'">DTD fixed attribute
        took effect via DOCTYPE resolved with catalog</sch:report>
    </sch:rule>
  </sch:pattern>
</sch:schema>
