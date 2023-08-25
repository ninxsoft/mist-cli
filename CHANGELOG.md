# Changelog

## [1.15](https://github.com/ninxsoft/mist-cli/releases/tag/v1.15) - 2023-08-23

- Added a temporary POSIX permissions fix to Installer applications that are being set incorrectly - thanks [meta-github](https://github.com/meta-github), [grahampugh](https://github.com/grahampugh), [PicoMitchell](https://github.com/PicoMitchell) and [k0nker](https://github.com/k0nker)!
- Rolled back the Bootable Disk Image (ISO) shrinking logic that was preventing the ISOs from booting correctly
- Bumped [Swift Argument Parser](https://github.com/apple/swift-argument-parser) version to **1.2.3**
- Bumped [Yams](https://github.com/jpsim/Yams) version to **5.0.6**

**Note:** Version **1.15** requires **macOS Big Sur 11** or later. If you need to run **mist** on an older operating system, you can still use version **1.14**.

## [1.14](https://github.com/ninxsoft/mist-cli/releases/tag/v1.14) - 2023-06-26

- `mist` will now inform you when a new update is available!
- Added colored borders to the ASCII table output when running `mist list`

## [1.13](https://github.com/ninxsoft/mist-cli/releases/tag/v1.13) - 2023-06-22

- Added support for the following legacy operating systems:
  - macOS Sierra 10.12.6
  - OS X El Capitan 10.11.6
  - OS X Yosemite 10.10.5
  - OS X Mountain Lion 10.8.5
  - Mac OS X Lion 10.7.5
  - Thanks [n8felton](https://github.com/n8felton)!
- Added support for creating Bootable Installers!
  - Specify the `bootableinstaller` argument for the `<output-type>`
  - Provide a `--bootable-installer-volume` argument for the mounted volume that will be used to create the Bootable Installer
  - **Note:** The volume must be formatted as **Mac OS Extended (Journaled)**. Use **Disk Utility** to format volumes as required.
  - **Note:** The volume will be erased automatically. Ensure you have backed up any necessary data before proceeding.
  - Available for **macOS Big Sur 11** and newer on **Apple Silicon Macs**
  - Available for **OS X Yosemite 10.10.5** and newer on **Intel-based Macs**
  - Thanks [5T33Z0](https://github.com/5T33Z0)!
- Added support for downloading Firmwares and Installers from an [Apple Content Caching Server](https://support.apple.com/en-us/guide/deployment/depde72e125f/web)!
  - Provide a `--caching-server` argument for the `<url:port>` that points to a Content Caching Server on the local network
  - **Note:** The cached content is served over HTTP, **not** HTTPS
  - Thanks [carlashley](https://github.com/carlashley)!
- Bootable Disk Image (ISO) sizes are now calculated dynamically, with minimal free space
  - Thanks [devZer0](https://github.com/devZer0) and [carlashley](https://github.com/carlashley)!
- Improved free disk space validation when running `mist` as `root` (ie. at the login screen) - thanks [TSPARR](https://github.com/TSPARR) and [PicoMitchell](https://github.com/PicoMitchell)!
- Improved / updated several `--help` descriptions

## [1.12](https://github.com/ninxsoft/mist-cli/releases/tag/v1.12) - 2023-05-20

- The percentage progress now displays correctly when the `--no-ansi` flag is used - thanks [grahampugh](https://github.com/grahampugh)!
- Improved how available free space is calculated - thanks [PicoMitchell](https://github.com/PicoMitchell)!
- Searching for a major macOS release number (ie. **13**) will now download the latest Firmware / Installer of said version - thanks [aschwanb](https://github.com/aschwanb)!
- Attempting to generate a macOS Catalina 10.15 or older Bootable Disk Image on Apple Silicon Macs will inform the user and exit (rather than failing after the download) - thanks [KenjiTakahashi](https://github.com/KenjiTakahashi)!

## [1.11](https://github.com/ninxsoft/mist-cli/releases/tag/v1.11) - 2023-04-16

- Specifying a macOS version with only one decimal no longer results in downloading a partial / incorrect match - thanks [kylerobertson0404](https://github.com/kylerobertson0404)!
- Using the `--no-ansi` flag when downloading now only outputs progress once per percentage increase, resulting in less verbose logging - thanks [grahampugh](https://github.com/grahampugh)!
- `mist` no longer displays mounted volumes in the Finder during disk image creation - thanks [wakco](https://github.com/wakco)!
- Improved free disk space detection - thanks [anewhouse](https://github.com/anewhouse)!
- Bumped [Swift Argument Parser](https://github.com/apple/swift-argument-parser) version to **1.2.2**
- Bumped [Yams](https://github.com/jpsim/Yams) version to **5.0.5**

## [1.10](https://github.com/ninxsoft/mist-cli/releases/tag/v1.10) - 2022-12-29

- When exporting a package for macOS 11 or newer, `mist` now saves time by re-using the Apple-provided Installer package when exporting a package - thanks [grahampugh](https://github.com/grahampugh)!
- macOS Firmware and Installer downloads that error (eg. due to timeouts) can now be resumed when `mist` is run again - thanks [Guisch](https://github.com/Guisch)!
  - Use the `--cache-downloads` flag to cache incomplete downloads
- Listing or downloading macOS Firmwares now caches the metadata from the [IPSW Downloads API](https://ipswdownloads.docs.apiary.io/) - thanks [NorseGaud](https://github.com/NorseGaud)!
  - Use the `--metadata-cache` option to specify a custom macOS Firmware metadata cache path
- `mist` output can now be redirected to a log file without ANSI escape sequences - thanks [NinjaFez](https://github.com/NinjaFez) and [n8felton](https://github.com/n8felton)!
  - Use the `--no-ansi` flag to remove all ANSI escape sequences, as well as limit the download progress output to once per second
- `mist` now defaults to creating a macOS Installer in a temporary disk image under-the-hood (no longer creating a macOS Installer in the `/Applications` directory) - thanks [grahampugh](https://github.com/grahampugh)!
- `mist` no longer outputs error messages twice - once is enough!
- Bumped [Swift Argument Parser](https://github.com/apple/swift-argument-parser) version to **1.2.0**
- Removed unused declarations and imports (ie. dead code)

## [1.9.1](https://github.com/ninxsoft/mist-cli/releases/tag/v1.9.1) - 2022-10-08

- Firmware SHA-1 checksum validation is now working correctly again - thanks [NorseGaud](https://github.com/NorseGaud)!

## [1.9](https://github.com/ninxsoft/mist-cli/releases/tag/v1.9) - 2022-09-26

- Added support for macOS Ventura 13
- macOS Installer files are retried when invalid cache files are detected on-disk
- Calculating ISO image sizes is _slightly_ more dynamic (to better support macOS Ventura ISOs)
- macOS Firmware / Installer lists are now sorted by version, then by date
- Firmwares with invalid SHA-1 checksums are now ignored and unavailable for download
- SHA-1 checksum validation logic is now implemented in Swift (no longer shells out to `shasum`)
- stdout stream buffering is disabled to improve output frequency - thanks [n8felton](https://github.com/n8felton)!
- Checking for mist updates now points to the recently renamed [mist-cli](https://github.com/ninxsoft/mist-cli) repository URL
- Looking up the version of mist-cli is now performed using the built-in `mist --version` command
- General code refactoring

**Note:** To help avoid conflicts with the [Mist](https://github.com/ninxsoft/Mist) companion Mac app, the mist-cli installer package + installer package identifier have been renamed to `mist-cli` and `com.ninxsoft.pkg.mist-cli` respectively.

## [1.8](https://github.com/ninxsoft/mist-cli/releases/tag/v1.8) - 2022-06-14

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

## [1.7.0](https://github.com/ninxsoft/mist-cli/releases/tag/v1.7.0) - 2022-03-06

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

## [1.6.1](https://github.com/ninxsoft/mist-cli/releases/tag/v1.6.1) - 2021-11-20

- `mist version` now correctly displays the current version when offline

## [1.6](https://github.com/ninxsoft/mist-cli/releases/tag/v1.6) - 2021-11-08

- SUCatalog URLs have been updated to point to **macOS Monterey (12)** URLs
- Beta versions of macOS are now excluded by default in search results
  - Use `--include-betas` to include betas in search results
- `mist version` now informs you if a new version is available for download
- Bumped [Swift Argument Parser](https://github.com/apple/swift-argument-parser) version to **1.0.1**

## [1.5](https://github.com/ninxsoft/mist-cli/releases/tag/v1.5) - 2021-09-03

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

## [1.4](https://github.com/ninxsoft/mist-cli/releases/tag/v1.4) - 2021-08-27

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

## [1.3.1](https://github.com/ninxsoft/mist-cli/releases/tag/v1.3.1) - 2021-08-12

- Fixed bug where SUCatalog files were not being parsed correctly

## [1.3](https://github.com/ninxsoft/mist-cli/releases/tag/v1.3) - 2021-06-21

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

## [1.2](https://github.com/ninxsoft/mist-cli/releases/tag/v1.2) - 2021-03-20

- Downloads now show progress: current + total download sizes and % completed
- Mist will now create the `--output` directory if it does not exist

## [1.1.1](https://github.com/ninxsoft/mist-cli/releases/tag/v1.1.1) - 2021-03-19

- `--application` and `--zip` flags are now detected correctly

## [1.1](https://github.com/ninxsoft/mist-cli/releases/tag/v1.1) - 2021-03-16

- Specify custom catalog seeds: **Customer**, **Developer** and **Public**
  - This allows downloading macOS Install Betas
- Output the macOS Installer application bundle to a custom directory
- Generate a ZIP archive of the macOS Installer application bundle
- Checks for free space before attempting any downloads and installations
- Cleaned up CLI argument flags, options, and formatting

## [1.0](https://github.com/ninxsoft/mist-cli/releases/tag/v1.0) - 2021-03-15

- Initial release
