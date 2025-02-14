# returns for non-interactive shells
[[ $- != *i* ]] && return


#----------------------------------------------------------------------
# tune global options
#----------------------------------------------------------------------
HISTSIZE=5000
HISTFILESIZE=10000


#----------------------------------------------------------------------
# utility
#----------------------------------------------------------------------

# Easy extract
function q-extract
{
	if [ -f $1 ] ; then
		case $1 in
		*.tar.bz2)   tar -xvjf $1    ;;
		*.tar.gz)    tar -xvzf $1    ;;
		*.tar.xz)    tar -xvJf $1    ;;
		*.bz2)       bunzip2 $1     ;;
		*.rar)       rar x $1       ;;
		*.gz)        gunzip $1      ;;
		*.tar)       tar -xvf $1     ;;
		*.tbz2)      tar -xvjf $1    ;;
		*.tgz)       tar -xvzf $1    ;;
		*.zip)       unzip $1       ;;
		*.Z)         uncompress $1  ;;
		*.7z)        7z x $1        ;;
		*)           echo "don't know how to extract '$1'..." ;;
		esac
	else
		echo "'$1' is not a valid file!"
	fi
}

# easy compress - archive wrapper
function q-compress
{
	if [ -n "$1" ] ; then
		FILE=$1
		case $FILE in
		*.tar) shift && tar -cf $FILE $* ;;
		*.tar.bz2) shift && tar -cjf $FILE $* ;;
		*.tar.xz) shift && tar -cJf $FILE $* ;;
		*.tar.gz) shift && tar -czf $FILE $* ;;
		*.tgz) shift && tar -czf $FILE $* ;;
		*.zip) shift && zip $FILE $* ;;
		*.rar) shift && rar $FILE $* ;;
		esac
	else
		echo "usage: q-compress <foo.tar.gz> ./foo ./bar"
	fi
}


# Display ANSI colours. Found this on the interwebs, credited
# to "HH".
function q-ansicolors 
{
	esc="\033["
	echo -e "\t  40\t   41\t   42\t    43\t      44       45\t46\t 47"
	for fore in 30 31 32 33 34 35 36 37; do
		line1="$fore  "
		line2="    "
		for back in 40 41 42 43 44 45 46 47; do
			line1="${line1}${esc}${back};${fore}m Normal  ${esc}0m"
			line2="${line2}${esc}${back};${fore};1m Bold    ${esc}0m"
		done
		echo -e "$line1\n$line2"
	done

	echo ""
	echo "# Example:"
	echo "#"
	echo "# Type a Blinkin TJEENARE in Swedens colours (Yellow on Blue)"
	echo "#"
	echo "#           ESC"
	echo "#            |  CD"
	echo "#            |  | CD2"
	echo "#            |  | | FG"
	echo "#            |  | | |  BG + m"
	echo "#            |  | | |  |         END-CD"
	echo "#            |  | | |  |            |"
	echo "# echo -e '\033[1;5;33;44mTJEENARE\033[0m'"
	echo "#"
	echo "# Sedika Signing off for now ;->"
}


#----------------------------------------------------------------------
# Logout
#----------------------------------------------------------------------

# Function to run upon exit of shell.
function _exit() {
	echo "Logged out actively at `date`"
}

function proxy_off() {
    unset no_proxy
    unset http_proxy
    unset https_proxy
    unset all_proxy
    echo -e "Proxy Disabled"
}

function proxy_on() {
    # CIDR 网段表示法只在部份受支持的程序里起效
    # 如果不起效，那么需要直接设置具体的 IP 地址
    export no_proxy=localhost,127.0.0.1,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    export http_proxy=http://10.208.62.158:7890
    export https_proxy=http://10.208.62.158:7890
    export all_proxy=socks://10.208.62.158:7890
    echo -e "Proxy Enabled"
}