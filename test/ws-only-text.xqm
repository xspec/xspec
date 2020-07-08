module namespace ws-only-text = "x-urn:test:ws-only-text";

(: Whitespace-only text node for test :)
declare variable $ws-only-text:wsot as text() := (
text { "&#x09;&#x0A;&#x0D;&#x20;" }
);

(: Elements for test :)
declare variable $ws-only-text:span-element-empty as element(span) := (
<span/>
);

declare variable $ws-only-text:span-element-wsot as element(span) := (
<span>{ $ws-only-text:wsot }</span>
);

declare variable $ws-only-text:pre-element-wsot as element(pre) := (
<pre>{ $ws-only-text:wsot }</pre>
);
