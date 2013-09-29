# Start by testing out how Canvas works.

# There's a canvas created already, with id "maincanvas", filling the whole page.
# Try drawing a square to it when clicked:

$('#maincanvas').click(->
    this.getContext('2d').fillRect(50, 25, 150, 100)
)
