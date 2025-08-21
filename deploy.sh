#!/bin/bash

swift build -c release
cp .build/release/swift-module-package-manager-cli $HOME/bin/swift-module-package
