# Start by testing out how Canvas works.

# There's a canvas created already, with id "maincanvas", filling the whole page.
# Try drawing a square to it when clicked:


#$('#maincanvas').click(->
    #this.getContext('2d').fillRect(50, 25, 150, 100)
#)


# Ok, great.
# Now let's start animating stuff.
# For asteroids, we need a couple of entities:
# - the rocks
# - the ship
# - and the bullets
#
# Making collision boxes match the rendered stuff exactly is a lot of work,
# and beyond the scope of what I want to do here.

canvas = $('#maincanvas').get(0)

random_position_in_canvas = ->
    pos = Vector.Random(2)
    pos.elements[0] *= canvas.width
    pos.elements[1] *= canvas.height
    return pos

# Simplify and treat actors as circles.
# Radius :: a number in pixels
# position :: a Vector of length 2
# render :: (canvas) ->
#   Draw the actor on the given canvas.
class Actor
    constructor: (@radius, @position, @velocity = Vector.Zero(2)) ->
    render: (canvas) ->

class Asteroid extends Actor
    render: (context) ->
        [x, y] = @position.elements
        context.fillRect(
            x - @radius,
            y - @radius,
            @radius,
            @radius)
        
class Ship extends Actor
    orientation: $V([0,1])
    render: (context) ->
        [x, y] = @position.elements
        context.translate(x, y)
        context.fillStyle = 'rgb(0,0,200)'

        rotation_angle = @orientation.angleFrom($V([0,1]))
        if (@orientation.elements[0] > 0)
            rotation_angle *= -1
        context.rotate(rotation_angle)

        context.beginPath()
        context.moveTo(-1 * @radius, -1 * @radius)
        context.lineTo(0, @radius)
        context.lineTo(@radius, -1 * @radius)
        context.bezierCurveTo(0, 0, 0, 0, -1 * @radius, -1 * @radius)
        context.fill()

actors = []
random_asteroid = (size = 20, speed = 100) ->
    coords = random_position_in_canvas()
    velocity = Vector.Random(2).subtract($V([0.5,0.5])).toUnitVector().x(speed)
    return new Asteroid(size, coords, velocity)

ship = new Ship(10, random_position_in_canvas())
actors.push(ship)

collision_check = (a,b) ->
    distance = a.position.subtract(b.position).modulus()
    if distance >= (a.radius + b.radius) / 2
        return
    if a == b
        return
    if a instanceof Asteroid and b instanceof Asteroid
        return
    if a instanceof Ship or b instanceof Ship
        actors = _(actors).without(a,b)
        alert 'Game Over'
    actors = _(actors).without(a,b)

# Set the regular update timer
last_update_time = Date.now()
update_fxn = ->
    now = Date.now()
    timedelta = (now - last_update_time) / 1000
    last_update_time = now

    snap_to_bounds = (v) ->
        v.elements[0] %= canvas.width
        v.elements[1] %= canvas.height
        v.elements[0] = canvas.width - 1 if v.elements[0] < 0
        v.elements[1] = canvas.height - 1 if v.elements[1] < 0
    actors.forEach((elem) ->
        elem.position = elem.position.add(elem.velocity.x(timedelta))
        snap_to_bounds(elem.position)
        )
    # Clear canvas by updating its dimensions:
    canvas.width = canvas.width

    # Re-render:
    actors.forEach((elem) ->
        context = canvas.getContext('2d')
        context.save()
        elem.render(context)
        context.restore()
        )

    # Check for collisions:
    # Just doing the naive n^2 for now.
    for i in [0 ... actors.length]
        for j in [i+1 ... actors.length]
            collision_check(actors[i], actors[j])
        

setInterval(update_fxn, 20)

# Add an asteroid on every click, for debugging
$(canvas).click(->
    actors.push(random_asteroid())
)

# Add keybindings for the ship
modify_ship_speed = (scaling_factor) ->
    ship.velocity = ship.velocity.add(
        ship.orientation.x(scaling_factor))
rotate_ship = (angle) ->
    ship.orientation = ship.orientation.rotate(angle, Vector.Zero(2))
    
keypress.combo('up', -> modify_ship_speed(5))
keypress.combo('down', -> modify_ship_speed(-5))
keypress.combo('left', -> rotate_ship(-0.1))
keypress.combo('right', -> rotate_ship(0.1))

# Set up the zaps.
class Bullet extends Actor
    constructor: (position, velocity, @orientation) ->
        super(5, position, velocity)

    render: (context) ->
        [x,y] = @position.elements
        context.translate(x,y)
        context.beginPath()
        context.fillStyle = 'rgb(200,0,0)'
        context.arc(0,0,@radius,0,2 * Math.PI)
        context.fill()

keypress.combo 'space', ->
    # Create a bullet in front of the ship,
    # with velocity equal to ship velocity, plus an extra push in the orientation of the ship.
    velocity = ship.velocity.add(ship.orientation.toUnitVector().x(200))
    delta = ship.orientation.toUnitVector().x(20)
    bullet = new Bullet(ship.position.add(delta),
        velocity,
        ship.orientation)
    actors.push(bullet)
