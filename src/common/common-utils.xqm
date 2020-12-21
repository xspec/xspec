(:
	Utilities common between XSLT and XQuery
:)

module namespace x = "http://www.jenitennison.com/xslt/xspec";

(:
	XSpec 'x' namespace URI
:)
declare variable $x:xspec-namespace as xs:anyURI := xs:anyURI('http://www.jenitennison.com/xslt/xspec');

(:
	U+0027
:)
declare variable $x:apos as xs:string := "'";

(:
	Returns numeric literal of xs:decimal
		https://www.w3.org/TR/xpath-31/#id-literals

		Example:
			in:  1
			out: '1.0'
:)
declare function x:decimal-string(
$decimal as xs:decimal
) as xs:string
{
	let $decimal-string as xs:string := string($decimal)
	return
		if (contains($decimal-string, '.')) then
			$decimal-string
		else
			($decimal-string || '.0')
};

(:
	Returns XPath expression of fn:QName() which represents the given xs:QName
:)
declare function x:QName-expression(
$qname as xs:QName
) as xs:string
{
	let $quoted-uri as xs:string := (
	$qname
	=> namespace-uri-from-QName()
	=> x:quote-with-apos()
	)
	return
		('QName(' || $quoted-uri || ", '" || $qname || "')")
};

(:
	Duplicates every apostrophe character in a string
	and quotes the whole string with apostrophes
:)
declare function x:quote-with-apos(
$input as xs:string
)
as xs:string
{
	let $escaped as xs:string := replace($input, $x:apos, ($x:apos || $x:apos))
	return
		($x:apos || $escaped || $x:apos)
};
