{File} = require 'atom'
spawn = require('child_process').spawn

module.exports =
class Invoker

  constructor: (@textFunction, @informationFunction) ->

  getExtension: (path) ->
    return path.substring(path.lastIndexOf('.') + 1)

  filterFiles: (directory, extension) ->
    files = (file for file in directory.getEntriesSync() when @getExtension(file.getPath()) == extension)
    return files

  getActiveDirectory: ->
    return new File(atom.workspace.getActiveTextEditor().getPath()).getParent()

  getConfig: (config) ->
    atom.config.get "compiler-invoker.#{config}"

  compileAndExecute: (doExecute) =>
    @killProcess()

    directory = @getActiveDirectory()

    # Define the type of compilation.
    all_files_build = (@getConfig("compilerOptions.buildMode") != "Current file only")
    if (all_files_build == true)
      files = (file.getPath() for file in @filterFiles(directory, "cpp"));
    else
      files = [atom.workspace.getActiveTextEditor().getPath()];

    # Define the language dialect
    lang_dialect = "-std=c++98"
    lang_dialect_str = @getConfig "compilerOptions.dialect"
    if (lang_dialect_str == "ISO C++98")
      lang_dialect = "-std=c++98"
    else if (lang_dialect_str == "ISO C++03")
      lang_dialect = "-std=c++03"
    else if (lang_dialect_str == "ISO C++11")
      lang_dialect = "-std=c++11"
    else if (lang_dialect_str == "ISO C++14")
      lang_dialect = "-std=c++14"
    else if (lang_dialect_str == "ISO C++17 (Experimental)")
      lang_dialect = "-std=c++17"
    else if (lang_dialect_str == "GNU C++98")
      lang_dialect = "-std=gnu++98"
    else if (lang_dialect_str == "GNU C++11")
      lang_dialect = "-std=gnu++11"
    else if (lang_dialect_str == "GNU C++14")
      lang_dialect = "-std=gnu++14"
    else if (lang_dialect_str == "GNU C++17 (Experimental)")
      lang_dialect = "-std=gnu++17"

    # Define the debugging information
    debug_info = "-g"
    debug_info_str = @getConfig "compilerOptions.debugInfo"
    if (debug_info_str == "None")
      debug_info = "-g0"
    else if (debug_info_str == "Minimal (-g1)")
      debug_info = "-g1"
    else if (debug_info_str == "Default (-g)")
      debug_info = "-g"
    else if (debug_info_str == "Maximal (-g3)")
      debug_info = "-g3"

    # Executing program
    executable = "a.exe"
    if (all_files_build == true)
      executable = directory.getPath() + "\\" + directory.getBaseName() + ".exe"
    else
      executable = atom.workspace.getActiveTextEditor().getPath() + ".exe"
    args = files.concat(['-o', executable, debug_info, lang_dialect])
    compilerProgram = @getConfig "environmentOptions.compilerPath"
    if (compilerProgram == "" || compilerProgram == undefined)
      compilerProgram = "g++"
    compiler = spawn(compilerProgram, args)
    compiler.stdout.on("data", (text) => @textFunction(text))
    compiler.stderr.on("data", (text) => @textFunction(text))
    compiler.on "exit", (code) =>
      if (code == 0)
        @informationFunction("Compilation succeeded.\n")
      else
        @informationFunction("Compilation finished with code " + code + ".\n")
      # Execute program if specified
      if (code == 0 && doExecute != false)
        @executeMain(executable)

    @informationFunction("Compling source code with GNU C++...\n")

  compileOnly: () =>
    @compileAndExecute(false)

  executeMain: (exec) =>
    if (exec == undefined || exec == "")
      @informationFunction("Failed to execute program: File not found.\n")
      return false
    @informationFunction("Executing program \"" + exec + "\"...\n")
    @exe = spawn(exec)
    @exe.stdout.on("data", @textFunction)
    @exe.stderr.on("data", @textFunction)
    @exe.on "exit", (exeCode, signal) =>
      @exe = undefined
      outcome = if exeCode? then ("code " + exeCode) else ("signal " + signal)
      # I am the glorious separator...
      @textFunction("\n----------------------------------------------------------------\n")
      if (outcome == "code 0")
        @informationFunction("Execution finished normally.\n")
      else
        @informationFunction("Execution finished with " + outcome + ".\n")

  executeOnly: () =>
    executable = "a.exe"
    all_files_build = (@getConfig("compilerOptions.buildMode") != "Current file only")
    directory = @getActiveDirectory()
    if (all_files_build == true)
      executable = directory.getPath() + "\\" + directory.getBaseName() + ".exe"
    else
      executable = atom.workspace.getActiveTextEditor().getPath() + ".exe"
    @executeMain(executable)

  writeToProcess: (data) =>
    if @exe?
      @textFunction(data)
      @exe.stdin.write(data + "\n")
      @textFunction("\n")

  killProcess: =>
    @exe?.kill()
