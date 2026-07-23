<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:impl="urn:x-xspec:compile:impl"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.1"
    type="impl:error-code-attr-to-qname">

    <p:documentation>
        Given a c:errors document that the XProc processor creates when catching
        an error, return the /c:errors/c:error/@code values as xs:QName items.
    </p:documentation>

    <p:input port="source" content-types="xml"/>
    <p:output port="result" content-types="application/json" sequence="true"/>

    <p:variable name="regex-for-NCName" as="xs:string" select="'([\i-[:]][\c-[:]]*)'"/>
    <p:variable name="regex-for-UQName" as="xs:string"
        select="'Q\{([^\{\}]*)\}' || $regex-for-NCName"/>

    <p:filter select="/c:errors/c:error"/>
    <p:for-each>
        <p:variable name="this-error" select="/c:error"/>
        <p:variable name="in-scope-prefixes" select="in-scope-prefixes($this-error)" as="xs:string*"/>
        <p:variable name="code" select="string($this-error/@code)" as="xs:string"/>
        <p:variable name="tokenized" select="tokenize($code, ':')" as="xs:string*"/>
        <!-- Maybe not all branches of the if/then/else clause come up in practice.
            Empirically, the cases seen are as follows, for an error code in p:error that is:

            a) Prefixed => c:error uses prefixed name
            b) In null namespace  => c:error uses unprefixed name and no xmlns="..."
            c) In non-null namespace but user provided no prefix =>
               In XML Calabash (v.0.50), c:error uses prefixed name with processor-generated prefix
               In MorganaXProc-IIIee (v1.8.14), c:error uses unprefixed name and xmlns="..."
                   binding to error code's namespace URI
        -->
        <p:variable name="code-as-QName" as="xs:QName?" select="
            if ($code eq '')
            then ()
            else if (matches($code, $regex-for-UQName) (: URI-qualified name :))
            then QName(replace($code, $regex-for-UQName, '$1'), replace($code, $regex-for-UQName, '$2'))
            else if (count($tokenized) eq 1 and ($code castable as xs:QName) (: Unprefixed, possibly default namespace :))
            then resolve-QName($code, $this-error)
            else if ((count($tokenized) eq 2) and ($tokenized[1] = $in-scope-prefixes) (: Prefixed :))
            then resolve-QName($code, $this-error)
            else () (: Unrecognized content :)
            "/>
        <p:identity>
            <p:with-input select="$code-as-QName">
                <p:inline/>
            </p:with-input>
        </p:identity>
    </p:for-each>
</p:declare-step>
