[![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/github/xspec/xspec?branch=master&svg=true "AppVeyor Build Status")](https://ci.appveyor.com/project/xspec/xspec/branch/master)
[![Azure Pipelines Build Status](https://dev.azure.com/xspec/xspec/_apis/build/status/xspec.xspec?branchName=master)](https://dev.azure.com/xspec/xspec/_build/latest?definitionId=1&branchName=master)
[![GitHub Actions Test Workflow Status](https://github.com/xspec/xspec/workflows/Test/badge.svg?branch=master&event=push)](https://github.com/xspec/xspec/actions?query=branch%3Amaster+event%3Apush+workflow%3ATest)
[![GitHub Actions Lint Workflow Status](https://github.com/xspec/xspec/workflows/Lint/badge.svg?branch=master&event=push)](https://github.com/xspec/xspec/actions?query=branch%3Amaster+event%3Apush+workflow%3ALint)

## XSpec [![Release](https://img.shields.io/github/v/release/xspec/xspec.svg)](https://github.com/xspec/xspec/releases/latest)

XSpec is a unit test and [behaviour-driven development](https://en.wikipedia.org/wiki/Behavior_Driven_Development) (BDD) framework for XSLT, XQuery, and Schematron. It is based on the Spec framework of [RSpec](https://rspec.info/), which is a BDD framework for Ruby.

XSpec consists of a syntax for describing the behaviour of XSLT, XQuery, or Schematron code, and some code that enables you to test the code against those descriptions.

## Getting Started

To get started, check out the installation instructions for [macOS/Linux](https://github.com/xspec/xspec/wiki/Installation-on-Mac-and-Linux) and [Windows](https://github.com/xspec/xspec/wiki/Installation-on-Windows) and how to [write your first XSpec test](https://github.com/xspec/xspec/wiki/Getting-Started).

## Support

Check out the XSpec documentation in the [wiki](https://github.com/xspec/xspec/wiki) before raising an issue or asking a question. If you have any question that is not answered in the wiki, feel free to [raise an issue](https://github.com/xspec/xspec/issues). For historical searches, the unmonitored [XSpec discussion list](https://groups.google.com/d/forum/xspec-users) might also be useful.

## Contribute

XSpec is an open source project originally written by [Jeni Tennison](https://github.com/JeniT). It was maintained in the past years by [Florent Georges](https://github.com/fgeorges). Active development of XSpec restarted in 2016 and the project is currently maintained by [AirQuick](https://github.com/AirQuick), [Amanda Galtman](https://github.com/galtm) (technical development) and [Sandro Cirulli](https://github.com/cirulls) (management and community) with the help of the XSpec community.

If you wish to contribute to XSpec, please read the [contributing guidelines](https://github.com/xspec/xspec/blob/master/CONTRIBUTING.md) and then [raise or pick up an issue](https://github.com/xspec/xspec/issues) and [send us your pull requests](https://github.com/xspec/xspec/pulls). Please document any issue with examples of your XSpec code.

## License

XSpec code is released under the [MIT License](LICENSE). [Few parts of the codebase](https://github.com/xspec/xspec/blob/master/java/com/jenitennison/xslt/tests/XSLTCoverageTraceListener.java) are released under the [Mozilla Public License](https://www.mozilla.org/en-US/MPL/).

Some files are derived from code examples that are licensed under the [W3C Software License](https://www.w3.org/copyright/software-license-2023/). Such files indicate their license in a code comment that includes "W3C Software License" text.

The content of the XSpec wiki is released under the [Creative Commons 3.0 BY](https://creativecommons.org/licenses/by/3.0/) license.
