#!/usr/bin/env bash

# Avoid sourcing this file more than once
if [ "${__my_prmpt_sourced}" == "$$" ]; then
    return
else
    declare -rx __my_prmpt_sourced="$$"
fi


# Load the bash-preexec.sh script's functions
__script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${__script_path}/bash-preexec.sh"
unset __script_path


#-------------------------------------------------------------------------------
function __my_prmpt_cmd {

    local __my_prmpt_marker1  __my_prmpt_marker2   __my_prmpt_username
    local __my_prmpt_atsymbol __my_prmpt_hostname  __my_prmpt_path
    local __my_prmpt_colours  __my_prmpt_jobs_flag __my_prmpt_resetcolours
    local __my_prmpt_usr __my_prmpt_usr_width __my_prmpt_host __my_prmpt_pad
    local __my_prmpt_pwd __my_prmpt_pwd_width __my_prmpt_host_width
    local __my_prmpt_pad_width __my_prmpt_trim_pwd __my_prmpt_trim_pwd_width

    # "jobs %%" prints the job ID of the most recent background process
    #(the "current job") and returns 0 on success or 1 if there is no such job
    if builtin jobs %% &> /dev/null
    then __my_prmpt_jobs_flag="!"
    else __my_prmpt_jobs_flag=" "
    fi

    # Check if stdout is a terminal...
    if test -t 1; then

        __my_prmpt_colours=$(tput colors)

        # See if it supports colours...
        if test -n "${__my_prmpt_colours}" && test ${__my_prmpt_colours} -ge 8; then

            if [ "$TERM" == "linux" ]; then
                __my_prmpt_marker1="\[\e[5;47;30m\]"
                if [ $EUID -eq "0" ]; then
                    # For root:
                    __my_prmpt_marker2="\[\e[5;41;97m\]"
                else
                    # For normal users:
                    __my_prmpt_marker2="\[\e[5;42;97m\]"
                fi
                __my_prmpt_username="\[\e[0;47;30m\]"
                __my_prmpt_atsymbol="\[\e[0;47;34m\]"
                __my_prmpt_hostname="\[\e[0;47;30m\]"
                __my_prmpt_path="\[\e[5;40;37m\]"
                __my_prmpt_resetcolours="\[\e[0m\]"
            else
                __my_prmpt_marker1="\[\e[0;107;30m\]"
                if [ $EUID -eq "0" ]; then
                    # For root:
                    __my_prmpt_marker2="\[\e[0;41;97m\]"
                else
                    # For normal users:
                    __my_prmpt_marker2="\[\e[0;42;96m\]"
                fi
                __my_prmpt_username="\[\e[0;47;30m\]"
                __my_prmpt_atsymbol="\[\e[0;47;34m\]"
                __my_prmpt_hostname="\[\e[0;47;30m\]"
                __my_prmpt_path="\[\e[1;100;97m\]"
                __my_prmpt_resetcolours="\[\e[0m\]"
            fi
        else
            __my_prmpt_marker1=""
            __my_prmpt_marker2=""
            __my_prmpt_username=""
            __my_prmpt_atsymbol=""
            __my_prmpt_hostname=""
            __my_prmpt_path=""
            __my_prmpt_resetcolours=""
        fi
    fi

    __my_prmpt_usr=$LOGNAME
    __my_prmpt_usr_width=${#__my_prmpt_usr}

    # Make PWD nicer by replacing our home directory with ~ if possible.
    __my_prmpt_pwd=${PWD//$HOME/\~}
    __my_prmpt_pwd_width=${#__my_prmpt_pwd}

    # We only want the host name!
    __my_prmpt_host=${HOSTNAME%%.*}
    __my_prmpt_host_width=${#__my_prmpt_host}

    # The magic number 9 = 3 characters for marker1 + 1 character for @ symbol
    # + 5 space characters used to separate the components.
    __my_prmpt_pad_width=$(($COLUMNS - ($__my_prmpt_usr_width + $__my_prmpt_host_width + 9 + $__my_prmpt_pwd_width)))
    __my_prmpt_pad=$(printf '%-*s' "${__my_prmpt_pad_width}")

    # If the PWD was very large, __my_prmpt_pad_width will be negative
    if [ ${__my_prmpt_pad_width} -le 0 ]; then
        # Due to wanting the tailing part of the PWD string, we need the
        # __my_prmpt_trim_pwd_width variable to be negative and the reason we are
        # negating 3 from it as well, is to account for the ... characters.
        __my_prmpt_trim_pwd_width=$((0-(COLUMNS-(__my_prmpt_usr_width+__my_prmpt_host_width+9+3))))
        __my_prmpt_pad=""

        # Check if its worth while to show a trimmed PWD
        if [ ${__my_prmpt_trim_pwd_width} -lt 0 ]; then
            __my_prmpt_trim_pwd="...${__my_prmpt_pwd: ${__my_prmpt_trim_pwd_width}}"
        else
            # If trimming the PWD results in no PWD being shown, then just
            # show the whole path since that's the sensible thing to do.
            __my_prmpt_trim_pwd=${PWD}
        fi
    else
        __my_prmpt_trim_pwd=${__my_prmpt_pwd}
    fi

    PS1="${__my_prmpt_marker1} ${__my_prmpt_jobs_flag} ${__my_prmpt_resetcolours} ${__my_prmpt_username} $__my_prmpt_usr${__my_prmpt_atsymbol}@${__my_prmpt_hostname}$__my_prmpt_host ${__my_prmpt_path} $__my_prmpt_trim_pwd ${__my_prmpt_pad}${__my_prmpt_resetcolours}\n${__my_prmpt_marker2} \\\$ ${__my_prmpt_resetcolours} "

}
#-------------------------------------------------------------------------------

# Add our prompt command to the precmd array
precmd_functions+=(__my_prmpt_cmd)
