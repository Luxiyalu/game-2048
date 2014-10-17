(function() {
  define(['jquery', 'TweenMax', 'data', 'three'], function($, TweenMax, Data) {
    var Transform, proto, transform;
    Transform = function() {
      return this.init();
    };
    proto = Transform.prototype;
    proto.init = function() {
      this.queue = {};
      this.padding = Data.padding;
      this.divWidth = Data.divWidth;
      this.numberPerLine = Data.numberPerLine;
      this.widthOfBoard = this.numberPerLine * this.divWidth + (this.numberPerLine - 1) * 10;
      return this.r = this.widthOfBoard / 2;
    };
    proto.fromTo = function(objects, targets, duration, delay) {
      var ease, i, object, randomP, target, _i, _ref, _results,
        _this = this;
      if (duration == null) {
        duration = 0.35;
      }
      if (delay == null) {
        delay = 0;
      }
      randomP = duration;
      _results = [];
      for (i = _i = 0, _ref = objects.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (objects[i] !== void 0) {
          object = objects[i];
          target = targets[i];
          if (randomP === 'random') {
            duration = 1 + Math.random();
            delay = 1.5 * Math.random();
            ease = Power3.easeInOut;
          } else {
            ease = Power3.easeOut;
          }
          TweenMax.to(object.position, duration, {
            x: target.position.x,
            y: target.position.y,
            z: target.position.z,
            ease: ease,
            delay: delay,
            overwrite: true,
            onUpdate: function() {
              return _this.game.render();
            }
          });
          if (target.rotation) {
            _results.push(TweenMax.to(object.rotation, duration, {
              x: target.rotation.x,
              y: target.rotation.y,
              z: target.rotation.z,
              ease: ease,
              delay: delay,
              overwrite: true
            }));
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    proto.getIndex = function(x, y) {
      return (y - 1) * this.numberPerLine + (x - 1);
    };
    proto.getSingleCoordinate = function(a) {
      return Math.round((a + this.r + this.padding + 0.5 * this.divWidth) / (this.divWidth + this.padding));
    };
    proto.getCoordinate = function(a, b) {
      var i, x, y;
      if (b !== void 0) {
        x = this.getSingleCoordinate(a);
        y = this.getSingleCoordinate(b);
      } else {
        i = a;
        x = i % this.numberPerLine + 1;
        y = Math.ceil((i + 1) / this.numberPerLine);
      }
      return [x, y];
    };
    proto.position = function(i) {
      var arr, coor;
      coor = this.getCoordinate(i);
      return arr = [this.getPositionX(coor[0]), this.getPositionY(coor[1])];
    };
    proto.getPositionX = function(x) {
      return (x - 1 / 2) * this.divWidth + (x - 1) * this.padding - this.r;
    };
    proto.getPositionY = function(y) {
      return (y - 1 / 2) * this.divWidth + (y - 1) * this.padding - this.r;
    };
    proto.getVacantI = function(objects) {
      var i, l, vacants, _i, _ref;
      vacants = [];
      for (i = _i = 0, _ref = objects.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (objects[i] === void 0) {
          vacants.push(i);
        }
      }
      l = vacants.length;
      if (l === 0) {
        return false;
      } else {
        i = Math.floor(Math.random() * l);
        return vacants[i];
      }
    };
    proto.killDuplicates = function(scene, objects, targets, duration) {
      var self,
        _this = this;
      self = this;
      return objects.forEach(function(object, i) {
        var pos, queueI, x, y;
        if (object && object.kill) {
          x = targets[i].position.x;
          y = targets[i].position.y;
          pos = _this.getCoordinate(x, y);
          queueI = _this.getIndex(pos[0], pos[1]);
          _this.queue[queueI] = object.power + 1;
          TweenMax.to(object.div, duration, {
            autoAlpha: 0,
            onComplete: function() {
              return scene.remove(object);
            }
          });
          return objects[i] = void 0;
        }
      });
    };
    proto.reorderObjects = function(preOrdered, targets) {
      var reordered,
        _this = this;
      reordered = new Array(preOrdered.length);
      preOrdered.forEach(function(object, i) {
        var coor, x, y;
        if (object !== void 0) {
          x = targets[i].position.x;
          y = targets[i].position.y;
          coor = _this.getCoordinate(x, y);
          i = _this.getIndex(coor[0], coor[1]);
          return reordered[i] = object;
        }
      });
      return reordered;
    };
    return transform = new Transform();
  });

}).call(this);
