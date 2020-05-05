module namespace my = "http://example.org/ns/my";

(: Example in Compilation.md, under "SUT" :)
declare function my:f($p1, $p2) as xs:boolean
{
  true()
};
