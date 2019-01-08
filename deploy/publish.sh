#!/bin/bash

if [[ $TRAVIS_PULL_REQUEST == "false" ]]; then
    ./gradlew -i -Dmaven.settings=$GPG_DIR/settings.xml deploy
    exit $?
fi