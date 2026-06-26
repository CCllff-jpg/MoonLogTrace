// Whitebox tests run within the package scope.

test "level to string" {
  assert_eq(level_to_string(Level::TRACE), "TRACE")
  assert_eq(level_to_string(Level::DEBUG), "DEBUG")
  assert_eq(level_to_string(Level::INFO), "INFO")
  assert_eq(level_to_string(Level::WARN), "WARN")
  assert_eq(level_to_string(Level::ERROR), "ERROR")
}

test "level ordinal" {
  assert_eq(level_ordinal(Level::TRACE), 0)
  assert_eq(level_ordinal(Level::DEBUG), 1)
  assert_eq(level_ordinal(Level::INFO), 2)
  assert_eq(level_ordinal(Level::WARN), 3)
  assert_eq(level_ordinal(Level::ERROR), 4)
}

test "should_log filtering" {
  assert_eq(should_log(Level::INFO, Level::DEBUG), true)
  assert_eq(should_log(Level::DEBUG, Level::INFO), false)
  assert_eq(should_log(Level::ERROR, Level::ERROR), true)
}

test "logrecord creation" {
  let r = LogRecord::new(Level::INFO, "hello", [("key", "val")], 1000)
  assert_eq(r.message, "hello")
  assert_eq(r.timestamp, 1000)
}

test "logrecord with empty fields" {
  let r = LogRecord::new(Level::WARN, "warning", [], 0)
  assert_eq(r.fields.length(), 0)
}

test "format text basic" {
  let r = LogRecord::new(Level::INFO, "Server started", [("port", "8080")], 1000)
  let s = format_text(r)
  assert_eq(s.contains("[1000]"), true)
  assert_eq(s.contains("INFO"), true)
  assert_eq(s.contains("Server started"), true)
  assert_eq(s.contains("port=8080"), true)
}

test "format json basic" {
  let r = LogRecord::new(Level::ERROR, "Fail", [("code", "500")], 2000)
  let s = format_json(r)
  assert_eq(s.contains("\"level\":\"ERROR\""), true)
  assert_eq(s.contains("\"msg\":\"Fail\""), true)
  assert_eq(s.contains("\"code\":\"500\""), true)
}

test "console appender generates text" {
  let appender = ConsoleAppender::new()
  let r = LogRecord::new(Level::INFO, "Hi", [], 0)
  let output = appender.append(r)
  assert_eq(output.contains("Hi"), true)
}

test "memory appender collects logs" {
  let appender = MemoryAppender::new()
  let r1 = LogRecord::new(Level::INFO, "First", [], 0)
  let r2 = LogRecord::new(Level::WARN, "Second", [], 1)
  let a2 = appender.append(r1)
  let a3 = a2.append(r2)
  assert_eq(a3.get_logs().length(), 2)
}

test "logger filters below threshold" {
  let logger = Logger::new().level(Level::WARN).build()
  let l2 = logger.info("should be filtered", [])
  assert_eq(l2.logs().length(), 0)
}

test "logger passes at or above threshold" {
  let logger = Logger::new().level(Level::INFO).build()
  let l2 = logger.info("hello", [])
  let l3 = l2.error("err", [])
  assert_eq(l3.logs().length(), 2)
}

test "logger convenience methods" {
  let logger = Logger::new().build()
  let l2 = logger.debug("debug msg", [])
  let l3 = l2.warn("warn msg", [("code", "42")])
  assert_eq(l3.logs().length(), 2)
}

test "span enter and exit" {
  let logger = Logger::new().build()
  let (l2, span) = Span::enter(logger, "db_query", [("table", "users")])
  let l3 = span.exit(l2)
  let logs = l3.logs()
  assert_eq(logs.length(), 2)
  assert_eq(logs[0].contains("db_query"), true)
  assert_eq(logs[1].contains("duration"), true)
}
