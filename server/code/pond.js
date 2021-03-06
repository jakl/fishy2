// Generated by CoffeeScript 1.3.3
(function() {
  var after, every, fish;

  every = function(ms, cb) {
    return setInterval(cb, ms);
  };

  after = function(ms, cb) {
    return setTimeout(cb, ms);
  };

  fish = require('./fish.js');

  module.exports = {
    reset: function() {
      var _this = this;
      this.keys = {
        up: false,
        down: false,
        left: false,
        right: false
      };
      this.fishes = [new fish(true)];
      this.player = this.fishes[0];
      this.draw();
      every(1000, function() {
        if (!(_this.fishes.length > 10)) {
          return _this.fishes.unshift(new fish());
        }
      });
      return this;
    },
    colide: function() {
      var f, i, _i, _len, _ref, _results;
      _ref = this.fishes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = this.fishes;
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            i = _ref1[_j];
            if (i === f) {
              continue;
            }
            if (f.colides(i)) {
              if (f.trumps(i)) {
                _results1.push(f.eats(i));
              } else {
                _results1.push(i.eats(f));
              }
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    },
    update: function() {
      var f, i, _i, _j, _len, _ref, _ref1, _ref2, _results;
      this.keyboardinput();
      _ref = this.fishes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        if (!f.isplayer && Math.random() > .2) {
          f.moverandomly();
        }
        f.move();
      }
      this.colide();
      _results = [];
      for (i = _j = _ref1 = this.fishes.length - 1; _ref1 <= 0 ? _j <= 0 : _j >= 0; i = _ref1 <= 0 ? ++_j : --_j) {
        if (this.fishes[i].isdead) {
          _results.push(([].splice.apply(this.fishes, [i, i - i + 1].concat(_ref2 = [])), _ref2));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    keyboardinput: function() {
      var f, _i, _j, _len, _len1, _ref, _ref1, _results;
      if (this.keys.up) {
        this.player.ya -= this.player.swimpower;
      }
      if (this.keys.down) {
        this.player.ya += this.player.swimpower;
      }
      if (this.keys.left) {
        this.player.xa -= this.player.swimpower;
      }
      if (this.keys.right) {
        this.player.xa += this.player.swimpower;
      }
      if (this.keys.z) {
        _ref = this.fishes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          f = _ref[_i];
          f.r *= 1.2;
        }
      }
      if (this.keys.x) {
        _ref1 = this.fishes;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          f = _ref1[_j];
          _results.push(f.r /= 1.2);
        }
        return _results;
      }
    },
    draw: function() {
      return this.update();
    },
    click: function(mx, my) {
      var f, _i, _len, _ref, _ref1, _results;
      _ref = this.fishes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        if (f.colides({
          x: mx,
          y: my,
          r: 0
        })) {
          if ((_ref1 = this.player) != null) {
            _ref1.isplayer = false;
          }
          this.player = f;
          _results.push(f.isplayer = true);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }
  };

}).call(this);
