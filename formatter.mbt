pub fn format_text(record : LogRecord) -> String {
  let result = "[" + record.timestamp.to_string() + "] " +
    level_to_string(record.level) + "  " + record.message
  format_fields(result, record.fields, 0)
}

fn format_fields(result : String, fields : Array[(String, String)], idx : Int) -> String {
  if idx >= fields.length() { result }
  else {
    let (k, v) = fields[idx]
    let new_result = result + "  " + k + "=" + v
    format_fields(new_result, fields, idx + 1)
  }
}

pub fn format_json(record : LogRecord) -> String {
  let result = "{\"time\":\"" + record.timestamp.to_string() +
    "\",\"level\":\"" + level_to_string(record.level) +
    "\",\"msg\":\"" + record.message + "\""
  format_json_fields(result, record.fields, 0)
}

fn format_json_fields(result : String, fields : Array[(String, String)], idx : Int) -> String {
  if idx >= fields.length() { result + "}" }
  else {
    let (k, v) = fields[idx]
    let new_result = result + ",\"" + k + "\":\"" + v + "\""
    format_json_fields(new_result, fields, idx + 1)
  }
}

// ANSI color codes for terminal output
fn ansi_color(level : Level) -> String {
  match level {
    Level::TRACE => "[90m"
    Level::DEBUG => "[36m"
    Level::INFO => "[32m"
    Level::WARN => "[33m"
    Level::ERROR => "[31m"
  }
}

fn ansi_reset() -> String { "[0m" }

pub fn format_color(record : LogRecord) -> String {
  let color = ansi_color(record.level)
  let result = color + "[" + record.timestamp.to_string() + "] " +
    level_to_string(record.level) + "  " + record.message + ansi_reset()
  format_fields(result, record.fields, 0)
}

// Compact single-line format: LEVEL|timestamp|msg|k=v|k=v
pub fn format_compact(record : LogRecord) -> String {
  let result = level_to_string(record.level).trim_space().to_string() +
    "|" + record.timestamp.to_string() + "|" + record.message
  format_compact_fields(result, record.fields, 0)
}

fn format_compact_fields(result : String, fields : Array[(String, String)], idx : Int) -> String {
  if idx >= fields.length() { result }
  else {
    let (k, v) = fields[idx]
    let new_result = result + "|" + k + "=" + v
    format_compact_fields(new_result, fields, idx + 1)
  }
}

// CSV format: timestamp,level,message,key1,val1,key2,val2,...
pub fn format_csv(record : LogRecord) -> String {
  let result = record.timestamp.to_string() + "," +
    level_to_string(record.level).trim_space().to_string() + "," +
    record.message
  format_csv_fields(result, record.fields, 0)
}

fn format_csv_fields(result : String, fields : Array[(String, String)], idx : Int) -> String {
  if idx >= fields.length() { result }
  else {
    let (k, v) = fields[idx]
    let new_result = result + "," + k + "," + v
    format_csv_fields(new_result, fields, idx + 1)
  }
}

// Format without timestamp (for testing)
pub fn format_plain(record : LogRecord) -> String {
  let result = level_to_string(record.level).trim_space().to_string() + " " + record.message
  format_fields(result, record.fields, 0)
}
