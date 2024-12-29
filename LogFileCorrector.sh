#!/bin/bash

directory=$1
validFiles=$(grep -r -l "/20[1-2][0-9]" "$directory")
mkdir -p correctedLogs # make the correctedLogs directory

			for file in $validFiles;	# iterate through the valid files of the directory
			do
			IFS=$'\n' # Set to cut off at the end of the line instead of each space
			set -f
			for line in $(cat < $file); do # iterates through each line of the file
				for (( i=0; i<${#line}; i++ )); do  # iterate through the characters of the line
    					if [ "${line:$i:1}" = '[' ]; then	# looking for the [ to locate the date information
					index=$i	# stores the index of the character
					fi
				done
				char_after=${line:($index+1):1} # var to hold the next char to see if it starts with the day or the month
				if [[ "$char_after" =~ [A-Za-z] ]]; then
					# starts with a month
				days=${line:($index+5):2} # substr to store the day
				month=${line:($index+1):3} # substr to store the month
				else
				days=${line:($index+1):2} # substr to store the day
                                month=${line:($index+4):3} # substr to store the month
				fi
				year=${line:($index+8):4} # substr to store the year
				begstr=${line:0:$index} # substr to store the beginning of the line
				last_char_index=${#line} # find the last index and store into a variable
				endstr=${line:($index+12):last_char_index} # substr to store the endstr
					case $month in # switch case to check for correct dates
					Jan|Mar|May|Jul|Aug|Oct|Dec)
						if [ "$days" -gt 31 ]; then
  							 days=31
						fi	;;
					Apr|Jun|Sep|Nov)
						if [ "$days" -gt 30 ]; then
                                                         days=30
                                       		fi	;;
					*)
						if (( ($year % 4 == 0 && $year % 100 != 0) || $year % 400 == 0 )); then
                                                	if [ "$days" -gt 29 ]; then
                                                        	 days=29
                                                fi
						else
							 if [ "$days" -gt 28 ]; then
                                                                 days=28
						fi
						fi
                                                        ;;
					esac
				modified_line="${begstr}[${days}/${month}/${year}${endstr}" # parse the line together
						mkdir -p correctedLogs/$year # create the directory for the file
				echo "$modified_line" >> correctedLogs/$year/"${month}-${year}_log.txt" # append the line into the file
			done # end the line for loop
			done # end the valid files for loop
