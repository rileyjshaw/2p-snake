$ () ->
  xy = (x, y) ->
    x: x
    y: y
    is: (point) ->
      return @x is point.x and @y is point.y

  # directions
  UP = xy 0, -1
  DOWN = xy 0, 1
  LEFT = xy -1, 0
  RIGHT = xy 1, 0

  KEYCODES =
    LEFT: 37
    UP: 38
    RIGHT: 39
    DOWN: 40
    A: 65
    D: 68
    S: 83
    W: 87

  class KeyboardController
    #- instance variables -#
    _watched_keys: {}
    _keys_down: []

    #- instance methods -#
    addCombo: (snake, keys) ->
      # Can I call addCombo from a snake and use 'this'
      # rather than passing in the snake?
      @_watched_keys[key] = snake for key in keys

    keyEvent: (e, pressed) =>
      key = e.which
      key_idx = @_keys_down.indexOf(key)
      if key_idx isnt -1 and pressed is true
        return

      snake = @_watched_keys[key]
      snake?.handleKey key, pressed

      if pressed is true then @_keys_down.push key
      else @_keys_down.splice key_idx, 1

    keyState: (key) =>
      return _keys_down.indexOf key isnt -1


  class Level
    constructor: (canvas = $('canvas'), @cell = 10, @primary = 'black', @secondary = 'yellow') ->
      @ctx = canvas[0].getContext('2d')
      @px_width = canvas.width()
      @px_height = canvas.height()
      @width = @px_width / @cell
      @height = @px_height / @cell
      @createFood()
      @clock = 0

    getTime: () =>
      return @clock

    paintCell: (x, y) =>
      @ctx.fillStyle = @primary
      @ctx.fillRect x * @cell, y * @cell, @cell, @cell

    paint: () =>
      @ctx.fillStyle = @secondary
      @ctx.fillRect 0, 0, @px_width, @px_height
      for snake in Snake.getPlayers()
        snake.step()
        @paintCell(node.x, node.y) for node in snake.nodes
      @paintCell @food.x, @food.y
      score_text = "Score 1: #{Snake.getPlayer(1).score}     Score 2: #{Snake.getPlayer(2).score}"
      @ctx.fillText score_text, 5, @px_height - 5
      @clock++

    createFood: () =>
      @food = xy(
        Math.round Math.random() * (@width - 1)
      , Math.round Math.random() * (@height - 1)
      )


  class Snake
    #- class variables & methods -#
    @_players: []

    @getPlayer: (num) ->
      return @_players[num - 1]
    @getPlayers: ->
      return @_players

    #- instance variables -#
    _direction: {}
    _load_direction: {}

    constructor: (direction, @load, up, down, left, right) ->
      Snake._players.push(@)
      @_direction = @_load_direction = direction
      @score = 0
      @_speed = 2
      ###
      -- TODO --
      Make the directions in a loop.
      ###
      @keys = {}
      @keys[up] =
        direction: UP
      @keys[down] =
        direction: DOWN
      @keys[left] =
        direction: LEFT
      @keys[right] =
        direction: RIGHT

      key_controller.addCombo @, [up, down, left, right]
      @resetSnakePosition()

    #- instance methods -#
    getDirection: =>
      return @_direction

    setDirection: (dir) =>
      if dir.x * @_direction.x + dir.y * @_direction.y isnt -1
        @_direction = dir
        @setSpeed 1

    getSpeed: (speed) =>
      return @_speed

    setSpeed: (speed) =>
      @_speed = speed

    handleKey: (key, pressed) =>
      dir = @keys[key].direction
      if pressed is true
        @setDirection dir
      else if dir.is @getDirection()
        @setSpeed 2

    resetSnakePosition: =>
      @_direction = @_load_direction
      @nodes = []
      for i in [4..0]
        @nodes.push xy @load.x + i * @_load_direction.x, @load.y + i * @_load_direction.y

    checkCollision: (point) =>
      if 0 <= point.x < level.width and 0 <= point.y < level.height
        for node in @nodes
          if point.is node
            return true
        return false
      else
        return true

    step: =>
      if level.getTime() % (Math.pow 2, @getSpeed()) is 0
        head = xy(
          @nodes[0].x + @getDirection().x,
          @nodes[0].y + @getDirection().y
        )

        if @checkCollision(head) is true
          @resetSnakePosition()
          @score = Math.max @score - 2, 0
        else
          if head.is level.food
            @score++
            level.createFood()
          else
            @nodes.pop()
          @nodes.unshift head

  (init = () ->
    ###
    TODO
    deal with window.yuck
    ###
    window.key_controller = new KeyboardController
    window.level = new Level()
    p1 = new Snake xy(1, 0), xy(0, 0), KEYCODES.W, KEYCODES.S, KEYCODES.A, KEYCODES.D
    p2 = new Snake xy(-1, 0), xy(level.width - 1, level.height - 1), KEYCODES.UP, KEYCODES.DOWN, KEYCODES.LEFT, KEYCODES.RIGHT

    $(document).bind
      keydown: (e) ->
        key_controller.keyEvent e, true
      keyup: (e) ->
        key_controller.keyEvent e, false

    game_loop = setInterval(level.paint, 16.667) #60fps
  )()