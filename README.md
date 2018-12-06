# Lighthouse

Lighthouse, near friendly shores.

With lighthouse, you can run a quick series of readiness tests to make sure things will be able to have a safe harbor on your Cloud Foundry platform.

## Getting Started

### Prerequisites

Install the following command-line tools.

* [jq](https://stedolan.github.io/jq/download/)
* [cf-cli](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
* [bosh-cli](https://bosh.io/docs/cli-v2-install/)
* [safe](https://github.com/starkandwayne/safe#attention-homebrew-users)
* make

We also assume you have a Vault backend to target which we'll use in the [authorize safe](#authorize-safe) section below.
### Install Make

There are different ways to use `make`, that depend on your operating system.  If you already have it, skip this.

<details><summary>macOS:</summary>

```bash
xcode-select --install
```

</details><br/>

<details><summary>Ubuntu:</summary>

```bash
sudo apt-get install build-essential
```

</details><br/>

<details><summary>centOS:</summary>

```bash
yum groupinstall "Development Tools"
```

</details><br/>

<details><summary>Windows:</summary>

Go here: http://gnuwin32.sourceforge.net/packages/make.htm


</details><br/>

### Get Software

```bash
git clone https://github.com/krutten/lighthouse.git
```

### Authorize Safe

Create a target to safe.

```bash
safe -k target https://10.200.130.4 lab
```

Then login to safe, with your token.

```bash
safe auth
```

## Usage

Once set up, flip the switch and turn on your lighthouse.  Run `make all` to run your tests and light the way home.

```bash
make all
```