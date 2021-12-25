# Package

version       = "0.1.0"
author        = "qb"
description   = "ImGui Frontend for Nimble"
license       = "MIT"
srcDir        = "src"
bin           = @["NimbleImGui"]
backend       = "cpp"


# Dependencies

requires "nim >= 1.4.2"
requires "nimgl"