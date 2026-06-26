// Syslog RFC 5424 and GELF format support

// RFC 5424 style: <pri>version timestamp hostname appname procid msgid [sd] msg
// Simplified: <pri>timestamp appname msg [fields]
pub fn format_syslog(record : LogRecord, app_name : String) -> String {
  let pri = syslog_priority(record.level)
  let ts = record.timestamp.to_string()
  let fields_str = build_syslog_sd(record.fields, 0, "")
  "<" + pri.to_string() + ">" + "1 " + ts + " " +
    app_name + " - - - " + fields_str + " " + record.message
}

fn syslog_priority(level : Level) -> Int {
  // Facility 1 (user) + severity
  let facility = 1
  let severity = match level {
    Level::TRACE => 7
    Level::DEBUG => 7
    Level::INFO => 6
    Level::WARN => 4
    Level::ERROR => 3
  }
  facility * 8 + severity
}

fn build_syslog_sd(fields : Array[(String, String)], idx : Int, result : String) -> String {
  if idx >= fields.length() { if result == "" { "-" } else { "[" + result + "]" } }
  else {
    let (k, v) = fields[idx]
    let pair = k + "=\"" + v + "\""
    let sep = if idx > 0 { " " } else { "" }
    build_syslog_sd(fields, idx + 1, result + sep + pair)
  }
}

// GELF (Graylog Extended Log Format) — JSON-based
pub fn format_gelf(record : LogRecord, host : String) -> String {
  let short_msg = escape_gelf(record.message)
  let result = "{\"version\":\"1.1\",\"host\":\"" + host +
    "\",\"short_message\":\"" + short_msg +
    "\",\"timestamp\":" + record.timestamp.to_string() +
    ",\"level\":" + gelf_level(record.level).to_string()
  format_gelf_fields(result, record.fields, 0)
}

fn gelf_level(level : Level) -> Int {
  match level {
    Level::TRACE => 7
    Level::DEBUG => 7
    Level::INFO => 6
    Level::WARN => 4
    Level::ERROR => 3
  }
}

fn escape_gelf(s : String) -> String {
  // Minimal escaping for JSON string
  escape_gelf_chars(s, 0, "")
}

fn escape_gelf_chars(s : String, idx : Int, result : String) -> String {
  if idx >= s.length() { result }
  else {
    let ch = s.substring(start=idx, end=idx + 1)
    let esc = if ch == "\"" { "\\\"" }
      else if ch == "\\" { "\\\\" }
      else { ch }
    escape_gelf_chars(s, idx + 1, result + esc)
  }
}

fn format_gelf_fields(result : String, fields : Array[(String, String)], idx : Int) -> String {
  if idx >= fields.length() { result + "}" }
  else {
    let (k, v) = fields[idx]
    let kv = ",\"_" + k + "\":\"" + escape_gelf(v) + "\""
    format_gelf_fields(result + kv, fields, idx + 1)
  }
}
