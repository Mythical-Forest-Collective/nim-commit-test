import json
import osproc

discard execCmd("git clone https://github.com/Mythical-Forest-Collective/Nim-Commit-Test .cache/head")

let currentNimblePkgData = execCmdEx("nimble dump --json", workingDir=".cache/head").output

echo currentNimblePkgData

discard execCmd("rm -rf .cache")