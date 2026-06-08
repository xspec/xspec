<?xml version="1.0" encoding="UTF-8"?>
<!-- This pattern is used in catch.sch (XSLT-based queryBinding) and xqs/catch-xqs.sch
	(XQuery-based queryBinding). -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:rule context="//error">
		<sch:report test="
				if (@throw eq 'true')
				then
					error(QName('', 'my-error-code'), 'my error description', ('my', 'error', 'object'))
				else
					()"/>
	</sch:rule>
</sch:pattern>
