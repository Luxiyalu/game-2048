define ['data', 'transform', 'three'], (Data, Transform) ->
  Shapes = {}
  random = (scale) ->
    if scale
      scale * (Math.random() - 0.5)
    else
      Math.random() - 0.5
  
  # something new
  vector = new THREE.Vector3()
  
  Shapes.getTargets = (shape) ->
    width = Data.numberPerLine
    length = width * width
    targets = []
    
    if shape is 'random'
      for i in [0...length]
        object = new THREE.Object3D()
        
        scale = 1600
        object.position.x = random(scale)
        object.position.y = random(scale)
        object.position.z = random(scale)
        
        # vector.copy(object.position).multiplyScalar(2)
        vector.x = random(scale)
        vector.y = random(scale)
        vector.z = random(scale)
        object.lookAt(vector)
        
        targets.push(object)
        
    if shape is 'cone'
      for i in [1..length]
        object = new THREE.Object3D()
        
        a = 20
        b = 50
        c = 50
        
        r = a * i
        theta = b * i
        object.position.x = r * Math.cos(theta)
        object.position.y = r * Math.sin(theta)
        object.position.z = c * i - 800
        
        # vector.copy(object.position).multiplyScalar(2)
        vector.x = 0
        vector.y = 0
        vector.z = object.position.z + 2 * i
        object.lookAt(vector)
        
        targets.push(object)
        
    if shape is 'board'
      for a in [1..width]
        for b in [1..width]
          object = new THREE.Object3D()
          
          object.position.x = Transform.getPositionX(a)
          object.position.y = Transform.getPositionY(b)
          object.position.z = 0
          
          vector.x = object.position.x
          vector.y = object.position.y
          vector.z = object.position.z + 1
          object.lookAt(vector)
          
          targets.push(object)
        
    targets
  
  Shapes
