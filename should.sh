#!/usr/bin/env bash
#
# Copyright 2026 Truls Becken
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
set -eu

TESTS_TOTAL=0
TESTS_PASS=0
TESTS_FAIL=0

declare PLAIN RED GREEN BLUE
if [ -t 1 ]; then
  PLAIN='\e[0m'
  RED='\e[31m'
  GREEN='\e[32m'
  BLUE='\e[34m'
fi

should() {
  printf "${BLUE}Test:${PLAIN} Should %-61s" "$*"
  ((++TESTS_TOTAL))
}

assert() {
  local command=$1
  local expect=${2:-}
  local pattern=${3:-}
  local output status found error
  output=$($command 2>&1) && status=0 || status=$?
  if { [ -n "$expect" ] && grep -qFx "$expect" <<< "$output"; } ||
     { [ -z "$expect" ] && [ "$status" -eq 0 ]; }; then
    echo -e "[${GREEN}PASS${PLAIN}]"
    ((++TESTS_PASS))
  else
    echo -e "[${RED}FAIL${PLAIN}]"
    ((++TESTS_FAIL))
    [ -n "$expect" ] && echo "Expect: $expect"
    if [ -n "$pattern" ]; then
      found=$(grep "$pattern" <<< "$output")
      [ -n "$found" ] && echo "Found:  $found"
    fi
    if [ -z "${found:-}" ] && [ "$status" -ne 0 ]; then
      error=$(tail -1 <<< "$output")
      [ -n "$error" ] && echo "Error: $error" || true
    fi
  fi
}

summary() {
  printf "%80s\n" "" | tr ' ' -
  if [ "$TESTS_FAIL" -eq 0 ] && [ "$TESTS_PASS" -eq "$TESTS_TOTAL" ]; then
    echo -e "${GREEN}All tests passed${PLAIN} ($TESTS_PASS)"
  else
    echo -e "${RED}TESTS FAILED${PLAIN} ($TESTS_FAIL/$TESTS_TOTAL failed)"
  fi
  printf "%80s\n" "" | tr ' ' -
}
