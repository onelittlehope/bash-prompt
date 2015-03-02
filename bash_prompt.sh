function __my_prmpt_cmd {

    local C1 C2 C3 C4 C5 C6 C7 JOBS_FLAG myUSER USER_WIDTH myPWD 
    local PWD_WIDTH myHOSTNAME HOSTNAME_WIDTH PADDING_WIDTH PADDING
    local TRIMMED_PWD TRIMMED_PWD_WIDTH

    # "jobs %%" prints the job ID of the most recent background process
    #(the "current job") and returns 0 on success or 1 if there is no such job
    if builtin jobs %% &> /dev/null
    then JOBS_FLAG="!"
    else JOBS_FLAG=" "
    fi

    # Setup our prompt's colours:
    C1="\[\e[0;107;30m\]"                       # Marker 1

    # Setup some colours based on what type of user we are:
    if [ $EUID -eq "0" ]; then                  # For root:
        C2="\[\e[0;41;97m\]"                    #  - Marker 2
        C3="\[\e[0;47;91m\]"                    #  - User name
    else                                        # For normal users:
        C2="\[\e[0;42;96m\]"                    #  - Marker 2
        C3="\[\e[0;47;92m\]"                    #  - User name
    fi

    C4="\[\e[0;47;97m\]"                        # @ symbol
    C5="\[\e[0;47;30m\]"                        # Host name
    C6="\[\e[1;100;97m\]"                       # Path
    C7="\[\e[0m\]"                              # Reset all colours

    # Removed external dependency to the whoami binary by using $LOGNAME.
    # Source: https://github.com/coreyreichle/bash-prompt/commit/bf4fa432b418e5701ee153adcd7ede9f672d5f01
    myUSER=$LOGNAME
    USER_WIDTH=${#myUSER}

    # Make PWD nicer by replacing our home directory with ~ if possible.
    myPWD=${PWD//$HOME/\~}
    PWD_WIDTH=${#myPWD}

    # We only want the host name!
    myHOSTNAME=${HOSTNAME%%.*}
    HOSTNAME_WIDTH=${#myHOSTNAME}

    # The magic number 9 = 3 characters for marker1 + 1 character for @ symbol
    # + 5 space characters used to separate the components.
    PADDING_WIDTH=$(($COLUMNS - ($USER_WIDTH + $HOSTNAME_WIDTH + 9 + $PWD_WIDTH)))
    PADDING=$(printf '%-*s' "${PADDING_WIDTH}")

    # If the PWD was very large, PADDING_WIDTH will be negative
    if [ ${PADDING_WIDTH} -le 0 ]; then
        # Due to wanting the tailing part of the PWD string, we need the
        # TRIMMED_PWD_WIDTH variable to be negative and the reason we are
        # negating 3 from it as well, is to account for the ... characters.
        TRIMMED_PWD_WIDTH=$((0-(COLUMNS-(USER_WIDTH+HOSTNAME_WIDTH+9+3))))
        PADDING=""

        # Check if its worth while to show a trimmed PWD
        if [ ${TRIMMED_PWD_WIDTH} -lt 0 ]; then
            TRIMMED_PWD="...${myPWD: ${TRIMMED_PWD_WIDTH}}"
        else
            # If trimming the PWD results in no PWD being shown, then just
            # show the whole path since thats the sensible thing to do.
            TRIMMED_PWD=${PWD}
        fi
    else
        TRIMMED_PWD=${myPWD}
    fi

    # Debugging...
    # echo "Columns width = $COLUMNS"
    # echo "User width = $USER_WIDTH"
    # echo "Hostname width = $HOSTNAME_WIDTH"
    # echo "PWD width = $PWD_WIDTH"
    # echo "Padding width = $PADDING_WIDTH"
    # echo "Trimmed PWD width = ${TRIMMED_PWD_WIDTH}"
    # echo "Trimmed PWD = [${TRIMMED_PWD}]"

    PS1="${C1} ${JOBS_FLAG} ${C7} ${C3} $myUSER${C4}@${C5}$myHOSTNAME ${C6} $TRIMMED_PWD ${PADDING}${C7}\n${C2} \\\$ ${C7} "

}

PROMPT_COMMAND=__my_prmpt_cmd
