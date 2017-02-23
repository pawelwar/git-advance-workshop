#!/bin/bash
hasMaltese=$(cat README.md | grep "five.maltese()")
if [[ -z $hasMaltese ]]; then
  echo "ok"
  exit 0
fi
echo "error"
exit 1
