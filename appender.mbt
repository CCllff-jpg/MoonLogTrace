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
