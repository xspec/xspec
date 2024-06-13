# XSLT Element Code Coverage

## Categories

The following list describes the categories used in code coverage. These categories are actually CSS class names used on span elements that enclose each node in the coverage report output.

- Hit - the node was executed
- Missed - the node was not executed
- Ignored - the node is a declaration and no trace information is provided. Without extensive work in XSpec to parse the stylesheet it is not possible to determine if these declarations are used
- Unknown - no trace information is provided about the node when it is executed so it cannot be determined if the node was executed
- Comment - this is a comment node (determined by the stylesheet analysis and not the trace output)
- Whitespace - this is a whitespace only text node (determined by the stylesheet analysis and not the trace output)

## Element Table Details

Each element section contains a table with the following columns. The first 4 provide information about the element based on the XSLT specification.

- CATEGORY - the type of element. Either Declaration, Instruction or blank.
- PARENT - list of permitted parent elements
- CHILDREN - list of permitted child elements
- CONTENT - whether the element has no content
- TRACE - whether the element is traced in the XSpec trace file
- RULE - the name of the coverage rule, or a specific rule for the element

## Rules

The following list describes the rules used to determine the category of each node in the stylesheet.

- Always Ignore - this is mainly for Declaration elements where Saxon does not produce trace output. This is always marked as 'ignored'
- Use Trace Data - if the trace data has a "hit" element the coverage report marks this as a 'hit', otherwise it marks it as 'missed'
- Use Parent Data - the element is not traced in the XSpec trace file, but if it has been executed then its parent is traced. If the parent is a 'hit' then this node is marked as a 'hit' otherwise it is marked as 'missed'
- Use Child Data - the element is not traced in the XSpec trace file, but if it has been executed then any children are traced. If there are no children it's not possible to decide if it was executed so mark as 'unknown'. If a child is traced then this node is marked as a 'hit' otherwise it is marked as 'missed'. NOTE: the fact that xsl:sequence is not traced may mean this produces the wrong result
- None - these elements aren't supported by XSpec code coverage
- TBD -
- Element Specific - the element does not fit into any of the other rules and has its own rule description

## xsl:accept

|          |                 |
| -------- | --------------- |
| CATEGORY |                 |
| PARENT   | xsl:use-package |
| CHILDREN |                 |
| CONTENT  | None            |
| TRACE    |                 |
| RULE     | None            |

#### Comment

Package related.

## xsl:accumulator

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN | xsl:accumulator-rule                       |
| CONTENT  |                                            |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:accumulator-rule

|          |                                                       |
| -------- | ----------------------------------------------------- |
| CATEGORY |                                                       |
| PARENT   | xsl:accumulator                                       |
| CHILDREN |                                                       |
| CONTENT  |                                                       |
| TRACE    | No                                                    |
| RULE     | Element Specific - always ignore, and any descendants |

#### Comment

Sequence constructor of xsl:accumulator-rule is not traced so any descendants need to be ignored.

## xsl:analyze-string

|          |                                                                  |
| -------- | ---------------------------------------------------------------- |
| CATEGORY | Instruction                                                      |
| PARENT   |                                                                  |
| CHILDREN | xsl:fallback, xsl:matching-substring, xsl:non-matching-substring |
| CONTENT  |                                                                  |
| TRACE    | Yes                                                              |
| RULE     | Use Trace Data                                                   |

## xsl:apply-imports

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN | xsl:with-param |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:apply-templates

|          |                          |
| -------- | ------------------------ |
| CATEGORY | Instruction              |
| PARENT   |                          |
| CHILDREN | xsl:with-param, xsl:sort |
| CONTENT  |                          |
| TRACE    | Yes                      |
| RULE     | Use Trace Data           |

## xsl:array

|          |             |
| -------- | ----------- |
| CATEGORY | Instruction |
| PARENT   |             |
| CHILDREN |             |
| CONTENT  |             |
| TRACE    |             |
| RULE     | TBD         |

#### Comment

XSLT 4.0 proposal.

## xsl:array-member

|          |             |
| -------- | ----------- |
| CATEGORY | Instruction |
| PARENT   |             |
| CHILDREN |             |
| CONTENT  |             |
| TRACE    |             |
| RULE     | TBD         |

#### Comment

XSLT 4.0 proposal.

## xsl:assert

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

## xsl:attribute

