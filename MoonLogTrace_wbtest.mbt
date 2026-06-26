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

test "format color includes ANSI codes" {
  let r = LogRecord::new(Level::ERROR, "Fail", [], 0)
  let s = format_color(r)
  assert_eq(s.contains("[31m"), true)
  assert_eq(s.contains("Fail"), true)
}

test "format compact output" {
  let r = LogRecord::new(Level::INFO, "Msg", [("a", "1")], 0)
  let s = format_compact(r)
  assert_eq(s.contains("INFO|"), true)
  assert_eq(s.contains("|Msg|"), true)
}

test "format csv output" {
  let r = LogRecord::new(Level::WARN, "W", [("k", "v")], 0)
  let s = format_csv(r)
  assert_eq(s.contains("WARN,W,k,v"), true)
}

test "level filter passes and blocks" {
  let f = LevelFilter::new(Level::INFO)
  assert_eq(f.check(Level::ERROR), true)
  assert_eq(f.check(Level::DEBUG), false)
}

test "message filter matches substring" {
  let f = MessageFilter::new("error")
  let r1 = LogRecord::new(Level::INFO, "an error occurred", [], 0)
  let r2 = LogRecord::new(Level::INFO, "all good", [], 0)
  assert_eq(f.check(r1), true)
  assert_eq(f.check(r2), false)
}

test "field filter matches key-value" {
  let f = FieldFilter::new("user", "admin")
  let r1 = LogRecord::new(Level::INFO, "login", [("user", "admin")], 0)
  let r2 = LogRecord::new(Level::INFO, "login", [("user", "guest")], 0)
  assert_eq(f.check(r1), true)
  assert_eq(f.check(r2), false)
}

test "log context merges with fields" {
  let ctx = LogContext::new().add("env", "prod").add("region", "us")
  let fields : Array[(String, String)] = [("request_id", "123")]
  let merged = ctx.merge(fields)
  assert_eq(merged.length(), 3)
}

test "logger with context" {
  let logger = Logger::new().add_context("app", "api").build()
  let l2 = logger.info("started", [])
  let logs = l2.logs()
  assert_eq(logs[0].contains("app=api"), true)
}

test "counter increments" {
  let c = Counter::new("requests").increment().increment().add(3)
  assert_eq(c.read(), 5)
}

test "timer measures elapsed" {
  let t = Timer::start("op", 10)
  let (name, elapsed) = t.stop(25)
  assert_eq(name, "op")
  assert_eq(elapsed, 15)
}

test "histogram basic stats" {
  let h = Histogram::new("latency")
    .record(10).record(20).record(30).record(40).record(50)
  assert_eq(h.count(), 5)
  assert_eq(h.sum(), 150)
  assert_eq(h.avg(), 30)
  assert_eq(h.min_val(), 10)
  assert_eq(h.max_val(), 50)
}

test "allow list filter" {
  let f = AllowListFilter::new([Level::ERROR, Level::WARN])
  assert_eq(f.check(Level::ERROR), true)
  assert_eq(f.check(Level::WARN), true)
  assert_eq(f.check(Level::INFO), false)
}

test "deny list filter" {
  let f = DenyListFilter::new([Level::TRACE, Level::DEBUG])
  assert_eq(f.check(Level::INFO), true)
  assert_eq(f.check(Level::DEBUG), false)
}
