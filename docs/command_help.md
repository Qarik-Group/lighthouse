
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

##### LH_DIRECTORY

This environment variable points to the lighthouse directory where it can find
the tests and their data files.   The default value is determined by the path
used to execute the lighthouse command. 

## Configuration Files

## Global Options
###### [-d debug-name[[,|:]debug-name]...]... 
This parameter takes debug name(s) that are defined in the code.  
This parameter takes one value but can be specified multiple times.
The value can contain multiple values separated by a comma, semicolon or a space.
If spaces are used, the value should be quoted so the shell interprets the value as a single argument.

###### [-t trace-name[[,|:],trace-name]...]...
This parameter takes trace name(s) that are defined in the code.
This parameter takes one value but can be specified multiple times.
The value can contain multiple values separated by a comma, semicolon or a space.
If spaces are used, the value should be quoted so the shell interprets the value as a single argument.


## Help
lh [options] help [cmd...]


## New
th [options] new \<environment\>

Create a config.\<environment\>.env and copy over the data files to the environment subdirectory

## Check
lh [options] check [dependencies|safe]..

## Init
lh [options] init \<working-directory\>

Create a lighhouse working directory and copy over the 
default data files used by the tests.  This directory 
should normally be put under source control.

## Login
lh [options] login [safe|bosh|cf|uaa]...

## Logout
lh [options] logout \<environment\>

## Repipe
lh [options] repipe \<environment\>

## Run
lh [options] run \<environment\> [-s] \<test\>

## Test
lh [options] test \<environment\> \<group\>
