(() => {
  var __create = Object.create;
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __getProtoOf = Object.getPrototypeOf;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __commonJS = (cb, mod) => function __require() {
    return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
    // If the importer is in node compatibility mode or this is not an ESM
    // file that has been converted to a CommonJS file using a Babel-
    // compatible transform (i.e. "__esModule" has not been set), then set
    // "default" to the CommonJS "module.exports" for node compatibility.
    isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
    mod
  ));

  // node_modules/asciichart/asciichart.js
  var require_asciichart = __commonJS({
    "node_modules/asciichart/asciichart.js"(exports) {
      "use strict";
      (function(exports2) {
        exports2.black = "\x1B[30m";
        exports2.red = "\x1B[31m";
        exports2.green = "\x1B[32m";
        exports2.yellow = "\x1B[33m";
        exports2.blue = "\x1B[34m";
        exports2.magenta = "\x1B[35m";
        exports2.cyan = "\x1B[36m";
        exports2.lightgray = "\x1B[37m";
        exports2.default = "\x1B[39m";
        exports2.darkgray = "\x1B[90m";
        exports2.lightred = "\x1B[91m";
        exports2.lightgreen = "\x1B[92m";
        exports2.lightyellow = "\x1B[93m";
        exports2.lightblue = "\x1B[94m";
        exports2.lightmagenta = "\x1B[95m";
        exports2.lightcyan = "\x1B[96m";
        exports2.white = "\x1B[97m";
        exports2.reset = "\x1B[0m";
        function colored(char, color) {
          return color === void 0 ? char : color + char + exports2.reset;
        }
        exports2.colored = colored;
        exports2.plot = function(series, cfg = void 0) {
          if (typeof series[0] == "number") {
            series = [series];
          }
          cfg = typeof cfg !== "undefined" ? cfg : {};
          let min = typeof cfg.min !== "undefined" ? cfg.min : series[0][0];
          let max = typeof cfg.max !== "undefined" ? cfg.max : series[0][0];
          for (let j = 0; j < series.length; j++) {
            for (let i = 0; i < series[j].length; i++) {
              min = Math.min(min, series[j][i]);
              max = Math.max(max, series[j][i]);
            }
          }
          let defaultSymbols = ["\u253C", "\u2524", "\u2576", "\u2574", "\u2500", "\u2570", "\u256D", "\u256E", "\u256F", "\u2502"];
          let range = Math.abs(max - min);
          let offset = typeof cfg.offset !== "undefined" ? cfg.offset : 3;
          let padding = typeof cfg.padding !== "undefined" ? cfg.padding : "           ";
          let height = typeof cfg.height !== "undefined" ? cfg.height : range;
          let colors = typeof cfg.colors !== "undefined" ? cfg.colors : [];
          let ratio = range !== 0 ? height / range : 1;
          let min2 = Math.round(min * ratio);
          let max2 = Math.round(max * ratio);
          let rows = Math.abs(max2 - min2);
          let width = 0;
          for (let i = 0; i < series.length; i++) {
            width = Math.max(width, series[i].length);
          }
          width = width + offset;
          let symbols = typeof cfg.symbols !== "undefined" ? cfg.symbols : defaultSymbols;
          let format = typeof cfg.format !== "undefined" ? cfg.format : function(x) {
            return (padding + x.toFixed(2)).slice(-padding.length);
          };
          let result = new Array(rows + 1);
          for (let i = 0; i <= rows; i++) {
            result[i] = new Array(width);
            for (let j = 0; j < width; j++) {
              result[i][j] = " ";
            }
          }
          for (let y = min2; y <= max2; ++y) {
            let label = format(rows > 0 ? max - (y - min2) * range / rows : y, y - min2);
            result[y - min2][Math.max(offset - label.length, 0)] = label;
            result[y - min2][offset - 1] = y == 0 ? symbols[0] : symbols[1];
          }
          for (let j = 0; j < series.length; j++) {
            let currentColor = colors[j % colors.length];
            let y0 = Math.round(series[j][0] * ratio) - min2;
            result[rows - y0][offset - 1] = colored(symbols[0], currentColor);
            for (let x = 0; x < series[j].length - 1; x++) {
              let y02 = Math.round(series[j][x + 0] * ratio) - min2;
              let y1 = Math.round(series[j][x + 1] * ratio) - min2;
              if (y02 == y1) {
                result[rows - y02][x + offset] = colored(symbols[4], currentColor);
              } else {
                result[rows - y1][x + offset] = colored(y02 > y1 ? symbols[5] : symbols[6], currentColor);
                result[rows - y02][x + offset] = colored(y02 > y1 ? symbols[7] : symbols[8], currentColor);
                let from = Math.min(y02, y1);
                let to = Math.max(y02, y1);
                for (let y = from + 1; y < to; y++) {
                  result[rows - y][x + offset] = colored(symbols[9], currentColor);
                }
              }
            }
          }
          return result.map(function(x) {
            return x.join("");
          }).join("\n");
        };
      })(typeof exports === "undefined" ? (
        /* istanbul ignore next */
        exports["asciichart"] = {}
      ) : exports);
    }
  });

  // index.js
  var import_asciichart = __toESM(require_asciichart());
  var MyRootContext = class extends RootContext {
    onVmStart() {
      log("Extending from JavaScript");
      return true;
    }
  };
  var MyHttpFilter = class extends HttpContext {
    onHttpRequestHeaders() {
      let chart = this.getRequestHeader("x-magic");
      if (chart) {
        let values = chart.split(",");
        values = values.map((el) => parseInt(el));
        this.sendHttpResponse(
          200,
          { "x-processed-by": "proxy-wasm-on-quickjs" },
          import_asciichart.default.plot(values)
        );
        return ACTION.pause;
      } else {
        return ACTION.continue;
      }
    }
    onHttpResponseHeaders() {
      this.setResponseHeader("x-powered-by", "proxy-wasm-on-quickjs");
      return ACTION.continue;
    }
  };
  set_root_context(MyRootContext);
  set_http_context(MyHttpFilter);
})();
