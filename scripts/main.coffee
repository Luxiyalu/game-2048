define ['jquery', 'data', 'element', 'gameLogic', 'transform', 'shapes', 'three', 'TrackballControls', 'CSS3DRenderer'], ($, Data, Element, GameLogic, Transform, Shapes) ->
  Game = ->
    Transform.game = this
    
    do @init
    do @reset
    do @bindEvents
    do @animate
  proto = Game.prototype
  
  proto.init = ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 40, window.innerWidth / window.innerHeight, 1, 10000
    @renderer = new THREE.CSS3DRenderer()
    @controls = new THREE.TrackballControls @camera, $('html')[0]
    @controls.rotateSpeed = 0.5
    @renderer.setSize(window.innerWidth, window.innerHeight)
    $('#container').append(@renderer.domElement)
    
    @menu = {}
    @menu.expand = false
    @menu.more = false
    @menu.length = $('.sub-controls .button').length
    
  proto.reset = (num = 4, clearBoard) ->
    if isNaN(num) || num != Math.floor(num) || num < 2
      return "Please reset with a natural number that's larger than or equal to 2."
    
    @noPressKey = false
    Data.numberPerLine = num
      
    @length = Data.numberPerLine * Data.numberPerLine
    @objects = new Array(@length)
    
    @controls.minDistance = 100
    @controls.maxDistance = 2500 / 4 * Data.numberPerLine

    GameLogic.init()
    Transform.init()
    
    do @resetCameraPosition
    do @clearScene
    do @resetMenu
    if !clearBoard
      do @insertNew
      do @insertNew

    x = Math.pow(2, @length)
    return "Game reset with a board "+num+" x "+num+". Highest possible score for a board this large: "+x+"."
  
  proto.resetMenu = ->
    if @menu.expand
      $('.controls .reset-6').trigger('click')

  proto.resetCameraPosition = ->
    @camera.position.set(0, 0, 800 / 4 * Data.numberPerLine)
    @camera.up = new THREE.Vector3(0,1,0)
    @camera.lookAt(new THREE.Vector3(0,0,0))
    window.scene = @scene
    
  proto.bindEvents = ->
    self = this
    # when controls are adjusted, rerender
    @controls.addEventListener 'change', =>
      do @render
      
    # when window resizes, rerender
    window.addEventListener 'resize', =>
        @camera.aspect = window.innerWidth / window.innerHeight
        @camera.updateProjectionMatrix()
        @renderer.setSize( window.innerWidth, window.innerHeight )
        
        do @render
      , false
  
      
    $(document).keydown (e) =>
      if @noPressKey
        return
      
      if e.which is 38
        direction = 'up'
      else if e.which is 40
        direction = 'down'
      else if e.which is 37
        direction = 'left'
      else if e.which is 39
        direction = 'right'
      else return
      
      @noPressKey = true
      setTimeout =>
          @noPressKey = false
        , Data.timeInterval * 1000
      
      @targets = GameLogic.getTargets(@objects, direction)
      
      # return if nothing to move, don't go on to insert a new number
      noMovement = [0...@objects.length].every (e, i, a) =>
        if @objects[i] isnt undefined
          posA = @objects[i].position
          posB = @targets[i].position
          # compare their positions (x, y) to see if there are movements
          posA.x == posB.x && posA.y == posB.y
        else
          true
      if noMovement
        return
        
      Transform.fromTo(@objects, @targets, Data.timeInterval)
      Transform.killDuplicates(@scene, @objects, @targets, Data.timeInterval)
      
      @objects = Transform.reorderObjects(@objects, @targets)
      @targets = Transform.reorderObjects(@targets, @targets)
        
      # fill in power up
      for i in [0...@objects.length]
        if Transform.queue[i]
          power = Transform.queue[i]
          coor = Transform.getCoordinate(i)
          @insertNew(coor[0], coor[1], power)
      Transform.queue = {}
      
      do @insertNew
    # bind the buttons
    $('.controls').on 'click', '.reset-4', =>
      @noPressKey = false
      $('.controls .reset-6').trigger('click') if @menu.expand
      do @reset
      
    $('.controls').on 'click', '.reset-6', =>
      if !@menu.expand
        @reset(6, true)
        @fillBoard()
        
        $('.sub-controls .button').each (index) ->
          TweenMax.to $(this), 0.5,
            autoAlpha: 1
            bottom: 29 * (self.menu.length - index - 1)
            ease: Power3.easeOut
            onComplete: ->
              self.menu.expand = true
              
      else
        $('.button.shape').addClass('inactive')
        $('.sub-controls .button').each (index) ->
          TweenMax.to $(this), 0.5,
            autoAlpha: 0
            bottom: 0
            ease: Power3.easeOut
            onComplete: ->
              self.menu.expand = false

    $('.controls').on 'click', '.shape', ->
      self.noPressKey = true
      return if $(this).hasClass('inactive')
      shape = $(this).data('shape')
      targets = Shapes.getTargets(shape)
      Transform.fromTo(self.objects, targets, 'random')
      
    $('.info .close').on 'click', ->
      TweenMax.to $('.info'), 0.3,
        # autoAlpha: 0
        bottom: -50
        ease: Power3.easeIn
    moreAnimateOut = =>
      @menu.more = false
      TweenMax.to $('.more'), 0.3,
        autoAlpha: 0
    moreAnimateIn = =>
      @menu.more = true
      TweenMax.to $('.more'), 0.3,
        autoAlpha: 1
        
    $('.controls').on 'click', '.more-control', =>
      if !@menu.more
        do moreAnimateIn
      else
        do moreAnimateOut
    $('#container').on 'click', =>
      do moreAnimateOut
    
      
  proto.fillBoard = () ->
    @noPressKey = true

    fill = (inc) =>
      if inc == @length
        setTimeout =>
            # when finished
            @noPressKey = false
            $('.button.shape').removeClass('inactive')
          , 100 * inc
        return
      else
        setTimeout =>
            @insertNew('randomPosition') if @noPressKey
          , 100 * inc
        fill(inc + 1)
          
    fill(0)

  proto.insertNew = (x, y, pow) ->
    if x is undefined || x is 'randomPosition'
      i = Transform.getVacantI(@objects)
      
      if i is false
        # check if it's dead in all four directions. If so, go to game over
        # not really necessary since player would've known
        do @gameOver
        return
      
    else
      i = Transform.getIndex(x, y)
      
    div = Element.create(pow)
    object = new THREE.CSS3DObject(div)
    object.div = div
    
    pos = Transform.position(i)
    object.position.x = pos[0]
    object.position.y = pos[1]
    
    @scene.add(object)
    $(div).fadeIn()
    do @render
    
    object.power = $(div).data('power')
    @objects[i] = object
    
    if x == 'randomPosition'
      target = {}
      target.position = {}
      target.position.x = object.position.x
      target.position.y = object.position.y
      target.position.z = object.position.z
      
      object.position.x = 1000 * (0.5 - Math.random())
      object.position.y = 1000 * (0.5 - Math.random())
      object.position.z = 2000
      
      Transform.fromTo([object], [target], 2 + Math.random())

  proto.clearScene = () ->
    @scene.children.slice().forEach (child, i, a) =>
      @scene.remove(child)

  proto.gameOver = ->
    # console.log "Game Over"

  proto.render = ->
    @renderer.render(@scene, @camera)

  proto.animate = ->
    requestAnimationFrame =>
      do @animate
    @controls.update()

  window.game = new Game()
