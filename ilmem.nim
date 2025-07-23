import std/os, std/strutils, std/httpclient, std/terminal, std/osproc, std/streams

const
    extensionDirHome = "~/.ilm/extensions/"
    repo = "https://raw.githubusercontent.com/BeauConstrictor/ILMEM/main/repo/"

let
    extensionDir = extensionDirHome.replace("~/", getHomeDir())
    http = newHttpClient()

proc md2ansi(md: string): string =
  let (cols, _) = terminalSize()

  const p = "/usr/local/bin/md2ansi"
  let prc = startProcess(p, ".", 
    ["--no-links", "--width", $cols])
  prc.inputStream.writeLine(md)
  prc.inputStream.flush()
  prc.inputStream.close()
  return prc.outputStream.readAll()

proc install(ext: string) =
    echo "Installing extension: '" & ext & "'"

    var notice: string
    try:
        notice = http.getContent(repo & ext & ".notice.md")
    except HttpRequestError as err:
        echo "Error while downloading '" & ext & "': " & err.msg
        quit 0
    echo "1. Downloading notice...\n"

    echo md2ansi("---\n\n" & notice & "\n\n---")
    if getch() != 'y':
        echo "Abort."
        return

    echo "2. Downloading executable..."
    let executable = http.getContent(repo & ext)

    echo "2. Downloading encoder..."
    let encoder = http.getContent(repo & ext & "-encoder")

    echo "3. Installing to " & extensionDir
    writeFile(extensionDir & ext, executable)
    writeFile(extensionDir & ext & "-encoder", encoder)

    echo "5. Adding execute permissions..."
    discard execShellCmd("chmod +x \"" & extensionDir & ext & "\"")
    discard execShellCmd("chmod +x \"" & extensionDir & ext & "-encoder" & "\"")

    echo "~~ Done!"

proc remove(ext: string) =
    if fileExists(extensionDir & ext):
        echo "1. Removing extension: '" & ext & "'"
        echo "2. Deleting file..."
        if tryRemoveFile(extensionDir & ext):
            echo "~~ Done!"
        else:
            echo "!! Deletion failed"
            echo "~~ Abort."
    else:
        echo "Extension '" & ext & "' is not installed"
        echo "Abort."

proc run(ext: string, loc: string) =
    let runCmd = "echo <loc> | ~/.ilm/extensions/<ext> | fmt -w$(tput cols)"
        .replace("<ext>", ext)
        .replace("<loc>", loc)
    discard execShellCmd(runCmd)

proc list() =
    echo "~~ Installed extensions:"
    for item in walkDir(extensionDir):
        echo item.path.split("/")[^1]

when isMainModule:
    if paramCount() == 3:
        case paramStr(1):
            of "run":
                run paramStr(2), paramStr(3)
            else:
                echo "Too many args, use --help."
    elif paramCount() == 2:
        case paramStr(1):
            of "install":
                install paramStr(2)
            of "remove":
                remove paramStr(2)
            of "update":
                install paramStr(2)
            of "run":
                echo "Run requires a location, as well as an argument."
            else:
                echo "Unknown mode '" & paramStr(1) & "', use --help."
    elif paramCount() == 1:
        if paramStr(1) == "--help" or paramStr(1) == "-h":
            const help = staticRead("help.txt")
            echo help
        elif paramStr(1) == "--version" or paramStr(1) == "-b":
            const version = staticRead("version.txt")
            echo version
        elif paramStr(1) == "list":
            list()

    else:
        const noArgs = staticRead("no-args.txt")
        echo noArgs
