module namespace transform = "x-urn:test:transform";

declare function transform:square(
$n as xs:integer
)
as xs:integer
{
	transform(
	map {
		'delivery-format': 'raw',
		'function-params': [$n],
		'initial-function': QName('http://example.org/ns/my', 'square'),
		'stylesheet-location': 'external_square.xsl'
	}
	)?output
};