|          |                                                                                                                                                                                            |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| CATEGORY | Instruction                                                                                                                                                                                |
| PARENT   |                                                                                                                                                                                            |
| CHILDREN |                                                                                                                                                                                            |
| CONTENT  |                                                                                                                                                                                            |
| TRACE    | Sometimes                                                                                                                                                                                  |
| RULE     | Element Specific - mark as 'ignored' if parent is xsl:attribute-set (xsl:attribute-set will be ignored). For other cases Use Trace Data i.e. mark as 'hit' or 'missed' based on trace data |

#### Comment

No trace when in xsl:attribute-set.

## xsl:attribute-set

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN | xsl:attribute                              |
| CONTENT  |                                            |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:break

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

#### Comment

Tested as part of xsl:iterate.

## xsl:call-template

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN | xsl:with-param |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:catch

|          |                |
| -------- | -------------- |
| CATEGORY |                |
| PARENT   | xsl:try        |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

#### Comment

Tested as part of xsl:try.

Children are hit if the xsl:catch is executed and there are children.

If xsl:catch has a select attribute we don't know if it was executed.

## xsl:character-map

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN | xsl:output-character                       |
| CONTENT  |                                            |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:choose

|          |                         |
| -------- | ----------------------- |
| CATEGORY | Instruction             |
| PARENT   |                         |
| CHILDREN | xsl:otherwise, xsl:when |
| CONTENT  |                         |
| TRACE    | Yes                     |
| RULE     | Use Trace Data          |

## xsl:comment

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:context-item

|          |               |
| -------- | ------------- |
| CATEGORY |               |
| PARENT   | xsl:template  |
| CHILDREN |               |
| CONTENT  | None          |
| TRACE    | No            |
| RULE     | Always Ignore |

#### Comment

Although it doesn't have a category it seems more like a declaration than an instruction, so ignore.

## xsl:copy

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:copy-of

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  | None           |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:decimal-format

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:document

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:element

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:evaluate

|          |                              |
| -------- | ---------------------------- |
| CATEGORY | Instruction                  |
| PARENT   |                              |
| CHILDREN | xsl:fallback, xsl:with-param |
| CONTENT  |                              |
| TRACE    | Column number 0              |
| RULE     | Element Specific - TBD       |

#### Comment

Column 0 in xspec and Saxon trace.

There is an option of accepting the trace output for now and saying if the node is xsl:evaluate then check column number 0 (the chance of 2 xsl:evaluate elements on the same line is low).

## xsl:expose

|          |             |
| -------- | ----------- |
| CATEGORY |             |
| PARENT   | xsl:package |
| CHILDREN |             |
| CONTENT  | None        |
| TRACE    |             |
| RULE     | None        |

#### Comment

Package related.

## xsl:fallback

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

## xsl:for-each

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:for-each-group

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:fork

|          |                                                |
| -------- | ---------------------------------------------- |
| CATEGORY | Instruction                                    |
| PARENT   |                                                |
| CHILDREN | xsl:fallback, xsl:for-each-group, xsl:sequence |
| CONTENT  |                                                |
| TRACE    |                                                |
| RULE     | TBD                                            |

#### Comment

Only sensible when Streaming, so needs to be investigated using Saxon-EE.

## xsl:function

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  |                                            |
| TRACE    | Yes                                        |
| RULE     | Use Trace Data                             |

#### Comment

Although this is a Declaration it is included in trace output.

## xsl:global-context-item

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:if

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

#### Comment

Note that xsl:if is traced irrespective of the result.

## xsl:import

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:import-schema

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  |                                            |
| TRACE    |                                            |
| RULE     | Always Ignore                              |

#### Comment

Requires Saxon-EE.

## xsl:include

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:item-type

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    |                                            |
| RULE     | TBD                                        |

#### Comment

XSLT 4.0 proposal.

## xsl:iterate

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:key

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  |                                            |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:map

|          |                        |
| -------- | ---------------------- |
| CATEGORY | Instruction            |
| PARENT   |                        |
| CHILDREN |                        |
| CONTENT  |                        |
| TRACE    | No                     |
| RULE     | Element Specific - TBD |

#### Comment

Difficult to know what to do here as it is never traced. Neither is xsl:map-entry.

Inclined to say unknown and add a comment on the Code Coverage page.

## xsl:map-entry

|          |                        |
| -------- | ---------------------- |
| CATEGORY | Instruction            |
| PARENT   |                        |
| CHILDREN |                        |
| CONTENT  |                        |
| TRACE    | No                     |
| RULE     | Element Specific - TBD |

#### Comment

Tested as part of xsl:map.

There is a trace entry for 1 xsl:map-entry element on line 13, column 0 in xsl-map-01.xsl but that seems to be related to the xsl:param and not xsl:map-entry.

