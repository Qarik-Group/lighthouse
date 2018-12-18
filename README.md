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

### Get Software

2. Clone this repo to your local computer.

```bash
git clone https://github.com/krutten/lighthouse.git
```

You've completed the **Getting Started** and are now ready to use Lighthouse!

### Configure

3. Do Configuration step.

### Login

Tests can be run from the commandline with the `bin/lh` script.  Yet you'll need to login first.

4. Login to `safe`, `bosh-cli`, and `cf-cli`.

```bash
bin/lh login
```

<p><details><summary>A successful <code>bin/lh login</code> looks like this :</summary>

```bash
$ bin/lh login
Now targeting lab at https://10.200.130.4

Please enter your vault token...
Authenticating against  at https://10.200.130.4
Token:
Using environment '10.200.195.1' as anonymous user

Name      xjkevin-bosh
UUID      7fc1393a-05b8-4312-a000-05f532a32465
Version   268.2.0 (00000000)
CPI       vsphere_cpi
Features  compiled_package_cache: disabled
          config_server: enabled
          local_dns: enabled
          power_dns: disabled
          snapshots: disabled
User      (not logged in)

Succeeded
Successfully authenticated with UAA

Succeeded
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
-----------------
Running BOSH Tests
------------------
PASSED
-----------------
Running CF Tests
------------------
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