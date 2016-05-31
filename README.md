# bash-prompt
Features
--------
* `bash-prompt.sh` - a neat looking bash prompt which dynamically trims the PWD and warns if you have background jobs. Its 99% pure bash and has one external dependency (tput) which is needed to figure out whether the terminal supports colours.
* `bash-audit-log.sh` - a script which neatly stores bash history in files named `YYYY-MM-DD` in `~/.bash_history/YYYY-MM/` folders. It records when the user had logged in, what commands were run and when the user had logged out. The type of detail recorded is:
    *  Audit Type (LOGIN / LOGOUT / COMMAND)
    *  Date + time in RFC 3339 format (2016-05-31 21:50:13.303030811+01:00)
    *  History command number
    *  Parent process ID
    *  UID
    *  EUID
    *  SHLVL (how deeply the current bash shell is nested)
    *  Login user name
    *  Login user's PID
    *  Current user name
    *  PID of the current shell
    *  TTY or SSH connection details
    *  Current working directory
    *  Command run

    This script isn't pure bash and has several external dependencies (date / who / awk). I've only tested it with the GNU version of these utils.

* `bash-preexec.sh` - Ryan Caloras's [bash-prexec](https://github.com/rcaloras/bash-preexec). This is used by both of the above scripts and it provides preexec and precmd hook functions for Bash in the style of Zsh. I came across it via the following [post](http://superuser.com/a/175802).

**Note:** The `bash-prompt.sh` and `bash-audit-log.sh` scripts are independent of each other. You can choose to use your own prompt and add audit logging capability to it by simply making use of the bash-audit-log.sh script alone. However, both scripts do require the `bash-preexec.sh` script.

Usage
-----
Copy the three (or two) scripts in to your `/etc/profile.d` folder to install this system wide or copy them to any other location you want and then source them from your `~/.bash_profile` script.

Screenshot
----------
This is what it looks like:

![screenshot](https://raw.githubusercontent.com/onelittlehope/bash-prompt/master/bash_prompt.png)

![screenshot](https://raw.githubusercontent.com/onelittlehope/bash-prompt/master/bash_prompt2.png)

![screenshot](https://raw.githubusercontent.com/onelittlehope/bash-prompt/master/bash_prompt3.png)

