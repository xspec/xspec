<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:impl="urn:x-xspec:compile:impl"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.1" type="impl:error-code-as-element">
    <p:input port="source" content-types="xml"/>
    <p:output port="result" content-types="xml"/>

    <p:variable name="regex-for-NCName" as="xs:string" select="'[\i-[:]][\c-[:]]*'"/>
    <p:variable name="regex-for-UQName" as="xs:string"
        select="'Q\{([^\{\}]*)\}' || $regex-for-NCName"/>

    <p:filter select="/c:errors/c:error"/>
    <p:for-each>
        <p:variable name="this-error" select="/c:error"/>
        <p:variable name="in-scope-prefixes" select="in-scope-prefixes($this-error)" as="xs:string*"/>
        <p:variable name="code" select="string($this-error/@code)" as="xs:string"/>
        <p:variable name="tokenized" select="tokenize($code, ':')" as="xs:string*"/>
        <p:identity name="x-error-code-with-placeholder">
            <p:with-input>
                <x:error-code><placeholder/></x:error-code>
            </p:with-input>
        </p:identity>
        <p:choose name="rename-or-delete-placeholder">
            <p:when test="$code eq ''" name="empty">
                <p:delete match="//placeholder"/>
            </p:when>
            <p:when test="matches($code, $regex-for-UQName)" name="UQName">
                <p:rename match="//placeholder">
                    <p:with-option name="new-name" select="$code"/>
                </p:rename>
            </p:when>
            <p:when test="count($tokenized) eq 1" name="no-namespace">
                <p:rename match="//placeholder">
                    <p:with-option name="new-name" select="$code"/>
                </p:rename>
            </p:when>
            <p:when test="(count($tokenized) eq 2) and ($tokenized[1] = $in-scope-prefixes)"
                name="prefixed">
                <p:rename match="//placeholder">
                    <p:with-option name="new-name" select="resolve-QName($code, $this-error)"/>
                </p:rename>
            </p:when>
            <p:otherwise name="unrecognized-content">
                <p:delete match="//placeholder"/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:wrap-sequence wrapper="x:error-codes"/>
</p:declare-step>
