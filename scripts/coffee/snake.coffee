$ () ->
  primary = '#f40'
  secondary = '#333'

  canvas = $('#canvas')
  ctx = canvas[0].getContext('2d')
  w_px = canvas.width()
  h_px = canvas.height()
  cell = 10
  w = w_px / cell
  h = h_px / cell

  class Snake
    constructor: (@direction, @load_pos) ->
    init: =>
      nodes = []
      dir = @direction
      dir_temp = @direction
      score: 0
      speed: 5
    step: =>
      x_head = @nodes[0].x
      y_head = @nodes[0].y
      @dir = @dir_temp
      switch @dir
        when "right" then x_head++
        when "left" then x_head--
        when "up" then y_head--
        when "down" then y_head++
      if checkCollision() is true
        init(0)
        return
      else if lead_x1 is food.x and lead_y1 is food.y
        tail1 = {x: lead_x1, y: lead_y1}
        score1++
        createFood()
      else
        tail1 = s1_array.pop()
        tail1.x = lead_x1
        tail1.y = lead_y1

    checkCollision: =>
      if 0 <= @x_head < w and 0 <= @y_head < h
        for node in @nodes
          if node.x is @x_head and node.y is @y_head
            return true
        return false
      else
        return true

  s1 = new Snake("right", 0)
  s2 = new Snake("left", 0)

  d1 = dt1 = 'right'
  d2 = dt2 = 'left'
  score1 = 0
  score2 = 0

  food = ''

  s1_array = []
  s2_array = []

  checkCollision = (x, y, array1, array2) ->
    full_array = array1.concat(array2)
    if 0 <= x < w and 0 <= y < h
      for pos in full_array
        if pos.x is x and pos.y is y
          return true
      return false
    else
      return true

  createFood = () ->
    food =
      x: Math.round Math.random() * (w - 1)
      y: Math.round Math.random() * (h - 1)

  paintCell = (x, y) ->
    ctx.fillStyle = primary
    ctx.fillRect x * cell, y * cell, cell, cell

  paint = () ->
    ctx.fillStyle = secondary
    ctx.fillRect 0, 0, w_px, h_px

    lead_x1 = s1_array[0].x
    lead_y1 = s1_array[0].y
    lead_x2 = s2_array[0].x
    lead_y2 = s2_array[0].y

    d1 = dt1
    d2 = dt2
    switch d1
      when "right" then lead_x1++
      when "left" then lead_x1--
      when "up" then lead_y1--
      when "down" then lead_y1++

    switch d2
      when "right" then lead_x2++
      when "left" then lead_x2--
      when "up" then lead_y2--
      when "down" then lead_y2++

    if checkCollision(lead_x1, lead_y1, s1_array, s2_array) is true
      init(0)
      return
    else if lead_x1 is food.x and lead_y1 is food.y
      tail1 = {x: lead_x1, y: lead_y1}
      score1++
      createFood()
    else
      tail1 = s1_array.pop()
      tail1.x = lead_x1
      tail1.y = lead_y1


    if checkCollision(lead_x2, lead_y2, s1_array, s2_array) is true
      init(0)
      return
    else if lead_x2 is food.x and lead_y2 is food.y
      tail2 = {x: lead_x2, y: lead_y2}
      score2++
      createFood()
    else
      tail2 = s2_array.pop()
      tail2.x = lead_x2
      tail2.y = lead_y2

    s1_array.unshift(tail1)
    s2_array.unshift(tail2)

    paintCell c.x, c.y for c in s1_array
    paintCell c.x, c.y for c in s2_array
    paintCell food.x, food.y
    score_text = "Score 1: #{score1}     Score 2: #{score2}"
    ctx.fillText score_text, 5, h_px - 5


  $(document).keydown (e) ->
    switch e.which
      when 37 then if d1 isnt "right" then dt1 = "left"
      when 38 then if d1 isnt "down" then dt1 = "up"
      when 39 then if d1 isnt "left" then dt1 = "right"
      when 40 then if d1 isnt "up" then dt1 = "down"
      when 65 then if d2 isnt "right" then dt2 = "left"
      when 87 then if d2 isnt "down" then dt2 = "up"
      when 68 then if d2 isnt "left" then dt2 = "right"
      when 83 then if d2 isnt "up" then dt2 = "down"

  init = (num) ->
    s1_array = []
    s2_array = []
    for i in [4..0]
      s1_array.push {x: i, y: 0}
      s2_array.push {x: w - 1 - i, y: h - 1}
    d1 = dt1 = 'right'
    d2 = dt2 = 'left'
    score1 = score2 = 0
    createFood()

    if num is 0 then clearInterval(game_loop)
    if num is 1 then game_loop = setInterval(paint, 60) #60fps

  init(1)