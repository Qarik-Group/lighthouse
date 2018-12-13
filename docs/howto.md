# HOWTO

## Run Tests

To run all tests.

```bash
bin/lh test
```

List the available types of tests.

```bash
bin/lh test -h
```

Run a specific test. Like only the Cloud Foundry tests.

```bin
bin/lh test cf
```

## Include and Exclude Tests

To either include or exclude a test from the `test all` run, simply edit the `included` file in the subfolder of each test group.

For example, in the Cloud Foundry folder we see:

```bash
.
├── apps.sh
├── feature_flags.sh
├── included
├── orgs.sh
└── spaces.sh
```

And the `included` file starts with all files included.

```bash
tests/cf/apps.sh
tests/cf/feature_flags.sh
tests/cf/orgs.sh
tests/cf/spaces.sh
```

The full path from the root of the repo is needed because commands are run from the root of the repository.