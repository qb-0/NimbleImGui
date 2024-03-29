import nimgl/glfw

type 
  Module* = object
    name*, url*, website*, descr*, license*: string

  InstalledModule* = object
    name*, version*, descr*: string

var
  Log*, NimbleLog*: seq[string]
  Modules*: seq[Module]
  Installed*: seq[InstalledModule]
  GLFWWin*: GLFWWindow