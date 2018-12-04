# Lighthouse

Lighthouse: near friendly shores.

With lighthouse you can run a quick series of readiness tests to make sure things will be able to have safe harbor on your Cloud Foundry platform.

## Getting Started

### Prerequisites

Install the following command-line tools. 

* [jq](https://stedolan.github.io/jq/download/)
* [cf-cli](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
* [bosh-cli](https://bosh.io/docs/cli-v2-install/)

### Setup

```bash
git clone https://github.com/krutten/lighthouse.git
```

### Configure

1. Open the `config.env` file.
2. Make changes to the variables so they match your users, endpoints, and so on.
3. Test a login by running `make login`.

This will prompt you for the password and then test your values.  If correct you're ready to go.

## Usage

Once everything is ready to rock, you're ready to flip the switch and turn on your lighthouse.  Run `make test` to give it a whirl.

```bash
make test
```