import
  os,
  nimgl/[glfw, opengl, imgui],
  nimgl/imgui/[impl_opengl, impl_glfw],
  ui, cmd, globals

const
  uiConfigName = "imgui.ini" 
  uiConfig = staticRead(uiConfigName)

template checkConfig =
  if not fileExists(uiConfigName):
    var f = open(uiConfigName, fmWrite)
    f.write(uiConfig)
    f.close()

template init =
  checkConfig()
  doAssert glfwInit()
  glfwWindowHint(GLFWDecorated, GLFWFalse)
  glfwWindowHint(GLFWResizable, GLFWFalse)
  glfwWindowHint(GLFWTransparentFramebuffer, GLFWTrue)
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglProfile, GLFWOpenglCoreProfile)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFWTrue)
  glfwWindowHint(GLFWSamples, 5)
  GLFWWin = glfwCreateWindow(
    getVideoMode(glfwGetPrimaryMonitor()).width - 1,
    getVideoMode(glfwGetPrimaryMonitor()).height - 1,
    icon=false, title="Nimble ImGui"
  )
  GlfwWin.makeContextCurrent()
  doAssert glInit()
  igCreateContext()
  doAssert igGlfwInitForOpenGL(GLFWWin, true)
  doAssert igOpenGL3Init()
  Modules = parseModules()
  Installed = parseInstalled()
  setStyle()

template uiLoop =
  var show = true
  igOpenGL3NewFrame()
  igGlfwNewFrame()
  igNewFrame()

  igBegin("Modules", show.addr)
  uiModules()
  igEnd()

  igBegin("Installed Modules")
  uiInstalledModules()
  igEnd()

  igBegin("Log")
  uiLog()
  igEnd()

  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())
  if not show: 
    GLFWWin.setWindowShouldClose(true)

proc main =
  init()
  while not GLFWWin.windowShouldClose():
    glfwPollEvents()
    glClear(GL_COLOR_BUFFER_BIT)
    uiLoop()
    GLFWWin.swapBuffers()

    if GLFWWin.getMouseButton(GLFWMouseButton.Button1) == 1 and not igGetIO().wantCaptureMouse:
      GLFWWin.iconifyWindow()

when isMainModule:
  main()