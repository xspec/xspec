module namespace my = "http://example.org/ns/my";

declare function my:subtract(
$left as xs:integer,
$right as xs:integer
) as xs:integer
{
	$left - $right
};
