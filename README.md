# MIST - macOS Installer Super Tool

![Latest Release](https://img.shields.io/github/v/release/ninxsoft/mist-cli?display_name=tag&label=Latest%20Release&sort=semver) ![Downloads](https://img.shields.io/github/downloads/ninxsoft/mist-cli/total?label=Downloads) [![Linting](https://github.com/ninxsoft/mist-cli/actions/workflows/linting.yml/badge.svg)](https://github.com/ninxsoft/mist-cli/actions/workflows/linting.yml) [![Unit Tests](https://github.com/ninxsoft/mist-cli/actions/workflows/unit_tests.yml/badge.svg)](https://github.com/ninxsoft/mist-cli/actions/workflows/unit_tests.yml) [![Build](https://github.com/ninxsoft/mist-cli/actions/workflows/build.yml/badge.svg)](https://github.com/ninxsoft/mist-cli/actions/workflows/build.yml)

A Mac command-line tool that automatically downloads **macOS Firmwares** / **Installers**:

![Example Screenshot](README%20Resources/Example.png)

<!-- markdownlint-disable no-trailing-punctuation -->

## :information_source: Check out [Mist](https://github.com/ninxsoft/Mist) for the companion Mac app!

## ![Slack](README%20Resources/Slack.png) Check out [#mist](https://macadmins.slack.com/archives/CF0CFM5B7) on the [Mac Admins Slack](https://macadmins.slack.com) to discuss all things mist-cli!

<!-- markdownlint-enable no-trailing-punctuation -->

## Features

- [x] List all available macOS Firmwares / Installers available for download:
  - Display names, versions, builds, sizes and release dates
  - Optionally list beta versions of macOS
  - Filter macOS versions that are compatible with the Mac the app is being run from
  - Export lists as **CSV**, **JSON**, **Property List** or **YAML**
- [x] Download available macOS Firmwares / Installers:
  - For Apple Silicon Macs:
    - Download a Firmware Restore file (.ipsw)
    - Validates the SHA-1 checksum upon download
  - For Intel based Macs (Universal for macOS Big Sur and later):
    - Generate an Application Bundle (.app)
    - Generate a Disk Image (.dmg)
    - Generate a Bootable Disk Image (.iso)
      - For use with virtualization software (ie. Parallels Desktop, VMware Fusion, VirtualBox)
    - Generate a macOS Installer Package (.pkg)
      - Supports packages on **macOS Big Sur and newer** with a massive 12GB+ payload!
    - Optionally codesign Disk Images and macOS Installer Packages
    - Check for free space before attempting any downloads or installations
    - Cache downloads to speed up build operations
    - Optionally specify a custom catalog URL, allowing you to list and download macOS Installers from the following:
      - **Customer Seed:** The catalog available as part of the [AppleSeed Program](https://appleseed.apple.com/)
      - **Developer Seed:** The catalog available as part of the [Apple Developer Program](https://developer.apple.com/programs/)
      - **Public Seed:** The catalog available as part of the [Apple Beta Software Program](https://beta.apple.com/)
      - **Note:** Catalogs from the Seed Programs may contain beta / unreleased versions of macOS. Ensure you are a member of these programs before proceeding.
    - Validates the Chunklist checksums upon download
  - Automatic retries for failed downloads!

## Usage

```bash
OVERVIEW: macOS Installer Super Tool.

Automatically download macOS Firmwares / Installers.

USAGE: mist <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  list                    List all macOS Firmwares / Installers available to download.
  download                Download a macOS Firmware / Installer.
  version                 Display the version of mist.

  See 'mist help <subcommand>' for detailed help.
```

**Note:** Depending on what **Mist** downloads, you may require allowing **Full Disk Access** for your **Terminal** application of choice via [System Settings](https://support.apple.com/en-us/guide/mac-help/mh15217/13.0/mac/13.0):

![Full Disk Access](README%20Resources/Full%20Disk%20Access.png)

## Examples

```bash
# List all available macOS Firmwares for Apple Silicon Macs:
mist list firmware

# List all available macOS Installers for Intel Macs,
# including Universal Installers for macOS Big Sur and later:
mist list installer

# List all available macOS Installers for Intel Macs, including betas,
# also including Universal Installers for macOS Big Sur and later:
mist list installer --include-betas

# List only macOS Ventura Installers for Intel Macs,
# including Universal Installers for macOS Big Sur and later:
mist list installer "macOS Ventura"

# List only the latest macOS Ventura Installer for Intel Macs,
# including Universal Installers for macOS Big Sur and later:
mist list installer --latest "macOS Ventura"

# List + Export macOS Installers to a CSV file:
mist list installer --export "/path/to/export.csv"

# List + Export macOS Installers to a JSON file:
mist list installer --export "/path/to/export.json"

# List + Export macOS Installers to a Property List:
mist list installer --export "/path/to/export.plist"

# List + Export macOS Installers to a YAML file:
mist list installer --export "/path/to/export.yaml"

# Download the latest macOS Ventura Firmware for
# Apple Silicon Macs, with a custom name:
mist download firmware "macOS Ventura" --firmware-name "Install %NAME% %VERSION%-%BUILD%.ipsw"

# Download the latest macOS Ventura Installer for Intel Macs,
# including Universal Installers for macOS Big Sur and later:
mist download installer "macOS Ventura" application

# Download a specific macOS Installer version for Intel Macs,
# including Universal Installers for macOS Big Sur and later:
mist download installer "13.1" application

# Download a specific macOS Installer version for Intel Macs,
# including Universal Installers for macOS Big Sur and later,
# with a custom name:
mist download installer "13.1" application --application-name "Install %NAME% %VERSION%-%BUILD%.app"

# Download a specific macOS Installer version for Intel Macs,
# including Universal Installers for macOS Big Sur and later,
# and generate a Disk Image with a custom name:
mist download installer "13.1" image --image-name "Install %NAME% %VERSION%-%BUILD%.dmg"

# Download a specific macOS Installer build for Inte Macs,
# including Universal Installers for macOS Big Sur and later,
# and generate a codesigned Disk Image output to a custom directory:
mist download installer "22C65" image \
     --image-signing-identity "Developer ID Application: Name (Team ID)" \
     --output-directory "/path/to/custom/directory"

# Download the latest macOS Ventura Installer for Intel Macs,
# including Universal Installers for macOS Big Sur and later,
# and generate an Installer Application bundle, a Disk Image,
# a Bootable Disk Image, a macOS Installer Package,
# all with custom names, codesigned, output to a custom directory:
mist download installer "macOS Ventura" application image iso package \
     --application-name "Install %NAME% %VERSION%-%BUILD%.app" \
     --image-name "Install %NAME% %VERSION%-%BUILD%.dmg" \
     --image-signing-identity "Developer ID Application: Name (Team ID)" \
     --iso-name "Install %NAME% %VERSION%-%BUILD%.iso" \
     --package-name "Install %NAME% %VERSION%-%BUILD%.pkg" \
     --package-identifier "com.mycompany.pkg.install-%NAME%" \
     --package-signing-identity "Developer ID Installer: Name (Team ID)" \
     --output-directory "/path/to/custom/directory"
```

## Build Requirements

- Swift **5.7**.
- Runs on **macOS Catalina 10.15** and later.

## Download

- Grab the latest version of **Mist** from the [releases page](https://github.com/ninxsoft/Mist/releases).
- Alternatively, install via [Homebrew](https://brew.sh) by running `brew install mist`
- **Note:** Version **1.8** requires **macOS Catalina 10.15** or later.
  - If you need to run **mist** on an older operating system, you can still use version **1.7**.

## Credits / Thank You

- Project created and maintained by Nindi Gill ([ninxsoft](https://github.com/ninxsoft)).
- Apple ([apple](https://github.com/apple)) for [Swift Argument Parser](https://github.com/apple/swift-argument-parser), used to perform command line argument and flag operations.
- JP Simard ([jpsim](https://github.com/jpsim)) for [Yams](https://github.com/jpsim/Yams), used to export YAML.
- Callum Jones ([cj123](https://github.com/cj123)) for [IPSW Downloads API](https://ipswdownloads.docs.apiary.io), used to determine macOS Firmware metadata.
- Timothy Sutton ([timsutton](https://github.com/timsutton)) for the [mist Homebrew Formula](https://formulae.brew.sh/formula/mist).

## License

> Copyright © 2023 Nindi Gill
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.
