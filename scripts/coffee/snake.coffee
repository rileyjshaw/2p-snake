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
    SPACE: 32
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
    constructor: (canvas = $('canvas'), @cell = 10, @primary = '#525252', @secondary = '#f2d435') ->
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
      for score_pair in @score_pairs
        score_pair[0].innerHTML = score_pair[1].getScore()
      @clock++

    createFood: () =>
      @food = xy(
        Math.round Math.random() * (@width - 1)
      , Math.round Math.random() * (@height - 1)
      )

    scoreMap: () =>
      @score_pairs = []
      for snake, i in Snake.getPlayers()
        @score_pairs.push [document.getElementById("score#{i + 1}"), snake]


  class Snake
    #- class variables & methods -#
    @_players: []

    @getPlayer: (num) ->
      return @_players[num - 1]
    @getPlayers: () ->
      return @_players

    #- instance variables -#
    _direction: {}
    _load_direction: {}

    constructor: (direction, @load, up, down, left, right) ->
      Snake._players.push(@)
      ###
      -- TODO --
      This is totally redundant with the first few
      lines of reset()
      ###
      @_direction = @_load_direction = direction
      @_score = 0
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
      @reset()

    #- instance methods -#
    getDirection: =>
      return @_direction

    setDirection: (dir, reset = false) =>
      if reset is true or (dir.x * @getDirection().x + dir.y * @getDirection().y) isnt -1
        @_direction = dir
        @setSpeed 1

    getSpeed: () =>
      return @_speed

    setSpeed: (speed) =>
      @_speed = speed

    getScore: () =>
      return @_score

    setScore: (score) =>
      @_score = score

    handleKey: (key, pressed) =>
      dir = @keys[key].direction
      if pressed is true
        @setDirection dir
      else if dir.is @getDirection()
        @setSpeed 2

    reset: =>
      @setDirection @_load_direction, true
      @setScore Math.max(@getScore() - 2, 0)
      @setSpeed 2
      @nodes = []
      for i in [@getScore() + 4..0]
        @nodes.unshift xy @load.x - i * @_load_direction.x, @load.y - i * @_load_direction.y

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
          @reset()
        else
          if head.is level.food
            @setScore @getScore() + 1
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
    level.scoreMap()

    $(document).bind
      keydown: (e) ->
        key_controller.keyEvent e, true
      keyup: (e) ->
        key_controller.keyEvent e, false

    game_loop = setInterval(level.paint, 16.667) #60fps
  )()