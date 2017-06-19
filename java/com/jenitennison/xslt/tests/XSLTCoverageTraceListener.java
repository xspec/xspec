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
import net.sf.saxon.om.Item;
import net.sf.saxon.om.StandardNames;
import java.lang.String;
import java.util.HashMap;
import java.util.HashSet;
import java.io.PrintStream;
import net.sf.saxon.lib.Logger;

/**
 * A Simple trace listener for XSLT that writes messages (by default) to System.err
 */

public class XSLTCoverageTraceListener implements TraceListener {

  private PrintStream out = System.err;
  private String xspecStylesheet = null;
  private String utilsStylesheet = null;
  private HashMap<String, Integer> modules = new HashMap<String, Integer>();
  private HashSet<Integer> constructs = new HashSet<Integer>();
  private int moduleCount = 0;
  
  public XSLTCoverageTraceListener() {
	System.out.println("****************************************");
  }

  /**
  * Method called at the start of execution, that is, when the run-time transformation starts
  */

  public void open(Controller c) {
    out.println("<trace>");
	System.out.println("controller="+c);
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
    out.println("</trace>");
  }

  /**
   * Method that is called when an instruction in the stylesheet gets processed.
   * @param instruction gives information about the instruction being
   * executed, and about the context in which it is executed. This object is mutable,
   * so if information from the InstructionInfo is to be retained, it must be copied.
   */

  public void enter(InstructionInfo info, XPathContext context) {
    int lineNumber = info.getLineNumber();
    String systemId = info.getSystemId();
    int constructType = info.getConstructType();
    if (utilsStylesheet == null &&
        systemId.indexOf("generate-tests-utils.xsl") != -1) {
      utilsStylesheet = systemId;
      out.println("<u u=\"" + systemId + "\" />");
    } else if (xspecStylesheet == null && 
               systemId.indexOf("/xspec/") != -1) {
      xspecStylesheet = systemId;
      out.println("<x u=\"" + systemId + "\" />");
    } 
    if (systemId != xspecStylesheet && systemId != utilsStylesheet) {
      Integer module;
      if (modules.containsKey(systemId)) {
        module = (Integer)modules.get(systemId);
      } else {
        module = new Integer(moduleCount);
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
