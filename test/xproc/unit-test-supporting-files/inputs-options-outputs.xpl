<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
    xmlns:s="x-urn:test:xproc:inputs-options-outputs"
    name="inputs-options-outputs" type="s:inputs-options-outputs" version="3.1">
    <p:input port="in1" primary="true"/>
    <p:input port="in2"/>
    <p:input port="in3"/>
    <p:output port="out1" pipe="@identity-in1" primary="true"/>
    <p:output port="out2" pipe="@identity-in2"/>
    <p:option name="s:opt1"/>
    <p:option name="Q{x-urn:test:xproc:inputs-options-outputs}opt2"/>
    <p:identity name="identity-in1"/>
    <p:identity name="identity-in2">
        <p:with-input>
            <p:pipe port="in2" step="inputs-options-outputs"/>
        </p:with-input>
    </p:identity>
    <p:identity name="identity-in3">
        <p:with-input>
            <p:pipe port="in3" step="inputs-options-outputs"/>
        </p:with-input>
    </p:identity>
</p:declare-step>