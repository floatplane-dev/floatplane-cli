#/bin/sh

set -e
set -o pipefail

# ----------

# RUBY, RBENV, POSTGRES

# Install missing packages for compiling Ruby
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev

# Install all packages for Postgres
sudo apt install -y postgresql postgresql-contrib libpq-dev

# Install Rbenv for managing Ruby versions
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
set -Ux fish_user_paths $HOME/.rbenv/bin $fish_user_paths
set -Ux fish_user_paths $HOME/.rbenv/shims $fish_user_paths
rbenv -v

# Install the rbenv plugins `ruby-build` and `rbenv-vars`:
mkdir ~/.rbenv/plugins
cd ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git
git clone https://github.com/rbenv/rbenv-vars.git

# Set a default Ruby version at user root
echo "2.6.5" >> ~/.ruby-version
rbenv install
ls -la /home/jw/.rbenv/versions/
du -sh /home/jw/.rbenv/versions/*
ruby  -v
gem -v

# ----------

exit 0;