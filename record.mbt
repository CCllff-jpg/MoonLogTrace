pub(all) struct LogRecord {
  level : Level
  message : String
  fields : Array[(String, String)]
  timestamp : Int
}

pub fn LogRecord::new(
  level : Level,
  message : String,
  fields : Array[(String, String)],
  timestamp : Int
) -> LogRecord {
  LogRecord::{ level, message, fields, timestamp }
}
