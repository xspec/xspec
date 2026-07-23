xquery version "4.0";
module namespace xq4 = "x-urn:test:xquery-version_4";

(:
	XQuery 4.0 supports 'case' matching multiple values
	https://www.saxonica.com/documentation12/index.html#!v4extensions/xquery40-extensions
:)

declare function xq4:switch-v4($f as xs:string) as xs:string {
    switch ($f)
    case ('svg','SVG')
        return "vector"
    case ('jpg','JPG','jpeg','JPEG')
        return "bitmap"
    default
        return "not supported"
};
