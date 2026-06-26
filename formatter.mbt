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

// Pattern formatter with configurable format
// Supports: {t} = timestamp, {l} = level, {m} = message, {f} = fields
pub fn format_pattern(record : LogRecord, pattern : String) -> String {
  replace_pattern(pattern, record, 0, "")
}

fn replace_pattern(pattern : String, record : LogRecord, idx : Int, result : String) -> String {
  if idx >= pattern.length() { result }
  else {
    let ch = pattern.substring(start=idx, end=idx + 1)
    if ch == "{" {
      if idx + 2 < pattern.length() && pattern.substring(start=idx + 2, end=idx + 3) == "}" {
        let key = pattern.substring(start=idx + 1, end=idx + 2)
        let replacement = get_pattern_value(key, record)
        replace_pattern(pattern, record, idx + 3, result + replacement)
      } else {
        replace_pattern(pattern, record, idx + 1, result + ch)
      }
    } else {
      replace_pattern(pattern, record, idx + 1, result + ch)
    }
  }
}

fn get_pattern_value(key : String, record : LogRecord) -> String {
  if key == "t" { record.timestamp.to_string() }
  else if key == "l" { level_to_string(record.level).trim_space().to_string() }
  else if key == "m" { record.message }
  else if key == "f" { format_all_fields(record.fields, 0, "") }
  else { "{" + key + "}" }
}

fn format_all_fields(fields : Array[(String, String)], idx : Int, result : String) -> String {
  if idx >= fields.length() { result }
  else {
    let (k, v) = fields[idx]
    let sep = if idx > 0 { " " } else { "" }
    format_all_fields(fields, idx + 1, result + sep + k + "=" + v)
  }
}

// Logfmt format: key=value pairs, level and message as special keys
pub fn format_logfmt(record : LogRecord) -> String {
  let result = "ts=" + record.timestamp.to_string() +
    " level=" + level_to_string(record.level).trim_space().to_string() +
    " msg=\"" + record.message + "\""
  format_logfmt_fields(result, record.fields, 0)
}

fn format_logfmt_fields(result : String, fields : Array[(String, String)], idx : Int) -> String {
  if idx >= fields.length() { result }
  else {
    let (k, v) = fields[idx]
    let new_result = result + " " + k + "=" + v
    format_logfmt_fields(new_result, fields, idx + 1)
  }
}

// XML format
pub fn format_xml(record : LogRecord) -> String {
  let result = "<log ts=\"" + record.timestamp.to_string() +
    "\" level=\"" + level_to_string(record.level).trim_space().to_string() +
    "\"><msg>" + record.message + "</msg>"
  format_xml_fields(result, record.fields, 0) + "</log>"
}

fn format_xml_fields(result : String, fields : Array[(String, String)], idx : Int) -> String {
  if idx >= fields.length() { result }
  else {
    let (k, v) = fields[idx]
    let new_result = result + "<" + k + ">" + v + "</" + k + ">"
    format_xml_fields(new_result, fields, idx + 1)
  }
}

// NDJSON (Newline Delimited JSON) — same as JSON but guaranteed single line
pub fn format_ndjson(record : LogRecord) -> String {
  format_json(record)
}
