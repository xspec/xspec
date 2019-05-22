module namespace xspec-space = "x-urn:test:xspec-space";

declare variable $xspec-space:wsot as text() := (
text { "&#x09;&#x0A;&#x0D;&#x20;" }
);

declare variable $xspec-space:span-element-empty as element(span) := (
<span/>
);

declare variable $xspec-space:span-element-wsot as element(span) := (
<span>{ $xspec-space:wsot }</span>
);
