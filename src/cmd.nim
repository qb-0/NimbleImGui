import osproc, strutils
import globals

const
  base = "nimble"
  opts = {poUsePath, poStdErrToStdOut}
  cmds = (
    update: @["update"],
    install: @["install", "-y"],
    list: @["list"],
    installed: @["list", "--installed"],
    uninstall: @["uninstall", "-y"]
  )

proc updateModules* =
  var
    p = startProcess(base, "", cmds.update, options=opts)
    (lines, exCode) = p.readLines()
  
  DebugLog.add(lines)

  if exCode == 0: 
    Log.add("Successfully updated modules") 
  else: 
    Log.add("Failed to update modules")

proc installModule*(m: string) =
  Log.add("Installing " & m)
  var 
    p = startProcess(base, "", cmds.install & m, options=opts)
    (lines, exCode) = p.readLines()

  DebugLog.add(lines)

  if exCode == 0: 
    Log.add("Successfully (re)installed " & m) 
  else: 
    Log.add("Failed to install " & m)

proc uninstallModule*(m: string) =
  Log.add("Uninstalling " & m)
  var 
    p = startProcess(base, "", cmds.uninstall & m, options=opts)
    (lines, exCode) = p.readLines()

  DebugLog.add(lines)

  if exCode == 0: 
    Log.add("Successfully uninstalled " & m)
  else: 
    Log.add("Failed to uninstall " & m)

proc parseModules*: seq[Module] =
  var 
    p = startProcess(base, "", cmds.list, options=opts)
    (lines, exCode) = p.readLines()
    m: Module

  DebugLog.add(lines)

  if exCode == 0:
    for l in lines:
      let 
        ln = l.split(":", 1)
        lnSt = l.replace(" ", "").split(":", 1)

      if ln.len == 1:
        if m.descr != "":
          result.add(m)
        m = Module()
      else:
        if ln[1] == "":
          m.name = ln[0]
        case lnSt[0]:
        of "url": m.url = lnSt[1].replace("(git)", "")
        of "description": m.descr = ln[1].strip()
        of "license": m.license = lnSt[1]
    Log.add("Parsed module list")
  else:
    Log.add("Failed to parse module list")

proc parseInstalled*: seq[InstalledModule] =
  var 
    p = startProcess(base, "", cmds.installed, options=opts)
    (lines, exCode) = p.readLines()

  DebugLog.add(lines)

  if exCode == 0:
    for l in lines:
      let ln = l.strip().split()
      var im = InstalledModule(
        name: ln[0], 
        version: ln[2].multiReplace([("[", ""), ("]", "")])
      )
      for m in Modules:
        if m.name == im.name:
          im.descr = m.descr
      result.add(im)
    Log.add("Parsed installed module list")
  else:
    Log.add("Failed to parse installed module list")