module.exports =
class CompilerInvokerView
  constructor: (serializedState) ->
    @dragInfo = {}
    @storedChars = ""
    @consoleShown = false

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('compiler-invoker')

    @resizer = document.createElement('div')
    @resizer.classList.add('resizer')
    @resizer.addEventListener 'mousedown', (e) =>
      @dragInfo = {x: e.clientX, y: e.clientY, height: @console.clientHeight}
      document.documentElement.addEventListener('mousemove', @resizeConsole, false)
      document.documentElement.addEventListener 'mouseup', =>
        document.documentElement.removeEventListener('mousemove', @resizeConsole, false)

    @consoleControl = document.createElement('div')
    @consoleControl.classList.add('console-control', 'icon')
    @consoleControl.addEventListener 'click', () =>
      @toggleConsole()

    # Create console element
    @console = document.createElement('textarea')
    @console.classList.add('console', 'native-key-bindings')
    @console.setAttribute('readonly', 'readonly')

    @input = document.createElement('input')
    @input.setAttribute('type', 'text')
    @input.classList.add('console-input', 'native-key-bindings')
    @input.addEventListener 'keydown', (e) =>
      if (e.keyCode == 13)
        @inputFunction(@input.value) if @inputFunction?
        @input.value = ''

    @element.appendChild(@resizer)
    @element.appendChild(@consoleControl)
    @element.appendChild(@console)
    @element.appendChild(@input)

    @hideConsole()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  resizeConsole: (e) =>
    height = (@dragInfo.height + (@dragInfo.y - e.clientY))
    if (height < (window.innerHeight - 100))
      @console.style.height = height + 'px';

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  onInput: (callback) ->
    @inputFunction = callback

  toggleConsole: ->
    if @consoleShown then @hideConsole() else @showConsole()

  showConsole: =>
    # if @consoleShown then return true
    @resizer.classList.remove('hidden')
    @console.classList.remove('hidden')
    @input.classList.remove('hidden')
    @consoleControl.classList.add('icon-triangle-down')
    @consoleControl.classList.remove('icon-triangle-up')
    @consoleShown = true

  hideConsole: =>
    # if @consoleShown then return false
    @resizer.classList.add('hidden')
    @console.classList.add('hidden')
    @input.classList.add('hidden')
    @consoleControl.classList.add('icon-triangle-up')
    @consoleControl.classList.remove('icon-triangle-down')
    @consoleShown = false

  appendText: (text) ->
    @console.textContent += @storedChars
    text = @handleNewLine(text)
    @console.textContent += text
    # In case it gets too long...
    @console.textContent = @console.textContent.slice(-10000)
    @console.scrollTop = @console.scrollHeight

  handleNewLine: (text) ->
    text += ""

    if (text.slice(-2) == '\r\n')
      @storedChars = '\r\n'
      text = text.substring(0, text.length - 2)
    else if (text.slice(-1) == '\n')
      @storedChars = '\n'
      text = text.substring(0, text.length - 1)
    else
      @storedChars = ""
    return text

  appendInformation: (info) ->
    @appendText("# " + info)

  clearText: ->
    @console.textContent = ''
    @storedChars = ''
