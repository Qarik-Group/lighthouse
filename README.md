# Lighthouse

Lighthouse, near friendly shores.

With lighthouse, you can run a quick series of readiness tests to make sure things will be able to have a safe harbor on your Cloud Foundry platform.

## Getting Started

### Prerequisites

1. Install the following command-line tools.

* [jq](https://stedolan.github.io/jq/download/)
* [cf-cli](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
* [bosh-cli](https://bosh.io/docs/cli-v2-install/)
* [safe](https://github.com/starkandwayne/safe#attention-homebrew-users)
* make

### Install Make

You'll install `make` based on what operating system you have.  If you already have it, skip to [get software](#get-software).

<details><summary>macOS:</summary>

```bash
xcode-select --install
```

</details>

<details><summary>Ubuntu:</summary>

```bash
sudo apt-get install build-essential
```

</details>

<details><summary>centOS:</summary>

```bash
yum groupinstall "Development Tools"
```

</details>

<details><summary>Windows:</summary>

Go here: [http://gnuwin32.sourceforge.net/packages/make.htm](http://gnuwin32.sourceforge.net/packages/make.htm)

</details>

### Get Software

2. Clone this repo to your local computer.

```bash
git clone https://github.com/krutten/lighthouse.git
```

### Authorize Safe

3. Create a target to safe.

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

TODO: add what a "good" `make check` looks like.

Once set up, flip the switch and turn on your lighthouse.  Run `make all` to run your tests and light the way home.

```bash
make all
```