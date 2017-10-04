# 🍔🍟 Fastfood

[![Swift 4](https://img.shields.io/badge/Swift-4-orange.svg?style=flat)](https://swift.org)
[![Homebrew](https://img.shields.io/badge/homebrew-compatible-brightgreen.svg?style=flat)]()
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=59c87630d2b355000114c416&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/59c87630d2b355000114c416/build/latest?branch=master)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

Fastfood is a simple way to share [lanes](https://github.com/fastlane/fastlane) between multiple projects.

## Features

- Syncing with remote `Fastfile`s
- Different `Fastfile` versions via tags and branches
- `Fastfile` import updating in projects

## Requirements

- masOS 10.10+
- Xcode 9.0+

## Usage

Fastfood is useful if you have shared lanes across multiple projects and you want to store the Fastfile in a remote git repository with local caching.
To use it run `fastfood update` in a project folder. That's all! Fastfood updates local saved `Fastfile`s if needed and creates a new `Fastfile` in current project or updates an existing file. By default Fastfood clones files from [this](https://github.com/rosberry/RSBFastlane) repo.

Run `fastfood help` to see available options:

```bash
Usage: fastfood update [options]
  -u, --url:
      URL to a repo contains Fastfile.
  -v, --version:
      A tag or branch name.
  -f, --force:
      Update to last version.
  --no-cache:
      Update shared fastlane ignoring cached versions. Usually uses for fastlane in development stage.
```
## Installation

### Homebrew (recommended):
```bash
$ brew install artemnovichkov/projects/fastfood
```
### Carthage:
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

```
github "artemnovichkov/Fastfood"
```
### Swift Package Manager:
```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Project",
    dependencies: [
    .package(url: "https://github.com/artemnovichkov/fastfood.git", from: "1.0.0"),
        ],
    targets: [
        .target(
            name: "Project", dependencies: ["Fastfood"])
    ]
)
```
### Manually:
Drag `Sources` folder from [last release](https://github.com/artemnovichkov/fastfood/releases) into your project.

## Author

Artem Novichkov, novichkoff93@gmail.com

## License

Fastfood is available under the MIT license. See the LICENSE file for more info.
