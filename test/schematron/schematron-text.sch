<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:pattern>
        <sch:rule context="section">
            <sch:assert test="title"
                id="a001"
                role="error"
                diagnostics="diag-rtl diag-ltr diag-emph diag-span diag-mixed diag-apos"
                properties="prop-rtl prop-ltr prop-emph prop-span prop-mixed prop-apos prop-data">
                <sch:name/><sch:value-of select="@xml:id ! concat(' with id ''',.,'''')"/>
                should have a title
            </sch:assert>
            <sch:report test="not(title)"
                id="r001"
                role="error"
                diagnostics="diag-rtl diag-ltr diag-emph diag-span diag-mixed diag-apos"
                properties="prop-rtl prop-ltr prop-emph prop-span prop-mixed prop-apos prop-data">
                Found untitled <sch:name/><sch:value-of select="@xml:id ! concat(' with id ''',.,'''')"/>
            </sch:report>
        </sch:rule>
    </sch:pattern>

    <sch:diagnostics>
        <sch:diagnostic id="diag-rtl">
            <sch:dir value="rtl">rtl text in dir element</sch:dir>
        </sch:diagnostic>
        <sch:diagnostic id="diag-ltr">
            <sch:dir value="ltr">ltr text in dir element</sch:dir>
        </sch:diagnostic>
        <sch:diagnostic id="diag-emph">
            <sch:emph>text in emph element</sch:emph>
        </sch:diagnostic>
        <sch:diagnostic id="diag-span">
            <sch:span class="c1">text in span element</sch:span>
        </sch:diagnostic>
        <sch:diagnostic id="diag-mixed">
            <sch:span class="c1">text in span element</sch:span> followed by
            <sch:emph>text in emph element</sch:emph>
        </sch:diagnostic>
        <sch:diagnostic id="diag-apos">
            text with &apos;apostrophe&apos; and 
            &quot;double quotation mark&quot;
        </sch:diagnostic>
    </sch:diagnostics>

    <sch:properties>
        <sch:property id="prop-rtl">
            <sch:dir value="rtl">rtl text in dir element</sch:dir>
        </sch:property>
        <sch:property id="prop-ltr">
            <sch:dir value="ltr">ltr text in dir element</sch:dir>
        </sch:property>
        <sch:property id="prop-emph">
            <sch:emph>text in emph element</sch:emph>
        </sch:property>
        <sch:property id="prop-span">
            <sch:span class="c1">text in span element</sch:span>
        </sch:property>
        <sch:property id="prop-mixed">
            <sch:span class="c1">text in span element</sch:span> followed by
            <sch:emph>text in emph element</sch:emph>
        </sch:property>
        <sch:property id="prop-apos">
            text with &apos;apostrophe&apos; and
            &quot;double quotation mark&quot;
        </sch:property>
        <sch:property id="prop-data">
            <user-data>
                <elem1 id="id1">user content</elem1>
                <elem2 id="id2">More user content</elem2>
            </user-data>
        </sch:property>
    </sch:properties>
</sch:schema>