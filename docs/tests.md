# Tests

* [Vault](#vault)
* [Cloud Foundry](#cloud-foundry)
* [BOSH](#bosh)
* [Writing Tests](#writing-tests)

## Vault

### Vault Target and Authenticate

* Target the Vault

User Inputs: URL and ALIAS

Where URL is `10.200.130.4` and ALIAS is `lab`.

```bash
$ safe -k target https://10.200.130.4 lab
Now targeting lab at https://10.200.130.4
```

* Authenticate

User Inputs: An authentication token.

```bash
$ safe auth
Token:
```

Command:

```bash
bin/lh login safe
```

### Safe Status

* Determine Safe Status

Prerequisites: Must be logged into Vault.

```bash
$ safe status
https://10.200.130.4:443 is unsealed
https://10.200.130.5:443 is unsealed
https://10.200.130.6:443 is unsealed
```

Command:

```bash
bin/lh check safe
```

## Cloud Foundry

### CF Target and Authenticate

* CF Target and Authenticate

Pre-requisites:

* [Authenticated to Vault](#vault-target-and-authenticate)

User Inputs: This function uses the following variables:

```bash
CF_USERNAME="admin"
CF_PASSWORD=$(bosh int <(safe get secret/xjkevin/cf/admin_user) --path /password)
     CF_API="https://api.system.xjkevin.scalecf.net"
     CF_ORG="system"
   CF_SPACE="dev"
```

Command:

```bash
bin/lh login cf
```

### Name of Environment/Domain/App Domain

Pre-requisites:

* [Authenticated to Vault](#vault-target-and-authenticate)
* [Authenticated to Cloud Foundry](#cf-target-and-authenticate)

Inputs:
Expects:

### Number of Routers

Specify the name of the Cloud Foundry deployment according to the `bosh vms` command.  And the number of routers you expect to be running in this environment.

```json
[
  {
    "deployment": "xjkevin-cf",
    "routers": "1"
  }
]
```

## BOSH

### BOSH Target and Authenticate

* BOSH Target and Authenticate

Pre-requisites:

* [Authenticated to Vault](#vault-target-and-authenticate)

User Inputs: This function uses the following variables:

```bash
  BOSH_ENVIRONMENT="10.200.195.1"
      BOSH_CA_CERT=certs/bosh-ssl.crt
       BOSH_CLIENT="admin"
BOSH_CLIENT_SECRET=$(bosh int <(safe get secret/xjkevin/bosh/users/admin) --path /password)
```

Command:

```bash
bin/lh login bosh
```

##Writing Tests

### Tracing and Debuging

The environment variables LH_TRACE and LH_DEBUG can be tested for existence
The value of these environment variables are unused at the moment.
```bash
   [[ ${LH_TRACE+yes} == "yes"]] && {
   }
   [[ ${LH_TRACE+yes} == "yes"]] && {
   }
```
The lighthouse command also supports -t and -d for setting the tracing and debugging flags before the sub-command.

```bash
lh -t -d test
```

Tests should be written assuming the authentication has already occurred.  
While developing tests, you can just keeping running the over and over again.

```bash
tests/cf/quotas.sh
```

The lh run command has the -s flag to skip the default login

```bash
lh run -s tests/cf/quotas.sh
```
