import strformat
import json
import osproc

const REPO = "https://github.com/Mythical-Forest-Collective/Nim-Commit-Test"

discard execCmd(fmt"git clone {REPO} .cache/head") # Clone the head
let prevCommit = execCmdEx("git rev-parse HEAD^", workingDir=".cache/head").output # Get previous commit hash

discard execCmd(fmt"git clone {REPO} -b prevCommit .cache/{prevCommit}") # Clone from commit

let currPkgVer = execCmdEx("nimble dump --json", workingDir=".cache/head").output.parseJson()["version"]
let prevPkgVer = execCmdEx("nimble dump --json", workingdir=fmt".cache/{prevCommit}").output.parseJson()["version"]

echo currPkgVer, ", ", prevCommit

discard execCmd("rm -rf .cache")