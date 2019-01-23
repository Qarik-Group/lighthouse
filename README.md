# Lighthouse

Lighthouse, near friendly shores.

With lighthouse, you can run a quick series of tests to make sure things will be able to have a safe harbor on your Cloud Foundry platform.

## Getting Started

### Prerequisites

1. Install the following command-line tools.

* [jq](https://stedolan.github.io/jq/download/)
* [cf-cli](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
* [bosh-cli](https://bosh.io/docs/cli-v2-install/)
* [safe](https://github.com/starkandwayne/safe#attention-homebrew-users)
* [uaa](docs/install-uaa.md)

### Get Software

2. Clone this repo to your local computer.

```bash
git clone https://github.com/starkandwayne/lighthouse.git
```

### Installation

Method A) Add the bin directory to your path

```bash
$ export PATH=~/path/to/lighthouse/bin:$PATH
```

Method B) Put the `lh` script in your path and set the `LH_DIRECTORY` variable to point to the folder with the templates

```bash
$ export LH_DIRECTORY=~/path/to/lighthouse
```
### Configure

3. Run the lighthouse init command to create a new directory/repo for your configuration

```bash
$ lh init dirname
Creating directory dirname
/Users/krutten/src/templates/data -> dirname/data
/Users/krutten/src/templates/data/uaa -> dirname/data/uaa
/Users/krutten/src/templates/data/uaa/local_users.json -> dirname/data/uaa/local_users.json
/Users/krutten/src/templates/data/cf -> dirname/data/cf
/Users/krutten/src/templates/data/cf/buildpacks.json -> dirname/data/cf/buildpacks.json
/Users/krutten/src/templates/data/cf/feature_flags.json -> dirname/data/cf/feature_flags.json
/Users/krutten/src/templates/data/cf/spaces.json -> dirname/data/cf/spaces.json
/Users/krutten/src/templates/data/cf/services.json -> dirname/data/cf/services.json
/Users/krutten/src/templates/data/cf/quotas.json -> dirname/data/cf/quotas.json
/Users/krutten/src/templates/data/cf/orgs.json -> dirname/data/cf/orgs.json
/Users/krutten/src/templates/data/cf/envvars.json -> dirname/data/cf/envvars.json
/Users/krutten/src/templates/data/cf/apps.json -> dirname/data/cf/apps.json
/Users/krutten/src/templates/data/bosh -> dirname/data/bosh
/Users/krutten/src/templates/data/bosh/routers.json -> dirname/data/bosh/routers.json
/Users/krutten/src/templates/tests -> dirname/tests
/Users/krutten/src/templates/tests/uaa -> dirname/tests/uaa
/Users/krutten/src/templates/tests/uaa/local_users.sh -> dirname/tests/uaa/local_users.sh
/Users/krutten/src/templates/tests/uaa/included -> dirname/tests/uaa/included
/Users/krutten/src/templates/tests/cf -> dirname/tests/cf
/Users/krutten/src/templates/tests/cf/quotas.sh -> dirname/tests/cf/quotas.sh
/Users/krutten/src/templates/tests/cf/services.sh -> dirname/tests/cf/services.sh
/Users/krutten/src/templates/tests/cf/buildpacks.sh -> dirname/tests/cf/buildpacks.sh
/Users/krutten/src/templates/tests/cf/orgs.sh -> dirname/tests/cf/orgs.sh
/Users/krutten/src/templates/tests/cf/spaces.sh -> dirname/tests/cf/spaces.sh
/Users/krutten/src/templates/tests/cf/apps.sh -> dirname/tests/cf/apps.sh
/Users/krutten/src/templates/tests/cf/included -> dirname/tests/cf/included
/Users/krutten/src/templates/tests/cf/envvars.sh -> dirname/tests/cf/envvars.sh
/Users/krutten/src/templates/tests/cf/feature_flags.sh -> dirname/tests/cf/feature_flags.sh
/Users/krutten/src/templates/tests/template -> dirname/tests/template
/Users/krutten/src/templates/tests/template/test_template.sh -> dirname/tests/template/test_template.sh
/Users/krutten/src/templates/tests/bosh -> dirname/tests/bosh
/Users/krutten/src/templates/tests/bosh/routers.sh -> dirname/tests/bosh/routers.sh
/Users/krutten/src/templates/tests/bosh/included -> dirname/tests/bosh/included
$ cd dirname
```

4. Run lighthouse new for each environment to use

```bash
$ lh new aws-prod
Adding Environment 'aws-prod'
Copying template files to aws-prod/data/ and aws-prod/tests/
/Users/krutten/src/lighthouse/templates/data -> aws-prod/data
/Users/krutten/src/lighthouse/templates/data/uaa -> aws-prod/data/uaa
/Users/krutten/src/lighthouse/templates/data/uaa/local_users.json -> aws-prod/data/uaa/local_users.json
/Users/krutten/src/lighthouse/templates/data/cf -> aws-prod/data/cf
/Users/krutten/src/lighthouse/templates/data/cf/buildpacks.json -> aws-prod/data/cf/buildpacks.json
/Users/krutten/src/lighthouse/templates/data/cf/feature_flags.json -> aws-prod/data/cf/feature_flags.json
/Users/krutten/src/lighthouse/templates/data/cf/spaces.json -> aws-prod/data/cf/spaces.json
/Users/krutten/src/lighthouse/templates/data/cf/services.json -> aws-prod/data/cf/services.json
/Users/krutten/src/lighthouse/templates/data/cf/quotas.json -> aws-prod/data/cf/quotas.json
/Users/krutten/src/lighthouse/templates/data/cf/orgs.json -> aws-prod/data/cf/orgs.json
/Users/krutten/src/lighthouse/templates/data/cf/envvars.json -> aws-prod/data/cf/envvars.json
/Users/krutten/src/lighthouse/templates/data/cf/apps.json -> aws-prod/data/cf/apps.json
/Users/krutten/src/lighthouse/templates/data/bosh -> aws-prod/data/bosh
/Users/krutten/src/lighthouse/templates/data/bosh/routers.json -> aws-prod/data/bosh/routers.json
```
When tests run, they will first look in the ./ENV/tests for the tests and then ./tests and then the lighthouse templates.

The tests themselves will look in ./ENV/data then ./data and finally the templates/data for the data file to use.

This allows you to customize your tests in general and for each environmant as needed.

5. Provide the required settings to the Vault backend by replacing all the `"replace-me"` values.

```bash
export VAULT_PATH="replace-me"
export VAULT_TOKEN="replace-me"
export VAULT_ADDR="replace-me"
export VAULT_ALIAS="replace-me"
export VAULT_SKIP_VERIFY=1
```

* `VAULT_PATH` is the beginning of the path to your secrets.  Like `secret/c-g6`.
* `VAULT_TOKEN` is a alpha-numeric authentication and authorization token.
* `VAULT_ADDR` is the IP address or FQDN to your vault.
* `VAULT_ALIAS` is the name of the target for safe to use. For example: `sandbox`, `pre-prod`, `prod`.
* `VAULT_SKIP_VERIFY` will skip the check for a TLS verification.

### Login

Tests can be run from the commandline with the `bin/lh` script.  Yet you'll need to login first.

5. Login to `safe`, `bosh-cli`, and `cf-cli`.

```bash
bin/lh login
```

<p><details><summary>A successful <code>bin/lh login</code> looks like this :</summary>

```bash
$ bin/lh login


==\
===> Logging into safe.
==/

Now targeting lab at https://10.200.130.4

Authenticating against  at https://10.200.130.4


==\
===> Logging into bosh.
==/

Using environment '10.200.195.1' as client 'admin'

Name      xjkevin-bosh
UUID      7fc1393a-05b8-4312-a000-05f532a32465
Version   268.2.0 (00000000)
CPI       vsphere_cpi
Features  compiled_package_cache: disabled
          config_server: enabled
          local_dns: enabled
          power_dns: disabled
          snapshots: disabled
User      admin

Succeeded
Successfully authenticated with UAA

Succeeded


==\
===> Logging into cf.
==/

Setting api endpoint to https://api.system.xjkevin.scalecf.net...
OK

api endpoint:   https://api.system.xjkevin.scalecf.net
api version:    2.114.0
API endpoint: https://api.system.xjkevin.scalecf.net
Authenticating...
OK
Use 'cf target' to view or set your target org and space.
api endpoint:   https://api.system.xjkevin.scalecf.net
api version:    2.114.0
user:           admin
org:            system
space:          dev


==\
===> Logged into all systems.
==/
```

</details></p>

### Run Tests

Run `bin/lh test` to start the tests.

```bash
bin/lh test
```

<p><details><summary>A successful <code>bin/lh test</code> looks like this :</summary>

```bash
$ bin/lh test


==\
===> Running BOSH tests.
==/

PASSED


==\
===> Running CF tests.
==/

FAILED  Application data  validation for org 'starkandwayne'
REASON Org does not exist
FAILED  Application data  validation for org 'starkandwayne'
REASON Org does not exist
FAILED  Is feature flag diego_docker enabled?
FAILED  Is feature flag set_roles enabled?
REASON Feature flag set_roles does not exist
PASSED  Is feature flag env_var_visibility enabled?
PASSED  Is feature flag service_instance_sharing disabled?
FAILED  Is feature flag hide_marketplace_from_unauthenticated_users disabled?
REASON Feature flag hide_marketplace_from_unauthenticated_users does not exis
FAILED  Does org starkandwayne exist?
FAILED  Does org Idonotexist exist?
FAILED  Does org cfdev-org exist?
FAILED  Does the expected spaces exist in org cfdev-org?
REASON Org does not exit
FAILED  Does the expected spaces exist in org starkandwayne?
REASON Org does not exit
```

</details></p>