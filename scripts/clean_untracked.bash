#!/usr/bin/env bash

# See the decription of these settings in scripts/README.md file
set -Eeuxo pipefail

cd $(dirname "$0")

if [ -d ../.git ]
then
  mv ../.gitignore ../gitignore
  git clean -d -f ../*/
  mv ../gitignore ../.gitignore
fi
