#!/bin/bash

set -e
set -o pipefail

domain=$1
repo=$1

echo "Setting up Deno project 🦕 ..."
echo "domain=$domain"
echo "repo=$repo"
echo "----------"