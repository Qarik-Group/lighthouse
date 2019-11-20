# Lighthouse Included Files

The included file defines the tests or test groups to run.
Included files are located in the test group directories and the file must be name
name "included".  Test files are located in test group directories.  All test files must
use the file suffix of ".sh".  Test groups are directories and they cannot
have the suffix of ".sh". 

    ../templates/tests
    ├── bosh
    │   ├── included
    │   └── routers.sh
    ├── cf
    │   ├── apps.sh
    │   ├── buildpacks.sh
    │   ├── envvars.sh
    │   ├── feature_flags.sh
    │   ├── included
    │   ├── orgs.sh
    │   ├── quotas.sh
    │   ├── services.sh
    │   └── spaces.sh
    └── uaa
        ├── included
        └── local_users.sh


