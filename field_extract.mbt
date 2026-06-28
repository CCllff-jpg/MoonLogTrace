// Field extractor — parse structured data from log messages

// Extract key=value pairs from a message string
pub fn extract_key_value_pairs(message : String) -> Array[(String, String)] {
  extract_pairs(message, 0, 0, "", "", [])
}

fn extract_pairs(s : String, idx : Int, state : Int,
    current_key : String, current_val : String,
    result : Array[(String, String)]) -> Array[(String, String)] {
  // state: 0=reading key, 1=reading value, 2=looking for start
  if idx >= s.length() {
    if current_key != "" && current_val != "" {
      result.push((current_key, current_val))
    }
    result
  } else {
    let ch = s.substring(start=idx, end=idx + 1)
    if ch == "=" && state == 0 {
      extract_pairs(s, idx + 1, 1, current_key, "", result)
    } else if ch == " " && state == 1 {
      if current_key != "" && current_val != "" {
        result.push((current_key, current_val))
      }
      extract_pairs(s, idx + 1, 0, "", "", result)
    } else if state == 0 {
      extract_pairs(s, idx + 1, 0, current_key + ch, current_val, result)
    } else {
      extract_pairs(s, idx + 1, 1, current_key, current_val + ch, result)
    }
  }
}

// Extract JSON-style fields from message: {"key": "value", ...}
pub fn extract_json_like(message : String) -> Array[(String, String)] {
  // Simple: look for "key":"value" patterns
  extract_json_pairs(message, 0, 0, "", "", [])
}

fn extract_json_pairs(s : String, idx : Int, state : Int,
    current_key : String, current_val : String,
    result : Array[(String, String)]) -> Array[(String, String)] {
  // state: 0=before key, 1=in key, 2=after key (looking for colon), 3=in value
  if idx >= s.length() {
    if current_key != "" { result.push((current_key, current_val)) }
    result
  } else {
    let ch = s.substring(start=idx, end=idx + 1)
    if ch == "\"" && state == 0 {
      extract_json_pairs(s, idx + 1, 1, "", "", result)
    } else if ch == "\"" && state == 1 {
      extract_json_pairs(s, idx + 1, 2, current_key, "", result)
    } else if ch == ":" && state == 2 {
      extract_json_pairs(s, idx + 1, 3, current_key, "", result)
    } else if ch == "\"" && state == 3 {
      extract_json_pairs(s, idx + 1, 0, "", current_val, result)
    } else if state == 1 {
      extract_json_pairs(s, idx + 1, 1, current_key + ch, current_val, result)
    } else if state == 3 && ch != "\"" {
      extract_json_pairs(s, idx + 1, 3, current_key, current_val + ch, result)
    } else {
      extract_json_pairs(s, idx + 1, state, current_key, current_val, result)
    }
  }
}

// Count words in a message
pub fn word_count(message : String) -> Int {
  count_words(message, 0, 0, false)
}

fn count_words(s : String, idx : Int, count : Int, in_word : Bool) -> Int {
  if idx >= s.length() { if in_word { count + 1 } else { count } }
  else {
    let ch = s.substring(start=idx, end=idx + 1)
    if ch == " " || ch == "\t" || ch == "\n" {
      count_words(s, idx + 1, if in_word { count + 1 } else { count }, false)
    } else {
      count_words(s, idx + 1, count, true)
    }
  }
}
