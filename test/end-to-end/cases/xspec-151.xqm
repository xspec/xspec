module namespace test-mix = "x-urn:test-mix";

import schema "x-urn:test-mix" at "xspec-151.xsd";

declare function test-mix:element-and-string() as item()+ {
	let $typed-element as element(test-mix:fooElement, test-mix:fooType) := (
	validate strict {doc('xspec-151.xml')/element()}
	)
	return
		($typed-element, 'string')
};
