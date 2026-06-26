pub(all) struct Logger {
  level : Level
  has_console : Bool
  console_json : Bool
  memory : MemoryAppender
  seq : Int
  context : LogContext
  console_json_enabled : Bool
}

pub fn Logger::new() -> Logger {
  Logger::{
    level: Level::TRACE,
    has_console: false,
    console_json: false,
    console_json_enabled: false,
    memory: MemoryAppender::new(),
    seq: 0,
    context: LogContext::new(),
  }
}

pub fn Logger::level(self : Logger, l : Level) -> Logger {
  Logger::{ ..self, level: l }
}

pub fn Logger::console(self : Logger) -> Logger {
  Logger::{ ..self, has_console: true }
}

pub fn Logger::console_json(self : Logger) -> Logger {
  Logger::{ ..self, has_console: true, console_json_enabled: true }
}

pub fn Logger::add_context(self : Logger, key : String, value : String) -> Logger {
  Logger::{ ..self, context: self.context.add(key, value) }
}

pub fn Logger::build(self : Logger) -> Logger { self }

fn Logger::_log(self : Logger, lvl : Level, msg : String, fields : Array[(String, String)]) -> Logger {
  if level_ordinal(lvl) < level_ordinal(self.level) { return self }
  let s = Logger::{ ..self, seq: self.seq + 1 }
  let ts = s.seq
  let merged_fields = s.context.merge(fields)
  let record = LogRecord::new(lvl, msg, merged_fields, ts)
  let new_memory = s.memory.append(record)
  if s.has_console {
    let output = if s.console_json_enabled { format_json(record) } else { format_text(record) }
    println(output)
  }
  Logger::{ ..s, memory: new_memory }
}

pub fn Logger::trace(self : Logger, msg : String, fields : Array[(String, String)]) -> Logger {
  self._log(Level::TRACE, msg, fields)
}
pub fn Logger::debug(self : Logger, msg : String, fields : Array[(String, String)]) -> Logger {
  self._log(Level::DEBUG, msg, fields)
}
pub fn Logger::info(self : Logger, msg : String, fields : Array[(String, String)]) -> Logger {
  self._log(Level::INFO, msg, fields)
}
pub fn Logger::warn(self : Logger, msg : String, fields : Array[(String, String)]) -> Logger {
  self._log(Level::WARN, msg, fields)
}
pub fn Logger::error(self : Logger, msg : String, fields : Array[(String, String)]) -> Logger {
  self._log(Level::ERROR, msg, fields)
}

pub fn Logger::logs(self : Logger) -> Array[String] {
  self.memory.get_logs()
}

pub fn Logger::log_count(self : Logger) -> Int {
  self.memory.get_logs().length()
}
