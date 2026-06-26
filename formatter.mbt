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
