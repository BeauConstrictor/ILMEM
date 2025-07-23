# ILMEM – ILM Extension Manager

A simple command-line utility for managing ILM (InterLinkedMarkdown) extensions. It allows you to install, remove, list, and update ILM extensions with a single command.

Extensions are stored in `~/.ilm/extensions/`, where each one is an executable script or binary that processes ILM links. This format is standardised by ILM, so should now be supported (sometimes along with a bespoke extension system for backwards compatibility) in most modern programs.

## Features

- Install extensions for a wide variety of links that you may encounter in an ILM document
- Remove installed extensions cleanly.
- List all installed extensions.

## Installation

To build `ilmem` from source (requires Nim):

```bash
nim c -d:release -o:ilmem ilmem.nim
```

## Example Usage

```bash
$ ilmem install gemini
Installing extension: 'gemini'
Downloading extension...
Installing to /home/user/.ilm/extensions/
Adding execute permission...
Done!
```

## Dependencies

The script `md2ansi` is the only real dependency of ILMPG. See it's [github page](http: https://raw.githubusercontent.com/Open-Technology-Foundation/md2ansi/refs/heads/main/README.md) for installation instructions

It is a python script that, as the name implies, converts markdown files to nicely rendered ANSI text for the terminal.

## Platform Support

- Linux/macOS: Fully supported.
- Windows: Not supported, as there is currently no standard extension system for Windows.
