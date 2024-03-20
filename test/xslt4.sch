<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPath 4.0 supports identity function
	https://www.saxonica.com/documentation12/index.html#!v4extensions/new-functions
-->
<!-- Is XPath 4.0 supposed to work in Schematron? queryBinding="xslt4" doesn't seem to be valid,
	so this file uses "xslt2" instead and the XSpec test uses xslt-version="4.0". -->
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern id="mypattern">
		<sch:rule context="*" id="myrule">
			<sch:report test="identity(true())" id="identity-works">The identity function works</sch:report>
		</sch:rule>
	</sch:pattern>
</sch:schema>
