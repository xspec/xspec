<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:sqf="http://www.schematron-quickfix.com/validator/process">

	<sch:include href="hook-me" />

	<sch:pattern>
		<sch:rule context="e">
			<sch:report id="hook-chain-verified" test="$verify-me eq 12345">Good</sch:report>
		</sch:rule>
	</sch:pattern>

</sch:schema>
