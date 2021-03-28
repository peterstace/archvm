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
~/r/dotfiles/scripts/clone_repos.sh

notice "setting up docker fish completions"
mkdir -p ~/.config/fish/completions
ln -sf /usr/share/fish/vendor_completions.d/docker.fish ~/.config/fish/completions/docker.fish

notice "installing vim plugins"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
vim +GoInstallBinaries +qall

notice "installing personal Go binaries (already cloned)"
for prog in csvfmt dauntless task tmuxssel vmbridge dbconnmgr luca; do
	pushd $HOME/go/src/github.com/peterstace/$prog
	go install ./...
	popd
done
