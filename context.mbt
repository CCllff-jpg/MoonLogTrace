pub(all) struct LogContext {
  pairs : Array[(String, String)]
}

pub fn LogContext::new() -> LogContext {
  LogContext::{ pairs: [] }
}

pub fn LogContext::add(self : LogContext, key : String, value : String) -> LogContext {
  let new_pairs = self.pairs
  new_pairs.push((key, value))
  LogContext::{ ..self, pairs: new_pairs }
}

pub fn LogContext::merge(self : LogContext, fields : Array[(String, String)]) -> Array[(String, String)] {
  merge_pairs(self.pairs, fields, 0)
}

fn merge_pairs(ctx_pairs : Array[(String, String)], fields : Array[(String, String)], idx : Int) -> Array[(String, String)] {
  if idx >= ctx_pairs.length() { fields }
  else {
    let (k, v) = ctx_pairs[idx]
    let new_fields = fields
    new_fields.push((k, v))
    merge_pairs(ctx_pairs, new_fields, idx + 1)
  }
}
