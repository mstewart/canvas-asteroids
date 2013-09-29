// Generated by CoffeeScript 1.3.3
(function() {
  var Actor, Asteroid, Bullet, Ship, actors, canvas, collision_check, last_update_time, modify_ship_speed, random_asteroid, random_position_in_canvas, rotate_ship, ship, update_fxn,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  canvas = $('#maincanvas').get(0);

  random_position_in_canvas = function() {
    var pos;
    pos = Vector.Random(2);
    pos.elements[0] *= canvas.width;
    pos.elements[1] *= canvas.height;
    return pos;
  };

  Actor = (function() {

    function Actor(radius, position, velocity) {
      this.radius = radius;
      this.position = position;
      this.velocity = velocity != null ? velocity : Vector.Zero(2);
    }

    Actor.prototype.render = function(canvas) {};

    return Actor;

  })();

  Asteroid = (function(_super) {

    __extends(Asteroid, _super);

    function Asteroid() {
      return Asteroid.__super__.constructor.apply(this, arguments);
    }

    Asteroid.prototype.render = function(context) {
      var x, y, _ref;
      _ref = this.position.elements, x = _ref[0], y = _ref[1];
      return context.fillRect(x - this.radius, y - this.radius, this.radius, this.radius);
    };

    return Asteroid;

  })(Actor);

  Ship = (function(_super) {

    __extends(Ship, _super);

    function Ship() {
      return Ship.__super__.constructor.apply(this, arguments);
    }

    Ship.prototype.orientation = $V([0, 1]);

    Ship.prototype.render = function(context) {
      var rotation_angle, x, y, _ref;
      _ref = this.position.elements, x = _ref[0], y = _ref[1];
      context.translate(x, y);
      context.fillStyle = 'rgb(0,0,200)';
      rotation_angle = this.orientation.angleFrom($V([0, 1]));
      if (this.orientation.elements[0] > 0) {
        rotation_angle *= -1;
      }
      context.rotate(rotation_angle);
      context.beginPath();
      context.moveTo(-1 * this.radius, -1 * this.radius);
      context.lineTo(0, this.radius);
      context.lineTo(this.radius, -1 * this.radius);
      context.bezierCurveTo(0, 0, 0, 0, -1 * this.radius, -1 * this.radius);
      return context.fill();
    };

    return Ship;

  })(Actor);

  actors = [];

  random_asteroid = function(size, speed) {
    var coords, velocity;
    if (size == null) {
      size = 20;
    }
    if (speed == null) {
      speed = 100;
    }
    coords = random_position_in_canvas();
    velocity = Vector.Random(2).subtract($V([0.5, 0.5])).toUnitVector().x(speed);
    return new Asteroid(size, coords, velocity);
  };

  ship = new Ship(10, random_position_in_canvas());

  actors.push(ship);

  collision_check = function(a, b) {
    var distance;
    distance = a.position.subtract(b.position).modulus();
    if (distance >= (a.radius + b.radius) / 2) {
      return;
    }
    if (a === b) {
      return;
    }
    if (a instanceof Asteroid && b instanceof Asteroid) {
      return;
    }
    if (a instanceof Ship || b instanceof Ship) {
      actors = _(actors).without(a, b);
      alert('Game Over');
    }
    return actors = _(actors).without(a, b);
  };

  last_update_time = Date.now();

  update_fxn = function() {
    var i, j, now, snap_to_bounds, timedelta, _i, _ref, _results;
    now = Date.now();
    timedelta = (now - last_update_time) / 1000;
    last_update_time = now;
    snap_to_bounds = function(v) {
      v.elements[0] %= canvas.width;
      v.elements[1] %= canvas.height;
      if (v.elements[0] < 0) {
        v.elements[0] = canvas.width - 1;
      }
      if (v.elements[1] < 0) {
        return v.elements[1] = canvas.height - 1;
      }
    };
    actors.forEach(function(elem) {
      elem.position = elem.position.add(elem.velocity.x(timedelta));
      return snap_to_bounds(elem.position);
    });
    canvas.width = canvas.width;
    actors.forEach(function(elem) {
      var context;
      context = canvas.getContext('2d');
      context.save();
      elem.render(context);
      return context.restore();
    });
    _results = [];
    for (i = _i = 0, _ref = actors.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      _results.push((function() {
        var _j, _ref1, _ref2, _results1;
        _results1 = [];
        for (j = _j = _ref1 = i + 1, _ref2 = actors.length; _ref1 <= _ref2 ? _j < _ref2 : _j > _ref2; j = _ref1 <= _ref2 ? ++_j : --_j) {
          _results1.push(collision_check(actors[i], actors[j]));
        }
        return _results1;
      })());
    }
    return _results;
  };

  setInterval(update_fxn, 20);

  $('button').click(function() {
    return actors.push(random_asteroid());
  });

  modify_ship_speed = function(scaling_factor) {
    return ship.velocity = ship.velocity.add(ship.orientation.x(scaling_factor));
  };

  rotate_ship = function(angle) {
    return ship.orientation = ship.orientation.rotate(angle, Vector.Zero(2));
  };

  keypress.combo('up', function() {
    return modify_ship_speed(5);
  });

  keypress.combo('down', function() {
    return modify_ship_speed(-5);
  });

  keypress.combo('left', function() {
    return rotate_ship(-0.1);
  });

  keypress.combo('right', function() {
    return rotate_ship(0.1);
  });

  Bullet = (function(_super) {

    __extends(Bullet, _super);

    function Bullet(position, velocity, orientation) {
      this.orientation = orientation;
      Bullet.__super__.constructor.call(this, 5, position, velocity);
    }

    Bullet.prototype.render = function(context) {
      var x, y, _ref;
      _ref = this.position.elements, x = _ref[0], y = _ref[1];
      context.translate(x, y);
      context.beginPath();
      context.fillStyle = 'rgb(200,0,0)';
      context.arc(0, 0, this.radius, 0, 2 * Math.PI);
      return context.fill();
    };

    return Bullet;

  })(Actor);

  keypress.combo('space', function() {
    var bullet, delta, velocity;
    velocity = ship.velocity.add(ship.orientation.toUnitVector().x(200));
    delta = ship.orientation.toUnitVector().x(20);
    bullet = new Bullet(ship.position.add(delta), velocity, ship.orientation);
    return actors.push(bullet);
  });

}).call(this);
