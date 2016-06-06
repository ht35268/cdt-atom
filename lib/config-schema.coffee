module.exports =

  environmentOptions:
    title: "Environment Options"
    type: "object"
    properties:

      compilerPath:
        title: "Compiler Path"
        description: "The relative / absolute path of your GNU C++ Compiler."
        type: "string"
        default: "g++"

  compilerOptions:
    title: "Compiler Options"
    type: "object"
    properties:

      dialect:
        title: "Language Dialect"
        description: "The C++ dialect you are currently using."
        enum: ["ISO C++98", "ISO C++03", "ISO C++11", "ISO C++14", "ISO C++17 (Experimental)", "GNU C++98", "GNU C++03", "GNU C++11", "GNU C++14", "GNU C++17 (Experimental)"]
        default: "ISO C++11"
        type: "string"

      debugInfo:
        title: "Debugging Information"
        description: "The level of debugging"
        enum: ["None", "Minimal (-g1)", "Default (-g)", "Maximal (-g3)"]
        default: "Default (-g)"
        type: "string"

      otherOptions:
        title: "Other Options"
        description: "Additional options when invoking the compiler."
        type: "string"
        default: ""

      buildMode:
        title: "Build Mode"
        description: "The mode of build compilation."
        enum: ["Current file only", "All files under current directory"]
        default: "Current file only"
        type: "string"

  terminalOptions:
    title: "Terminal Options"
    type: "object"
    properties:

      fontSize:
        title: "Terminal Font Size"
        description: "The font size of the terminal."
        type: "integer"
        default: 20
        min: 8
        max: 100
