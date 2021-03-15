# MIST - macOS Installer Super Tool

A Mac command-line tool that automatically generates **macOS Installer** Disk Images and Packages:

![Example](Readme%20Resources/Example.png)

## Features

*   [x] List all available macOS Installers available for download:
    *   Displays product identifers, name, versions, builds and release dates
    *   Optionally export list as **CSV**, **JSON**, **Property List** or **YAML**

*   [x] Download an available macOS Installer:
    *   Generate a Disk Image (DMG)
    *   Generate an Installer Package (PKG)
        *   Supports generating **macOS Big Sur** packages (with a massive 12GB payload!)
    *   Optionally codesign both the Disk Image and Installer Package

## Usage

```bash
OVERVIEW: macOS Installer Super Tool.

Automatically generate macOS Installer Disk Images and Packages.

USAGE: mist <options>

OPTIONS:
  -l, --list              List all macOS Installers available to download.
  -e, --export <export>   Optionally export the list to a file.
  -f, --format <format>   Format of the list to export:
                          csv
                          json
                          plist
                          yaml
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
  -o, --output <output>   Specify the output directory (default: /Users/Shared/macOS Installers)
  -i, --image             Export as macOS Disk Image (.dmg).
  -p, --package           Export as macOS Installer Package (.pkg).
  -i, --identifier <identifier>
                          Specify the package identifier.
                          eg. com.yourcompany.pkg.mac-os-install-{name}
  -s, --sign <sign>       Optionally codesign macOS Disk Images (.dmg) and macOS Installer Packages (.pkg).
                          Specify a signing identity name, eg. "Developer ID Installer: ABC XYZ (Team ID)".
  -v, --version           Display the version of mist.
  -h, --help              Show help information.
```

## Examples

```bash
# List all available macOS Installers:
mist --list

# List + Export to a CSV file:
mist --list --export "/path/to/export.csv" --format csv

# List + Export to a JSON file:
mist --list --export "/path/to/export.json" --format json

# List + Export to a Property List:
mist --list --export "/path/to/export.plist" --format plist

# List + Export to a YAML file:
mist --list --export "/path/to/export.yaml" --format yaml

# Download the latest available macOS Installer and
# generate a Disk Image in the default output directory:
mist --download --image

# Download the latest macOS Catalina Installer and
# generate a codesigned Disk Image:
mist --download \
     --name "Catalina" \
     --image \
     --sign "Developer ID Installer: Nindi Gill (Team ID)"

# Download the specific macOS Mojave Installer version and
# generate an Installer Package in a custom directory:
mist --download \
     --name "Mojave" \
     --mac-os-version "10.14.5" \
     --package \
     --identifier "com.ninxsoft.mist.pkg.mojave-installer" \
     --output "/path/to/custom/directory"

# Download a specific macOS High Sierra Installer version and build and
# generate an codesigned Installer Package:
mist --download \
     --name "High Sierra" \
     --mac-os-version "10.13.6" \
     --build "17G66" \
     --package \
     --identifier "com.ninxsoft.mist.pkg.high-sierra-installer" \
     --sign "Developer ID Installer: Nindi Gill (Team ID)"
```

## Build Requirements

*   Swift **5.3**.
*   Runs on macOS Yosemite **10.10** and later.

## Download

Grab the latest version of **MIST** from the [releases page](https://github.com/ninxsoft/MIST/releases).

## Credits / Thank You

*   Project created and maintained by Nindi Gill ([ninxsoft](https://github.com/ninxsoft)).
*   Apple ([apple](https://github.com/apple)) for [Swift Argument Parser](https://github.com/apple/swift-argument-parser), used to perform command line argument and flag operations.
*   JP Simard ([@jpsim](https://github.com/jpsim)) for [Yams](https://github.com/jpsim/Yams), used to export YAML.

## Version History

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
