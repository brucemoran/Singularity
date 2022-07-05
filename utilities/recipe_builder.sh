#! bin/bash

##since Singularity hub has gone, we need a way to pull these containers
##this downloads the recipe from Github, builds into a designated dir

##arguments are:
##$1 recipe_name, this is grepped from all files available in -t(ype) scs or shub
##$2 output dir
recipe=$1;
dir=$2;

if [[ $1 =~ "^-h" || $1 =~ "^--h" || $1 == "" ]]; then
  echo -ne "Usage:\nsh recipe_builder.sh <recipe.file> <path/to/output/dir> "
  echo -e "optional: <scs/shub> <dryrun>"
else
  ##set type to scs as this still exists, but allow changing using $3
  if [[ ! $3 =~ "^s" ]]; then
    type="scs"
  fi

  if [[ $3 =~ "shub" ]]; then
    type="shub"
    typf="brucemoran-Singularity-"
  fi

  ##download git repo and get file, build
  git clone https://github.com/brucemoran/Singularity "singtmp"
  file=$(find singtmp | grep ${type} | grep ${recipe})
  echo "Found $file, building..."

  ##create naming structure for scs
  if [[ ${type} == "scs" ]]; then
    typf="bruce.moran-default-"$(echo $file | perl -ane '@s=split("scs/", $F[0]); print "$s[1]\n";' | sed "s/${recipe}//" | sed 's/\//-/g')
  fi

  buildn=${dir}/${typf}$(echo ${file##*/} | awk '{print tolower($0)}' | sed 's/recipe.//')".img"
  echo "Build into ${buildn}..."
  if [[ ! $4 == "dryrun" ]]; then
    singularity build --remote ${buildn} ${file}
  fi

  rm -rf singtmp
fi
