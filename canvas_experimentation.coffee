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
# update_position :: (timedelta) ->
#   Update the actor's position based on the given timedelta
class Actor
    constructor: (@radius, @position) ->

    render: (canvas) ->
    update_position: ->

class Asteroid extends Actor
    render: (canvas) ->
        [x, y] = @position.elements
        canvas.getContext('2d').fillRect(
            x - @radius,
            y - @radius,
            @radius,
            @radius)

$('#maincanvas').click(->
    coords = Vector.Random(2).multiply(400)
    asteroid = new Asteroid(20, coords)
    asteroid.render(this)
)

