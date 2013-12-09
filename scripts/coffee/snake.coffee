$ () ->
  # directions
  UP = LEFT = -1
  DOWN = RIGHT = 1

  # colors
  PRIMARY = '#f40'
  SECONDARY = '#333'

  # deal with this
  level = []

  xy = (x, y) ->
    x: x
    y: y
    is: (point) ->
      return @x is point.x and @y is point.y

  class Level
    constructor: (canvas = $('canvas'), @cell = 10) ->
      @ctx = canvas[0].getContext('2d')
      @px_width = canvas.width()
      @px_height = canvas.height()
      @width = @px_width / @cell
      @height = @px_height / @cell
      @createFood()

    paintCell: (x, y) =>
      @ctx.fillStyle = PRIMARY
      @ctx.fillRect x * @cell, y * @cell, @cell, @cell

    paint: () =>
      @ctx.fillStyle = SECONDARY
      @ctx.fillRect 0, 0, @px_width, @px_height
      for snake in Snake.getPlayers()
        snake.step()
        @paintCell(node.x, node.y) for node in snake.nodes
      @paintCell @food.x, @food.y
      score_text = "Score 1: #{Snake.getPlayer(1).score}     Score 2: #{Snake.getPlayer(2).score}"
      @ctx.fillText score_text, 5, @px_height - 5

    createFood: () =>
      @food = xy(
        Math.round Math.random() * (@width - 1)
      , Math.round Math.random() * (@height - 1)
      )

  class Snake
    ###

    @direction [x, y]
      Direction of motion.
      [1, 0]:  Left
      [-1, 0]: Right
      [0, 1]:  Down
      [0, -1]: Up

    @load [x, y]
      Starting position of the tail node.
      [0, 0] represents the level's top left corner.
    ###

    #- class methods & variables -#
    @_players: []

    @getPlayer: (num) ->
      return @_players[num - 1]
    @getPlayers: ->
      return @_players

    #- instance methods & variables -#
    _buffer_direction: {}
    _direction: {}
    _load_direction: {}

    getDirection: =>
      return @_direction

    setX: (x) =>
      @_buffer_direction = xy(x, 0)
    setY: (y) =>
      @_buffer_direction = xy(0, y)

    resetSnakePosition: =>
      @_buffer_direction = @_direction = @_load_direction
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
      @_direction = @_buffer_direction

      head = xy(
        @nodes[0].x + @getDirection().x,
        @nodes[0].y + @getDirection().y
      )

      if @checkCollision(head) is true
        @resetSnakePosition()
        @score = 0
        return
      else
        if head.is level.food
          @score++
          level.createFood()
        else
          @nodes.pop()
        @nodes.unshift head

    constructor: (direction, @load) ->
      Snake._players.push(@)
      @_buffer_direction = @_direction = @_load_direction = direction
      @score = 0
      @speed = 5
      @resetSnakePosition()

  $(document).keydown (e) ->
    switch e.which
      when 65
        if Snake.getPlayer(1).getDirection().x isnt RIGHT
          Snake.getPlayer(1).setX(LEFT)
      when 87
       if Snake.getPlayer(1).getDirection().y isnt DOWN
        Snake.getPlayer(1).setY(UP)
      when 68
       if Snake.getPlayer(1).getDirection().x isnt LEFT
        Snake.getPlayer(1).setX(RIGHT)
      when 83
       if Snake.getPlayer(1).getDirection().y isnt UP
        Snake.getPlayer(1).setY(DOWN)
      when 37
       if Snake.getPlayer(2).getDirection().x isnt RIGHT
        Snake.getPlayer(2).setX(LEFT)
      when 38
       if Snake.getPlayer(2).getDirection().y isnt DOWN
        Snake.getPlayer(2).setY(UP)
      when 39
       if Snake.getPlayer(2).getDirection().x isnt LEFT
        Snake.getPlayer(2).setX(RIGHT)
      when 40
       if Snake.getPlayer(2).getDirection().y isnt UP
        Snake.getPlayer(2).setY(DOWN)

  (init = () ->
    level = new Level()
    p1 = new Snake xy(1, 0), xy(0, 0)
    p2 = new Snake xy(-1, 0), xy(level.width - 1, level.height - 1)

    game_loop = setInterval(level.paint, 60) #60fps
  )()