This procedure is a primitive end-to-end testing for XSpec itself.

The primary goal is to verify that XSpec is generating the report files as expected. The test should be done as simply as possible and without using XSpec itself.

## Prerequisites

- Make sure that `../run-bats.sh` (or `.cmd`) does not fail. If it fails, this end-to-end testing may not work or does not make sense.

## Preparing the expected report files

First you need to set up the expected report files. This is a manual operation which you have to perform only once.

1. Put `*.xspec` files into the `cases/` directory.

1. Run `./generate-expected.sh` (or `.cmd`). For end-to-end code coverage testing, include the argument `-Dcases.dir=cases-coverage`.

   Alternatively you can open `ant/generate-expected/build.xml` in oXygen and apply **ANT (with Saxon 9 EE XSLT support)** in **Transformation Scenarios** pane. (You may want to duplicate the transformation scenario and set `-silent` in **Additional arguments**.)

1. The script executes the `cases/*.xspec` files, or the `cases-coverage/*.xspec` files if you supplied the `-Dcases.dir=cases-coverage` argument.

   In the `cases` or `cases-coverage` directory, two kinds of the report files are generated:

   - Original ones: `actual__/(query|schematron|stylesheet)/*.*`
   - Normalized ones: `expected/(query|schematron|stylesheet)/*.*`

1. Verify that the original ones (`actual__/`) contain the scenario results as expected.

1. Compare the normalized ones (`expected/`) with the original ones (`actual__/`).

   Verify that they are identical, except for the transient parts (`href`, `id`, datetime and file path) and whether the HTML report uses inline CSS styles or a CSS file link.

1. Commit the normalized ones (`expected/`) to the repository.

   They are called the expected report files hereafter.

1. You can discard the original ones (`actual__/` directory).

## Running the regular tests

Once the expected report files are prepared, you can run tests regularly by executing `./run-e2e-tests.sh -silent` (or `.cmd`). For end-to-end code coverage testing, use `./run-e2e-coverage-tests.sh -silent` (or `.cmd`).

Alternatively you can open `ant/run-e2e-tests/build.xml` in oXygen and apply **ANT (with Saxon 9 EE XSLT support)** transformation scenario.

The script performs these tasks:

1. Executes the `*.xspec` files in `cases/` or `cases-coverage/` directory.

   The report files are generated: `actual__/(query|schematron|stylesheet)/*.*`

1. Loads the report files, normalizes them on memory, and compares them with the expected report files (`expected/`).

   If they are different, the test is considered as failure.
