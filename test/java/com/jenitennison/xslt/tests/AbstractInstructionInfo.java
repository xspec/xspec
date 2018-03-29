/** *********************************************************************** */
/*  File:       AbstractInstructionInfo.java                                */
/*  Author:     Christophe Marchand                                         */
/*  URI:        https://github.com/expath/xspec/                            */
/*  Tags:                                                                   */
/*  Copyright (c) 2008-2018 (see end of file.)                              */
/* ------------------------------------------------------------------------ */
package com.jenitennison.xslt.tests;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import net.sf.saxon.expr.parser.Location;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trace.InstructionInfo;

/**
 * Provides a default implementation for InstructionInfo, to simplify tests.
 * @author cmarchand
 */
public abstract class AbstractInstructionInfo implements InstructionInfo {

    @Override
    public int getConstructType() {
        return 1;
    }

    @Override
    public StructuredQName getObjectName() {
        return null;
    }

    @Override
    public Object getProperty(String string) {
        return null;
    }

    @Override
    public Iterator<String> getProperties() {
        List<String> props = new LinkedList<>();
        return props.iterator();
    }

    @Override
    public String getSystemId() {
        return null;
    }

    @Override
    public String getPublicId() {
        return null;
    }

    @Override
    public int getLineNumber() {
        return -1;
    }

    @Override
    public int getColumnNumber() {
        return -1;
    }

    @Override
    public Location saveLocation() {
        return null;
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
