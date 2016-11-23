#! /usr/bin/env bats

load ../environment

setup() {
  create_test_go_script 'echo "$COLUMNS"'
}

teardown() {
  remove_test_go_rootdir
}

@test "$SUITE: set COLUMNS if unset" {
  run env COLUMNS= "$TEST_GO_SCRIPT"
  assert_success
  [[ -n "$output" ]]
}

@test "$SUITE: honor COLUMNS if already set" {
  run env COLUMNS="19700918" "$TEST_GO_SCRIPT"
  assert_success '19700918'
}

@test "$SUITE: default COLUMNS to 80 if actual columns can't be determined" {
  run env COLUMNS= PATH= "$BASH" "$TEST_GO_SCRIPT"
  assert_success '80'
}

@test "$SUITE: default to 80 columns if tput fails or use mode.com on Windows" {
  local expected_cols='80'

  if [[ "$(mode.com con)" =~ Columns:\ +([0-9]+) ]]; then
    expected_cols="${BASH_REMATCH[1]}"
  fi

  # One way to cause tput to fail is to set `$TERM` to null. On Travis it's set
  # to 'dumb', but tput fails anyway. The code now defaults to 80 on all errors.
  run env COLUMNS= TERM= "$TEST_GO_SCRIPT"
  assert_success "$expected_cols"
}
