dotfiles
========

My dotfiles using the bare repository method.

Initial set up:

```bash
git init --bare $HOME/.dotfiles

# Create an alias (add this to your .bashrc/.zshrc)
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Hide untracked files (so 'status' isn't overwhelming)
dotfiles config --local status.showUntrackedFiles no

# Add and commit files normally
dotfiles add ~/.bashrc ~/.zshrc ~/.vimrc
dotfiles commit -m "Initial dotfiles commit"
dotfiles remote add origin git@github.com:you/dotfiles.git
dotfiles push -u origin main
```

On a new machine:

```bash
git clone --bare git@github.com:you/dotfiles.git $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout
```

## Tips

- **Use a `.gitignore`** in your home dir to avoid accidentally committing secrets
- **Branch per machine** if configs differ significantly between systems (e.g., `work` vs `personal`)
