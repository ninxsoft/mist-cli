# MIST - macOS Installer Super Tool

A Mac command-line tool that automatically generates **macOS Installers**:

![Example](Readme%20Resources/Example.png)

## Features

*   [x] List all available macOS Installers available for download:
    *   Display product identifiers, names, versions, builds and release dates
    *   Optionally export list as **CSV**, **JSON**, **Property List** or **YAML**
*   [x] Download an available macOS Installer:
    *   Generate a Disk Image (.dmg)
    *   Generate a macOS Installer Package (.pkg)
        *   Supports **macOS Big Sur** packages - with a massive 12GB+ payload!
    *   Optionally codesign Disk Images and macOS Installer Packages
    *   Check for free space before attempting any downloads or installations
*   [x] Optionally specify a custom catalog URL, allowing you to list and download macOS Installers from the following:
    *   **Customer Seed** - AppleSeed Program
    *   **Developer Seed** - Apple Developer Program
    *   **Public Seed** - Apple Beta Software Program

## Usage

```bash
OVERVIEW: macOS Installer Super Tool.

Automatically generate macOS Installers.

USAGE: mist <options>

OPTIONS:
  -c, --catalog-url <catalog-url>
                          Override the default Software Update Catalog URL.
  -l, --list              List all macOS Installers available to download.
  -e, --list-export <list-export>
                          Specify the path to export the list to one of the following formats:
                          * /path/to/export.csv (CSV file).
                          * /path/to/export.json (JSON file).
                          * /path/to/export.plist (Property List) file).
                          * /path/to/export.yaml (YAML file).
                          Note: The file extension will determine the output file format.
  -d, --download <download>
                          Download a macOS Installer, specifying a macOS name, version or build:
                          * macOS Monterey
                          * macOS Big Sur
                          * macOS Catalina
                          * macOS Mojave
                          * macOS High Sierra
                          * 12.x (macOS Monterey)
                          * 11.x (macOS Big Sur)
                          * 10.15.x (macOS Catalina)
                          * 10.14.x (macOS Mojave)
                          * 10.13.x (macOS High Sierra)
                          * 21A5248p (macOS Monterey Beta 12.0)
                          * 20F71 (macOS Big Sur 11.4)
                          * 19H524 (macOS Catalina 10.15.7)
                          * 18G8022 (macOS Mojave 10.14.6)
                          * 17G14042 (macOS High Sierra 10.13.6)
                          Note: Specifying a macOS name will assume the latest version and build of that particular macOS.
                          Note: Specifying a macOS version will assume the latest build of that particular macOS.
  -o, --output-directory <output-directory>
                          Specify the output directory. The following variables will be dynamically substituted:
                          * %NAME% will be replaced with 'macOS Monterey'
                          * %VERSION% will be replaced with '12.0'
                          * %BUILD% will be replaced with '21A5248p'
                          Note: Parent directories will be created automatically.
                           (default: /Users/Shared/macOS Installers)
  -i, --image             Generate a macOS Disk Image.
  --image-name <image-name>
                          Specify the macOS Disk Image output filename. The following variables will be dynamically substituted:
                          * %NAME% will be replaced with 'macOS Monterey'
                          * %VERSION% will be replaced with '12.0'
                          * %BUILD% will be replaced with '21A5248p'
                           (default: Install %NAME% %VERSION%-%BUILD%.dmg)
  --image-signing-identity <image-signing-identity>
                          Codesign the exported macOS Disk Image (.dmg).
                          Specify a signing identity name, eg. "Developer ID Application: Nindi Gill (Team ID)".
  -p, --package           Generate a macOS Installer Package.
  --package-name <package-name>
                          Specify the macOS Installer Package output filename. The following variables will be dynamically substituted:
                          * %NAME% will be replaced with 'macOS Monterey'
                          * %VERSION% will be replaced with '12.0'
                          * %BUILD% will be replaced with '21A5248p'
                           (default: Install %NAME% %VERSION%-%BUILD%.pkg)
  --package-identifier <package-identifier>
                          Specify the macOS Installer Package identifier. The following variables will be dynamically substituted:
                          * %NAME% will be replaced with 'macOS Monterey'
                          * %VERSION% will be replaced with '12.0'
                          * %BUILD% will be replaced with '21A5248p'
                          * Spaces will be replaced with hyphens -
                           (default: com.mycompany.pkg.install-%NAME%)
  --package-signing-identity <package-signing-identity>
                          Codesign the exported macOS Installer Package (.pkg).
                          Specify a signing identity name, eg. "Developer ID Installer: Nindi Gill (Team ID)".
  -k, --keychain <keychain>
                          Specify a keychain path to search for signing identities.
                          Note: If no keychain is specified, the default user login keychain will be used.
  -t, --temporary-directory <temporary-directory>
                          Specify the temporary downloads directory.
                          Note: Parent directories will be created automatically.
                           (default: /private/tmp)
  -v, --version           Display the version of mist.
  -h, --help              Show help information.
```

