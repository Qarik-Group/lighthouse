
[options](##options)
[environment variables](##environment-variables)
[help](##help)
[new](##new)
[check](##check)
[init](##init)
[login](##login)
[logout](##logout)
[repipe](##repipe)
[run](##run)
[test](##test)

## Environment Variables

## Options
[-d debug-name[[,|:]debug-name]...]... 

[-t trace-name[[,|:],trace-name]...]...

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
