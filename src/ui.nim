import strutils, browsers
import nimgl/imgui
import globals, cmd

const
  debugColor = ImVec4(y: 0.6, z: 1, w: 1)
  installedColor = ImVec4(y: 1, z: 0.2, w: 1)

proc setAlpha*(v: float32) =
  var style = igGetStyle()
  for i, c in style.colors:
    var vec = ImVec4(x: c.x, y: c.y, z: c.z, w: v)
    style.colors[i] = vec

proc uiLog* =
  var
    autoscroll {.global.}: bool = true
    debug {.global.}: bool

  if igButton("Clear"):
    Log.setLen(0)
    NimbleLog.setLen(0)
  igSameLine()
  igCheckBox("Autoscroll", autoscroll.addr)
  igSameLine()
  igCheckBox("Nimble", debug.addr)
  igBeginChild("scrolling", flags=ImGuiWindowFlags.NoBackground)
  igPushStyleVar(ImguiStyleVar.ItemSpacing, ImVec2(x: 0, y: 1))
  if debug:
    for l in NimbleLog:
      igTextColored(debugColor, l.strip().cstring)
  for l in Log:
    igTextColored(installedColor, l.cstring)
  if autoscroll:
    igSetScrollHereY(1.0)
  igPopStyleVar()
  igEndChild()

proc uiInstalledModules* =
  var
    selected {.global.} = -1
    selectedMod {.global.}: InstalledModule
  
  if igButton("Refresh"):
    Installed = parseInstalled()
  igSameLine()
  if igButton("Uninstall") and selected != -1:
    uninstallModule(selectedMod.name)
    Installed = parseInstalled()
  igSameLine()
  if igButton("Reinstall") and selected != -1:
    installModule(selectedMod.name)
    Installed = parseInstalled()
  igBeginChild("installed", flags = ImGuiWindowFlags.NoBackground)
  igSeparator()
  igColumns(2, "modulelist", true)
  igSetColumnWidth(0, 200)
  igText("Name")
  igNextColumn()
  igText("Version")
  igNextColumn()
  igSeparator()
  for i, m in Installed:
    if igSelectable(m.name.cstring, selected == i, flags = ImGuiSelectableFlags.SpanAllColumns):
      selected = i
      selectedMod = m
    if igIsItemHovered() and igGetCurrentContext().hoveredIdTimer > 0.3:
      igBeginTooltip()
      igTextUnformatted(m.descr.cstring)
      igEndTooltip()
    igNextColumn()
    igText(m.version.cstring)
    igNextColumn()
  igEndChild()

proc uiModules* =
  var
    filterBuf {.global.}: string
    selected {.global.} = -1
    selectedMod {.global.}: Module
    transparency {.global.}: float32 = 0.9

  filterBuf.setLen(20)
  if igButton("Update"):
    updateModules()
    Modules = parseModules()
  igSameLine()
  if igButton("Install") and selected != -1 or
  igIsAnyItemHovered() and igIsMouseDoubleClicked(ImGuiMouseButton.Left):
    installModule(selectedMod.name)
    Installed = parseInstalled()
  igSameLine()
  if igButton("Website") and selected != -1:
    Log.add("Visiting " & selectedMod.url)
    openDefaultBrowser(selectedMod.url)
  igSameLine()
  igText(("Modules: " & $len(Modules)).cstring)
  igSameLine()
  igDummy(ImVec2(x: 200))
  igSameLine()
  igSetNextItemWidth(-1)
  if igSliderFloat("##Transparency", transparency.addr, 0.1, 1.0, format="Transparency: %.1f"):
    setAlpha(transparency)
  igSetNextItemWidth(-1)
  igInputText("Filter", filterBuf.cstring, 20)
  igSeparator()
  igColumns(3, "moduleheader", true)
  igSetColumnWidth(0, 150)
  igText("Name")
  igNextColumn()
  igSetColumnWidth(1, 150)
  igText("License") 
  igNextColumn()
  igText("Description")
  igSeparator()
  igEndColumns()
  igBeginChild("modules", flags=ImGuiWindowFlags.NoBackground)
  igColumns(3, "modulelist", true)
  igSetColumnWidth(0, 150)
  igSetColumnWidth(1, 150)
  var filterStr = $cast[cstring](filterBuf[0].unsafeAddr)
  for i, m in Modules:
    var installed: bool
    if filterStr.toLower() notin m.name.toLower() and 
    filterStr.toLower() notin m.descr.toLower(): continue
    for im in Installed:
      if im.name == m.name:
        igPushStyleColor(ImGuiCol.Text, installedColor)
        installed = true
    if igSelectable(m.name.cstring, selected == i, flags = ImGuiSelectableFlags.SpanAllColumns):
      selected = i
      selectedMod = m
    igNextColumn()
    igText(m.license.cstring)
    igNextColumn()
    igTextWrapped(m.descr.cstring)
    igNextColumn()
    if installed:
      igPopStyleColor()
  igSeparator()
  igEndChild()

