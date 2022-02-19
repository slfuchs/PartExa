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

if [[ $file == *.cpp || $file == *.cc || $file == *.H || $file == *.h || $file == *.hpp ]]; then
  if [[ $(grep -c 'using namespace dealii' $file) -ne 0 ]]; then

    # print warning
    echo "-- Found forbidden 'using namespace dealii'"

    # write file name to error file
    echo "$file" >> code-checks-namespace-dealii.err

  fi
fi
