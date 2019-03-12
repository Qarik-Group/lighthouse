
- [Environment Variables](##environment-variables)
- [Configuration Files](##configuration-files)
- [Options](##global-options)
- [help](##help)
- [new](##new)
- [check](##check)
- [init](##init)
- [login](##login)
- [logout](##logout)
- [repipe](##repipe)
- [run](##run)
- [test](##test)

## Environment Variables

##### LH\_DIRECTORY

This environment variable points to the lighthouse directory where it can find
the tests and their data files.   The default value is determined by the path
used to execute the lighthouse command. 

## Configuration Files

## Global Options
__[-d DEBUG-NAME[[,|:]DEBUG-NAME]...]...__

The debug parameter enables debugging output.  
Its parameter value takes one or more debug names that are defined in the code.  
The debug-name parameter value can contain multiple debug names separated
by a comma, semicolon or a space.  The value should be quoted if you specify
multiple debug-name values .
The debug parameter can be specified multiple times which concantinates
debug name values together.

__[-t TRACE-NAME[[,|:],TRACE-NAME]...]...__

The trace parameter enables tracing output.  
Its parameter value takes one or more trace names that are defined in the code.  
The trace-name parameter value can contain multiple trace names separated
by a comma, semicolon or a space.  The value should be quoted if you specify
multiple trace-name values .
The trace parameter can be specified multiple times which concantinates
trace name values together.

## Help
__lh__  
__lh [options] help [HELP-CHOICE]...__

The help command will either list a quick summary of the available help
choices or displays detailed help for one or more help choices.

## New
__th [options] new ENVIRONMENT__

Create a config.\<environment\>.env and copy over the data files to the environment subdirectory

## Check
__lh [options] check [dependencies|safe]..__

## Init
__lh [options] init WORKING-DIRECTORY__

Create a lighhouse working directory and copy over the 
default data files used by the tests.  This directory 
should normally be put under source control.

## Login
__lh [options] login ENVIRONMENT [safe|bosh|cf|uaa]...__

## Logout
__lh [options] logout ENVIRONMENT__

## Repipe
__lh [options] repipe ENVIRONMENT__

## Run
__lh [options] run ENVIRONMENT [-s] TEST__

## Test
__lh [options] test ENVIRONMENT GROUP__
