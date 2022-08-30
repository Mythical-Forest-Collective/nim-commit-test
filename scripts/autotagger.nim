import strformat
import strutils
import sequtils
import json
import osproc
import os

const REPO = "github.com/Mythical-Forest-Collective/nim-commit-test.git"

var REPO_URL = "https://" & REPO

if getEnv("GITHUB_TOKEN") != "":  # Github Actions-specific, can be modified if other hosts have something similar
  REPO_URL = "https://" & getEnv("GITHUB_TOKEN") & "@" & REPO

proc semver(versionString:string):seq[int] = split(versionString, '.', 3).map(parseInt)

discard execCmd("rm -rf .cache")


discard execCmd(fmt"git clone {REPO_URL} .cache/head") # Clone the head
var prevCommit = execCmdEx("git rev-parse HEAD^", workingDir=".cache/head").output.replace("\n", "") # Get previous commit hash


discard execCmd(fmt"git clone -n {REPO_URL} .cache/prevCommit") # Clone new repo so we can change to prev commit
echo fmt"git checkout {prevCommit}"
discard execCmdEx(fmt"git checkout {prevCommit}", workingDir=".cache/prevCommit")


var currPkgVerStr = execCmdEx("nimble dump --json", workingDir=".cache/head").output.parseJson()["version"].getStr
var prevPkgVerStr = execCmdEx("nimble dump --json", workingdir=".cache/prevCommit").output.parseJson()["version"].getStr


var currPkgVer = currPkgVerStr.semver
var prevPkgVer = prevPkgVerStr.semver


echo currPkgVer, ", ", prevPkgVer


if currPkgVer[0] <= prevPkgVer[0]:
  if currPkgVer[1] <= prevPkgVer[1]:
    if currPkgVer[2] <= prevPkgVer[2]:
      quit("No new version! Not creating a tag for the last version!", 0)

echo "\n\n"

echo execCmdEx(fmt "GIT_COMMITTER_DATE=\"$(git show --format=%aD | head -1)\" git tag -a v{prevPkgVerStr} {prevCommit} -am \"Release v{prevPkgVerStr} as commit hash \\`{prevCommit}\\`\"", workingDir=".cache/head").output

echo "\n\n"

echo execCmdEx(fmt"git push origin v{prevPkgVerStr}", workingDir=".cache/head").output


quit("Created tag for last version!", 0)