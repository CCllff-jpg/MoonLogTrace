// Batch logger — accumulates logs and flushes them together

pub(all) struct BatchLogger {
  logger : Logger
  buffer : Array[LogRecord]
  batch_size : Int
}

pub fn BatchLogger::new(logger : Logger, batch_size : Int) -> BatchLogger {
  BatchLogger::{ logger, buffer: [], batch_size }
}

pub fn BatchLogger::log(self : BatchLogger, lvl : Level, msg : String, fields : Array[(String, String)]) -> BatchLogger {
  let ts = self.logger.seq + self.buffer.length() + 1
  let record = LogRecord::new(lvl, msg, fields, ts)
  let new_buffer = self.buffer
  new_buffer.push(record)
  if new_buffer.length() >= self.batch_size {
    flush_buffer(BatchLogger::{ ..self, buffer: new_buffer }, new_buffer, 0)
  } else {
    BatchLogger::{ ..self, buffer: new_buffer }
  }
}

fn flush_buffer(bl : BatchLogger, buffer : Array[LogRecord], idx : Int) -> BatchLogger {
  if idx >= buffer.length() { BatchLogger::{ ..bl, buffer: [], logger: bl.logger } }
  else {
    let r = buffer[idx]
    let new_logger = bl.logger._log(r.level, "[BATCH] " + r.message, r.fields)
    let updated = BatchLogger::{ ..bl, logger: new_logger }
    flush_buffer(updated, buffer, idx + 1)
  }
}

// Convenience methods
pub fn BatchLogger::trace(self : BatchLogger, msg : String, fields : Array[(String, String)]) -> BatchLogger {
  self.log(Level::TRACE, msg, fields)
}
pub fn BatchLogger::debug(self : BatchLogger, msg : String, fields : Array[(String, String)]) -> BatchLogger {
  self.log(Level::DEBUG, msg, fields)
}
pub fn BatchLogger::info(self : BatchLogger, msg : String, fields : Array[(String, String)]) -> BatchLogger {
  self.log(Level::INFO, msg, fields)
}
pub fn BatchLogger::warn(self : BatchLogger, msg : String, fields : Array[(String, String)]) -> BatchLogger {
  self.log(Level::WARN, msg, fields)
}
pub fn BatchLogger::error(self : BatchLogger, msg : String, fields : Array[(String, String)]) -> BatchLogger {
  self.log(Level::ERROR, msg, fields)
}

pub fn BatchLogger::flush(self : BatchLogger) -> BatchLogger {
  flush_buffer(self, self.buffer, 0)
}

pub fn BatchLogger::pending(self : BatchLogger) -> Int {
  self.buffer.length()
}
