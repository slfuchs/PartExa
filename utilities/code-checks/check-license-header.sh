#!/bin/bash
## ---------------------------------------------------------------------
##
## PartExa - A Particle Library for the Exa-Scale
##
## Copyright (C) 2022 by the PartExa authors
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <https://www.gnu.org/licenses/>.
##
## ---------------------------------------------------------------------

if [[ -f $1 ]]; then
  file=$1
else
  echo "No file provided!"
  exit 1
fi

# determine pure file name without full path
name=$(basename $file)
  
# examine file type and determine comment symbol
if [[ $name == CMakeLists.txt || $name == *.cmake || $name == *.sh ]]; then
  comment="##"
elif [[ $name == *.h || $name == *.h.in || $name == *.cc ]]; then
  comment="\/\/" 
elif [[ $name == *.rst ]]; then
  comment=".."
else
  exit 0
fi

# get the year the file is added to the repository
yearadded=$(git log --diff-filter=A --follow --find-renames=90% --format=%ad --date=format:'%Y' -- $file | tail -n 1)

# set current year if the file is not in the repository yet
if [[ -z "$yearadded" ]]; then
  yearadded=$(date +"%Y")
fi

# get the year of the last modification of the file
yearlastmod=$(git log --format="%ad" --date=format:'%Y' --max-count=1 -- $file)

# set current year if the file is not in the repository yet
if [[ -z "$yearlastmod" ]]; then
  yearlastmod=$yearadded
fi

# set current year if file is indexed
if [[ -n $(git status --porcelain 2>/dev/null | grep $file | grep "^A\|^C\|^M\|^R\|") ]]; then
  yearlastmod=$yearadded
fi

# generate range of years
if [[ "$yearadded" == "$yearlastmod" ]]; then
  years=$yearadded
else
  years=$yearadded-$yearlastmod
fi

# generate correct license header
sed -e "s/\${comment}/$comment/" -e "s/\${years}/$years/" utilities/code-checks/template-license-header > correct-license-header

# determine number of lines of correct license header
headerlines=$(wc -l < utilities/code-checks/template-license-header)

# check for shebang in first line
if [[ $(head -c 2 $file) == "#!" ]]; then
  shebang=1
else
  shebang=0
fi

# get number of different lines
numlinediff=$(sed -n "$((1+$shebang)),$(($headerlines+$shebang)) p" $file | diff --side-by-side --suppress-common-lines correct-license-header - | wc -l)

# print warning and correct header if non-compliant license header found
if [[ ! $numlinediff == 0 ]]; then

  # print warning
  echo "-- Non-compliant license header"

  # write file name and correct license header to error file
  echo "$file" >> code-checks-license-header.err
  cat correct-license-header >> code-checks-license-header.err

fi

# remove generated correct license header
rm correct-license-header
