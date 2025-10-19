export EDITOR=vim
export VISUAL=vim
export ZSH="$HOME/.oh-my-zsh"
export PATH="/opt/gitstatus/bin:$PATH"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-history-substring-search zsh-completions)
source $ZSH/oh-my-zsh.sh
zstyle ':omz:update' mode disabled
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh