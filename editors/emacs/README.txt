nXML-mode and XSpec
===================

To add support for XSpec in nXML-mode such that nXML-mode will use the
XSpec schema with XSpec files:

1. Select `rng-schema-locating-files' for customization by:

   a. Either, using the menu, selecting:

         Options->Customize Emacs->Specific Option...

      or, using the keyboard, entering:

         M-x customize-variable

   b. Entering:

         rng-schema-locating-files RET

2. Select one of the INS buttons.

3. Enter the location of the 'schema.el' file in this directory as the
   value for the new 'File:' text box.

4. Select the 'State' button then select the 'Save for Future
   Sessions' option.

You could also customize `rng-preferred-prefix-alist' to add the XSpec
namespace URI, "http://www.jenitennison.com/xslt/xspec", and preferred
prefix, "x", if you want.
