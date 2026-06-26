// Log Router — route log entries to different outputs based on level

pub(all) struct LogRouter {
  memory_all : MemoryAppender
  memory_errors : MemoryAppender
  logger : Logger
}

pub fn LogRouter::new(logger : Logger) -> LogRouter {
  LogRouter::{
    memory_all: MemoryAppender::new(),
    memory_errors: MemoryAppender::new(),
    logger,
  }
}

pub fn LogRouter::dispatch(self : LogRouter, lvl : Level, msg : String, fields : Array[(String, String)]) -> LogRouter {
  let s = Logger::{ ..self.logger, seq: self.logger.seq + 1 }
  let ts = s.seq
  let record = LogRecord::new(lvl, msg, fields, ts)

  // All logs go to memory_all
  let new_all = self.memory_all.append(record)

  // Only errors and warnings go to memory_errors
  let new_errors = if level_ordinal(lvl) >= level_ordinal(Level::WARN) {
    self.memory_errors.append(record)
  } else {
    self.memory_errors
  }

  LogRouter::{ ..self, memory_all: new_all, memory_errors: new_errors, logger: s }
}

pub fn LogRouter::all_logs(self : LogRouter) -> Array[String] {
  self.memory_all.get_logs()
}

pub fn LogRouter::error_logs(self : LogRouter) -> Array[String] {
  self.memory_errors.get_logs()
}

pub fn LogRouter::all_count(self : LogRouter) -> Int {
  self.memory_all.count()
}

pub fn LogRouter::error_count(self : LogRouter) -> Int {
  self.memory_errors.count()
}
