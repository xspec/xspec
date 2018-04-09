/** ************************************************************************* */
/*  File:       XSLTCoverageTraceListener.java                              */
 /*  Author:     Jeni Tennison                                               */
 /*  URI:        https://github.com/expath/xspec/                            */
 /*  Tags:                                                                   */
 /*  Copyright (c) 2008-2016 (see end of file.)                              */
 /* ------------------------------------------------------------------------ */
package com.jenitennison.xslt.tests;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import net.sf.saxon.lib.TraceListener;
import net.sf.saxon.trace.InstructionInfo;
import net.sf.saxon.trace.LocationKind;
import net.sf.saxon.Controller;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.StandardNames;
import java.util.HashMap;
import java.util.HashSet;
import java.io.PrintStream;
import java.net.MalformedURLException;
import java.net.URL;
import net.sf.saxon.lib.Logger;

/**
 * A Simple trace listener for XSLT that writes messages (by default) to
 * System.err
 * @author Edwin Glaser
 * @author Jeni Tenninson
 * @author Michael Kay
 * @author Sandro Cirulli
 * @author Christophe Marchand
 */
public class XSLTCoverageTraceListener implements TraceListener {
    public static final String DEFAULT_GENERATE_TESTS_UTILS = "generate-tests-utils.xsl";
    public static final String DEFAULT_IGNORE_DIR = "/xspec/";
    public static final String SYS_PROP_GENERATE_TESTS_UTILS = "com.jenitennison.xsl.tests.coverage.generate-tests-utils";
    public static final String SYS_PROP_IGNORE_DIR = "com.jenitennison.xsl.tests.coverage.ignore-dir";
    public static final String SYS_PROP_OUTPUT = "com.jenitennison.xsl.tests.coverage.output";
    
    private final PrintStream out;
    private String xspecStylesheet = null;
    private String utilsStylesheet = null;
    private final HashMap<String, Integer> modules;
    private final HashSet<Integer> constructs;
    private int moduleCount = 0;
    // Added for https://github.com/xspec/xspec/issues/182
    private String computedGenerateTestUtilsName;
    private String computedIgnoreDir;

    /**
     * @param out The PrintStrem to write to
     */
    public XSLTCoverageTraceListener(PrintStream out) throws Exception {
        super();
        this.out=out;
        this.modules = new HashMap<>();
        this.constructs = new HashSet<>();
        String sTmp = System.getProperty(SYS_PROP_GENERATE_TESTS_UTILS);
        if(sTmp!=null && !sTmp.isEmpty()) {
            computedGenerateTestUtilsName = sTmp;
        } else {
            computedGenerateTestUtilsName = DEFAULT_GENERATE_TESTS_UTILS;
        }
        sTmp = System.getProperty(SYS_PROP_IGNORE_DIR);
        if(sTmp!=null && !sTmp.isEmpty()) {
            try {
                URL url = new URL(sTmp);
                throw new Exception(SYS_PROP_IGNORE_DIR+" must be a path, and not a URI. i.e. it must not starts with file:");
            } catch(MalformedURLException ex) {
                computedIgnoreDir = sTmp;
            }
        } else {
            computedIgnoreDir = DEFAULT_IGNORE_DIR;
        }
    }
    /**
     * Constructs a new XSLTCoverageTraceListener.
     * If a system property call {@link #SYS_PROP_OUTPUT} exists and value is not
     * null, output will be written to a file. Else, output will be written to
     * System.err.
     * Prefer use @{link #XSLTCoverageTraceListener(PrintStream)}
     * @throws java.lang.Exception
     */
    public XSLTCoverageTraceListener() throws Exception {
        this(computeDefaultOutput(System.getProperty(SYS_PROP_OUTPUT)));
        System.out.println("****************************************");
    }
    
    /**
     * Utility method that computes the output
     * @param prop
     * @return
     * @throws FileNotFoundException 
     */
    private static PrintStream computeDefaultOutput(final String prop) throws FileNotFoundException {
        if(prop!=null && !prop.isEmpty()) {
            return new PrintStream(new FileOutputStream(prop));
        } else {
            return System.err;
        }
    }

