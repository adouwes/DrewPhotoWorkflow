#!/bin/bash

# http://drew.pub Workflow SD Camera Card Ripper

# Directory where SD Cards will show up
basedir=/Volumes

# Volumes to ignore grabbing files from. To list all, leave blank (omitdir="")
omitdir="Macintosh HD"

# Destination for all media files
basedestdir=/Volumes/3GIGABERRY

# New destination directory name will include the date
newdirname=$basedestdir/$(date +%F)

shopt -s extglob nullglob
# Create array of directories within base directory so user can select which SD card to rip media from.
 if [[ -z "$omitdir" ]]; then
   cdarray=( "$basedir"/*/ )
else
   cdarray=( "$basedir"/!("$omitdir")/ )
fi
# remove leading basedir:
cdarray=( "${cdarray[@]#"$basedir/"}" )
# remove trailing backslash and insert Exit choice
cdarray=( Exit "${cdarray[@]%/}" )

# Confirm at least 1 directory exists.
if ((${#cdarray[@]}<=1)); then
    printf 'No directories found. Exiting.\n'
    exit 0
fi

# Prompt user to select Media Source:
printf 'Please choose directory to copy media from:\n'
for i in "${!cdarray[@]}"; do
    printf '   %d %s\n' "$i" "${cdarray[i]}"
done
printf '\n'

# Now wait for user input
while true; do
    read -e -r -p 'Your choice: ' choice
    # Check that user's choice is a valid number
    if [[ $choice = +([[:digit:]]) ]]; then
        # Force the number to be interpreted in radix 10
        ((choice=10#$choice))
        # Check that choice is a valid choice
        ((choice<${#cdarray[@]})) && break
    fi
    printf 'Invalid choice, please start again.\n'
done

# At this point, you're sure the variable choice contains
# a valid choice.
if ((choice==0)); then
    printf 'Good bye.\n'
    exit 0
fi

# Now you can work with subdirectory:
usersource="$basedir/${cdarray[choice]}"
echo $usersource

# If destination directory already exists, generate random name... else just generate the dir with standard name.
if [ -d "$newdirname" ]; then
  echo "$newdirname already exists. Generating random name."
  randomdirname=$(mktemp -d $newdirname.XXXXX)
  else
    mkdir $basedestdir/$(date +%F)
    randomdirname="$basedestdir/$(date +%F)"
fi

find $usersource -type f \( -iname \*.JPG -o -iname \*.MOV \) -exec cp -v {} $randomdirname \;

echo "Source Size:"
du -h -c $usersource | tail -1

echo "Destination Size:"
du -h -c $randomdirname | tail -1

read -p "Would you like a detailed breakdown of both directories? [y/N] " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo
  echo "####### SOURCE DIRECTORY"
  du -h -c $usersource
  echo
  echo "#################################################"
  echo
  echo "####### DESTINATION DIRECTORY"
  du -h -c $randomdirname
fi
