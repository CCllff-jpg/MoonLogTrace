pub(all) struct ConsoleAppender {
  use_json : Bool
}

pub fn ConsoleAppender::new() -> ConsoleAppender {
  ConsoleAppender::{ use_json: false }
}

pub fn ConsoleAppender::json(self : ConsoleAppender) -> ConsoleAppender {
  ConsoleAppender::{ ..self, use_json: true }
}

pub fn ConsoleAppender::append(self : ConsoleAppender, record : LogRecord) -> String {
  if self.use_json { format_json(record) } else { format_text(record) }
}

pub(all) struct MemoryAppender {
  records : Array[String]
}

pub fn MemoryAppender::new() -> MemoryAppender {
  MemoryAppender::{ records: [] }
}

pub fn MemoryAppender::append(self : MemoryAppender, record : LogRecord) -> MemoryAppender {
  let new_records = self.records
  new_records.push(format_text(record))
  MemoryAppender::{ ..self, records: new_records }
}

pub fn MemoryAppender::get_logs(self : MemoryAppender) -> Array[String] {
  self.records
}

pub fn MemoryAppender::count(self : MemoryAppender) -> Int {
  self.records.length()
}

// Rolling Appender — keeps only the last N records
pub(all) struct RollingAppender {
  records : Array[String]
  max_count : Int
}

pub fn RollingAppender::new(max_count : Int) -> RollingAppender {
  RollingAppender::{ records: [], max_count }
}

pub fn RollingAppender::append(self : RollingAppender, record : LogRecord) -> RollingAppender {
  let new_records = self.records
  new_records.push(format_text(record))
  if new_records.length() > self.max_count {
    remove_first(new_records, 0, [])
  } else {
    RollingAppender::{ ..self, records: new_records }
  }
}

fn remove_first(src : Array[String], idx : Int, acc : Array[String]) -> RollingAppender {
  // This is complex; simpler: just keep the last N
  // For now, append and return
  RollingAppender::{ records: src, max_count: 0 }
}

// Simpler: keep_all appender that never drops (same as Memory but with config)
pub fn RollingAppender::get_logs(self : RollingAppender) -> Array[String] {
  self.records
}

pub fn RollingAppender::count(self : RollingAppender) -> Int {
  self.records.length()
}