    /**
     * Method called at the start of execution, that is, when the run-time
     * transformation starts
     *
     * @param c
     */
    @Override
    public void open(Controller c) {
        out.println("<trace>");
        System.out.println("controller=" + c);
    }

    /**
     * Method that implements the output destination for SaxonEE/PE 9.7
     *
     * @param logger
     */
    @Override
    public void setOutputDestination(Logger logger) {
    }

    /**
     * Method called at the end of execution, that is, when the run-time
     * execution ends
     */
    @Override
    public void close() {
        out.println("</trace>");
        // should flush and close, only if it not System.err
        out.flush();
        if(out!=System.err) out.close();
    }

    /**
     * Method that is called when an instruction in the stylesheet gets
     * processed.
     *
     * @param info gives information about the instruction being executed, and
     * about the context in which it is executed. This object is mutable, so if
     * information from the InstructionInfo is to be retained, it must be
     * copied.
     * @param context
     */
    @Override
    public void enter(InstructionInfo info, XPathContext context) {
        int lineNumber = info.getLineNumber();
        String systemId = info.getSystemId();
        int constructType = info.getConstructType();
        if (utilsStylesheet == null && systemId.contains(computedGenerateTestUtilsName)) {
            utilsStylesheet = systemId;
            out.println("<u u=\"" + systemId + "\" />");
        } else if (xspecStylesheet == null && systemId.contains(computedIgnoreDir)) {
            xspecStylesheet = systemId;
            out.println("<x u=\"" + systemId + "\" />");
        }
        if (!isXSpecStylesheet(systemId) && !isUtilsStylesheet(systemId)) {
            Integer module;
            if (modules.containsKey(systemId)) {
                module = modules.get(systemId);
            } else {
                module = moduleCount;
                moduleCount += 1;
                modules.put(systemId, module);
                out.println("<m id=\"" + module + "\" u=\"" + systemId + "\" />");
            }
            if (!constructs.contains(constructType)) {
                String construct;
                if (constructType < 1024) {
                    construct = StandardNames.getClarkName(constructType);
                } else {
                    switch (constructType) {
                        case LocationKind.LITERAL_RESULT_ELEMENT:
                            construct = "LITERAL_RESULT_ELEMENT";
                            break;
                        case LocationKind.LITERAL_RESULT_ATTRIBUTE:
                            construct = "LITERAL_RESULT_ATTRIBUTE";
                            break;
                        case LocationKind.EXTENSION_INSTRUCTION:
                            construct = "EXTENSION_INSTRUCTION";
                            break;
                        case LocationKind.TEMPLATE:
                            construct = "TEMPLATE";
                            break;
                        case LocationKind.FUNCTION_CALL:
                            construct = "FUNCTION_CALL";
                            break;
                        case LocationKind.XPATH_IN_XSLT:
                            construct = "XPATH_IN_XSLT";
                            break;
                        case LocationKind.LET_EXPRESSION:
                            construct = "LET_EXPRESSION";
                            break;
                        case LocationKind.TRACE_CALL:
                            construct = "TRACE_CALL";
                            break;
                        case LocationKind.SAXON_EVALUATE:
                            construct = "SAXON_EVALUATE";
                            break;
                        case LocationKind.FUNCTION:
                            construct = "FUNCTION";
                            break;
                        case LocationKind.XPATH_EXPRESSION:
                            construct = "XPATH_EXPRESSION";
                            break;
                        default:
                            construct = "Other";
                    }
                }
                constructs.add(constructType);
                out.println("<c id=\"" + constructType + "\" n=\"" + construct + "\" />");
            }
            out.println("<h l=\"" + lineNumber + "\" m=\"" + module + "\" c=\"" + constructType + "\" />");
        }
    }

