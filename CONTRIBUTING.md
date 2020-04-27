# Contributing to XSpec

:+1::tada: Thanks for taking the time to contribute! :tada::+1:

# How to contribute

- [Report an issue](https://github.com/xspec/xspec/issues/new): whether you find a bug in XSpec or have a feature request, raise an issue to let us know. Please submit code examples to reproduce a bug and read the [wiki](https://github.com/xspec/xspec/wiki) to check how XSpec is supposed to work.  
- [Raise a pull request](https://github.com/xspec/xspec/pulls): all code changes in XSpec are initiated via pull requests towards the `master` branch and are usually reviewed by a maintainer or another contributor before merging. Your pull request will be automatically scanned by our CI systems so you may want to [run the test suite locally](https://github.com/xspec/xspec/wiki/How-to-Run-the-Test-Suite-Locally) to avoid surprises. If possible, add a test when submitting a bug fix or a new feature and consider writing some documentation in the pull request which could be later added to the wiki. Before implementing a large feature or fix, consider discussing it first with the maintainers via an issue, this usually speeds up the review process and avoids disappointment. 
- [Improve the documentation](https://github.com/xspec/xspec/wiki): if you notice a gap in the documentation on the [wiki](https://github.com/xspec/xspec/wiki), raise an issue or discuss it within an existing issue or pull request. Changes in the wiki can only be made by maintainers and contributors with write permissions. 

All contributions are submitted under the [MIT License](https://github.com/xspec/xspec/blob/master/LICENSE).

# Code Conventions 

## Git commit messages

We use [Commit Lint](https://www.commit-lint.com) to enforce conventions in commit messages and pull requests and we follow the [Angular Coding Conventions](https://www.commit-lint.com/conventions). If you raise a pull request without using one of the valid prefixes for type in your last commit, the automatic checks in the pull request will report an error.

These are the valid prefixes for type (see also [the Angular documentation](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#type)):

| Type | Description |
| --- | --- |
| `feat` | New feature or enhancement | 
| `fix` | Bug fix | 
| `test` | Test | 
| `ci` | CI configuration (Travis, Azure Pipelines, AppVeyor) | 
| `docs` | Documentation | 
| `perf` | Performance improvement | 
| `refactor` | Refactoring improvement (no new feature or bug fix) | 
| `style` | Style change (white-space, formatting, etc.) | 
| `build` | Build and release changes | 

You are also encouraged to use a scope to highlight which functionality is affected by your change:  

| Scope | Description |
| --- | --- |
| `xslt` | XSLT | 
| `xquery` | XQuery | 
| `schematron` | Schematron | 
| `oxygen` | Oxygen | 
| `basex` | BaseX | 
| `deps` | Dependencies | 
| `report` | Test result reports | 
| `xproc` | XProc | 
| `schema` | Schema for .xspec files | 
| `maven` | Maven |

Note that type is mandatory and scope is optional and both values should be written in lower case.
 
Here are some examples of valid commit message with type and scope:

```
feat(xslt): add XSLT code coverage transformation scenario
fix(schematron): remove scenario
fix: invalid col element in result HTML
test(xslt): add test for mode="#all"
ci: run tests with XML Calabash 1.1.30 
docs: document code coverage
build: increment pom.xml
```
