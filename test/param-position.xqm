module namespace param-position = "x-urn:test:param-position";

declare function param-position:join(
$p1 as xs:string,
$p2 as xs:string,
$p3 as xs:string,
$p4 as xs:string
) as xs:string
{
	($p1, $p2, $p3, $p4) => string-join()
};
