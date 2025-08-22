#!/bin/bash

swift build -c release
mkdir $HOME/bin
cp .build/release/swift-module-package-manager-cli $HOME/bin/swift-module-package
$SHELL
