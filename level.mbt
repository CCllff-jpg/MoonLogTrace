pub(all) enum Level {
  TRACE
  DEBUG
  INFO
  WARN
  ERROR
}

pub fn level_to_string(l : Level) -> String {
  match l {
    Level::TRACE => "TRACE"
    Level::DEBUG => "DEBUG"
    Level::INFO => "INFO "
    Level::WARN => "WARN "
    Level::ERROR => "ERROR"
  }
}

pub fn level_ordinal(l : Level) -> Int {
  match l {
    Level::TRACE => 0
    Level::DEBUG => 1
    Level::INFO => 2
    Level::WARN => 3
    Level::ERROR => 4
  }
}

pub fn should_log(msg_level : Level, threshold : Level) -> Bool {
  level_ordinal(msg_level) >= level_ordinal(threshold)
}