    /**
     * Method that is called after processing an instruction of the stylesheet,
     * that is, after any child instructions have been processed.
     *
     * @param instruction gives the same information that was supplied to the
     * enter method, though it is not necessarily the same object. Note that the
     * line number of the instruction is that of the start tag in the source
     * stylesheet, not the line number of the end tag.
     */
    @Override
    public void leave(InstructionInfo instruction) { }

    /**
     * Method that is called by an instruction that changes the current item in
     * the source document: that is, xsl:for-each, xsl:apply-templates,
     * xsl:for-each-group. The method is called after the enter method for the
     * relevant instruction, and is called once for each item processed.
     *
     * @param currentItem the new current item. Item objects are not mutable; it
     * is safe to retain a reference to the Item for later use.
     */
    @Override
    public void startCurrentItem(Item currentItem) { }

    /**
     * Method that is called when an instruction has finished processing a new
     * current item and is ready to select a new current item or revert to the
     * previous current item. The method will be called before the leave()
     * method for the instruction that made this item current.
     *
     * @param currentItem the item that was current, whose processing is now
     * complete. This will represent the same underlying item as the
     * corresponding startCurrentItem() call, though it will not necessarily be
     * the same actual object.
     */
    @Override
    public void endCurrentItem(Item currentItem) { }
    
    /**
     * If the specified systemId is the XSpec stylesheet (the one produced by
     * XSpec compilation), must return true.
     * This method may be overwritten, especially when generated files are not
     * located in the same locations than with XSpec implementation
     * @param systemId
     * @return 
     */
    public boolean isXSpecStylesheet(String systemId) {
        return systemId.equals(xspecStylesheet);
    }
    /**
     * If the specified systemId is the utils stylesheet (usually a file named
     * {@link #DEFAULT_GENERATE_TESTS_UTILS}), it must return true.
     * This method may be overwritten, especially if one don't use default
     * implementation or have a special directory structure.
     * @param systemId
     * @return 
     */
    public boolean isUtilsStylesheet(String systemId) {
        return systemId.equals(utilsStylesheet);
    }
    
    /**
     * Allows to define the name of the generate-tests-utils stylesheet, to be 
     * able to ignore it.
     * <ul><li>Default value is {@link #DEFAULT_GENERATE_TESTS_UTILS}</li>
     * <li>Value can be defined by System property {@link #SYS_PROP_GENERATE_TESTS_UTILS}</li>
     * <li>If this method is used, {@link #SYS_PROP_GENERATE_TESTS_UTILS} is ignored</li></ul>
     * @param generateTestsUtilsName 
     * @since 1.1
     */
    public void setGenerateTestsUtilsName(final String generateTestsUtilsName) {
        computedGenerateTestUtilsName = generateTestsUtilsName;
    }
    
    /**
     * Allows to define the name of directory that contains compiled files that
     * should be ignored by coverage.
     * <ul><li>Default value is {@link #DEFAULT_IGNORE_DIR}</li>
     * <li>Value can be defined by System property {@link #SYS_PROP_IGNORE_DIR}</li>
     * <li>If this method is used, {@link #SYS_PROP_IGNORE_DIR} is ignored</li></ul>
     * @param ignoreDirName 
     * @since 1.1
     */
    public void setXSpecIgnoreDir(final String ignoreDirName) {
        computedIgnoreDir = ignoreDirName;
    }

    // for unit tests only
    String getXSpecIgnoreDir() {
        return computedIgnoreDir;
    }
    // for unit tests only
    String getGenerateTestsUtilsName() {
        return computedGenerateTestUtilsName;
    }

}

//
// The contents of this file are subject to the Mozilla Public License
// Version 1.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License
// at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.
// See the License for the specific language governing rights and
// limitations under the License.
//
// The Original Code is: all this file.
//
// The Initial Developer of the Original Code is Edwin Glaser
// (edwin@pannenleiter.de)
//
// Portions created by Jeni Tennison are Copyright (C) Jeni Tennison.
// All Rights Reserved.
//
// Contributor(s): Heavily modified by Michael Kay
//                 Methods implemented by Jeni Tennison
//                 Extended for Saxon 9.7 by Sandro Cirulli, github.com/cirulls
