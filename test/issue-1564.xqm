module namespace issue-1564 = "x-urn:test:issue-1564";

declare variable $issue-1564:g as xs:string := 'global default value';

(:
	Returns global variable value. Function parameter is not used at all.
:)
declare function issue-1564:get-g($unused as xs:string) as xs:string {
	$issue-1564:g
};
