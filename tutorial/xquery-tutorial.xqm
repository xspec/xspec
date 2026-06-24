module namespace cf = "x-urn:tutorial:xquery-tutorial";

(:
    Capitalizes the first character of a string
:)
declare function cf:capitalize-first
($arg as xs:string?) as xs:string {
    
    analyze-string($arg, '^.')/(upper-case(fn:match) || fn:non-match)
};