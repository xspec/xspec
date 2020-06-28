module namespace functx = "http://www.functx.com";

declare function functx:capitalize-first
($arg as xs:string?) as xs:string? {
    
    concat(upper-case(substring($arg, 1, 1)),
    substring($arg, 2))
};