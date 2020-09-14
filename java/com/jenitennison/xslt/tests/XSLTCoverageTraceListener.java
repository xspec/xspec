/****************************************************************************/
/*  File:       XSLTCoverageTraceListener.java                              */
/*  Author:     Jeni Tennison                                               */
/*  URI:        https://github.com/expath/xspec/                            */
/*  Tags:                                                                   */
/*  Copyright (c) 2008-2016 (see end of file.)                              */
/* ------------------------------------------------------------------------ */


package com.jenitennison.xslt.tests;

import net.sf.saxon.lib.TraceListener;
import net.sf.saxon.trace.InstructionInfo;
import net.sf.saxon.trace.LocationKind;
import net.sf.saxon.Controller;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.functions.ResolveURI;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.StandardNames;
import java.lang.String;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.HashSet;
import java.io.File;
import net.sf.saxon.lib.Logger;

import javax.xml.stream.XMLStreamException;
import net.sf.saxon.event.StreamWriterToReceiver;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;

/**
 * A Simple trace listener for XSLT that writes messages to XML file
 */

public class XSLTCoverageTraceListener implements TraceListener {

  private int openCount = 0;
  private String xspecStylesheet = null;
  private HashMap<String, Integer> utils = new HashMap<String, Integer>();
  private HashMap<String, Integer> modules = new HashMap<String, Integer>();
  private HashSet<Integer> constructs = new HashSet<Integer>();
  private int utilsCount = 0;
  private int moduleCount = 0;
  private StreamWriterToReceiver writer = null;
  private String srcDir = null;
  private String ignoreDir = null;
  private boolean debugPrintEnabled = (System.getenv("DEBUG_XSLT_COVERAGE_TRACE_LISTENER") != null);

  private void debugPrintf(String format, Object... args) {
    if (debugPrintEnabled) {
      System.err.printf(format, args);
    }
  }

  private URI filePathToUri(String filePath) {
    File f = new File(filePath);
    return f.toURI();
  }

  public XSLTCoverageTraceListener() {
    System.out.println("****************************************");
  }

  /**
   * Method called at the start of execution, that is, when the run-time transformation starts
   * @param c Controller used
   */

  public void open(Controller c) {
    System.out.println("controller="+c);

    openCount++;
    if (openCount >= 2) {
      // Re-entered. Maybe by transform().
      return;
    }

    // Get the URI of XSpec home
    URI xspecHomeUri;
    String xspecHomeUriProp = System.getProperty("xspec.home.uri");
    if (xspecHomeUriProp == null) {
      String xspecHomeProp = System.getProperty("xspec.home");
      debugPrintf("%-17s: %s%n", "xspec.home", xspecHomeProp);

      xspecHomeUri = filePathToUri(xspecHomeProp + File.separator);
    }
    else {
      debugPrintf("%-17s: %s%n", "xspec.home.uri", xspecHomeUriProp);
      try {
        xspecHomeUri = new URI(xspecHomeUriProp);
      } catch (URISyntaxException e) {
        throw new RuntimeException(e);
      }
    }
    debugPrintf("%-17s: %s%n", "xspecHomeUri", xspecHomeUri);

    // Get 'src/' URI and normalize it
    try {
        // Use net.sf.saxon.functions.ResolveURI#makeAbsolute, because
        // java.net.URI#resolve cannot handle "jar:" scheme.
        srcDir = ResolveURI.makeAbsolute("src/", xspecHomeUri.toString()).normalize().toString();
    } catch (URISyntaxException e) {
        throw new RuntimeException(e);
    }
    debugPrintf("%-17s: %s%n", "srcDir", srcDir);

    // Get the directory path to ignore
    ignoreDir = System.getProperty("xspec.coverage.ignore");
    debugPrintf("%-17s: %s%n", "ignoreDir (raw)", ignoreDir);

    // Normalize the directory as URI
    ignoreDir = filePathToUri(ignoreDir + File.separator).normalize().toString();
    debugPrintf("%-17s: %s%n", "ignoreDir (norm)", ignoreDir);

    // Coverage XML file
    String outPath = System.getProperty("xspec.coverage.xml");
    File outFile = new File(outPath);

    // XSpec file
    String xspecPath = System.getProperty("xspec.xspecfile");
    xspecPath = filePathToUri(xspecPath).toString();

    Serializer serializer = new Processor(false).newSerializer(outFile);
    serializer.setOutputProperty(Serializer.Property.INDENT, "yes");

    try {
      writer = serializer.getXMLStreamWriter();
    } catch(SaxonApiException e) {
      throw new RuntimeException(e);
    }

    try {
      writer.writeStartDocument();
      writer.writeStartElement("trace");
      writer.writeAttribute("xspec", xspecPath);
    } catch(XMLStreamException e) {
      throw new RuntimeException(e);
    }
  }

