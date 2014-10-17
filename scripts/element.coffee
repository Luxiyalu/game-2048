define ['jquery', 'data'], ($, Data) ->
  CreateElement = ->
  proto = CreateElement.prototype
  
  proto.create = (power) ->
    power = power || if Math.random() > 0.2 then 1 else 2
    number = Math.pow(2, power)
    color = Data.colors[power - 1]
    
    $element = $('<div class="element"></div>')
      .data
        power: power
        number: number
        color: color
      .css
        width: Data.divWidth
        height: Data.divWidth
        background: 'rgba('+color+', 0.15)'
        boxShadow: '0 0 12px rgba('+color+', 0.5)'
      
    $number = $('<h1 class="number"></h1>')
      .html(number)
      .css
        textShadow: '0 0 12px rgba('+color+', 0.5)'
        
    if number >= 100 and number < 1000
      $number.css fontSize: '50px'
    else if number >= 1000 and number < 10000
      $number.css fontSize: '45px'
    else if number >= 10000
      $number.css fontSize: '38px'
      
    $element.append($number)
    $element[0]

  createElement = new CreateElement()
