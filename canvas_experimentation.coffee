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

# Simplify and treat actors as circles.
# Radius :: a number in pixels
# position :: a Vector of length 2
# render :: (canvas) ->
#   Draw the actor on the given canvas.
class Actor
    constructor: (@radius, @position, @velocity = 0) ->
    render: (canvas) ->
    update_position: (timedelta) ->

class Asteroid extends Actor
    render: (canvas) ->
        console.log canvas
        [x, y] = @position.elements
        canvas.getContext('2d').fillRect(
            x - @radius,
            y - @radius,
            @radius,
            @radius)
        

asteroids = []
random_asteroid = (size = 20, bounds = 400, speed = 100) ->
    coords = Vector.Random(2).multiply(bounds)
    velocity = Vector.Random(2).toUnitVector().x(speed)
    return new Asteroid(size, coords, velocity)



canvas = $('#maincanvas').get(0)
# Set the regular update timer
last_update_time = Date.now()
update_fxn = ->
    now = Date.now()
    timedelta = (now - last_update_time) / 1000
    last_update_time = now

    asteroids.forEach((elem) ->
        elem.position = elem.position.add(elem.velocity.x(timedelta))
        elem.position.elements[0] %= 600    # hardcoded canvas size
        elem.position.elements[1] %= 400    # hardcoded canvas size
        )
    # Clear canvas by updating its dimensions:
    canvas.width = canvas.width

    asteroids.forEach((elem) -> elem.render(canvas))

setInterval(update_fxn, 20)

# Add an asteroid on every click, for debugging
$(canvas).click(->
    asteroids.push(random_asteroid())
)
