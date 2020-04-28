# Testing .xspec files

<!-- "?v=" in the src parameter value is to invalidate cache -->

![diagram](https://www.plantuml.com/plantuml/proxy?src=https://raw.github.com/xspec/xspec/master/test/ant/diagram.txt?v=1)

1. Put `.xspec` files in a directory.

   - The default directory is `../` defined by `xspecfiles.dir` Ant property.

1. Run `../run-xspec-tests-ant.sh` (or `.cmd`)

   - Alternatively you can open `build.xml` in oXygen and apply **ANT (with Saxon 9 EE XSLT support)** in **Transformation Scenarios** pane.

     - You may want to duplicate the transformation scenario and set `-silent` in **Additional arguments**.

1. `run-xspec-tests-ant.sh` (or `.cmd`) runs `build.xml` in this directory.

1. `build.xml` runs `worker/generate.xsl`.

1. `generate.xsl` collects `.xspec` files.

1. `generate.xsl` transforms `build-worker_template.xml` into `build-worker.xml`

   - For each `.xspec` file, `<run-xspec>` element is created with every applicable `@test-type`.

1. Done generating `build-worker.xml`.

1. `build.xml` runs the generated `build-worker.xml`.

1. `build-worker.xml` runs all the `<run-xspec>` elements.

   - `<run-xspec>` element is just a handy wrapper to call `xspec` target in XSpec's main Ant build file (`../../build.xml`).
   - `<run-xspec>` elements run in parallel (one element in one thread, one thread per logical processor).

1. XSpec's `build.xml` terminates on any Failure.

1. Any Failure bubbles up. If all the tests in the `.xspec` files passed, `build-worker.xml` exits successfully.

   - Now you can delete `build-worker.xml`.

1. `build.xml` returns "BUILD SUCCESSFUL" or "BUILD FAILED".

1. `run-xspec-tests-ant.sh` (or `.cmd`) returns zero on Success, otherwise non zero.
