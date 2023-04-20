// #[macro_use]
// extern crate lazy_static;

mod quickjs;

use quickjs::QuickJs;
use proxy_wasm::traits::*;
use proxy_wasm::types::*;

proxy_wasm::main! {{
    proxy_wasm::set_log_level(LogLevel::Trace);
    proxy_wasm::set_root_context(|_| -> Box<dyn RootContext> {
        Box::new(RootQuickJs { qjs: QuickJs::new() })
    });
}}

struct RootQuickJs {
    /// The QuickJS runtime
    qjs: QuickJs
}

impl Context for RootQuickJs {}

impl RootContext for RootQuickJs {
    fn get_type(&self) -> Option<ContextType> {
        let filter = self.qjs.global_property("http_filter");

        if filter.is_undefined() {
            None
        } else {
            Some(ContextType::HttpContext)
        }
    }

    fn create_http_context(&self, context_id: u32) -> Option<Box<dyn HttpContext>> {
        let filter = self.qjs.global_property("http_filter");

        if filter.is_undefined() {
            None
        } else {
            Some(Box::new(HttpQuickJs { context_id, qjs: self.qjs.clone() }))
        }
    }

    fn on_vm_start(&mut self, _: usize) -> bool {
        let filter = self.qjs.global_property("root_filter");
        let method = filter.get_property("onVmStart").unwrap();

        let null = self.qjs.null_value();
        method.call(&null, &[]).unwrap().as_bool().unwrap()
    }

    fn on_configure(&mut self, _: usize) -> bool {
        if let Some(source_bytes) = self.get_plugin_configuration() {
            self.qjs.set_source(source_bytes);
        }

        true
    }
}

struct HttpQuickJs {
    context_id: u32,
    /// The QuickJS runtime
    qjs: QuickJs
}

impl Context for HttpQuickJs {}

impl HttpContext for HttpQuickJs {
    fn on_http_request_headers(&mut self, _: usize, _: bool) -> Action {
        self.call_method_with_action("onHttpRequestHeaders")
    }

    fn on_http_response_headers(&mut self, _: usize, _: bool) -> Action {
        self.call_method_with_action("onHttpResponseHeaders")
    }
}

impl HttpQuickJs {
    fn call_method_with_action(&mut self, method: &str) -> Action {
        let filter = self.qjs.global_property("http_filter");
        let method = filter.get_property(method).unwrap();

        let res = method.call(&filter, &[]).unwrap().try_as_integer().unwrap();

        if res == 0 {
            Action::Continue
        } else {
            Action::Pause
        }
    }
}