
[Environment Variables](#environment-variables)  
[Configuration Files](#configuration-files)  
[Options](#global-options)  
[Debug Parameter](#debug-parameter)  
[Trace Parameter](#trace-parameter)  
[help](#help)  
[new](#new)  
[check](#check)  
[init](#init)  
[login](#login)  
[logout](#logout)  
[repipe](#repipe)  
[run](#run)  
[test](#test)

## Environment Variables

##### LH\_DIRECTORY

This environment variable points to the lighthouse directory where it can find
the tests and their data files.   The default value is determined by the path
used to execute the lighthouse command. 

## Configuration Files

## Global Options

##### Debug Parameter
**[-d** *DEBUG-NAME[[,|:]DEBUG-NAME]***...]**  

The debug parameter enables debugging output.  
Its parameter value takes one or more debug names that are defined in the code.  
The debug-name parameter value can contain multiple debug names separated
by a comma, semicolon or a space.  The value should be quoted if you specify
multiple debug-name values .
The debug parameter can be specified multiple times which concantinates
debug name values together.

##### Trace Parameter
**[-t** *TRACE-NAME[[,|:],TRACE-NAME]***...]** 

The trace parameter enables tracing output.  
Its parameter value takes one or more trace names that are defined in the code.  
The trace-name parameter value can contain multiple trace names separated
by a comma, semicolon or a space.  The value should be quoted if you specify
multiple trace-name values .
The trace parameter can be specified multiple times which concantinates
trace name values together.

## Help
Usage: **lh**  
       **lh** *[options]* **help** *[HELP-CHOICE]***...**  

The help command will either list a quick summary of the available help
choices or displays detailed help for one or more help choices.

## New
Usage: **lh** *[options]* **new** *ENVIRONMENT*

Create a config.\<environment\>.env file and copy over the data files to 
the environment subdirectory.  

## Check
Usage: **lh** *[options]* **check [dependencies|safe]...**

## Init
Usage: **lh** *[options]* **init** *WORKING-DIRECTORY*

Create a lighhouse working directory and copy over the 
default data files used by the tests.  This directory 
should normally be put under source control.

## Login
Usage: **lh** *[options]* **login** *ENVIRONMENT* **[safe|bosh|cf|uaa]...**

## Logout
Usage: **lh** *[options]* **logout** *ENVIRONMENT*

## Repipe
Usage: **lh** *[options]* **repipe** *ENVIRONMENT*

## Run
Usage: **lh** *[options]* **run** *ENVIRONMENT* **[-s]** *TEST*

Takes one or more paths to test scripts and runs them if possible.
The path will be 'group/test.sh' such as 'cf/orgs.sh'
Will login to each component unless instructed otherwise.
Options:
-s: skip login to bosh, cf, and uaa.

## Test
Usage: **lh** *[options]* **test** *ENVIRONMENT GROUP*

run all tests.
test bosh: only the bosh tests.
test cf: only cloud foundry tests.
