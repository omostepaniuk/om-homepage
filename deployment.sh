#!/bin/bash

# bash ftp deployment script
# version 1.0.0

# check if all configuration options have been provided
# upload

# source directory to be uploaded (contents without a directory itself)
SOURCE_DIR=./_site

declare -A DEPLOYMENT_SETTINGS

function print_help(){
  printf "Usage: -e|--environment <environment_to_deploy_to> -- target environment (e.g. staging/production)\n    -f|--file <name_of_configuration_file>"
}

function parse_config(){
  echo "Parsing configuration file ..."
  if [[ -z $1 ]] || [[ ! -f $1 ]]; then
    echo "Please, specify correct configuration file to use"
    exit 1
  fi

  while read line; do
    if [[ $line =~ ^"["(.+)"]"$ ]]; then
      section=${BASH_REMATCH[1]}
    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
      #declare ${arrname}[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
      if [[ ${TARGET_ENVIRONMENT,,} == ${section,,} ]]; then
        read DEPLOYMENT_SETTINGS[${BASH_REMATCH[1]}] <<< "${BASH_REMATCH[2]}"
      fi
    fi
  done < $1

  # test it
  #for i in "${!STAGING[@]}"; do echo "$i ==> ${STAGING[$i]}"; done
  #echo length: ${#STAGING[@]}
}

if [[ $# < 2 ]]; then
  print_help
  exit 1
fi

# parsing command-line options
while [[ $# > 1 ]]
do
  key="$1"

  case $key in
    -e|--environment)
      TARGET_ENVIRONMENT="$2"
      shift
    ;;
    -f|--file)
      CONFIG_FILE="$2"
      shift
    ;;
    *)
      print_help
      # TODO can we exit the script from within while loop?
      exit 1
    ;;
  esac
  shift
done

# checking correct target environment has been specified
if [[ $TARGET_ENVIRONMENT != "staging" && $TARGET_ENVIRONMENT != "production" ]]; then
  echo "Unknown type of target environment specified. Either 'staging' or 'production' must be used with -e option"
  exit 1
fi

# reading configuration
parse_config $CONFIG_FILE

FTP_USER=${DEPLOYMENT_SETTINGS[FTP_USER]}
FTP_HOST=${DEPLOYMENT_SETTINGS[FTP_HOST]}
FTP_DIR=${DEPLOYMENT_SETTINGS[FTP_TARGET_DIR]}

lftp ftp://$FTP_USER@$FTP_HOST -e "set ftp:ssl-allow no; mirror --exclude .htaccess --delete-first -R $SOURCE_DIR $FTP_DIR ; quit"

echo "Success!"
