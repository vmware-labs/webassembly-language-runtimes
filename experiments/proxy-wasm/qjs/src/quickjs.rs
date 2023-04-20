use quickjs_wasm_rs::{Context as QuickJsContext, Value};
use anyhow::Result;
use proxy_wasm::{hostcalls, types::MapType};
use log::info;

pub struct QuickJs {
    /// The initialized context
    context: QuickJsContext,
    /// Bytecode
    bytecode: Vec<u8>
}

impl QuickJs {
    pub fn new() -> Self {
        let context = QuickJsContext::default();
        Self::inject_globals(&context).unwrap();

        Self {
            context,
            bytecode: Vec::new()
        }
    }

    pub fn set_source(&mut self, source_bytes: Vec<u8>) {
        let content = String::from_utf8(source_bytes).unwrap();

        let bytecode = self.context.compile_module("index.mjs", &content).unwrap();
        self.context.eval_binary(&bytecode).unwrap();

        // Store the bytecode
        self.bytecode = bytecode;
    }

    pub fn set_bytecode(&mut self, bytecode: Vec<u8>) {
        self.context.eval_binary(&bytecode).unwrap();

        // Store the bytecode
        self.bytecode = bytecode;
    }

    pub fn clone(&self) -> Self {
        let mut qjs = Self::new();

        qjs.set_bytecode(self.bytecode.clone());

        qjs
    }

    pub fn global(&self) -> Value {
        self.context.global_object().unwrap()
    }

    pub fn global_property(&self, key: &str) -> Value {
        self.global().get_property(key).unwrap()
    }

    pub fn null_value(&self) -> Value {
        self.context.null_value().unwrap()
    }

    fn inject_globals(context: &QuickJsContext) -> Result<()> {
        let global = context.global_object()?;

        global.set_property(
            "__pw_proxy_log",
            context.wrap_callback(|ctx, _this_arg, args| {
                info!("{}", args[0].as_str().unwrap());
                ctx.undefined_value()
            })?,
        )?;

        global.set_property(
            "__pw_get_request_header",
            context.wrap_callback(|ctx, _this_arg, args| {
                let name = args[0].as_str().unwrap();

                match hostcalls::get_map_value(MapType::HttpRequestHeaders, name).unwrap() {
                    Some(val) => ctx.value_from_str(&val),
                    None => ctx.undefined_value()
                }
            })?,
        )?;

        global.set_property(
            "__pw_set_response_header",
            context.wrap_callback(|ctx, _this_arg, args| {
                let name = args[0].as_str().unwrap();

                if args[1].is_null_or_undefined() {
                    hostcalls::set_map_value(MapType::HttpResponseHeaders, name, None).unwrap()
                } else {
                    let val = args[1].as_str().unwrap();

                    hostcalls::set_map_value(MapType::HttpResponseHeaders, name, Some(val)).unwrap()
                }

                ctx.undefined_value()
            })?,
        )?;

        global.set_property(
            "__pw_send_http_response",
        context.wrap_callback(|ctx, _this_arg, args| {
                let status_code = args[0].as_u32_unchecked();
                let mut headers: Vec<(String, String)> = Vec::new();
                let body = match args[2].as_str() {
                    Ok(str) => Some(str.as_bytes()),
                    Err(err) => {
                        info!("Error processing the body {err}");
                        None
                    }
                };

                let mut props = args[1].properties().unwrap();
                let mut key: Option<Value> = props.next_key().unwrap();
                let mut val;

                while key.is_some() {
                    val = props.next_value().unwrap();
                    let key_some = key.unwrap();
                    let key_str = key_some.as_str().unwrap();
                    let val_str = val.as_str().unwrap();

                    headers.push((key_str.to_string(), val_str.to_string()));

                    key = props.next_key().unwrap();
                }

                // TODO: avoid this conversion by adding proper lifetimes
                let str_headers = headers.iter().map(|(k, v)| (k.as_str(), v.as_str())).collect();

                hostcalls::send_http_response(status_code, str_headers, body).unwrap();

                ctx.undefined_value()
            })?,
        )?;

        context.eval_global(
            "proxy-wasm.js",
            include_str!("../bindings/proxy-wasm.js"),
        )?;

        Ok(())
    }
}