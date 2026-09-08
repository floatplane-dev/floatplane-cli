# Floatplane CLI

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
- configure and activate firewall
- configure certbot
- set Fish as default shell 🐠
- spin up Nginx
- install tools:
  - git
  - curl
  - nginx
  - certbot
  - ufw
  - fish
  - rbenv
  - NVM
  - Node
  - NPM
  - PNPM
  - Yarn
  - PM2
  - Deno 🦕

Tested and optimised for Debian servers spun up at [Vultr](https://www.vultr.com) or [Digital Ocean](https://www.digitalocean.com).

### 2. Sets up apps

```bash
fp setup app
```

This command will:

- Set up a Node, Deno or Ruby based apps on your server
- Configure Nginx to direct your domain to your app
- Set up a deployment hook for CLI tools to hit

### 3. Deploy an app

```
fp deploy
```

This command will:

- Ask you which app to deploy
- Hit the deployment hook of your app to deploy the latest production code

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