Difficult to know what to do here as it is never traced. Neither is xsl:map.

Inclined to say unknown and add a comment on the Code Coverage page.

## xsl:matching-substring

|          |                    |
| -------- | ------------------ |
| CATEGORY |                    |
| PARENT   | xsl:analyze-string |
| CHILDREN |                    |
| CONTENT  |                    |
| TRACE    | No                 |
| RULE     | Use Child Data     |

#### Comment

Tested as part of xsl:analyze-string.

## xsl:merge

|          |                                                  |
| -------- | ------------------------------------------------ |
| CATEGORY | Instruction                                      |
| PARENT   |                                                  |
| CHILDREN | xsl:fallback, xsl:merge-action, xsl:merge-source |
| CONTENT  |                                                  |
| TRACE    | Yes                                              |
| RULE     | Use Trace Data                                   |

#### Comment

None of the xsl:merge children are traced.

I don't know if it is safe to say if xsl:merge is hit then all the xsl:merge children are hit as well.

There is a problem that the sequence constructor in xsl:merge-key is not traced even though it is executed (can we say that is hit if xsl:merge is hit?).

The sequence constructor in xsl:merge-action is traced. If this is traced can the xsl:merge elements be marked as hit?

## xsl:merge-action

|          |                |
| -------- | -------------- |
| CATEGORY |                |
| PARENT   | xsl:merge      |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

#### Comment

Tested as part of xsl:merge.

The sequence constructor in xsl:merge-action is traced.

See comment on xsl:merge.

## xsl:merge-key

|          |                        |
| -------- | ---------------------- |
| CATEGORY |                        |
| PARENT   | xsl:merge-source       |
| CHILDREN |                        |
| CONTENT  |                        |
| TRACE    | No                     |
| RULE     | Element Specific - TBD |

#### Comment

Tested as part of xsl:merge.

See comment on xsl:merge.

## xsl:merge-source

|          |                        |
| -------- | ---------------------- |
| CATEGORY |                        |
| PARENT   | xsl:merge              |
| CHILDREN | xsl:merge-key          |
| CONTENT  |                        |
| TRACE    | No                     |
| RULE     | Element Specific - TBD |

#### Comment

Tested as part of xsl:merge.

See comment on xsl:merge.

## xsl:message

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:mode

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:namespace

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:namespace-alias

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:next-iteration

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN | xsl:with-param |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

#### Comment

Tested as part of xsl:iterate.

## xsl:next-match

|          |                              |
| -------- | ---------------------------- |
| CATEGORY | Instruction                  |
| PARENT   |                              |
| CHILDREN | xsl:fallback, xsl:with-param |
| CONTENT  |                              |
| TRACE    | Yes                          |
| RULE     | Use Trace Data               |

## xsl:non-matching-substring

|          |                    |
| -------- | ------------------ |
| CATEGORY |                    |
| PARENT   | xsl:analyze-string |
| CHILDREN |                    |
| CONTENT  |                    |
| TRACE    | No                 |
| RULE     | Use Child Data     |

#### Comment

Tested as part of xsl:analyze-string.

## xsl:number

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  | None           |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:on-completion

|          |                |
| -------- | -------------- |
| CATEGORY |                |
| PARENT   | xsl:iterate    |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

#### Comment

Tested as part of xsl:iterate.

## xsl:on-empty

|          |                        |
| -------- | ---------------------- |
| CATEGORY | Instruction            |
| PARENT   |                        |
| CHILDREN |                        |
| CONTENT  |                        |
| TRACE    | No                     |
| RULE     | Element Specific - TBD |

#### Comment

With the select attribute there is column 0 in xpsec trace.

With a sequence constructor the children are traced but not the xsl:on-empty element.

May change in the next release of Saxon due to this issue: https://saxonica.plan.io/issues/6428

## xsl:on-non-empty

|          |                        |
| -------- | ---------------------- |
| CATEGORY | Instruction            |
| PARENT   |                        |
| CHILDREN |                        |
| CONTENT  |                        |
| TRACE    | Partly                 |
| RULE     | Element Specific - TBD |

#### Comment

Column 0 in xspec trace. Not in Saxon trace.

