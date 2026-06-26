// Parse log level from string (useful for config files and CLI args)

pub fn parse_level(s : String) -> Level {
  let upper = to_upper(s)
  if upper == "TRACE" { Level::TRACE }
  else if upper == "DEBUG" { Level::DEBUG }
  else if upper == "INFO" { Level::INFO }
  else if upper == "WARN" { Level::WARN }
  else if upper == "WARNING" { Level::WARN }
  else if upper == "ERROR" { Level::ERROR }
  else { Level::INFO }  // default
}

fn to_upper(s : String) -> String {
  to_upper_chars(s, 0, "")
}

fn to_upper_chars(s : String, idx : Int, result : String) -> String {
  if idx >= s.length() { result }
  else {
    let ch = s.substring(start=idx, end=idx + 1)
    let upper_ch = char_to_upper(ch)
    to_upper_chars(s, idx + 1, result + upper_ch)
  }
}

fn char_to_upper(ch : String) -> String {
  if ch == "a" { "A" } else if ch == "b" { "B" }
  else if ch == "c" { "C" } else if ch == "d" { "D" }
  else if ch == "e" { "E" } else if ch == "f" { "F" }
  else if ch == "g" { "G" } else if ch == "h" { "H" }
  else if ch == "i" { "I" } else if ch == "j" { "J" }
  else if ch == "k" { "K" } else if ch == "l" { "L" }
  else if ch == "m" { "M" } else if ch == "n" { "N" }
  else if ch == "o" { "O" } else if ch == "p" { "P" }
  else if ch == "q" { "Q" } else if ch == "r" { "R" }
  else if ch == "s" { "S" } else if ch == "t" { "T" }
  else if ch == "u" { "U" } else if ch == "v" { "V" }
  else if ch == "w" { "W" } else if ch == "x" { "X" }
  else if ch == "y" { "Y" } else if ch == "z" { "Z" }
  else { ch }
}

// Get all level names
pub fn level_names() -> Array[String] {
  ["TRACE", "DEBUG", "INFO", "WARN", "ERROR"]
}

// Validate a level string is valid
pub fn is_valid_level(s : String) -> Bool {
  let upper = to_upper(s)
  upper == "TRACE" || upper == "DEBUG" || upper == "INFO" ||
  upper == "WARN" || upper == "WARNING" || upper == "ERROR"
}
