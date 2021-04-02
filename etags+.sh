########################################
########### ORIENTQATION ###############
########################################

# PURPOSE: Creates a TAGS file for Python code, useable by Emacs.
# Unlike the usual "etags" program,
# this also creates tags for constants, not just functions.

# USAGE: Run this from the folder where I want a TAGS file to appear,
# to create tags for all python files anywhere in that folder or its descendents.
# find . -name "*.py" | xargs ~/bash/etags+.sh

# ORIGIN:
# https://stackoverflow.com/questions/66755201/python-in-emacs-jump-to-the-definition-of-a-top-level-constant/66759956?noredirect=1#comment118171644_66759956


########################################
############# THE CODE #################
########################################

#!/bin/bash

# make sure that some input files are provided, or else there's
# nothing to parse
if [ $# -eq 0 ]; then
    # the following message is just a copy of etags' error message
    echo "$(basename ${0}): no input files specified."
    echo "  Try '$(basename ${0}) --help' for a complete list of options."
    exit 1
fi

# extract all non-flag parameters as the actual filenames to consider
TAGS2="TAGS2"
argflags=($(etags -h | grep '^-' | sed 's/,.*$//' | grep ' ' | awk '{print $1}'))
files=()
skip=0
for arg in "${@}"; do
    # the variable 'skip' signals arguments that should not be
    # considered as filenames, even though they don't start with a
    # hyphen
    if [ ${skip} -eq 0 ]; then
        # arguments that start with a hyphen are considered flags and
        # thus not added to the 'files' array
        if [ "${arg:0:1}" = '-' ]; then
            if [ "${arg:0:9}" = "--output=" ]; then
                TAGS2="${arg:9}2"
            else
                # however, since some flags take a parameter, we also
                # check whether we should skip the next command line
                # argument: the arguments for which this is the case are
                # contained in 'argflags'
                for argflag in ${argflags[@]}; do
                    if [ "${argflag}" = "${arg}" ]; then
                        # we need to skip the next 'arg', but in case the
                        # current flag is '-o' we should still look at the
                        # next 'arg' so as to update the path to the
                        # output file of our own parsing below
                        if [ "${arg}" = "-o" ]; then
                            # the next 'arg' will be etags' output file
                            skip=2
                        else
                            skip=1
                        fi
                        break
                    fi
                done
            fi
        else
            files+=("${arg}")
        fi
    else
        # the current 'arg' is not an input file, but it may be the
        # path to the etags output file
        if [ "${skip}" = 2 ]; then
            TAGS2="${arg}2"
        fi
        skip=0
    fi
done

# create a separate TAGS file specifically for global variables
for file in "${files[@]}"; do
    # find all lines that are not indented, are not comments or
    # decorators, and contain a '=' character, then turn them into
    # TAGS format, except that the filename is prepended
    grep -P -Hbn '^[^[# \t].*=' "${file}" | sed -E 's/([0-9]+):([0-9]+):([^= \t]+)\s*=.*$/\3\x7f\1,\2/'
done |\

# count the bytes of each entry - this is needed for the TAGS
# specification
while read line; do
    echo "$(echo $line | sed 's/^.*://' | wc -c):$line"
done |\

# turn the information above into the correct TAGS file format
awk -F: '
    BEGIN { filename=""; numlines=0 }
    {
        if (filename != $2) {
            if (numlines > 0) {
                print "\x0c\n" filename "," bytes+1

                for (i in lines) {
                    print lines[i]
                    delete lines[i]
                }
            }

            filename=$2
            numlines=0
            bytes=0
        }

        lines[numlines++] = $3;
        bytes += $1;
    }
    END {
        if (numlines > 0) {
            print "\x0c\n" filename "," bytes+1

            for (i in lines)
                print lines[i]
        }
    }' > "${TAGS2}"

# now run the actual etags, instructing it to include the global
# variables information
if ! etags -i "${TAGS2}" "${@}"; then
    # if etags failed to create the TAGS file, also delete the TAGS2
    # file
    /bin/rm -f "${TAGS2}"
fi
