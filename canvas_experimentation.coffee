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
    update_position: (timedelta) ->

class Asteroid extends Actor
    render: (context) ->
        [x, y] = @position.elements
        context.fillRect(
            x - @radius,
            y - @radius,
            @radius,
            @radius)
        
class Ship extends Actor
    render: (context) ->
        [x, y] = @position.elements
        context.fillStyle = 'rgb(0,0,200)'
        context.fillRect(
            x - @radius,
            y - @radius,
            @radius,
            @radius)

actors = []
random_asteroid = (size = 20, speed = 100) ->
    coords = random_position_in_canvas()
    velocity = Vector.Random(2).toUnitVector().x(speed)
    return new Asteroid(size, coords, velocity)

ship = new Ship(10, random_position_in_canvas())
actors.push(ship)

# Set the regular update timer
last_update_time = Date.now()
update_fxn = ->
    now = Date.now()
    timedelta = (now - last_update_time) / 1000
    last_update_time = now

    actors.forEach((elem) ->
        elem.position = elem.position.add(elem.velocity.x(timedelta))
        elem.position.elements[0] %= canvas.width
        elem.position.elements[1] %= canvas.height
        )
    # Clear canvas by updating its dimensions:
    canvas.width = canvas.width

    actors.forEach((elem) ->
        context = canvas.getContext('2d')
        context.save()
        elem.render(context)
        context.restore()
        )

setInterval(update_fxn, 20)

# Add an asteroid on every click, for debugging
$(canvas).click(->
    actors.push(random_asteroid())
)
