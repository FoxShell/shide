"use strict";


function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _instanceof(left, right) { if (right != null && typeof Symbol !== "undefined" && right[Symbol.hasInstance]) { return right[Symbol.hasInstance](left); } else { return left instanceof right; } }

function _typeof(obj) { if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _classCallCheck(instance, Constructor) { if (!_instanceof(instance, Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

var writeToCon = false;

var VFPProxy = function () {
  function VFPProxy() {
    _classCallCheck(this, VFPProxy);

    this._num = 0;
    this._funcs = {};
  }

  _createClass(VFPProxy, [{
    key: "str",
    value: function str(_str) {
      _str = _str || "";
      return _str.replace(/\r|\n|\'|\&/g, function (a) {
        if (a == "\r") {
          return "'+chr(13)+'";
        } else if (a == "\n") {
          return "'+chr(10)+'";
        } else if (a == "&") {
          return "'+chr(38)+'";
        } else {
          return "'+ \"'\" +'";
        }
      });
    }
  }, {
    key: "stringify",
    value: function stringify(value) {
      var str = [];

      var r = this._stringify(value, undefined, undefined, 0, str);

      str.push("retorno= m." + r);

      //var b = _iconvLite.default.encode(str.join("\r\n"), 'latin1');
	  var b = Buffer.from(str.join("\r\n"))
      return b.toString('base64');
    }
  }, {
    key: "_stringify",
    value: function _stringify(value, property, index) {
      var current = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : 0;
      var str = arguments.length > 4 && arguments[4] !== undefined ? arguments[4] : [];
      var svalue = '';
      var cia = "current" + current;
      var cio = "current" + (current + 1);
      current++;

      if (Buffer.isBuffer(value)) {
        value = value.toString('base64');
      } else if (_typeof(value) == "object") {
        if (_instanceof(value, Error)) {
          value = {
            message: value.message,
            code: value.code,
            stack: value.stack
          };
        }

        if (_instanceof(value, Date)) {
          svalue = "datetime(".concat((value.getFullYear(), value.getMonth() + 1, value.getDate()), ")");
        } else if (_instanceof(value, Array)) {
          str.push("m.".concat(cio, "= createobject('collection')"));

          for (var i = 0; i < value.length; i++) {
            this._stringify(value[i], undefined, i + 1, current, str);
          }

          svalue = "m." + cio;
        } else if (value) {
          str.push("m.".concat(cio, "= createobject('empty')"));

          for (var id in value) {
            this._stringify(value[id], id, undefined, current, str);
          }

          svalue = "m." + cio;
        } else {
          svalue = "NULL";
        }
      } else if (typeof value == "string") {
        value = Buffer.from(value, 'latin1').toString('base64');
      }

      if (typeof value == "string") {
        if (value.length > 200) {
          str.push("m.".concat(cio, " = ''"));

          while (value.length) {
            str.push("m.".concat(cio, " = m.").concat(cio, " + '").concat(this.str(value.substring(0, 200)), "'"));
            value = value.substring(200);
          }

          str.push("m.".concat(cio, " = strconv(m.").concat(cio, ", 14)"));
          svalue = "m." + cio;
        } else {
          svalue = "strconv('".concat(this.str(value), "', 14)");
        }
      } else if (value === null || value === undefined || value === NaN || value === Infinity) {
        svalue = "NULL";
      } else if (value === true) {
        svalue = ".t.";
      } else if (value === false) {
        svalue = ".f.";
      } else if (!svalue) {
        svalue = JSON.stringify(value);
      }

      if (svalue) {
        if (property) {
          if (/\d/.test(property[0])) {
            property = "_" + property;
          }

          property = property.replace(/\W/g, "_");
          str.push("addproperty(m.".concat(cia, ", '").concat(this.str(property), "', ").concat(svalue, ")"));
        } else if (index) str.push("m.".concat(cia, ".add(").concat(svalue, ",\"").concat(index, "\")"));else if (cio != svalue) str.push("m.".concat(cio, "=").concat(svalue));
      }

      return cio;
    }
  }, {
    key: "parse",
    value: function parse(params) {
      return params;
    }
  }, {
    key: "register",
    value: function register(string) {
      var f = Function("KModule, proxy, params", string);
      var num = this._num++;
      this._funcs[num] = f;
      process.stdout.write("#function:" + num + "\n");
      return num;
    }
  }, {
    key: "execute",
    value: function execute(num, id, params) {
      var f = this._funcs[num];
      writeToCon = true;

      try {
        var self = this;

        if (!f) {
          process.stdout.write("#result:" + id + ":" + this.stringify({
            exception: new Error("Function " + num + " not found")
          }) + "\n");
          return;
        }

        params = this.parse(params);

        try {
          var result = f(KModule, this, params);

          if (result && result.then) {
            result.then(function (r) {
              process.stdout.write("#result:" + id + ":" + self.stringify(r) + "\n");
            }).catch(function (e) {
              process.stdout.write("#result:" + id + ":" + self.stringify({
                exception: e
              }) + "\n");
            });
          } else {
            process.stdout.write("#result:" + id + ":" + self.stringify(result) + "\n");
          }
        } catch (e) {
          return process.stdout.write("#result:" + id + ":" + self.stringify({
            exception: e
          }) + "\n");
        }
      } catch (e) {
        return process.stdout.write("#error:" + id + ":" + e.message.replace(/\r\n|\r|\n/g, ' ') + "\n");
      } finally {
        writeToCon = false;
      }
    }
  }]);

  return VFPProxy;
}();

var proxy = new VFPProxy();
var bstr = '';
process.stdin.on("data", function (d) {
  var str = d.toString();

  if (bstr) {
    str = bstr + str;
  }

  var code, parts, num;
  var y = str.indexOf("\n");

  while (y >= 0) {
    try {
      code = str.substring(0, y);
      parts = code.split(":");

      if (parts[0] == "exit") {
        process.exit();
      } else if (parts[0] == "register") {
        proxy.register(Buffer.from(parts[1], 'base64').toString('binary'));
      } else if (parts[0] == "heartbeat") {
        proxy.date = Date.now();
      } else if (parts[0] == "execute") {
        proxy.execute(parts[1], parts[2], parts[3] ? Buffer.from(parts[3], 'base64').toString('binary') : undefined);
      } else if (parts[0] == "evaluate") {
        num = proxy.register(Buffer.from(parts[1], 'base64').toString('binary'));
        proxy.execute(num, parts[2], parts[3] ? Buffer.from(parts[3], 'base64').toString('binary') : undefined);
      }

      str = str.substring(y + 1);
      y = str.indexOf("\n");
    } catch (e) {
      process.stdout.write("#error:" + e.message + "\n");
    }
  }

  bstr = str;
});
setInterval(function () {
  if (writeToCon) process.stdout.write(".\n");
}, 12000);
// kawi converted. Preserve this line, Kawi transpiler will not reprocess if this line found
