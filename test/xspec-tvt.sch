<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">

	<sch:ns prefix="x" uri="http://www.jenitennison.com/xslt/xspec" />

	<sch:pattern>
		<sch:rule context="context-child | href-doc-child">

			<!-- Writing the curly braces directly in sch:report/@test seems to break the skeleton
				Schematron implementation. That's why the strings are used via sch:let. -->
			<sch:let name="tvt-enabled" value="'}false{'" />
			<sch:let name="tvt-disabled" value="'}}{false()}{{'" />

			<sch:report id="tvt-enabled" test="string() eq $tvt-enabled">TVT is enabled</sch:report>
			<sch:report id="tvt-disabled" test="string() eq $tvt-disabled">TVT is
				disabled</sch:report>

			<sch:report id="x-expand-text-not-exist"
				test="empty(descendant-or-self::*/@x:expand-text)">@x:expand-text does not
				exist</sch:report>
			<sch:report id="x-expand-text-yes" test="@x:expand-text eq 'yes'">@x:expand-text is
				yes</sch:report>

			<sch:report id="expand-text-not-exist" test="empty(descendant-or-self::*/@expand-text)"
				>@expand-text does not exist</sch:report>
			<sch:report id="expand-text-yes" test="@expand-text eq 'yes'">@expand-text is
				yes</sch:report>
		</sch:rule>
	</sch:pattern>

</sch:schema>
