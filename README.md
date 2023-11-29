# Dotfiles
Personal settings for awesome development

## Settings
The settings to link
Currently:
- [X] zsh
- [X] git
- [X] tmux
- [X] nvim
- [X] gnome-terminal (colors)
- [X] vscode

To add:
- conda?
- postman?

## Scripts
A bunch of scripts that do cool things

## Pyalias
A Python script that allows you to search accross your alias.
The alias are saved and separated by categories

## TODO
- [ ] Installations fails to unzip fonts in the right folder (failed to create the file $HOME/.fonts/fonts.zip)
- [ ] After changing the shell the script stops, fix it
- [ ] Switch pyalias to rsalias
- [ ] Create something similar to pyalias but for key shortcuts
- [ ] Add gitconfig priorities (rebase for merges, etc...)
- [ ] Find how to set up packer packages for neovim
- [ ] Finish git-hooks (pre-commit)

## Installation

```shell
sudo apt -y install git

git clone https://github.com/lucas-montes/.dotfiles $HOME/.dotfiles

sudo chmod u+x $HOME/.dotfiles/scripts/installation -R

. $HOME/.dotfiles/scripts/installation/install

```
