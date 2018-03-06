module namespace xspec-space = "x-urn:test:xspec-space";

declare variable $xspec-space:span-element-empty as element(span) := (
<span/>
);

declare variable $xspec-space:span-element-wsot as element(span) := (
<span>&#x09;&#x0A;&#x0D;&#x20;</span>
);
