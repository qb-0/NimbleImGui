import 
  osproc, strscans
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
      discard scanf(l, "$w*:$.", m.name)
      discard scanf(l, "$sdescription:$s$*$.", m.descr)
      discard scanf(l, "$slicense:$s$*$.", m.license)
      if scanf(l, "$swebsite:$s$*$.", m.url):
        result.add(m)
        m = Module()
    Log.add("Load module list")
  else:
    Log.add("Failed to parse module list")

proc parseInstalled*: seq[InstalledModule] =
  var 
    p = startProcess(base, "", cmds.installed, options=opts)
    (lines, exCode) = p.readLines()

  DebugLog.add(lines)

  if exCode == 0:
    for l in lines:
      var im: InstalledModule
      discard scanf(l, "$*  [$*]", im.name, im.version)
      for m in Modules:
        if m.name == im.name:
          im.descr = m.descr
      result.add(im)
    Log.add("Load installed module list")
  else:
    Log.add("Failed to parse installed module list")