import nimgl/glfw

type 
  Module* = object
    name*, url*, descr*, license*: string

  InstalledModule* = object
    name*, version*, descr*: string

var
  Log*: seq[string]
  DebugLog*: seq[string]
  Modules*: seq[Module]
  Installed*: seq[InstalledModule]
  GLFWWin*: GLFWWindow