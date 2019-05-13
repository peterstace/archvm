#!/bin/bash

set -exo pipefail

notice() {
	set +x
	printf '\e[32m'
	echo $@
	printf '\e[0m'
	set -x
}

#
# Requires interaction:
#

# irrelevant ## notice "installing pspg"
# irrelevant ## tmp=$(mktemp -d)
# irrelevant ## pushd "$tmp"
# irrelevant ## git clone https://aur.archlinux.org/pspg-git.git
# irrelevant ## cd pspg-git
# irrelevant ## makepkg --install --noconfirm
# irrelevant ## popd

notice "setting up github keys"
ssh-keygen -N "" -f "$HOME/.ssh/id_rsa"
set +x
printf "github token (must have write:public_key scope) > "
read github_token
set -x
payload=$(jq -R "{title: $(hostname | jq -R .), key: .}" ~/.ssh/id_rsa.pub)
curl \
	-u "peterstace:$github_token" \
	--data "$payload" \
	"https://api.github.com/user/keys"

# irrelevant ## notice "installing GPG keys"
# irrelevant ## git clone git@github.com:peterstace/gpg.git ~/r/gpg
# irrelevant ## ~/r/gpg/setup.sh

#
# Doesn't require interaction.
#

notice "setting up dotfiles"
git clone git@github.com:peterstace/dotfiles.git ~/r/dotfiles
~/r/dotfiles/link.sh

# irrelevant ## notice "cloning repos"
# irrelevant ## ~/r/dotfiles/clone_repos.sh

# irrelevant ## notice "setting up kubectl"
# irrelevant ## mkdir -p $HOME/aur
# irrelevant ## git clone https://aur.archlinux.org/kubectl-bin.git $HOME/aur/kubectl-bin
# irrelevant ## pushd $HOME/aur/kubectl-bin
# irrelevant ## makepkg --install --noconfirm
# irrelevant ## popd
# irrelevant ## mkdir -p $HOME/.config/fish/completions
# irrelevant ## pushd $HOME/.config/fish
# irrelevant ## git clone https://github.com/evanlucas/fish-kubectl-completions
# irrelevant ## ln -s \
# irrelevant ## 	$HOME/.config/fish/fish-kubectl-completions/completions/kubectl.fish \
# irrelevant ## 	$HOME/.config/fish/completions/kubectl.fish
# irrelevant ## popd

# irrelevant ## notice "setting up docker fish completions"
# irrelevant ## mkdir -p ~/.config/fish/completions
# irrelevant ## ln -sf /usr/share/fish/vendor_completions.d/docker.fish ~/.config/fish/completions/docker.fish

notice "installing vim plugins"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
# irrelevant ## ~/.vim/plugged/YouCompleteMe/install.py
# breaks because the vim-go plugin is disabled ## vim +GoInstallBinaries +qall

# irrelevant ## notice "installing dep"
# irrelevant ## GOPATH="$HOME/go" go get github.com/golang/dep/...

# irrelevant ## notice "installing personal Go binaries (already cloned)"
# irrelevant ## GOPATH="$HOME/go" go install github.com/peterstace/dauntless/...
# irrelevant ## GOPATH="$HOME/go" go install github.com/peterstace/task/...
# irrelevant ## GOPATH="$HOME/go" go install github.com/peterstace/cliscreensaver/...
# irrelevant ## GOPATH="$HOME/go" go install github.com/peterstace/abacus/...
# irrelevant ## GOPATH="$HOME/go" go install github.com/peterstace/csvfmt/...
# irrelevant ## GOPATH="$HOME/go" go install github.com/peterstace/tmuxssel/...
# irrelevant ## GOPATH="$HOME/go" go install github.com/peterstace/vmbridge/...

# irrelevant ## notice "installing public Go binaries"
# irrelevant ## GOPATH="$HOME/go" go get github.com/kardianos/govendor/...

# irrelevant ## notice "installing rust binaries"
# irrelevant ## cargo install ktmpl

# irrelevant ## notice "installing python binaries"
# irrelevant ## pip2 install --user aws-adfs
