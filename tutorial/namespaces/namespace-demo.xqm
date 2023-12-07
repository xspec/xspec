module namespace ns-demo = "x-urn:tutorial:namespaces:namespace-demo";
declare namespace db = "http://docbook.org/ns/docbook";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace h = "http://www.w3.org/1999/xhtml";
declare namespace xlink = "http://www.w3.org/1999/xlink";

(:
    Default element namespace is for XHTML.
    DocBook and XLink namespaces are also in use.
:)
declare function ns-demo:link($arg as element(db:link))
as element(a) {
    (: Produces XHTML 'a' :)
    <a href="{$arg/@xlink:href}">
        { string($arg) }
    </a>
};