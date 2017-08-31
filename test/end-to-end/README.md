This procedure is a primitive end-to-end testing for XSpec itself.

The primary goal is to verify that XSpec is generating the report HTML files as expected. The test should be done as simply as possible and without using XSpec itself.

## Preparing the expected HTML files

First you need to set up the expected HTML files. This is a manual operation which you have to perform only once.

1. Put `*.xspec` files into the `cases` directory.

1. Run `./generate-expected.sh` (or `.cmd`).

	The script executes the `cases/*.xspec` files.
	
	In the `cases/expected` directory, two kinds of the report HTML files are generated:
	
	* Original ones: `*-result.html`
	* Normalized ones: `*-result-norm.html`
	
1. Verify that the original ones (`*-result.html`) contain the scenario results as expected.

1. Compare the normalized ones (`*-result-norm.html`) with the original ones (`*-result.html`).

	Verify that they are essentially identical. Only the transient parts (`href`, `id`, datetime and file path) should be different.

1. Commit the normalized ones (`*-result-norm.html`) to the repository. (You can discard the other sibling files.)

	They are called the expected HTML files hereafter.

## Running the regular tests

Once the expected HTML files are prepared, you can run tests regularly by executing `./run-e2e-tests.sh` (or `.cmd`).

The script performs these tasks in sequence:

1. Executes the `cases/*.xspec` files.

	The report HTML files are generated: `cases/xspec/*-result.html`

1. Loads the report HTML files, normalizes them on memory, and compares them with the expected HTML files (`cases/expected/*-result-norm.html`).

	If they are different, the test is considered as failure.
