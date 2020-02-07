<!-- "?v=" in the src parameter value is to invalidate cache -->
![diagram](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.github.com/AirQuick/xspec/puml_run-xspec-tests-ant/test/ant/diagram.txt?v=1)

1. Run `../run-xspec-tests-ant.sh` (or `.cmd`)

	Alternatively you can open `build.xml` in oXygen and apply **ANT (with Saxon 9 EE XSLT support)** in **Transformation Scenarios** pane. (You may want to duplicate the transformation scenario and set `-silent` in **Additional arguments**.) 

1. `run-xspec-tests-ant.sh` (or `.cmd`) runs `build.xml` in this directory.
1. `build.xml` runs `worker/generate.xsl`.
1. `generate.xsl` transforms `build-worker_template.xml` into `build-worker.xml`
	* In doing so, it inspects all `../*.xspec` files and creates a series of `<run-xspec>` elements with every applicable `@test-type`.
1. `build-worker.xml` runs all the `<run-xspec>` elements.
	* `<run-xspec>` element is just a handy wrapper to call `xspec` target in XSpec's main Ant build file (`../../build.xml`).
	* If all the tests in the `.xspec` files passed, `build-worker.xml` exits successfully ("BUILD SUCCESSFUL")
	* If one of the tests failed, `build-worker.xml` terminates ("BUILD FAILED").
1. Once you get "BUILD SUCCESSFUL" or "BUILD FAILED", you can delete `build-worker.xml`.

