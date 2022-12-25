# MIST - macOS Installer Super Tool

![Latest Release](https://img.shields.io/github/v/release/ninxsoft/mist-cli?display_name=tag&label=Latest%20Release&sort=semver) ![Downloads](https://img.shields.io/github/downloads/ninxsoft/mist-cli/total?label=Downloads) [![Linting](https://github.com/ninxsoft/mist-cli/actions/workflows/linting.yml/badge.svg)](https://github.com/ninxsoft/mist-cli/actions/workflows/linting.yml) [![Unit Tests](https://github.com/ninxsoft/mist-cli/actions/workflows/unit_tests.yml/badge.svg)](https://github.com/ninxsoft/mist-cli/actions/workflows/unit_tests.yml) [![Build](https://github.com/ninxsoft/mist-cli/actions/workflows/build.yml/badge.svg)](https://github.com/ninxsoft/mist-cli/actions/workflows/build.yml)

A Mac command-line tool that automatically downloads **macOS Firmwares** / **Installers**:

![Example Screenshot](README%20Resources/Example.png)

## :information_source: Check out [Mist](https://github.com/ninxsoft/Mist) for the companion Mac app!

## ![Slack](README%20Resources/Slack.png) Check out [#mist](https://macadmins.slack.com/archives/CF0CFM5B7) on the [Mac Admins Slack](https://macadmins.slack.com) to discuss all things mist-cli!

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
mist download installer "13.0.1" application

# Download a specific macOS Installer version for Intel Macs,
# including Universal Installers for macOS Big Sur and later,
# with a custom name:
mist download installer "13.0.1" application --application-name "Install %NAME% %VERSION%-%BUILD%.app"

# Download a specific macOS Installer version for Intel Macs,
# including Universal Installers for macOS Big Sur and later,
# and generate a Disk Image with a custom name:
mist download installer "13.0.1" image --image-name "Install %NAME% %VERSION%-%BUILD%.dmg"

# Download a specific macOS Installer build for Inte Macs,
# including Universal Installers for macOS Big Sur and later,
# and generate a codesigned Disk Image output to a custom directory:
mist download installer "22A400" image \
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

## Version History

- 1.9.1

  - Firmware SHA-1 checksum validation is now working correctly again - thanks Nathan Pierce ([Norse Gaud](https://github.com/NorseGaud))!

- 1.9

  - Added support for macOS Ventura 13
  - macOS Installer files are retried when invalid cache files are detected on-disk
  - Calculating ISO image sizes is _slightly_ more dynamic (to better support macOS Ventura ISOs)
  - macOS Firmware / Installer lists are now sorted by version, then by date
  - Firmwares with invalid SHA-1 checksums are now ignored and unavailable for download
  - SHA-1 checksum validation logic is now implemented in Swift (no longer shells out to `shasum`)
  - stdout stream buffering is disabled to improve output frequency - thanks Nate Felton ([n8felton](https://github.com/n8felton))!
  - Checking for mist updates now points to the recently renamed [mist-cli](https://github.com/ninxsoft/mist-cli) repository URL
  - Looking up the version of mist-cli is now performed using the built-in `mist --version` command
  - General code refactoring

  **Note:** To help avoid conflicts with the [Mist](https://github.com/ninxsoft/Mist) companion Mac app, the mist-cli installer package + installer package identifier have been renamed to `mist-cli` and `com.ninxsoft.pkg.mist-cli` respectively.

- 1.8

  - `mist` is now a [Universal macOS Binary](https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary)
    - Supports Apple Silicon
    - Supports Intel-based Macs
  - `mist` now supports automatic retrying failed downloads:
    - Specify a value to the `--retries` option to override the total number of retry attempts **(default: 10)**
    - Specify a value to the `--retry-delay` option to override the number of seconds to wait before the next retry attempt **(default: 30)**
  - To help keep the `mist` command line options unambiguous, the `-k, --kind` option has been removed:
    - Use `mist list firmware` to list all available macOS Firmwares
    - Use `mist list installer` to list all available macOS Installers
    - Use `mist download firmware` to download a macOS Firmware
    - Use `mist download installer` to download a macOS Installer
    - Add `--help` to any of the above commands for additional information
  - Firmware downloads now have `0x644` POSIX permissions correctly applied upon successful download
  - Installer downloads can be cached using the `--cache-downloads` flag
    - Cached downloads will be stored in the temporary directory
    - Supply a value to the `--temporary-directory` option to change the temporary directory location
  - Installers downloads are now chunklist-verified upon successful download
  - The `--compatible` flag has been added to `mist list` and `mist download` to list / download Firmwares and Installers compatible with the Mac that is running `mist`
  - The `--export` option has been added to `mist download` to optionally generate a report of performed actions
  - The `--quiet` flag has been added to `mist download` to optionally suppress verbose output
  - Reports exported as JSON now have their keys sorted alphabetically
  - Bumped [Swift Argument Parser](https://github.com/apple/swift-argument-parser) version to **1.1.2**
  - Bumped [Yams](https://github.com/jpsim/Yams) version to **5.0.1**
  - General code refactoring and print message formatting fixes

  **Note:** Requires macOS Catalina 10.15 or later

- 1.7

  - The `--platform` option has been renamed to `-k, --kind`, to improve readability and reduce confusion
    - Specify `firmware` or `ipsw` to download a macOS Firmware IPSW file
    - Specify `installer` or `app` to download a macOS Install Application bundle
  - Support for generating Bootable Disk Images (.iso)
    - For use with virtualization software (ie. Parallels Desktop, VMware Fusion, VirtualBox)
    - `mist download <search-string> --iso`
    - Optionally specify `--iso-name` for a custom output file name
  - Downloading macOS Firmware IPSW files no longer requires escalated `sudo` privileges
  - Improved error messaging for when things go wrong (no longer outputs just the command that failed)
  - Granular error messages for when searching for Firmwares fails

- 1.6.1

  - `mist version` now correctly displays the current version when offline

- 1.6

  - SUCatalog URLs have been updated to point to **macOS Monterey (12)** URLs
  - Beta versions of macOS are now excluded by default in search results
    - Use `--include-betas` to include betas in search results
  - `mist version` now informs you if a new version is available for download
  - Bumped [Swift Argument Parser](https://github.com/apple/swift-argument-parser) version to **1.0.1**

- 1.5

  - Added List search support
    - `mist list <search-string>` to filter on results
    - `--latest` to filter the latest (first) match found
    - `--quiet` to suppress verbose output
    - `--output-type` to specify a custom output type
  - Added progress indicators
    - Displays current and total download amounts
    - Displays overal percentage downloaded
  - macOS Firmwares and Installers will fail to download if they already exist
    - Use `--force` to overwrite this behaviour
  - Faster macOS Firmwares list retrieval time
  - Faster macOS Installers list retrieval time
  - Replaced **SANITY CHECKS** headers with more inclusive **INPUT VALIDATION**
  - Fixed a bug with partial string matching when searching for downloads
  - Improved error handling and messaging

- 1.4

  - Support for downloading macOS Firmware (IPSW) files
    - Shasum is validated upon download
  - Moved list, download and version options to subcommands:
    - `mist --list` is now `mist list`
    - `mist --download` is now `mist download`
    - `mist --version` is now `mist version`
    - See `mist <subcommand> --help` for detailed help
  - Renamed `--list-export` option to `--export`
  - Re-added `--application` output option, back by popular demand!
  - Removed short flags for output options due to naming collisions:
    - Removed `-a` for `--application`
    - Removed `-i` for `--image`
    - Removed `-p` for `--package`
  - Lists now display / export total size
  - More verbose output for input validation

- 1.3.1

  - Fixed bug where SUCatalog files were not being parsed correctly

- 1.3

  - Removed `--name`, `--mac-os-version` and `--build` options, `--download` now supports all three
  - Removed `--list-format` option and renamed `--list-path` to `--list-export`, file extension determines export type
  - Removed `--application` and `--zip` options
  - Added `--catalogURL`
  - Added `--temporary-directory` option
  - Added `--keychain` option
  - Added free space check before downloads are initiated
  - Support for building hardware specific installers on all Macs
  - macOS name is now determined from the distribution files, no longer hardcoded
  - CSV cells with spaces now display correctly
  - Better input validation before downloads are initiated
  - Cleanup of standard output messaging (less verbose)
  - Removed download progress output
  - General code refactoring

- 1.2

  - Downloads now show progress: current + total download sizes and % completed
  - Mist will now create the `--output` directory if it does not exist

- 1.1.1

  - `--application` and `--zip` flags are now detected correctly

- 1.1

  - Specify custom catalog seeds: **Customer**, **Developer** and **Public**
    - This allows downloading macOS Install Betas
  - Output the macOS Installer application bundle to a custom directory
  - Generate a ZIP archive of the macOS Installer application bundle
  - Checks for free space before attempting any downloads and installations
  - Cleaned up CLI argument flags, options, and formatting

- 1.0
  - Initial release

## License

> Copyright © 2022 Nindi Gill
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
