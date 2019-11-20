
## Lighthouse Environment

The Lighthouse execution environment is based upon the Cloud Foundry Linux Stemcell
and assumes we have a Linux file system.  As part of this environment, we also can 
build Concourse pipelines to run Lighthouse. We also assume the output devices support
ANSI control sequences. The Lighthouse environment is heavily dependent on bash 4.3 and
greater functionality.

These assumptions allows us to execute Lighthouse in other Linux environments like MacOS.

## Tests

Tests can be written in any programming language.  The requirements for a test are:
1. Tests are launched from a shell script
1. The test filename has the suffix ".sh".
1. The test returns a return value of 0 for success and non-zero failure. 

It is recommended that filenames use only alphanumeric characters
along with underscores and dashes to avoid shell interpretations issues

    #!/usr/bin/env python3

    print("Hello Lighthouse")

Tests should be written that they can reused.  They should be configured using data files.

## Test Groups

A test group is a logical grouping of validation tests.  A group can represent whatever
you need it to. 
A test group is represented as a directory which contains zero or more tests.
A test group may also contain a special file named "included". This
file contains the list of tests or test
groups to run. 
The test group directory name
must not have a suffix of ".sh".  It is recommended to that filenames use only
alphanumeric characters along with underscores and dashes to avoid
shell interpolation issues


## Test Environments

A Test Environment is a Cloud Foundry deployment you want lighthouse to validate against.
For Lighthouse, it mostly means the set of parameters to access the
Cloud Foundry environment.  These parameters can be defined either through
1. shell variables passed to the Lighthouse command
1. shell variables defined in the test environment configuration file
1. Vault or Credhub secret paths defined in test environment configuration file or 
in the Lighthouse command itself.

The environment name should be limited to alphanumeric characters
along with underscores and dashes to avoid issues with the various tooling
that needs to use this name.

We have identified the following environments.
1. Genesis Deployments that use Vault
1. Pivotal Cloud Foundry deployments that use Vault
1. Open Source Cloud Foundry that uses Vault
1. Pivotal Cloud Foundry that uses Credhub
1. Open Source Cloud Foundry that uses Credhub 

## Test Hierarchy

Tests are located in three different directory hierarchies.  The lowest level
hierarchy are tests provided by Lighthouse.  The next level of tests are tests written
for a test environment.   The highest level of tests are the tests defined in your
current work space and is normally used for creating new tests.

Tests are found in the tests directory.  There is parallel directory structure for 
test data files and the search for the data is done the same way as test files.
The test and data directories contains test group directories.

**local test directory structure**  

    data  
    ├── bosh  
    ├── cf  
    └── uaa  
    lib  
    tests  
    ├── bosh  
    ├── cf  
    └── uaa  

**test environment directory structure**  

    test_envionrment  
    ├── data  
    │   ├── bosh  
    │   ├── cf  
    │   └── uaa  
    ├── lib  
    └── tests  
        ├── bosh  
        ├── cf  
        └── uaa  

**lighthouse  directory structure**  

    templates  
    ├── data  
    │   ├── bosh  
    │   ├── cf  
    │   └── uaa  
    ├── lib  
    └── tests  
        ├── bosh  
        ├── cf  
        └── uaa  
