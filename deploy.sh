#!/bin/bash

swift build -c release
bin_path="${HOME}/.local/bin"
mkdir -p ${bin_path}
cp .build/release/swift-module-package-manager-cli ${bin_path}/swift-module-package
${SHELL}
