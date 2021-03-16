# MIST - macOS Installer Super Tool

A Mac command-line tool that automatically generates **macOS Installer** Disk Images and Packages:

![Example](Readme%20Resources/Example.png)

## Features

*   [x] List all available macOS Installers available for download:
    *   Displays product identifers, name, versions, builds and release dates
    *   Optionally export list as **CSV**, **JSON**, **Property List** or **YAML**

*   [x] Download an available macOS Installer:
    *   Generate the macOS Installer application bundle (.app)
    *   Generate a Disk Image (.dmg)
    *   Generate a macOS Installer Package (.pkg)
        *   Supports **macOS Big Sur** packages - with a massive 12GB+ payload!
    *   Generate a ZIP archive (.zip)
    *   Optionally codesign Disk Images, macOS Installer Packages and ZIP archives
    *   Checks for free space before attempting any downloads and installations

*   [x] Optionally specify custom seed catalogs, allowing you to list and download macOS Installers betas from the following:
    *   **Customer Seed** - AppleSeed Program
    *   **Developer Seed** - Apple Developer Program
    *   **Public Seed** - Apple Beta Software Program

## Usage

```bash
OVERVIEW: macOS Installer Super Tool.

Automatically generate macOS Installer Disk Images and Packages.

USAGE: mist <options>

OPTIONS:
  -c, --catalog <catalog> Optionally specify a catalog seed, examples:
                          customer (Customer Seed - AppleSeed Program)
                          developer (Developer Seed - Apple Developer Program)
                          public (Public Seed - Apple Beta Software Program) (default: standard)
  -l, --list              List all macOS Installers available to download.
  --list-path <list-path> Optionally export the list to a file.
  --list-format <list-format>
                          Format of the list to export:
                          csv (Comma Separated Values)
                          json (JSON file)
                          plist (Property List)
                          yaml (YAML file)
  -d, --download          Download a macOS Installer.
  -n, --name <name>       Optionally specify macOS name, examples:
                          Big Sur (11.x)
                          Catalina (10.15.x)
                          Mojave (10.14.x)
                          High Sierra (10.13.x) (default: latest)
  -m, --mac-os-version <mac-os-version>
                          Optionally specify macOS version, examples:
                          11.2.3 (macOS Big Sur)
                          10.15.7 (macOS Catalina)
                          10.14.6 (macOS Mojave)
                          10.13.6 (macOS High Sierra) (default: latest)
  -b, --build <build>     Optionally specify macOS build number, examples:
                          20D91 (macOS Big Sur 11.2.3)
                          19H524 (macOS Catalina 10.15.7)
                          18G8022 (macOS Mojave 10.14.6)
                          17G14042 (macOS High Sierra 10.13.6) (default: latest)
  -o, --output <output>   Optionally specify the output directory. (default: /Users/Shared/macOS Installers)
  -a, --application       Export as macOS Installer application bundle (.app).
  -i, --image             Export as macOS Disk Image (.dmg).
  --image-identity <image-identity>
                          Optionally codesign the exported macOS Disk Image (.dmg).
                          Specify a signing identity name, eg. "Developer ID Application: Nindi Gill (Team ID)".
  -p, --package           Export as macOS Installer Package (.pkg).
  --package-identifier <package-identifier>
                          Specify the package identifier.
                          eg. com.yourcompany.pkg.mac-os-install-{name}
  --package-identity <package-identity>
                          Optionally codesign the exported macOS Installer Packages (.pkg).
                          Specify a signing identity name, eg. "Developer ID Installer: Nindi Gill (Team ID)".
  -z, --zip               Export as ZIP Archive (.zip).
  --zip-identity <zip-identity>
                          Optionally codesign the exported ZIP archive (.zip).
                          Specify a signing identity name, eg. "Developer ID Application: Nindi Gill (Team ID)".
  -v, --version           Display the version of mist.
  -h, --help              Show help information.
```

## Examples

```bash
# List all available macOS Installers:
mist --list

# List + Export to a CSV file:
mist --list --list-path "/path/to/export.csv" --list-format "csv"

# List + Export to a JSON file:
mist --list --list-path "/path/to/export.json" --list-format "json"

# List + Export to a Property List:
mist --list --list-path "/path/to/export.plist" --list-format "plist"

# List + Export to a YAML file:
mist --list --list-path "/path/to/export.yaml" --list-format "yaml"

# Download the latest available macOS Installer to the default output directory:
mist --download --application

# Download the latest macOS Catalina Installer and generate a Disk Image:
mist --download --name "Catalina" --image

# Download a specific macOS Mojave Installer version and generate a
# codesigned macOS Installer Package in a custom directory:
mist --download \
     --name "Mojave" \
     --mac-os-version "10.14.5" \
     --output "/path/to/custom/directory" \
     --package \
     --package-identifier "com.ninxsoft.mist.pkg.mojave-installer" \
     --package-identity "Developer ID Installer: Nindi Gill (Team ID)"

# Download a specific macOS High Sierra Installer version and build and generate a
# codesigned ZIP archive:
mist --download \
     --name "High Sierra" \
     --mac-os-version "10.13.6" \
     --build "17G66" \
     --zip \
     --zip-identity "Developer ID Application: Nindi Gill (Team ID)"

# Download the latest available macOS Installer from the Public Seed catalogs and
# generate all available output options, signing where possible:
mist --catalog "public" \
     --download \
     --output "/path/to/custom/directory" \
     --application \
     --image \
     --image-identity "Developer ID Application: Nindi Gill (Team ID)" \
     --package \
     --package-identifier "com.ninxsoft.mist.pkg.latest-installer" \
     --package-identity "Developer ID Installer: Nindi Gill (Team ID)"
     --zip \
     --zip-identity "Developer ID Application: Nindi Gill (Team ID)"
```

## Build Requirements

*   Swift **5.3**.
*   Runs on macOS Yosemite **10.10** and later.

## Download

Grab the latest version of **MIST** from the [releases page](https://github.com/ninxsoft/MIST/releases).

## Credits / Thank You

*   Project created and maintained by Nindi Gill ([ninxsoft](https://github.com/ninxsoft)).
*   Apple ([apple](https://github.com/apple)) for [Swift Argument Parser](https://github.com/apple/swift-argument-parser), used to perform command line argument and flag operations.
*   JP Simard ([jpsim](https://github.com/jpsim)) for [Yams](https://github.com/jpsim/Yams), used to export YAML.

## Version History

*   1.1
    *   Specify custom catalog seeds: **Customer**, **Developer** and **Public**
        *   This allows downloading macOS Install Betas
    *   Output the macOS Installer application bundle to a custom directory
    *   Generate a ZIP archive of the macOS Installer application bundle
    *   Check for free space before attempting any downloads and installations
    *   Cleaned up CLI argument flags, options, and formatting

*   1.0
    *   Initial release

## License

    Copyright © 2021 Nindi Gill

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
