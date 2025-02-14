#----------------------------------------------------------------------
# Initialize environment and alias
#----------------------------------------------------------------------
case "$OSTYPE" in
	*gnu*|*linux*|*msys*|*cygwin*|*solaris*) alias ls='ls --color' ;;
	*freebsd*|*darwin*) alias ls='ls -G' ;;
esac


alias ll='ls -lh'
alias la='ls -lAh'


case "$OSTYPE" in
	*solaris*) ;;
	*) alias grep='grep --color=tty' ;;
esac


# setup for /usr/local/app/bin if it exists
if [ -d /usr/local/app/bin ]; then
	export PATH="/usr/local/app/bin:$PATH"
fi

# setup for ~/bin if it exists
if [ -d "$HOME/bin" ]; then
	export PATH="$HOME/bin:$PATH"
fi

# setup for ~/.local/bin if it exists
if [ -d "$HOME/.local/bin" ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

# setup for java environment if it exists
# check if the first element of the array is a directory. The script will only use the first directory found.
java_dirs=($HOME/softwares/java-11-openjdk-*)
if [ -d "${java_dirs[0]}" ]; then
	export JAVA_HOME="${java_dirs[0]}"
	export PATH="$JAVA_HOME/bin:$PATH"
fi

# setup for maven environment if it exists
# check if the first element of the array is a directory. The script will only use the first directory found.
maven_dirs=($HOME/softwares/apache-maven-*)
if [ -d "${maven_dirs[0]}" ]; then
	export MAVEN_HOME="${maven_dirs[0]}"
	export PATH="$MAVEN_HOME/bin:$PATH"
fi


#----------------------------------------------------------------------
# exit if not bash/zsh, or not in an interactive shell
#----------------------------------------------------------------------
[ -z "$BASH_VERSION" ] && [ -z "$ZSH_VERSION" ] && return
[[ $- != *i* ]] && return


#----------------------------------------------------------------------
# other interactive shell settings
#----------------------------------------------------------------------
export GCC_COLORS=1
export EXECIGNORE="*.dll"


