# Conventions for Per-XSLT-Element Test Cases

## Filenames

Filename is `xsl-<xslt element name>-01` with `.xsl` or `.xspec` extension, except that tests that use `@run-as="external"` have filenames starting with `"external_"`.

Any import/include stylesheet has A, B, etc. added to the filename.

## XSpec Code

XSpec scenario label is xsl-<xslt element name> Coverage Test Case.

XSpec scenario context is <root><xsl-<xslt element name>></root>.

Data is defined in `x:context` where it is needed in XSpec file.

Individual XSpec files use the default `run-as` behavior, except those that require `run-as=external`:

- `external_xsl-global-context-item-01.xspec`
- `external_xsl-result-document-01.xspec`

## XSLT Code

XSLT has comment of xsl:<element name> Coverage Test Case across 3 lines.

XSLT template match is xsl-<element-name>.

Where an element can have a select attribute or a sequence constructor, tests are done for both.

The transformation always outputs something.

The intention is for one element per line, with text enclosed in xsl:text tags.

To facilitate importing multiple tests in a single XSpec file `external_xsl-all-01.xspec`, `xsl:mode is used extensively to avoid interference among individual tests.

Some tests seem trivial because the contents appear in many other tests, e.g., `xsl:template`, `xsl:stylesheet`, and `xsl:text`, but they are included so that there is a specific test that can be viewed.
