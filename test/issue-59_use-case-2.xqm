module namespace issue-59 = "https://github.com/xspec/xspec/issues/59#issuecomment-281689650";

declare function issue-59:extract-local-name-and-namespace-from-lexical-qname(
$lexical-qname as xs:string
)
as attribute()+
{
	let $qname as xs:QName := xs:QName($lexical-qname)
	return
		(
		attribute local-name {local-name-from-QName($qname)},
		attribute namespace {namespace-uri-from-QName($qname)}
		)
};
