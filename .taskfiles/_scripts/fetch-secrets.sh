#!/usr/bin/env bash

HOSTNAME=$(hostname -s)

function listSecrets() {
  op item list --tags $HOSTNAME
}

function fetchAllSecrets() {
  secrets=$(op item list --tags $HOSTNAME | sed 1,1d | awk '{print $1}')
  for id in $secrets; do
    fetchSecret $id
  done
}

function fetchPath() {
  local id
  local paths
  local path

  id=$1
  paths=$(op item get $id --format json | jq -r .fields[].label | grep :path)
  path=$(echo $paths | grep $HOSTNAME:path)
  if [[ -n $path ]]; then
    echo $(op item get $id --fields label=$HOSTNAME:path --format json | jq -r .value)
  else
    path=$(echo $paths | grep $(uname):path)
    if [[ -n $path ]]; then
      echo $(op item get $id --fields label=$(uname):path --format json | jq -r .value)
    else
      echo $(op item get $id --fields label=default:path --format json | jq -r .value)
    fi
  fi
}

function fetchScript() {
  local id
  local scripts
  local script

  id=$1
  scripts=$(op item get $id --format json | jq -r .fields[].label | grep :script)
  script=$(echo $scripts | grep $HOSTNAME:script)
  if [[ -n $script ]]; then
    echo $HOSTNAME:script
  else
    script=$(echo $scripts | grep $(uname):script)
    if [[ -n $script ]]; then
      echo $(uname):script
    else
      script=$(echo $scripts | grep default:script)
      if [[ -n $script ]]; then
        echo default:script
      else
        echo ""
      fi
    fi
  fi
}

function fetchSecret() {
  local id
  local info
  local title
  local filename
  local path
  local script

  id=$1
  info=$(op item get $id --format json)
  title=$(echo $info | jq -r .title)
  filename=$(echo $info | jq -r .files[0].name)

  echo Processing $title
  path=$(fetchPath $id)
  script=$(fetchScript $id)
  mkdir -p $path
  rm -f $path/$filename
  op document get $id --out-file $path/$filename > /dev/null
  if [[ -n $script ]]; then
    op item get $id --fields label=$script --format json | jq -r .value > script
    source ./script
    rm script
  fi
}

case $1 in
  all)
    fetchAllSecrets
    ;;
  list)
    listSecrets
    ;;
  *)
    if [[ -z $1 ]]; then
      fetchAllSecrets
    else
      fetchSecret $1
    fi
    ;;
esac
