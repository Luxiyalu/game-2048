define ['jquery', 'TweenMax', 'data', 'three'], ($, TweenMax, Data) ->
  Transform = ->
    do @init
  proto = Transform.prototype
  
  proto.init = ->
    @queue = {}
    @padding = Data.padding
    @divWidth = Data.divWidth
    @numberPerLine = Data.numberPerLine
    @widthOfBoard = @numberPerLine * @divWidth + (@numberPerLine - 1) * 10
    @r = @widthOfBoard / 2

  proto.fromTo = (objects, targets, duration = 0.35, delay = 0) ->
    randomP = duration
    
    for i in [0...objects.length]
      if objects[i] isnt undefined
        object = objects[i]
        target = targets[i]
        
        if randomP is 'random'
          # console.log 'random'
          duration = 1 + Math.random()
          delay = 1.5 * Math.random()
          ease = Power3.easeInOut
        else
          ease = Power3.easeOut
        
        TweenMax.to object.position, duration,
          x: target.position.x
          y: target.position.y
          z: target.position.z
          ease: ease
          delay: delay
          overwrite: true
          onUpdate: =>
            do @game.render
            
        if target.rotation
          TweenMax.to object.rotation, duration,
            x: target.rotation.x
            y: target.rotation.y
            z: target.rotation.z
            ease: ease
            delay: delay
            overwrite: true

  proto.getIndex = (x, y) ->
    (y - 1) * @numberPerLine + (x - 1)
  proto.getSingleCoordinate = (a) ->
    Math.round((a + @r + @padding + 0.5*@divWidth) / (@divWidth + @padding))
  proto.getCoordinate = (a, b) ->
    if b isnt undefined
      x = @getSingleCoordinate(a)
      y = @getSingleCoordinate(b)
    else
      i = a
      x = i % @numberPerLine + 1
      y = Math.ceil ((i+1) / @numberPerLine)
    [x, y]

  proto.position = (i) ->
    coor = @getCoordinate(i)
    arr = [@getPositionX(coor[0]), @getPositionY(coor[1])]
  proto.getPositionX = (x) ->
    (x - 1/2) * @divWidth + (x - 1) * @padding - @r
  proto.getPositionY = (y) ->
    (y - 1/2) * @divWidth + (y - 1) * @padding - @r
    
  proto.getVacantI = (objects) ->
    vacants = []
    for i in [0...objects.length]
      if objects[i] is undefined
        vacants.push(i)
    l = vacants.length
    if l == 0
      false
    else
      i = Math.floor( Math.random() * l )
      vacants[i]
     
  proto.killDuplicates = (scene, objects, targets, duration) ->
    self = this
    objects.forEach (object, i) =>
      if object && object.kill
        # add to queue
        x = targets[i].position.x
        y = targets[i].position.y
        pos = @getCoordinate(x, y)
        queueI = @getIndex(pos[0], pos[1])
        @queue[queueI] = object.power + 1
        
        TweenMax.to object.div, duration,
          autoAlpha: 0
          onComplete: ->
            scene.remove(object)
            # no need to remove dom since removing from scene already includes that
            # $(object.div).remove()
            
        objects[i] = undefined
        
  proto.reorderObjects = (preOrdered, targets) ->
    reordered = new Array(preOrdered.length)
    
    preOrdered.forEach (object, i) =>
      if object isnt undefined
        x = targets[i].position.x
        y = targets[i].position.y
        coor = @getCoordinate(x, y)
        i = @getIndex(coor[0], coor[1])
        
        reordered[i] = object
        
    reordered

  transform = new Transform()
