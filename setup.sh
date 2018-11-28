#!/bin/bash

set -exo pipefail

git clone git@github.com:peterstace/dotfiles.git ~/r/dotfiles
~/r/dotfiles/link.sh
~/r/dotfiles/clone_repos.sh
