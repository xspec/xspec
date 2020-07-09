module namespace x = "x-urn:test:prefix-conflict";

(:
	Returns the items in the parameter intact
:)
declare function x:param-mirror($x:param-items as item()*) as item()* {
	$x:param-items
};

(:
	Emulates fn:false()
:)
declare function x:false() as xs:boolean {
	false()
};