  /**  
   * Method that implements the output destination for SaxonEE/PE 9.7
   */
  public void setOutputDestination(Logger logger) {
  }

  /**
  * Method called at the end of execution, that is, when the run-time execution ends
  */
  public void close() {
    openCount--;
    if (openCount >= 1) {
      return;
    }

    try {
      writer.writeEndElement(); // </trace>
      writer.writeEndDocument();
      writer.close();
    } catch(XMLStreamException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * Method that is called when an instruction in the stylesheet gets processed.
   * @param info Instruction gives information about the instruction being
   * executed, and about the context in which it is executed. This object is mutable,
   * so if information from the InstructionInfo is to be retained, it must be copied.
   * @param context XPath context used
   */

  public void enter(InstructionInfo info, XPathContext context) {
    int lineNumber = info.getLineNumber();

    // Get the current file URI
    String systemId = info.getSystemId();
    debugPrintf("%-17s: %s:%d%n", "enter()", systemId, lineNumber);

    // Normalize the current file URI
    URI systemIdUri;
    try {
      systemIdUri = new URI(systemId);
    } catch (URISyntaxException e) {
      throw new RuntimeException(e);
    }
    systemId = systemIdUri.normalize().toString();
    debugPrintf("%-17s: %s%n", "systemId (norm)", systemId);
    
    boolean isUtil = false;

    if (systemId.startsWith(srcDir)) {
      isUtil = true;

      if (!utils.containsKey(systemId)) {
        Integer utilId = new Integer(utilsCount);
        debugPrintf(
          "%-17s: %s%n",
          "util[" + utilId + "]",
          systemId
        );

        utilsCount++;
        utils.put(systemId, utilId);

        try {
          writer.writeStartElement("u");
          writer.writeAttribute("id", String.valueOf(utilId));
          writer.writeAttribute("u", systemId);
          writer.writeEndElement();
        } catch(XMLStreamException e) {
          throw new RuntimeException(e);
        }
      }
    } else if (xspecStylesheet == null && 
               systemId.startsWith(ignoreDir)) {
      xspecStylesheet = systemId;
      debugPrintf("%-17s: %s%n", "xspecStylesheet", xspecStylesheet);

      try {
        writer.writeStartElement("x");
        writer.writeAttribute("u", systemId);
        writer.writeEndElement();
      } catch(XMLStreamException e) {
        throw new RuntimeException(e);
      }
    } 

    if (systemId != xspecStylesheet && !isUtil) {
      Integer module;
      if (modules.containsKey(systemId)) {
        module = (Integer)modules.get(systemId);
      } else {
        module = new Integer(moduleCount);
        moduleCount += 1;
        modules.put(systemId, module);

        try {
          writer.writeStartElement("m");
          writer.writeAttribute("id", String.valueOf(module));
          writer.writeAttribute("u", systemId);
          writer.writeEndElement();
        } catch(XMLStreamException e) {
          throw new RuntimeException(e);
        }
      }

      int constructType = info.getConstructType();

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

        try {
          writer.writeStartElement("c");
          writer.writeAttribute("id", String.valueOf(constructType));
          writer.writeAttribute("n", construct);
          writer.writeEndElement();
        } catch(XMLStreamException e) {
          throw new RuntimeException(e);
        }
      }

      try {
        writer.writeStartElement("h");
        writer.writeAttribute("l", String.valueOf(lineNumber));
        writer.writeAttribute("m", String.valueOf(module));
        writer.writeAttribute("c", String.valueOf(constructType));
        writer.writeEndElement();
      } catch(XMLStreamException e) {
        throw new RuntimeException(e);
      }
    }
  }

  /**
   * Method that is called after processing an instruction of the stylesheet,
   * that is, after any child instructions have been processed.
   * @param instruction gives the same information that was supplied to the
   * enter method, though it is not necessarily the same object. Note that the
   * line number of the instruction is that of the start tag in the source stylesheet,
   * not the line number of the end tag.
   */

  public void leave(InstructionInfo instruction) {
    // Do nothing
  }

  /**
   * Method that is called by an instruction that changes the current item
   * in the source document: that is, xsl:for-each, xsl:apply-templates, xsl:for-each-group.
   * The method is called after the enter method for the relevant instruction, and is called
   * once for each item processed.
   * @param currentItem the new current item. Item objects are not mutable; it is safe to retain
   * a reference to the Item for later use.
   */

  public void startCurrentItem(Item currentItem) {
    // Do nothing
  }

  /**
   * Method that is called when an instruction has finished processing a new current item
   * and is ready to select a new current item or revert to the previous current item.
   * The method will be called before the leave() method for the instruction that made this
   * item current.
   * @param currentItem the item that was current, whose processing is now complete. This will represent
   * the same underlying item as the corresponding startCurrentItem() call, though it will
   * not necessarily be the same actual object.
   */

  public void endCurrentItem(Item currentItem) {
    // Do nothing
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
