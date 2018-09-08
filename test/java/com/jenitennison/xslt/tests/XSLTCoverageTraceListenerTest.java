/** *********************************************************************** */
/*  File:       XSLTCoverageTraceListenerTest.java                          */
/*  Author:     Christophe Marchand                                         */
/*  URI:        https://github.com/expath/xspec/                            */
/*  Tags:                                                                   */
/*  Copyright (c) 2008-2018 (see end of file.)                              */
/* ------------------------------------------------------------------------ */
package com.jenitennison.xslt.tests;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.PrintStream;
import net.sf.saxon.trace.InstructionInfo;
import org.junit.Assert;
import org.junit.Test;

/**
 * Tests XSLTCoverageTraceListener
 * @author cmarchand
 */
public class XSLTCoverageTraceListenerTest {
    
    @Test
    public void testConstructorWithPrintStream() throws Exception {
        File outputDir = new File(new File(System.getProperty("user.dir")), "target/testFiles");
        outputDir.mkdirs();
        File outputFile = new File(outputDir, "test1.xml");
        if(outputFile.exists()) outputFile.delete();
        XSLTCoverageTraceListener l = new XSLTCoverageTraceListener(new PrintStream(outputFile));
        // just send one event
        InstructionInfo ii = new AbstractInstructionInfo() {
            @Override
            public String getSystemId() {
                return "foe/"+XSLTCoverageTraceListener.DEFAULT_GENERATE_TESTS_UTILS;
            }
            
        };
        l.enter(ii, null);
        l.close();
        Assert.assertTrue("Specified output file does not exists", outputFile.exists());
        outputFile.delete();
    }
    
    @Test
    public void testDefaultConstructorNoSysProp() throws Exception {
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_GENERATE_TESTS_UTILS);
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_IGNORE_DIR);
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_OUTPUT);
        PrintStream err = System.err;
        try {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PrintStream ps = new PrintStream(baos);
        System.setErr(ps);
        XSLTCoverageTraceListener l = new XSLTCoverageTraceListener();
        // just send one event
        InstructionInfo ii = new AbstractInstructionInfo() {
            @Override
            public String getSystemId() {
                return "foe/"+XSLTCoverageTraceListener.DEFAULT_GENERATE_TESTS_UTILS;
            }
            
        };
        l.enter(ii, null);
        l.close();
        Assert.assertTrue("There were no write to System.err", baos.size()>0);
        } catch(Exception ex) {
            throw ex;
        } finally {
            // restores System.err, even if an Exception was thrown
            System.setErr(err);
        }
    }
    
    @Test
    public void testDefaultConstructorWithOutputProperty() throws Exception {
        File outputDir = new File(new File(System.getProperty("user.dir")), "target/testFiles");
        outputDir.mkdirs();
        File outputFile = new File(outputDir, "test2.xml");
        if(outputFile.exists()) outputFile.delete();

        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_GENERATE_TESTS_UTILS);
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_IGNORE_DIR);
        System.setProperty(XSLTCoverageTraceListener.SYS_PROP_OUTPUT, outputFile.getAbsolutePath());

        XSLTCoverageTraceListener l = new XSLTCoverageTraceListener();
        // just send one event
        InstructionInfo ii = new AbstractInstructionInfo() {
            @Override
            public String getSystemId() {
                return "foe/"+XSLTCoverageTraceListener.DEFAULT_GENERATE_TESTS_UTILS;
            }
            
        };
        l.enter(ii, null);
        l.close();
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_OUTPUT);
        Assert.assertTrue("Specified output file does not exists", outputFile.exists());
        outputFile.delete();
    }
    
    @Test
    public void testSysPropertyIgnoreDir() throws Exception {
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_GENERATE_TESTS_UTILS);
        System.setProperty(XSLTCoverageTraceListener.SYS_PROP_IGNORE_DIR, "/foe/");
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_OUTPUT);

        XSLTCoverageTraceListener l = new XSLTCoverageTraceListener();
        Assert.assertEquals("Property "+XSLTCoverageTraceListener.SYS_PROP_IGNORE_DIR+" is ignored", "/foe/", l.getXSpecIgnoreDir());
        l.setXSpecIgnoreDir("/bar/");
        Assert.assertNotEquals("When using setXSpecIgnoreDir(String), property "+XSLTCoverageTraceListener.SYS_PROP_IGNORE_DIR+" is not ignored", "/foe/", l.getXSpecIgnoreDir());
    }
    
    @Test
    public void testsSysPropertyGenerateTestUtils() throws Exception {
        System.setProperty(XSLTCoverageTraceListener.SYS_PROP_GENERATE_TESTS_UTILS, "generate-it.xsl");
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_IGNORE_DIR);
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_OUTPUT);

        XSLTCoverageTraceListener l = new XSLTCoverageTraceListener();
        Assert.assertEquals("Property "+XSLTCoverageTraceListener.SYS_PROP_GENERATE_TESTS_UTILS+" is ignored", "generate-it.xsl", l.getGenerateTestsUtilsName());
        l.setGenerateTestsUtilsName("generate-me.xsl");
        Assert.assertNotEquals("When using setXSpecIgnoreDire(String), property "+XSLTCoverageTraceListener.SYS_PROP_IGNORE_DIR+" is not ignored", "generate-it.xsl", l.getGenerateTestsUtilsName());
    }
    
    @Test
    public void testDefaultValue() throws Exception {
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_GENERATE_TESTS_UTILS);
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_IGNORE_DIR);
        System.clearProperty(XSLTCoverageTraceListener.SYS_PROP_OUTPUT);

        XSLTCoverageTraceListener l = new XSLTCoverageTraceListener();
        Assert.assertEquals("Default value for generate-tests-utils.xsl is wrong", XSLTCoverageTraceListener.DEFAULT_GENERATE_TESTS_UTILS, l.getGenerateTestsUtilsName());
        Assert.assertEquals("Default value for ignore-dir is wrong", XSLTCoverageTraceListener.DEFAULT_IGNORE_DIR, l.getXSpecIgnoreDir());
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
// The Initial Developer of the Original Code is Christophe Marchand
// (christophe@marchand.top)
//
// All Rights Reserved.
//
// Contributor(s): 
