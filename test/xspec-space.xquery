module namespace xspec-space = "x-urn:test:xspec-space";

(: Whitespace-only text node for test :)
declare variable $xspec-space:wsot as text() := (
text { "&#x09;&#x0A;&#x0D;&#x20;" }
);

(: Elements for test :)
declare variable $xspec-space:span-element-empty as element(span) := (
<span/>
);

declare variable $xspec-space:span-element-wsot as element(span) := (
<span>{ $xspec-space:wsot }</span>
);

declare variable $xspec-space:pre-element-wsot as element(pre) := (
<pre>{ $xspec-space:wsot }</pre>
);
