# floatplane-cli

A command line tool for setting up and managing servers. ⛵

### 1. Sets up servers

```bash
fp setup server
```

This command will:

- set up a unique SSH connection with your server
- create a sudo user
- locks down the root user 🔒
- prevent password logins
- close all ports except HTTP, HTTPS and SSH
- activate firewall
- install Fish as default shell 🐠
- install missing packages

Tested and optimised for Debian servers spun up at [Vultr](https://www.vultr.com) or [Digital Ocean](https://www.digitalocean.com).

### 2. Sets up projects

```bash
fp setup project
```

This command will:

- Set up a Node, Deno or Ruby based project on your server
- Configure Nginx to direct your domain to your project
- Set up a deployment hook for CLI tools to hit

### 3. Deploy a project

```
fp deploy
```

This command will:

- Ask you which project to deploy
- Hit the deployment hook of your project to deploy the latest production code

Ideally have your CI tools do this. But yes, sometimes a manual deploy is necessary.

---

### How to install this CLI

Please first sanity check if `echo $PATH` includes `/usr/local/`. If yes, continue.

```bash
git clone git@github.com:floatplane-dev/floatplane-cli.git
cd floatplane-cli/
./install.sh
```

Then finally test by running `fp` should show you a success message.

### Upgrade the CLI

```bash
cd floatplane-cli/
git pull
./install.sh
```
