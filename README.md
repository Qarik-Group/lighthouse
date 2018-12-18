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

### Authorize Safe

3. Create a target to your vault with safe.

```bash
safe -k target https://10.200.130.4 lab
```

4. Then login to safe, with a token.

```bash
safe auth
```

You've completed the **Getting Started** and are now ready to use Lighthouse!

## Usage

Let's first run a command to test that tool is connected to your authencation backend.

```bash
make check
```

<p><details><summary>A successful <code>make check</code> will login to BOSH and Cloud Foundry:</summary>

```bash
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

Once set up, flip the switch and turn on your lighthouse.  Run `make all` to run your tests and light the way home.

```bash
make all
```
