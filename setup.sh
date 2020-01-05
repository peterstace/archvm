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

notice "installing jid"
tmp=$(mktemp -d)
pushd "$tmp"
git clone https://aur.archlinux.org/jid.git
cd jid
makepkg --install --noconfirm
popd

notice "installing pspg"
tmp=$(mktemp -d)
pushd "$tmp"
git clone https://aur.archlinux.org/pspg-git.git
cd pspg-git
makepkg --install --noconfirm
popd

notice "installing jo"
tmp=$(mktemp -d)
pushd "$tmp"
git clone https://aur.archlinux.org/jo.git
cd jo
makepkg --install --noconfirm
popd

notice "installing up kubectl"
tmp=$(mktemp -d)
pushd "$tmp"
git clone https://aur.archlinux.org/kubectl-bin.git
pushd kubectl-bin
makepkg --install --noconfirm
popd
mkdir -p $HOME/.config/fish/completions
pushd $HOME/.config/fish
if [ ! -e "$HOME/.config/fish/fish-kubectl-completions" ]; then
	git clone https://github.com/evanlucas/fish-kubectl-completions
	ln -s \
		$HOME/.config/fish/fish-kubectl-completions/completions/kubectl.fish \
		$HOME/.config/fish/completions/kubectl.fish
fi
popd

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

notice "installing GPG keys"
git clone git@github.com:peterstace/gpg.git ~/r/gpg
~/r/gpg/setup.sh

#
# Doesn't require interaction.
#

notice "setting up dotfiles"
git clone git@github.com:peterstace/dotfiles.git ~/r/dotfiles
~/r/dotfiles/link.sh

notice "cloning repos"
~/r/dotfiles/clone_repos.sh

notice "setting up docker fish completions"
mkdir -p ~/.config/fish/completions
ln -sf /usr/share/fish/vendor_completions.d/docker.fish ~/.config/fish/completions/docker.fish

notice "installing vim plugins"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
~/.vim/plugged/YouCompleteMe/install.py
vim +GoInstallBinaries +qall

notice "installing dep"
GOPATH="$HOME/go" go get github.com/golang/dep/...

notice "installing personal Go binaries (already cloned)"
GOPATH="$HOME/go" go install github.com/peterstace/csvfmt/...
GOPATH="$HOME/go" go install github.com/peterstace/dauntless/...
GOPATH="$HOME/go" go install github.com/peterstace/task/...
GOPATH="$HOME/go" go install github.com/peterstace/tmuxssel/...
GOPATH="$HOME/go" go install github.com/peterstace/vmbridge/...

pushd "$HOME/go/src/github.com/peterstace/dbconnmgr"
go install
popd