## Examples

```bash
# List all available macOS Installers:
mist --list

# List + Export to a CSV file:
mist --list --list-export "/path/to/export.csv"

# List + Export to a JSON file:
mist --list --list-export "/path/to/export.json"

# List + Export to a Property List:
mist --list --list-export "/path/to/export.plist"

# List + Export to a YAML file:
mist --list --list-export "/path/to/export.yaml"

# Download the latest macOS Big Sur Installer and generate a Disk Image:
mist --download "Big Sur" --image

# Download a specific macOS Installer version
# and generate a Disk Image with a custom name:
mist --download "11.4" --image --image-name "Install %NAME %VERSION%.dmg"

# Download a specific macOS Installer build and generate
# a codesigned Disk Image output to a custom directory:
mist --download "19H15" \
     --image \
     --image-signing-identity "Developer ID Application: First Last (Team ID)" \
     --output-directory "/path/to/custom/directory"

# Download the latest macOS Big Sur Installer and generate
# a Disk Image and macOS Installer Package, both with custom
# names, codesigned, output to a custom directory:
mist --download "Big Sur" \
     --image \
     --image-name "Install %NAME% %VERSION%-%BUILD%.dmg"
     --image-signing-identity "Developer ID Application: First Last (Team ID)" \
     --package \
     --package-name "Install %NAME% %VERSION%-%BUILD%.pkg" \
     --package-identifier "com.mycompany.pkg.install-%NAME%" \
     --package-signing-identity "Developer ID Installer: First Last (Team ID)" \
     --output-directory "/path/to/custom/directory"
```

## Build Requirements

*   Swift **5.3**.
*   Runs on macOS Yosemite **10.10** and later.

## Download

Grab the latest version of **Mist** from the [releases page](https://github.com/ninxsoft/MIST/releases).

## Credits / Thank You

*   Project created and maintained by Nindi Gill ([ninxsoft](https://github.com/ninxsoft)).
*   Apple ([apple](https://github.com/apple)) for [Swift Argument Parser](https://github.com/apple/swift-argument-parser), used to perform command line argument and flag operations.
*   JP Simard ([jpsim](https://github.com/jpsim)) for [Yams](https://github.com/jpsim/Yams), used to export YAML.

## Version History

*   1.3
    *   Removed `name`, `--mac-os-version` and `--build` options, `--download` now supports all three
    *   Removed `--list-format` option and renamed `--list-path` to `--list-export`, file extension determines export type
    *   Removed `--application` and `--zip` options
    *   Added `--catalogURL`
    *   Added `--temporary-directory` option
    *   Added `--keychain` option
    *   Added free space check before downloads are initiated
    *   Support for building hardware specific installers on all Macs
    *   macOS name is now determined from the distribution files, no longer hardcoded
    *   CSV cells with spaces now display correctly
    *   Better sanity checks before downloads are initiated
    *   Cleanup of standard output messaging (less verbose)
    *   Removed download progress output
    *   General code refactoring
*   1.2
    *   Downloads now show progress: current + total download sizes and % completed
    *   Mist will now create the `--output` directory if it does not exist

*   1.1.1
    *   `--application` and `--zip` flags are now detected correctly

*   1.1
    *   Specify custom catalog seeds: **Customer**, **Developer** and **Public**
        *   This allows downloading macOS Install Betas
    *   Output the macOS Installer application bundle to a custom directory
    *   Generate a ZIP archive of the macOS Installer application bundle
    *   Checks for free space before attempting any downloads and installations
    *   Cleaned up CLI argument flags, options, and formatting

*   1.0
    *   Initial release

## License

>   Copyright © 2021 Nindi Gill
>
>   Permission is hereby granted, free of charge, to any person obtaining a copy
>   of this software and associated documentation files (the "Software"), to deal
>   in the Software without restriction, including without limitation the rights
>   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>   copies of the Software, and to permit persons to whom the Software is
>   furnished to do so, subject to the following conditions:
>
>   The above copyright notice and this permission notice shall be included in all
>   copies or substantial portions of the Software.
>
>   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
>   SOFTWARE.
