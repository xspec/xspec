<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-inline-prefixes="#all"
    name="run-xproc-error-cases" type="x:run-xproc-error-cases" version="3.1">

    <p:documentation>
        <p>This pipeline compiles or executes all .xspec files in a directory.</p>
        <p><b>error-phase option:</b> If 'compiler', uses compiler-error-cases/ directory.
            If 'runner', uses runner-error-cases/ directory.</p>
        <p><b>Input ports:</b> None.</p>
        <p><b>Output ports:</b> None. This pipeline raises an error at the end, if any
            tests catch no error or catch an error with an unexpected message.</p>
    </p:documentation>

    <p:import href="../../src/xproc3/harness-lib.xpl"/>
    <p:import href="../../src/xproc3/xproc-testing/run-xproc.xpl"/>
    <p:import href="version-utils.xpl"/>

    <p:option name="debugmode" as="xs:boolean" select="false()" static="true"/>
    <p:option name="xspec-home" as="xs:string" select="resolve-uri('../../')"/>
    <p:option name="parameters" as="map(xs:QName,item()*)" select="map{}"/>

    <p:option name="error-phase" as="xs:string" select="'compiler'">
        <!--'compiler' or 'runner'-->
    </p:option>
    <p:variable name="cases-dir" as="xs:anyURI" select="
        if ($error-phase eq 'runner')
        then resolve-uri('runner-error-cases/')
        else resolve-uri('compiler-error-cases/')
        "/>

    <p:variable name="this-version" as="xs:string"
        select="p:system-property('p:product-version')"/>
    <p:variable name="this-version-int" select="x:version-int($this-version)?result"/>
    <p:variable name="min-version-marker" as="xs:string" select="'min-xmlcalabash-version='"/>

    <p:directory-list path="{$cases-dir}" max-depth="1" include-filter="\.xspec$"/>
    <p:variable name="case-count" select="count(//c:file)"/>

    <p:for-each message="Found {$case-count} test cases.">
        <p:with-input select="//c:file"/>
        <p:variable name="test-filename" select="/*/@name"/>
        <p:variable name="idx" select="p:iteration-position()"/>
        <p:load href="{$cases-dir}{$test-filename}" name="test-file"/>
        <p:variable as="xs:string?" name="min-version"
            select="processing-instruction(xspec-test)[starts-with(.,$min-version-marker)]/
            substring-after(.,$min-version-marker)"/>
        <p:for-each>
            <p:with-input select="/"/>
            <p:variable as="processing-instruction(xspec-test)*" name="pi"
                select="processing-instruction(xspec-test)"/>
            <p:variable name="expected-message" select="
                $pi[starts-with(., 'message=')]
                /substring-after(., 'message=')
                "/>
            <p:choose>
                <p:when test="exists($min-version) and
                    (
                    contains($min-version,'future') or
                    $this-version-int lt x:version-int($min-version)?result
                    )">
                    <p:identity message="&#10;--- Case #{ $idx }: SKIPPING { $test-filename } ---">
                        <p:with-input>
                            <p:empty/>
                        </p:with-input>
                    </p:identity>
                </p:when>
                <p:otherwise>
                    <p:identity
                        message="&#10;--- Case #{ $idx }: { $test-filename } ---"
                        name="msg"/>
                    <p:try>
                        <p:group>
                            <p:choose>
                                <p:when test="$error-phase eq 'runner'">
                                    <x:run-xproc p:depends="msg">
                                        <p:with-input pipe="result@test-file"/>
                                        <p:with-option name="xspec-home" select="$xspec-home"/>
                                    </x:run-xproc>                            
                                </p:when>
                                <p:otherwise>
                                    <x:compile-xproc p:depends="msg">
                                        <p:with-input pipe="result@test-file"/>
                                        <p:with-option name="xspec-home" select="$xspec-home"/>
                                    </x:compile-xproc>
                                </p:otherwise>
                            </p:choose>
                            <p:identity>
                                <p:with-input>
                                    <message>{string($test-filename)} did not raise an error.</message>
                                </p:with-input>
                            </p:identity>
                        </p:group>
                        <p:catch>
                            <!--
                                We expected an error and got one. Compare the error message with the one
                                stored in a PI in the XSpec file,
                                <?xspec-test message=expected error message goes here?>
                                The expected error message can use .../ in place of $cases-dir, for portability.
                            -->
                            <p:filter select="//cx:message/text()"/>
                            <p:cast-content-type content-type="text/plain"/>
                            <!-- Remove boilerplate prefix to help focus on inner message -->
                            <p:text-replace pattern="^Stylesheet terminated with xsl:message: &#8220;(.+)&#8221;."
                                replacement="$1"/>
                            <p:text-replace pattern="^XSLT error: " replacement=""/>
                            <!-- Replace $cases-dir, which can vary by platform or on GitHub -->
                            <p:text-replace pattern="{$cases-dir}" replacement=".../"/>
                            <p:choose>
                                <p:when test=". eq $expected-message">
                                    <p:identity>
                                        <p:with-input>
                                            <p:inline/>
                                        </p:with-input>
                                    </p:identity>
                                </p:when>
                                <p:otherwise>
                                    <p:identity>
                                        <p:with-input expand-text="true">
                                            <message>{string($test-filename)} issued wrong message.&#10;Actual:   '{
                                                . }'&#10;Expected: '{$expected-message}'</message>
                                        </p:with-input>
                                    </p:identity>
                                </p:otherwise>
                            </p:choose>
                        </p:catch>
                    </p:try>
                    <p:store href="{$cases-dir}/results/{$test-filename}.html" use-when="$debugmode"/>                    
                </p:otherwise>
            </p:choose>
        </p:for-each>
    </p:for-each>
    <p:wrap-sequence>
        <p:with-option name="wrapper" select="QName('','messages')"/>
    </p:wrap-sequence>
    <p:if test="string-length(.) gt 0">
        <p:error code="x:TEST-EVENT-XPROC-002"/>
    </p:if>
    <p:identity message="&#10;--- Each test raised the expected error. ---&#10;"/>
    <p:sink/>
</p:declare-step>
