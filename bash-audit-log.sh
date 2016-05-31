#!/usr/bin/env bash

# Avoid sourcing this file more than once
if [ "${__my_audit_log_sourced}" == "$$" ]; then
    return
else
    declare -rx __my_audit_log_sourced="$$"
fi


# Load the bash-preexec.sh script's functions
__script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${__script_path}/bash-preexec.sh"
unset __script_path


# Configure Bash's history options
# --------------------------------
# - If HISTFILE is unset, or if the history file is not writeable, the history
#   is not saved. We deliberately unset HISTFILE since we will be managing the
#   recording history commands to file by ourselves.
# - We also don't want any limits on the size of history entries in memory /
#   file.
unset -v HISTSIZE HISTFILESIZE HISTFILE

# We don't want to ignore duplicates, spaces or patterns.
declare -x HISTCONTROL=""
declare -x HISTIGNORE=""

# When typing the "history" command, ensure a time stamp is displayed against
# each command.
declare -x HISTTIMEFORMAT="[%F %T] "

# If set, Bash attempts to save all lines of a multiple-line command in the
# same history entry. This allows easy re-editing of multi-line commands.
shopt -s cmdhist

# If set, and Readline is being used, a user is given the opportunity to
# re-edit a failed history substitution.
shopt -s histreedit

# If the histverify shell option is enabled, and Readline is being used,
# history substitutions are not immediately passed to the shell parser.
# Instead, the expanded line is reloaded into the Readline editing buffer
# for further modification.
shopt -s histverify

# If set, Bash checks the window size after each command and, if necessary,
# updates the values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable extended pattern matching features.
shopt -s extglob

#-------------------------------------------------------------------------------
function __my_audit_log() {

    local __auditstr __audittype __datetime __histcmd __histfile
    local __loginuser __loginpid __ssh __tty

    __audittype=$1
    __histcmd=$2
    __histcmdnum=$3

    __datetime="$(date --rfc-3339=ns)"
    __histfile="$HOME/.bash_history/$(date '+%Y-%m/%Y-%m-%d')"

    __loginuser="$(who -mu | awk '{print $1}')"
    __loginpid="$(who -mu | awk '{print $6}')"

    __ssh="$([ -n "$SSH_CONNECTION" ] && echo "$SSH_CONNECTION" | awk '{print " | "$1":"$2"->"$3":"$4}')"
    __tty="$(who -mu | awk '{print $2}')"

    case "${__audittype}" in
        command)
            __auditstr="# COMMAND"
            ;;
        login)
            __auditstr="# LOGIN  "
            ;;
        logout)
            __auditstr="# LOGOUT "
            ;;
        *)
            __auditstr="# INVALID"
            ;;
    esac

    __auditstr="${__auditstr} | ${__datetime} | ${__histcmdnum} | PPID=${PPID}, UID=${UID}, EUID=${EUID}, SHLVL=${SHLVL} | ${__loginuser}/${__loginpid} as ${USER}/$$ on ${__tty}${__ssh} | ${PWD}\n${__histcmd}"

    # As we cannot have a file and folder with the same name, we check and
    # remove any existing .bash_history file before creating the folder
    # with the same name.
    if [ -f "$HOME/.bash_history" ]; then
        rm -f "$HOME/.bash_history"
    fi

    mkdir -p "${__histfile%/*}"

    echo -e "${__auditstr}" >> "${__histfile}"

}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
function __my_audit_log_cmd_exit() {
    trap - EXIT
    __my_audit_log "logout" "" "-1"
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
function __my_audit_log_cmd() {

    local __histcmd __currhistlinecmdnum __currhistlinecmd

    # Current history command
    __histcmd="$(history 1)"

    # Extract just the history command number from __histcmd:
    __currhistlinecmdnum="${__histcmd%%+([^ 0-9])*}"

    # Strip spaces from the command number
    __currhistlinecmdnum="${__currhistlinecmdnum// }"

    # Extract the history command
    __currhistlinecmd="${__histcmd##*( )+([0-9])*( )\[+([0-9])-+([0-9])-+([0-9])*( )+([0-9]):+([0-9]):+([0-9])\] }"

    # Avoid logging un-executed commands. E.g. after a 'ctrl+c', 'empty+enter'
    if [ "${__currhistlinecmdnum:-0}" -eq "${__my_prmpt_lasthistline:-0}" ]; then
        return
    else
        # Record history entry to file
        __my_audit_log "command" "${__currhistlinecmd}" "${__currhistlinecmdnum}"
        __my_prmpt_lasthistline="${__currhistlinecmdnum}"
    fi
}
#-------------------------------------------------------------------------------


# To avoid logging the same history line twice, we track what the last history
# line was.
declare -x __my_prmpt_lasthistline=""

# Record a login record in the history file when this file is sourced
__my_audit_log "login" "" "0"

# Setup a trap to catch the exit from the shell so that we may record a logout
# entry into the history file
trap __my_audit_log_cmd_exit EXIT

# Add the audit log command to the preexec array
preexec_functions+=(__my_audit_log_cmd)
