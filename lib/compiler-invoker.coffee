CompilerInvokerView = require './compiler-invoker-view'
Invoker = require './invoker'
{CompositeDisposable} = require 'atom'

configSchema = require "./config-schema"

module.exports = ConsoleView =
  config: configSchema

  consumeToolBar: (toolBar) ->
    @toolBar = toolBar('compiler-invoker')
    
    @toolBar.addButton
      icon: 'code'
      callback: 'compiler-invoker:compile-and-run'
      tooltip: 'Compile and Run'
      iconset: 'ion'
      priority: 256
	
    @toolBar.addButton
      icon: 'hammer'
      callback: 'compiler-invoker:compile-only'
      tooltip: 'Compile'
      iconset: 'ion'
      priority: 256
    
    @toolBar.addSpacer
      priority: 256

    @toolBar.addButton
      icon: 'gear-a'
      callback: 'compiler-invoker:execute-only'
      tooltip: 'Run Program'
      iconset: 'ion'
      priority: 256
	
    @toolBar.addButton
      icon: 'backspace'
      callback: 'compiler-invoker:clear-console'
      tooltip: 'Clear console'
      iconset: 'ion'
      priority: 256
	
    @toolBar.addButton
      icon: 'alert'
      callback: 'compiler-invoker:kill-process'
      tooltip: 'Kill process'
      iconset: 'ion'
      priority: 256

    @toolBar.addSpacer
      priority: 256

  activate: (state) ->
    @compilerInvokerView = new CompilerInvokerView(state.compilerInvokerViewState)
    @invoker = new Invoker ((text) => @compilerInvokerView.appendText(text)), \
                           ((info) => @compilerInvokerView.appendInformation(info))

    @compilerInvokerView.onInput(@invoker.writeToProcess)
    @modalPanel = atom.workspace.addBottomPanel(item: @compilerInvokerView.getElement(), visible: true)

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'compiler-invoker:toggle': =>
        @compilerInvokerView.toggleConsole()
      'compiler-invoker:compile-and-run': =>
        @compilerInvokerView.showConsole()
        @invoker.compileAndExecute(true)
      'compiler-invoker:compile-only': =>
        @compilerInvokerView.showConsole()
        @invoker.compileOnly()
      'compiler-invoker:execute-only': =>
        @compilerInvokerView.showConsole()
        @invoker.executeOnly()
      'compiler-invoker:clear-console': =>
        @compilerInvokerView.clearText()
      'compiler-invoker:kill-process': =>
        @invoker.killProcess()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @compilerInvokerView.destroy()
    @toolBar?.removeItems();

  serialize: ->
    compilerInvokerViewState: @compilerInvokerView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
