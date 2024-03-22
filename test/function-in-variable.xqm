module namespace fv = "x-urn:test:function-in-variable";

(:
	Returns the first and last items in a sequence.
	If sequence has fewer than 2 items, returns sequence intact.
:)
declare variable $fv:first-last as function(*) :=
    function($param-items as item()*) as item()* {
		(head($param-items), $param-items[last()][count($param-items) gt 1])
	};

declare variable $fv:function-item as function(*) :=
    function() as function(*) {
        function-lookup(QName('http://www.w3.org/2005/xpath-functions','head'),1)
    };