#
# ~/.bashrc
#

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\e[1;35m\]\u\[\e[1;37m\] \[\e[1;32m\]\W\[\e[1;37m\] $ \[\e[1;36m\]'
		#PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		#PS1='\u@\h \w \$ '
		PS1='[\u@\h \W]\$ '
	fi
fi

unset use_color safe_term match_lhs sh

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# better yaourt colors
export YAOURT_COLORS="nb=1:pkg=1:ver=1;32:lver=1;45:installed=1;42:grp=1;34:od=1;41;5:votes=1;44:dsc=0:other=1;35"

# NVM
source /usr/share/nvm/init-nvm.sh

# alias
alias ll="ls -la"
alias ..="cd .."
alias ifconfig="ip address"
alias dig="drill"
alias guf="git fetch upstream && git rebase upstream/master && git push && git push --tags"
alias gufm="git fetch upstream && git rebase upstream/main && git push origin main --force && git push --tags"
alias freex="free -h | head -2 && sync && sudo sysctl -w vm.drop_caches=3 && free -h | head -2"

########################## Kubernetes #############################################
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k

# krew (K8s plugin manager)
export PATH="$PATH:$HOME/.krew/bin"

# Release Notes - Shadow - krel
export KUBE_EDITOR="code -w"

########################## Rackspace - KAAS #######################################
export AWS_CREDS_DIR=/home/ramrodo/.aws/
export KAASCTL_CONFIG_DIR=/home/ramrodo/git/ramrodo-forks/kaas/secrets/unencrypted/.kaas
export KAASCTL_PROVIDER_NAME=dev1

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export RS_USERNAME=rms-sre-rodolfo-martinez 
export RS_API_KEY=d71f7e0e5234481aa4cc8d3ad04dc112

########################## Go ###################################################
export PATH=$PATH:$HOME/go/bin
export GOPATH=$(go env GOPATH)

########################## Ruby #################################################
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

############################## Commands helpful #############################
# Cleanup Docker
# Stop all containers
# docker stop `docker ps -qa`

# Remove all containers
# docker rm `docker ps -qa`

# Remove all images
# docker rmi -f `docker images -qa `

# Remove all volumes
# docker volume rm $(docker volume ls -q)

################## Common used/util commands #######################
# Extract a page of a PDF
# pdftk 9_Estado-de-cuenta.pdf cat 1 output 9_Estado-de-cuenta-caratula.pdf
# Merge two PDFs with specific pages into one
# pdftk A=Llenado.pdf B=Scan.pdf cat A1-4 B1-2 output SGMM-cambio-poliza.pdf
# Merge many PDFs into one
# pdftk file1.pdf file2.pdf file3.pdf cat output newfile.pdf
# Decrypt/Remove password from PDFs
# qpdf --password=<pwd-here> --decrypt 2022-12.pdf 2022-12-d.pdf

### 1Password CLI
source /home/ramrodo/.config/op/plugins.sh


# add Pulumi to the PATH
export PATH=$PATH:$HOME/.pulumi/bin
