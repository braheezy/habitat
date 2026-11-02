# habitat

Pleasant scenes for the terminal.

```sh
habitat           # aquarium
habitat --park    # park
```

Press `q` to quit, `p` to pause, or `r` to restart.

## Install

Download the binary for your system from [Releases](../../releases/latest), make it executable if needed, and run it:

```sh
chmod +x ./habitat-linux-x86_64
./habitat-linux-x86_64 --park
```

The release page provides builds for Linux and macOS (x86_64 and ARM64), plus Windows (x86_64).

## Development

Requires Zig 0.17.0 or newer.

```sh
zig build
zig build run
zig build test
```

## Attribution and license

The aquarium scene in Habitat is a direct port of [Asciiquarium 1.1](https://robobunny.com/projects/asciiquarium) by Kirk Baucom. Most art is by Joan Stark, with marine life contributed by Claudio Matsuoka. Copyright © 2003 Kirk Baucom. Habitat's aquarium code and artwork are distributed under the original GPL-2.0-or-later license.

The park scene is original work generated for Habitat.
