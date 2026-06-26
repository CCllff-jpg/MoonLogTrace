// Log pipeline — transforms applied to records before output

pub(all) struct Pipeline {
  add_field_keys : Array[String]
  add_field_values : Array[String]
  prefix_message : String
  redact_keys : Array[String]
}

pub fn Pipeline::new() -> Pipeline {
  Pipeline::{
    add_field_keys: [],
    add_field_values: [],
    prefix_message: "",
    redact_keys: [],
  }
}

pub fn Pipeline::add_field(self : Pipeline, key : String, value : String) -> Pipeline {
  let new_keys = self.add_field_keys
  let new_values = self.add_field_values
  new_keys.push(key)
  new_values.push(value)
  Pipeline::{ ..self, add_field_keys: new_keys, add_field_values: new_values }
}

pub fn Pipeline::prepend_msg(self : Pipeline, prefix : String) -> Pipeline {
  Pipeline::{ ..self, prefix_message: prefix }
}

pub fn Pipeline::redact(self : Pipeline, key : String) -> Pipeline {
  let new_redact = self.redact_keys
  new_redact.push(key)
  Pipeline::{ ..self, redact_keys: new_redact }
}

pub fn Pipeline::apply(self : Pipeline, record : LogRecord) -> LogRecord {
  let r1 = if self.prefix_message == "" { record }
    else { LogRecord::{ ..record, message: self.prefix_message + record.message } }

  let r2 = apply_added_fields(r1, self.add_field_keys, self.add_field_values, 0)
  let r3 = apply_redactions(r2, self.redact_keys, 0)
  r3
}

fn apply_added_fields(record : LogRecord, keys : Array[String], values : Array[String], idx : Int) -> LogRecord {
  if idx >= keys.length() { record }
  else {
    let new_fields = record.fields
    new_fields.push((keys[idx], values[idx]))
    apply_added_fields(LogRecord::{ ..record, fields: new_fields }, keys, values, idx + 1)
  }
}

fn apply_redactions(record : LogRecord, keys : Array[String], idx : Int) -> LogRecord {
  if idx >= keys.length() { record }
  else {
    let new_fields = redact_field_key(record.fields, keys[idx], 0, [])
    apply_redactions(LogRecord::{ ..record, fields: new_fields }, keys, idx + 1)
  }
}

fn redact_field_key(fields : Array[(String, String)], key : String, idx : Int, result : Array[(String, String)]) -> Array[(String, String)] {
  if idx >= fields.length() { result }
  else {
    let (k, v) = fields[idx]
    let replacement = if k == key { "***" } else { v }
    result.push((k, replacement))
    redact_field_key(fields, key, idx + 1, result)
  }
}

pub fn Pipeline::transform_count(self : Pipeline) -> Int {
  let n = self.add_field_keys.length()
  let n2 = if self.prefix_message == "" { 0 } else { 1 }
  n + n2 + self.redact_keys.length()
}
