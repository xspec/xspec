module namespace mirror = "x-urn:test:mirror";

(:
	Returns the items in the parameter intact
:)
declare function mirror:param-mirror($param-items as item()*) as item()* {
	$param-items
};

(:
	Emulates fn:true()
:)
declare function mirror:true() as xs:boolean {
	true()
};

(:
	Emulates fn:false()
:)
declare function mirror:false() as xs:boolean {
	false()
};

(:
	Emulates fn:upper-case()
:)
declare function mirror:upper-case($input as xs:string?) as xs:string {
	upper-case($input)
};
