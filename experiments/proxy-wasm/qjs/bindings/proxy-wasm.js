(function() {
  const __pw_proxy_log = globalThis.__pw_proxy_log;
  const __pw_get_request_header = globalThis.__pw_get_request_header;
  const __pw_set_response_header = globalThis.__pw_set_response_header;
  const __pw_send_http_response = globalThis.__pw_send_http_response;

  globalThis.log = (number) => {
    return __pw_proxy_log(number);
  }

  globalThis.set_root_context = (Filter) => {
    globalThis.root_filter = new Filter();
  };

  globalThis.set_http_context = (Filter) => {
    globalThis.http_filter = new Filter();
  };

  globalThis.ACTION = {
    continue: 0,
    pause: 1
  }

  class RootContext {
    onVmStart() {
      return true;
    }
  }

  class HttpContext {
    onHttpRequestHeaders() {
      return ACTION.continue;
    }

    onHttpResponseHeaders() {
      return ACTION.continue;
    }

    getRequestHeader(name) {
      return __pw_get_request_header(name);
    }

    setResponseHeader(name, value) {
      __pw_set_response_header(name, value);
    }

    sendHttpResponse(status, headers, body) {
      __pw_send_http_response(status, headers, body);
    }
  }

  globalThis.RootContext = RootContext;
  globalThis.HttpContext = HttpContext;

  // Initialize required filters.
  // They can be overriden later on.
  set_root_context(RootContext);
  set_http_context(HttpContext);

  Reflect.deleteProperty(globalThis, "__pw_proxy_log");
  Reflect.deleteProperty(globalThis, "__pw_get_request_header");
  Reflect.deleteProperty(globalThis, "__pw_set_response_header");
  Reflect.deleteProperty(globalThis, "__pw_send_http_response");
})();