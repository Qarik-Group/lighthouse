# Lighthouse

Lighthouse, near friendly shores.

With lighthouse, you can run a quick series of readiness tests to make sure things will be able to have a safe harbor on your Cloud Foundry platform.

## Getting Started

### Prerequisites

Install the following command-line tools. 

* [jq](https://stedolan.github.io/jq/download/)
* [cf-cli](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
* [bosh-cli](https://bosh.io/docs/cli-v2-install/)

### Get Software

```bash
git clone https://github.com/krutten/lighthouse.git
```

### Configure

1. Open the `config.env` file.
2. Make changes to the variables.
3. Test a login by running `make login`.

A password prompt will appear, put in your password and continue.  Then if the login succeeds you're all set up.

## Usage

Once set up, flip the switch and turn on your lighthouse.  Run `make test` to run your tests and light the way home.

```bash
make test
```