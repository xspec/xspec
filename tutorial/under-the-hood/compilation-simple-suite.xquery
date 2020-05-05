module namespace my = "http://example.org/ns/my";

(: Example in Compilation.md, under "Simple suite" :)

declare function my:f() as xs:integer
{
  xs:integer(1)
};
