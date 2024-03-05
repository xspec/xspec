<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:pattern>
        <sch:rule context="section">
            <sch:assert test="title"
                id="a001"
                role="error"
                diagnostics="diag-rtl diag-ltr diag-emph diag-span diag-mixed diag-apos">
                <sch:name/><sch:value-of select="@xml:id ! concat(' with id ''',.,'''')"/>
                should have a title
            </sch:assert>
            <sch:report test="not(title)"
                id="r001"
                role="error"
                diagnostics="diag-rtl diag-ltr diag-emph diag-span diag-mixed diag-apos">
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
</sch:schema>