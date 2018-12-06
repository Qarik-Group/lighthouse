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

An example configuration file is provided in the repository.   This is to prevent the storage of passwords in your repository.

```bash
cp config.env.example config.env
```

Open the `config.env` to add your passwords and correct settings.  For example, here's how you'd configure Cloud Foundry:

```env
## Cloud Foundry

CF_USERNAME="admin"
CF_PASSWORD=""
     CF_API="https://api.system.xjkevin.scalecf.net"
     CF_ORG=system
   CF_SPACE=dev
```

## Usage

Once set up, flip the switch and turn on your lighthouse.  Run `make all` to run your tests and light the way home.

```bash
make all
```