There is a Saxonica issue (https://saxonica.plan.io/issues/6428) that it outputs the contents of xsl:on-non-empty when the parent is actually empty if tracing is enabled.

Suggest it is marked as 'unknown' including the children until theSaxon issue is fixed.

## xsl:otherwise

|          |                |
| -------- | -------------- |
| CATEGORY |                |
| PARENT   | xsl:choose     |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

#### Comment

Tested as part of xsl:choose.

## xsl:output

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:output-character

|          |                   |
| -------- | ----------------- |
| CATEGORY |                   |
| PARENT   | xsl:character-map |
| CHILDREN |                   |
| CONTENT  | None              |
| TRACE    | No                |
| RULE     | Always Ignore     |

#### Comment

Tested as part of xsl:character-map.

## xsl:override

|          |                                                                        |
| -------- | ---------------------------------------------------------------------- |
| CATEGORY |                                                                        |
| PARENT   | xsl:use-package                                                        |
| CHILDREN | xsl:attribute-set, xsl:function, xsl:param, xsl:template, xsl:variable |
| CONTENT  |                                                                        |
| TRACE    |                                                                        |
| RULE     | None                                                                   |

#### Comment

Package related.

## xsl:package

|          |      |
| -------- | ---- |
| CATEGORY |      |
| PARENT   |      |
| CHILDREN |      |
| CONTENT  |      |
| TRACE    |      |
| RULE     | None |

#### Comment

Package related.

## xsl:param

|          |                                                                                                   |
| -------- | ------------------------------------------------------------------------------------------------- |
| CATEGORY | Declaration                                                                                       |
| PARENT   | xsl:function, xsl:iterate, xsl:override, xsl:package, xsl:stylesheet, xsl:template, xsl:transform |
| CHILDREN |                                                                                                   |
| CONTENT  |                                                                                                   |
| TRACE    | Sometimes                                                                                         |
| RULE     | Element Specific - TBD                                                                            |

#### Comment

**_Trace Details_**

Global xsl:param - traced including all children.

xsl:iterate xsl:param - not traced. Note: sequence constructor elements NOT traced either.

xsl:function xsl:param - not traced (no default value allowed).

xsl:template xsl:param with no default value - valid trace.

xsl:template xsl:param with select attribute - trace with column 0.

xsl:template xsl:param with sequence constructor - trace on first sequence constructor element.

xsl:template xsl:param with sequence constructor, and default value used then sequence constructor elements traced.

xsl:template xsl:param with sequence constructor, and value supplied by xsl:with-param then sequence constructor elements NOT traced (but xsl:param trace is on first element).

**_Rule Details_**

Global xsl:param can just use the Trace Data with no additional rules.

xsl:function xsl:param can use the state of the parent xsl:function element.

xsl:iterate xsl:param can use the state of the parent xsl:iterate element. And if it is 'hit' then that state needs to be set on all descendants of the xsl:param element.

xsl:template xsl:param trace causes confusion because it can cause the first sequence constructor element to appear to be hit. Suggest ignoring the trace data related to xsl:param in a template and rely on xsl:template state.

**_BUT_** also need to stop the first sequence constructor element using the xsl:param trace to record a 'hit'. Is the easiest approach to not output the hit element in the TraceListener in this case? The other approach is for all elements to check if the trace is for UQName eq 'param' and if so ignore it.

## xsl:perform-sort

|          |                        |
| -------- | ---------------------- |
| CATEGORY | Instruction            |
| PARENT   |                        |
| CHILDREN |                        |
| CONTENT  |                        |
| TRACE    | Partly                 |
| RULE     | Element Specific - TBD |

#### Comment

With a select attribute the column number is 4 in the trace output.

With a sequence constructor children are traced, excluding xsl:sort. If the only child is xsl:sort, cannot determine if it was executed.

## xsl:preserve-space

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:processing-instruction

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:result-document

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:sequence

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

#### Comment

Outstanding Saxon issue regarding tracing: https://saxonica.plan.io/issues/6295

With a select attribute there is no trace information.

With a sequence constructor children are traced if they are executed.

## xsl:sort

|          |                                                                         |
| -------- | ----------------------------------------------------------------------- |
| CATEGORY |                                                                         |
| PARENT   | xsl:apply-templates, xsl:for-each, xsl:for-each-group, xsl:perform-sort |
| CHILDREN |                                                                         |
| CONTENT  |                                                                         |
| TRACE    | No                                                                      |
| RULE     | Element Specific - TBD                                                  |

#### Comment

When child of xls:apply-templates, xsl:for-each and xsl:for-each-group could mark xsl:sort as 'hit' if these parents are traced.

When child of xsl:perform-sort there is no easy way of determining if it was executed unless checking if its siblings are traced.

When using a sequence constructor with xsl:sort the children are not traced.

## xsl:source-document

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:strip-space

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN |                                            |
| CONTENT  | None                                       |
| TRACE    | No                                         |
| RULE     | Always Ignore                              |

## xsl:stylesheet

|          |               |
| -------- | ------------- |
| CATEGORY |               |
| PARENT   |               |
| CHILDREN |               |
| CONTENT  |               |
| TRACE    | No            |
| RULE     | Always Ignore |

#### Comment

Should this be marked as 'hit'? It isn't traced but it has to be executed.

## xsl:switch

|          |                                       |
| -------- | ------------------------------------- |
| CATEGORY | Instruction                           |
| PARENT   |                                       |
| CHILDREN | xsl:fallback, xsl:otherwise, xsl:when |
| CONTENT  |                                       |
| TRACE    |                                       |
| RULE     | TBD                                   |

#### Comment

XSLT 4.0 proposal.

## xsl:template

|          |                                                          |
| -------- | -------------------------------------------------------- |
| CATEGORY | Declaration                                              |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform, xsl:override |
| CHILDREN |                                                          |
| CONTENT  |                                                          |
| TRACE    | Yes                                                      |
| RULE     | Use Trace Data                                           |

#### Comment

Although this is a Declaration it is included in trace output.

## xsl:text

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:transform

|          |               |
| -------- | ------------- |
| CATEGORY |               |
| PARENT   |               |
| CHILDREN |               |
| CONTENT  |               |
| TRACE    | No            |
| RULE     | Always Ignore |

#### Comment

Should this be marked as 'hit'? It isn't traced but it has to be executed.

## xsl:try

|          |                        |
| -------- | ---------------------- |
| CATEGORY | Instruction            |
| PARENT   |                        |
| CHILDREN |                        |
| CONTENT  |                        |
| TRACE    | Partly                 |
| RULE     | Element Specific - TBD |

#### Comment

With a select attribute it is traced but the column number is wrong (7 and 0 occur in the xsl-try-01.xsl trace output). In all cases the class is net.sf.saxon.expr.TryCatch.

With a sequence constructor xsl:try is not traced, but the first child is traced and has a class of net.sf.saxon.expr.TryCatch (the first child may also be traced in its own right as well). Other children are traced.

## xsl:use-package

|          |                                            |
| -------- | ------------------------------------------ |
| CATEGORY | Declaration                                |
| PARENT   | xsl:package, xsl:stylesheet, xsl:transform |
| CHILDREN | xsl:accept, xsl:override                   |
| CONTENT  |                                            |
| TRACE    |                                            |
| RULE     | None                                       |

#### Comment

Package related.

## xsl:value-of

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | Yes            |
| RULE     | Use Trace Data |

## xsl:variable

|          |                         |
| -------- | ----------------------- |
| CATEGORY | declaration/instruction |
| PARENT   |                         |
| CHILDREN |                         |
| CONTENT  |                         |
| TRACE    | Sometimes               |
| RULE     | Element Specific - TBD  |

#### Comment

Note: optimization settings affect the tracing.

There is a Saxonica issue (https://saxonica.plan.io/issues/6415) around xsl:variable.

Global variables seem ok and could be done as Use Trace Data.

With Non-global variables it is difficult to assess and the best approach is probably to rely on the Saxon results.

## xsl:when

|          |                |
| -------- | -------------- |
| CATEGORY |                |
| PARENT   | xsl:choose     |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

#### Comment

Tested as part of xsl:choose.

Any children are traced.

## xsl:where-populated

|          |                |
| -------- | -------------- |
| CATEGORY | Instruction    |
| PARENT   |                |
| CHILDREN |                |
| CONTENT  |                |
| TRACE    | No             |
| RULE     | Use Child Data |

#### Comment

Note: The test shows the child of xsl:where-populated hit even if it does nothing.

## xsl:with-param

|          |                                                                                                             |
| -------- | ----------------------------------------------------------------------------------------------------------- |
| CATEGORY |                                                                                                             |
| PARENT   | xsl:apply-imports, xsl:apply-templates, xsl:call-template, xsl:evaluate, xsl:next-iteration, xsl:next-match |
| CHILDREN |                                                                                                             |
| CONTENT  |                                                                                                             |
| TRACE    | Sometimes                                                                                                   |
| RULE     | Use Parent Data                                                                                             |

#### Comment

Traced when a child of xls:apply-templates, xsl:call-template.

Not traced when a child of xsl:apply-imports, xsl:evaluate, xsl:next-iteration, xsl:next-match.

Suggest it is always marked as a 'hit' if the parent is traced.
