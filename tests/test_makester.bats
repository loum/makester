#!/usr/bin/env bats

@test "Override MAKESTER__LOCAL_IP" {
  result="$(MAKESTER__LOCAL_IP=127.0.0.1 make -f makefiles/makester.mk print-MAKESTER__LOCAL_IP)"
  [ "$result" = "MAKESTER__LOCAL_IP=127.0.0.1" ]
}