proc setStyle* =
  proc igVec4(x, y, z, w: float32): ImVec4 = ImVec4(x: x, y: y, z: z, w: w)

  var s = igGetStyle()
  
  s.colors[ImGuiCol.Text.int32]                   = igVec4(1.00, 1.00, 1.00, 1.00)
  s.colors[ImGuiCol.TextDisabled.int32]           = igVec4(0.40, 0.40, 0.40, 1.00)
  s.colors[ImGuiCol.ChildBg.int32]                = igVec4(0.25, 0.25, 0.25, 1.00)
  s.colors[ImGuiCol.WindowBg.int32]               = igVec4(0.25, 0.25, 0.25, 1.00)
  s.colors[ImGuiCol.PopupBg.int32]                = igVec4(0.25, 0.25, 0.25, 1.00)
  s.colors[ImGuiCol.Border.int32]                 = igVec4(0.12, 0.12, 0.12, 0.71)
  s.colors[ImGuiCol.BorderShadow.int32]           = igVec4(1.00, 1.00, 1.00, 0.06)
  s.colors[ImGuiCol.FrameBg.int32]                = igVec4(0.42, 0.42, 0.42, 0.54)
  s.colors[ImGuiCol.FrameBgHovered.int32]         = igVec4(0.42, 0.42, 0.42, 0.40)
  s.colors[ImGuiCol.FrameBgActive.int32]          = igVec4(0.56, 0.56, 0.56, 0.67)
  s.colors[ImGuiCol.TitleBg.int32]                = igVec4(0.19, 0.19, 0.19, 1.00)
  s.colors[ImGuiCol.TitleBgActive.int32]          = igVec4(0.22, 0.22, 0.22, 1.00)
  s.colors[ImGuiCol.TitleBgCollapsed.int32]       = igVec4(0.17, 0.17, 0.17, 0.90)
  s.colors[ImGuiCol.MenuBarBg.int32]              = igVec4(0.335, 0.335, 0.335, 1.000)
  s.colors[ImGuiCol.ScrollbarBg.int32]            = igVec4(0.24, 0.24, 0.24, 0.53)
  s.colors[ImGuiCol.ScrollbarGrab.int32]          = igVec4(0.41, 0.41, 0.41, 1.00)
  s.colors[ImGuiCol.ScrollbarGrabHovered.int32]   = igVec4(0.52, 0.52, 0.52, 1.00)
  s.colors[ImGuiCol.ScrollbarGrabActive.int32]    = igVec4(0.76, 0.76, 0.76, 1.00)
  s.colors[ImGuiCol.CheckMark.int32]              = igVec4(0.65, 0.65, 0.65, 1.00)
  s.colors[ImGuiCol.SliderGrab.int32]             = igVec4(0.52, 0.52, 0.52, 1.00)
  s.colors[ImGuiCol.SliderGrabActive.int32]       = igVec4(0.64, 0.64, 0.64, 1.00)
  s.colors[ImGuiCol.Button.int32]                 = igVec4(0.54, 0.54, 0.54, 0.35)
  s.colors[ImGuiCol.ButtonHovered.int32]          = igVec4(0.52, 0.52, 0.52, 0.59)
  s.colors[ImGuiCol.ButtonActive.int32]           = igVec4(0.76, 0.76, 0.76, 1.00)
  s.colors[ImGuiCol.Header.int32]                 = igVec4(0.38, 0.38, 0.38, 1.00)
  s.colors[ImGuiCol.HeaderHovered.int32]          = igVec4(0.47, 0.47, 0.47, 1.00)
  s.colors[ImGuiCol.HeaderActive.int32]           = igVec4(0.76, 0.76, 0.76, 0.77)
  s.colors[ImGuiCol.Separator.int32]              = igVec4(0.000, 0.000, 0.000, 0.137)
  s.colors[ImGuiCol.SeparatorHovered.int32]       = igVec4(0.700, 0.671, 0.600, 0.290)
  s.colors[ImGuiCol.SeparatorActive.int32]        = igVec4(0.702, 0.671, 0.600, 0.674)
  s.colors[ImGuiCol.ResizeGrip.int32]             = igVec4(0.26, 0.59, 0.98, 0.25)
  s.colors[ImGuiCol.ResizeGripHovered.int32]      = igVec4(0.26, 0.59, 0.98, 0.67)
  s.colors[ImGuiCol.ResizeGripActive.int32]       = igVec4(0.26, 0.59, 0.98, 0.95)
  s.colors[ImGuiCol.PlotLines.int32]              = igVec4(0.61, 0.61, 0.61, 1.00)
  s.colors[ImGuiCol.PlotLinesHovered.int32]       = igVec4(1.00, 0.43, 0.35, 1.00)
  s.colors[ImGuiCol.PlotHistogram.int32]          = igVec4(0.90, 0.70, 0.00, 1.00)
  s.colors[ImGuiCol.PlotHistogramHovered.int32]   = igVec4(1.00, 0.60, 0.00, 1.00)
  s.colors[ImGuiCol.TextSelectedBg.int32]         = igVec4(0.73, 0.73, 0.73, 0.35)
  s.colors[ImGuiCol.ModalWindowDimBg.int32]       = igVec4(0.80, 0.80, 0.80, 0.35)
  s.colors[ImGuiCol.DragDropTarget.int32]         = igVec4(1.00, 1.00, 0.00, 0.90)
  s.colors[ImGuiCol.NavHighlight.int32]           = igVec4(0.26, 0.59, 0.98, 1.00)
  s.colors[ImGuiCol.NavWindowingHighlight.int32]  = igVec4(1.00, 1.00, 1.00, 0.70)
  s.colors[ImGuiCol.NavWindowingDimBg.int32]      = igVec4(0.80, 0.80, 0.80, 0.20)

  s.windowPadding    = ImVec2(x: 4, y: 4)
  s.framePadding     = ImVec2(x: 6, y: 4)
  s.itemSpacing      = ImVec2(x: 6, y: 2)

  s.scrollbarSize     = 18

  s.windowBorderSize  = 1
  s.childBorderSize   = 1
  s.popupBorderSize   = 1
  s.frameBorderSize   = 0

  s.popupRounding     = 3
  s.windowRounding    = 3
  s.childRounding     = 3
  s.frameRounding     = 3
  s.scrollbarRounding = 2
  s.grabRounding      = 2