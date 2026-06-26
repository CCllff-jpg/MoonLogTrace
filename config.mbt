// Logger configuration builder — programmatic and from-simple-struct

pub(all) struct LoggerConfig {
  level : Level
  enable_console : Bool
  console_json : Bool
  context_keys : Array[String]
  context_values : Array[String]
}

pub fn LoggerConfig::new() -> LoggerConfig {
  LoggerConfig::{
    level: Level::TRACE,
    enable_console: false,
    console_json: false,
    context_keys: [],
    context_values: [],
  }
}

pub fn LoggerConfig::set_level(self : LoggerConfig, l : Level) -> LoggerConfig {
  LoggerConfig::{ ..self, level: l }
}

pub fn LoggerConfig::enable_console(self : LoggerConfig) -> LoggerConfig {
  LoggerConfig::{ ..self, enable_console: true }
}

pub fn LoggerConfig::enable_console_json(self : LoggerConfig) -> LoggerConfig {
  LoggerConfig::{ ..self, enable_console: true, console_json: true }
}

pub fn LoggerConfig::add_context(self : LoggerConfig, key : String, value : String) -> LoggerConfig {
  let new_keys = self.context_keys
  let new_values = self.context_values
  new_keys.push(key)
  new_values.push(value)
  LoggerConfig::{ ..self, context_keys: new_keys, context_values: new_values }
}

pub fn LoggerConfig::build_logger(self : LoggerConfig) -> Logger {
  let logger = Logger::new().level(self.level)
  let logger2 = if self.enable_console {
    if self.console_json { logger.console_json() } else { logger.console() }
  } else { logger }
  let logger3 = build_context(logger2, self.context_keys, self.context_values, 0)
  logger3.build()
}

fn build_context(logger : Logger, keys : Array[String], values : Array[String], idx : Int) -> Logger {
  if idx >= keys.length() { logger }
  else {
    let next = logger.add_context(keys[idx], values[idx])
    build_context(next, keys, values, idx + 1)
  }
}

// Named logger factory — creates pre-configured loggers
pub fn create_dev_logger() -> Logger {
  LoggerConfig::new()
    .set_level(Level::TRACE)
    .enable_console()
    .build_logger()
}

pub fn create_prod_logger() -> Logger {
  LoggerConfig::new()
    .set_level(Level::INFO)
    .enable_console_json()
    .add_context("env", "production")
    .build_logger()
}

pub fn create_test_logger() -> Logger {
  LoggerConfig::new()
    .set_level(Level::DEBUG)
    .build_logger()
}
