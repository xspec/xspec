# ========================================================================== #
#   File:       test/Makefile                                                #
#   Author:     Jeni Tennsion                                                #
#   Tags:                                                                    #
#     Copyright (c) 2010 Jeni Tennsion (see end of file.)                    #
# -------------------------------------------------------------------------- #
#   TODO: Use the XSpec test harnesses (in XProc) themselves, by using
#   XProject directly.  Adapt the process to be able (for some tests) to
#   compile some XSpec code and test either (1) its report or (2) the result
#   of its compilation.
# ----------------------------------------------------------------------------
#   To use this Makefile, $SAXON_HOME must be set to a directory that
#   contains either saxon9.jar (for B in 9.1 or below) or saxon9he.jar
#   (for HE in 9.2 and above).  Set it the usual way you set environ
#   variables.
# ----------------------------------------------------------------------------


# the classpath to invoke Saxon
CP=$$SAXON_HOME/saxon9he.jar:$$SAXON_HOME/saxon9.jar
# invoke Saxon as XSLT processor
XSLT=java -cp $(CP) net.sf.saxon.Transform
# invoke Saxon as XQuery processor
XQUERY=java -cp $(CP) net.sf.saxon.Query

### MAIN TARGETS ###

# run all tests
all: xslt xquery

# run XSLT tests
xslt: xspec-function-xsl.html                     \
      xspec-rule-xsl.html                         \
      xspec-import-xsl.html                       \
      xspec-focus-1-xsl.html                      \
      xspec-focus-2-xsl.html                      \
      xspec-pending-xsl.html                      \
      xspec-variable-xsl.html                     \
      generate-tests-utils-xsl.html               \
      generate-xspec-tests-xsl.html

# run XQuery tests
xquery: xspec-function-xq.html                    \
        xspec-import-xq.html                      \
        xspec-focus-1-xq.html                     \
        xspec-focus-2-xq.html                     \
        xspec-pending-xq.html                     \
        xspec-variable-xq.html                    \
        generate-tests-utils-xq.html

# clean result files
clean:
	rm -fv *.html

### FILE RULES ###

# compile to XSLT
%.xsl: %.xspec
	$(XSLT)                                               \
	    -xsl:../src/compiler/generate-xspec-tests.xsl     \
	    -s:$<                                             \
	    -o:$@

# compile to XQuery
%.xq: %.xspec
	$(XSLT)                                               \
	    -xsl:../src/compiler/generate-query-tests.xsl     \
	    -s:$<                                             \
	    -o:$@

# run an XSLT compiled suite
%-xsl.xml: %.xsl xspec-tested.xsl
	$(XSLT)                                               \
	    -xsl:$<                                           \
	    -o:$@                                             \
	    -it:"{http://www.jenitennison.com/xslt/xspec}main"

# run an XQuery compiled suite
%-xq.xml: %.xq xspec-tested.xql
	$(XQUERY)                                             \
	    -o:$@ $< '!indent=yes'

# format an XML report to HTML
%.html: %.xml
	$(XSLT)                                               \
	    -xsl:../src/reporter/format-xspec-report.xsl      \
	    -s:$<                                             \
	    -o:$@


# -------------------------------------------------------------------------- #
#   DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.                #
#                                                                            #
#   Copyright (c) 2010 Jeni Tennsion                                         #
#                                                                            #
#   The contents of this file are subject to the MIT License (see the URI    #
#   http://www.opensource.org/licenses/mit-license.php for details).         #
#                                                                            #
#   Permission is hereby granted, free of charge, to any person obtaining    #
#   a copy of this software and associated documentation files (the          #
#   "Software"), to deal in the Software without restriction, including      #
#   without limitation the rights to use, copy, modify, merge, publish,      #
#   distribute, sublicense, and/or sell copies of the Software, and to       #
#   permit persons to whom the Software is furnished to do so, subject to    #
#   the following conditions:                                                #
#                                                                            #
#   The above copyright notice and this permission notice shall be           #
#   included in all copies or substantial portions of the Software.          #
#                                                                            #
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,          #
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF       #
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   #
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY     #
#   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,     #
#   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        #
#   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                   #
# -------------------------------------------------------------------------- #
