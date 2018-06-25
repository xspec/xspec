module namespace t = "catalog/test";
declare function t:test($doc as item()) as xs:string? {
    $doc/root/@dtd-version
};
