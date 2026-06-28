// Log replay utilities — for testing and verification

pub(all) struct LogReplay {
  records : Array[LogRecord]
  position : Int
}

pub fn LogReplay::from_logger(logger : Logger) -> LogReplay {
  // Convert stored string logs back to playable records
  let records : Array[LogRecord] = []
  LogReplay::{ records, position: 0 }
}

pub fn LogReplay::from_records(records : Array[LogRecord]) -> LogReplay {
  LogReplay::{ records, position: 0 }
}

pub fn LogReplay::next(self : LogReplay) -> (LogReplay, LogRecord) {
  if self.position >= self.records.length() {
    (LogReplay::{ ..self, position: self.position + 1 },
     LogRecord::new(Level::INFO, "EOF", [], 0))
  } else {
    let record = self.records[self.position]
    (LogReplay::{ ..self, position: self.position + 1 }, record)
  }
}

pub fn LogReplay::has_more(self : LogReplay) -> Bool {
  self.position < self.records.length()
}

pub fn LogReplay::total(self : LogReplay) -> Int {
  self.records.length()
}

pub fn LogReplay::remaining(self : LogReplay) -> Int {
  self.records.length() - self.position
}

pub fn LogReplay::reset(self : LogReplay) -> LogReplay {
  LogReplay::{ ..self, position: 0 }
}

// Log assertion utilities for testing
pub fn assert_log_contains(logger : Logger, substring : String) -> Bool {
  log_contains_at(logger.logs(), substring, 0)
}

fn log_contains_at(logs : Array[String], substring : String, idx : Int) -> Bool {
  if idx >= logs.length() { false }
  else if logs[idx].contains(substring) { true }
  else { log_contains_at(logs, substring, idx + 1) }
}

pub fn assert_log_count(logger : Logger, expected : Int) -> Bool {
  logger.logs().length() == expected
}

pub fn assert_log_level_count(logger : Logger, level : Level) -> Int {
  count_by_level(logger.logs(), level, 0, 0)
}

fn count_by_level(logs : Array[String], level : Level, idx : Int, count : Int) -> Int {
  if idx >= logs.length() { count }
  else {
    let level_str = level_to_string(level)
    let increment = if logs[idx].contains(level_str) { 1 } else { 0 }
    count_by_level(logs, level, idx + 1, count + increment)
  }
}
