class MyRootContext extends RootContext {
  onVmStart() {
    log("The JavaScript translation filter is ready!");
    return true;
  }
}

class MyHttpFilter extends HttpContext {
  onHttpRequestHeaders() {
    let accept = this.getRequestHeader("x-magic");

    if (chart) {
      let values = chart.split(",");

      values = values.map(el => parseInt(el));

      this.sendHttpResponse(
        200,
        { "x-processed-by": "proxy-wasm-on-quickjs" },
        asciichart.plot(values)
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
}

set_root_context(MyRootContext);
set_http_context(MyHttpFilter);