# XQS
XQuery for Schematron (XQS) (pron. /ɛksˈkju&#x2D0;z/) is an XQuery implementation of Schematron.

The development version is a highly conformant implementation of the forthcoming 2025 edition of the international standard, ISO/IEC 19757-3:2025.

# Limitations
The only known area of non-conformance is XInclude-like language fixup, which is mandated by Clause 6.7 _Localization and language fixup_.

See also https://github.com/AndrewSales/XQS/issues/29.

# Pre-requisites
Tested under [BaseX](https://basex.org/) 10.x.

# Installation
1. Install [BaseX](https://basex.org/download/) version 10 or later.
1. Download the latest release and navigate to the root directory of the extracted archive (containing `*.xqm` files).

# Usage
XQS provides two methods of validating with a Schematron schema, by either:

- evaluating the schema dynamically; or
- compiling the schema to an XQuery main module.

## At the command line

Basic [command scripts](https://docs.basex.org/wiki/Commands#Command_Scripts) are provided in `bin/` to run XQS using BaseX in standalone mode. This allows you to use XQS as a straightforward, standalone validator.

The `-b` options given below simply bind a variable; their order is not significant.

The named example files used in the commands below are also included in this repository, in `examples/`.

### Evaluate

Run `evaluate.bxs`, passing the locations of the XML document (`uri`) and the Schematron schema (`schema`):

    basex -buri=myDoc.xml -bschema=mySchema.sch evaluate.bxs
    
You can also pass an optional phase (as `phase`):

    basex -buri=myDoc.xml -bschema=mySchema.sch -bphase=myPhase evaluate.bxs

The output is in the Schematron Validation Reporting Language (SVRL) format.

### Compile

Run `compile.bxs`, passing the location of the Schematron schema (`schema`):

    basex -bschema=mySchema.sch compile.bxs
    
Example output for this command is shown in `mySchema.xqy`.    
    
If your schema uses phases, you can also select a phase:

    basex -bschema=mySchema.sch -bphase=myPhase compile.bxs
    
Example output for this command is shown in `mySchema-myPhase.xqy`.

The output from `compile.bxs` is an XQuery main module, which contains two external variables allowing the document to validate to be passed in:

    $Q{http://www.andrewsales.com/ns/xqs}uri
    $Q{http://www.andrewsales.com/ns/xqs}doc
    
`$uri` should be a URI. If your XQuery processor supports it, you can use `$doc` to pass a document node instead. 

**CAUTION** When compiling, avoid using the XQS namespace (`http://www.andrewsales.com/ns/xqs`) in your schema, which XQS uses for variables internal to the application.

### Reporting the Schematron edition

Both evaluation and compile scripts support the `report-edition` option, which  is a new conformance requirement for implementations. In XQS, it can be invoked by passing one of the values `y`, `true`, `yes` or `1` in any combination of case to the `report-edition` option:

    basex -buri=myDoc.xml -bschema=mySchema.sch -breport-edition=Y evaluate.bxs
    
When this option is enabled, XQS reports this via an empty `schema` root element as the first item returned, including the attribute `schematronEdition` if specified in the schema e.g.

    <schema xmlns='http://purl.oclc.org/dsdl/schematron' schematronEdition='2025'/>
    
Output from evaluating or compiling the schema will be the second item returned in this scenario.    

### Validate

For convenience, if you have compiled a schema using `compile.bxs`, you can run `validate.bxs`, passing the schema and document locations:

    basex -bschema=mySchema.xqy -buri=myDoc.xml validate.bxs
    
The output is again SVRL.

## In XQuery
You can also use the XQuery API contained in `xqs.xqm`, e.g.

    import module namespace xqs = 'http://www.andrewsales.com/ns/xqs' at 'path/to/xqs.xqm;
    xqs:validate(doc('myDoc.xml'), doc('mySchema.xml')/*)
    
or

    xqs:compile(doc('mySchema.xml')/*)
    
If you use phases, you can pass them in like so:

    xqs:compile(doc('mySchema.xml')/*, map{'phase':'myPhase'})
    
or

    xqs:validate(doc('myDoc.xml'), doc('mySchema.xml')/*, map{'phase':'myPhase'})
    
where `myPhase` is the ID of the selected phase. 

Here you may also use the reserved values:
- `#ALL` - to indicate that all patterns are active;
- `#ANY` - to choose the phase dynamically based on evaluating `phase/@when` against the instance document (new in Schematron 2025); or
- `#DEFAULT` to select the default phase.     
    
## Inclusion and expansion

Inclusions are resolved and abstract rules and patterns instantiated automatically, whether you are compiling or evaluating a schema. There is no need to carry out a separate initial process.

If you do wish to perform this step only, in order to produce a fully resolved and instantiated schema, `include-expand.bxs` is provided for this purpose. Run it, passing the location of the schema, as follows:

    basex -bschema=myModularSchema.sch include-expand.bxs
    
Example output for this command is shown in `examples/myResolvedSchema.sch`.
    
The output from `include-expand.bxs` is the schema with inclusions resolved and abstract patterns and rules instantiated. (Note that this command script can be used on **any** valid Schematron schema, regardless of the target query language; it does not depend on the query language binding the schema declares.)  
    
# Running the test suite
The test suite is found in the `test/ `sub-directory.
To run all the tests there, at the command line, specify the `-t` option and the path to the `test` directory:

    basex -t path/to/test
    
The command returns `0` if all tests pass, otherwise `1`.  
    
# Advisory notes
This is an early release and should be treated as such. Bug reports, feature requests and other observations are welcome.
Please refer to the issues for a list of known bugs and planned enhancements.

## Query language binding
Your schema should specify a `queryBinding` value of : `xquery`, `xquery3` or `xquery31`, in any combination of upper or lower case.

# Troubleshooting

## My existing schema produces different results with XQS: rules don't fire that I expect to.

When using an XSLT implementation, a rule's `context` attribute with an XPath such as `foo` will match any instance of that element in the document being validated, and the rule is said to "fire".

The key difference with XQS is that it evaluates these XPaths _in the context of the document root_, so the expression `foo` will only match **if it is the root element**.

To address this, XPaths should be changed as appropriate, e.g. to `//foo`, which will ensure that the element would be matched anywhere in the document.

## User-defined functions in my existing schema aren't working.

If your schema was intended for use with an XSLT implementation, then any user-defined functions will most likely be expressed using `xsl:function`.

XQS is a pure XQuery implementation and doesn't recognize these, so they need to be re-written as XQuery, contained in `function` elements in the XQuery namespace, e.g.

    <function xmlns='http://www.w3.org/2012/xquery'>
    declare function local:foo($i as xs:int) as xs:int{
      $i * $i
    };
    </function>
