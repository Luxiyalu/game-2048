define ['transform', 'element', 'data'], (Transform, Ele, Data) ->
  GameLogic = () ->
    do @init
  proto = GameLogic.prototype
  
  proto.init = ->
    @numberPerLine = Data.numberPerLine
  
  proto.getTargets = (objects, direction) ->
    targetLines = []
    
    lines = @arrToLines(objects, direction)
    lines.forEach (lineOfObjects, I, A) =>
      targetLine = @lineCompile(lineOfObjects)
      targetLines.push targetLine
      
    targetArr = @linesToArr(direction, targetLines)
    
    targetArr.forEach (object, i, a) =>
      if object isnt undefined
        obj = {}
        obj.position = {}
        
        if direction is 'left'
          obj.position.x = Transform.getPositionX(object.pos + 1)
          obj.position.y = object.position.y
        if direction is 'right'
          obj.position.x = Transform.getPositionX(@numberPerLine - object.pos)
          obj.position.y = object.position.y
        if direction is 'down'
          obj.position.y = Transform.getPositionY(object.pos + 1)
          obj.position.x = object.position.x
        if direction is 'up'
          obj.position.y = Transform.getPositionY(@numberPerLine - object.pos)
          obj.position.x = object.position.x
          
        targetArr[i] = obj
          
    targetArr

  proto.lineCompile = (array) ->
    killLine = []
    # this array might not be all filled
    filledArr = array.filter (object) ->
      object isnt undefined
      
    filledlength = filledArr.length
    
    compile = (i, pos, targetArr) =>
      n = i + 1
      if i == filledlength
        targetArr
      else if i + 1 == filledlength
        # last one left, leave this one out cos filledArr[n] might not exist
        targetArr.push pos
        compile i+1, pos+1, targetArr
      else if filledArr[i].power == filledArr[n].power
        killLine.push i, i+1
        targetArr.push pos, pos
        compile i+2, pos+1, targetArr
      else
        targetArr.push pos
        compile i+1, pos+1, targetArr
        
    arr = compile(0, 0, [])

    for i in killLine
      filledArr[i].kill = true
    
    targetLine = []
    array.forEach (object, i) ->
      if object
        object.pos = arr.shift()
        
    array

  proto.arrToLines = (objects, direction) ->
    lines = []
    
    [1..@numberPerLine].forEach (a) =>
      line = []
      
      [1..@numberPerLine].forEach (b) =>
        
        if direction is 'right' or direction is 'left'
          i = Transform.getIndex(b, a)
        if direction is 'up' or direction is 'down'
          i = Transform.getIndex(a, b)
          
        line.push objects[i]
          
      if direction is 'up' or direction is 'right'
        line.reverse()
        
      lines.push(line)
     
    lines

  proto.linesToArr = (direction, lines) ->
    targets = []
    
    [0...@numberPerLine].forEach (a) =>
      [0...@numberPerLine].forEach (b) =>
        if direction is 'left'
          object = lines[a][b]
          
        if direction is 'right'
          y = @numberPerLine - 1 - b
          object = lines[a][y]
          
        if direction is 'down'
          object = lines[b][a]
          
        if direction is 'up'
          y = @numberPerLine - 1 - a
          object = lines[b][y]
          
        targets.push object
     
    targets
  
  gameLogic = new GameLogic()
