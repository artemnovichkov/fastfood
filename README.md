# 🍔🍟 Fastfood

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

Fastfood is a simple tool for updating local `Fastfile` and [fastlane](https://github.com/fastlane/fastlane) imports in projects.

## Features

- Syncing with remote `Fastfile`
- Different versions via tags
- `Fastfile` updating in projects

## Requirements

- masOS 10.10+
- Xcode 9.0+

## Installation

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

```
github "artemnovichkov/Fastfood"
```
#### Manually

Drag `Sources` folder from [last release](https://github.com/artemnovichkov/fastfood/releases) into your project.

## Usage

```bash
$ fastfood -u https://github.com/artemnovichkov/fastfile-test.git -t 1.0
```

## Authors

* Artem Novichkov, novichkoff93@gmail.com

## License

Fastfood is available under the MIT license. See the LICENSE file for more info.
