import std/os, std/strutils, std/httpclient, std/terminal

const
    extensionDirHome = "~/.ilm/extensions/"
    repo = "https://raw.githubusercontent.com/BeauConstrictor/ILMEM/main/repo/"

let
    extensionDir = extensionDirHome.replace("~/", getHomeDir().string)
    http = newHttpClient()

proc install(ext: string) =
    echo "Installing extension: '" & ext & "'"

    echo "Downloading notice...\n"
    let notice = http.getContent(repo & ext & ".notice.txt")

    stdout.write notice
    if getch() != 'y':
        echo "Abort."
        return

    echo "Downloading extension..."
    let executable = http.getContent(repo & ext)

    echo "Installing to " & extensionDir
    writeFile(extensionDir & ext, executable)

    echo "Adding execute permission..."
    echo execShellCmd("chmod +x \"" & extensionDir & ext & "\"")

    echo "Done!"

proc remove(ext: string) =
    if fileExists(extensionDir & ext):
        echo "Removing extension: '" & ext & "'"
        echo "Deleting file..."
        if tryRemoveFile(extensionDir & ext):
            echo "Done!"
        else:
            echo "Deletion failed"
            echo "Abort."
    else:
        echo "Extension '" & ext & "' is not installed"
        echo "Abort."

proc run(ext: string, loc: string) =
    let runCmd = "echo <loc> | ~/.ilm/extensions/<ext> | fmt -w$(tput cols)"
        .replace("<ext>", ext)
        .replace("<loc>", loc)
    discard execShellCmd(runCmd)

proc list() =
    echo "Installed extensions:"
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
