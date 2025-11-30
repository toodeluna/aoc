#!/usr/bin/env bash

usage() {
  echo "usage: $0 -y <year> -l <language> -d <day>"
  exit 1
}

year=""
language=""
day=""

while getopts ":y:l:d:" option; do
  case "$option" in
    y)
      year="$OPTARG"
      ;;
    l)
      language="$OPTARG"
      ;;
    d)
      day="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$year" ] || [ -z "$language" ] || [ -z "$day" ]; then
  usage
fi

if ! [ -d "./solutions/$year/$language" ]; then
  echo "error: no solutions implemented in $language in $year"
  exit 1
fi

case "$language" in
  rust)
    pushd "./solutions/$year/rust" || exit
    cargo run --bin "day$day"
    popd || exit
    ;;
  zig)
    pushd "./solutions/$year/zig" || exit
    zig run "./src/day$day.zig"
    popd || exit
    ;;
  haskell)
    pushd "./solutions/$year/haskell" || exit
    runghc "./Day$day.hs"
    popd || exit
    ;;
  *)
    echo "error: unknown language \"$language\" specified"
    exit 1
esac
