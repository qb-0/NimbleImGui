# Package

version       = "1.0.0"
author        = "qb"
description   = "ImGui Frontend for Nimble"
license       = "MIT"
srcDir        = "src"
installFiles  = @["imgui.ini"]
bin           = @["NimbleImGui"]
backend       = "cpp"


# Dependencies

requires "nim >= 1.4.2"
requires "nimgl"