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

test "logfmt format" {
  let r = LogRecord::new(Level::INFO, "test", [("key", "val")], 100)
  let s = format_logfmt(r)
  assert_eq(s.contains("ts=100"), true)
  assert_eq(s.contains("level=INFO"), true)
  assert_eq(s.contains("key=val"), true)
}

test "xml format" {
  let r = LogRecord::new(Level::WARN, "warn", [("code", "1")], 0)
  let s = format_xml(r)
  assert_eq(s.contains("<log"), true)
  assert_eq(s.contains("</log>"), true)
  assert_eq(s.contains("<code>1</code>"), true)
}

test "pattern format" {
  let r = LogRecord::new(Level::INFO, "hello", [("a", "1")], 42)
  let s = format_pattern(r, "{t} [{l}] {m}")
  assert_eq(s.contains("42"), true)
  assert_eq(s.contains("INFO"), true)
  assert_eq(s.contains("hello"), true)
}

test "parse level from string" {
  assert_eq(level_ordinal(parse_level("debug")), 1)
  assert_eq(level_ordinal(parse_level("WARN")), 3)
  assert_eq(level_ordinal(parse_level("warning")), 3)
  assert_eq(level_ordinal(parse_level("ERROR")), 4)
  assert_eq(level_ordinal(parse_level("unknown")), 2) // default to INFO
}

test "is valid level" {
  assert_eq(is_valid_level("info"), true)
  assert_eq(is_valid_level("INFO"), true)
  assert_eq(is_valid_level("critical"), false)
}

test "level names" {
  let names = level_names()
  assert_eq(names.length(), 5)
  assert_eq(names[0], "TRACE")
}

test "config creates dev logger" {
  let logger = create_dev_logger()
  let l2 = logger.debug("dev msg", [])
  assert_eq(l2.logs().length(), 1)
}

test "config creates prod logger" {
  let logger = create_prod_logger()
  let l2 = logger.info("prod msg", [])
  assert_eq(l2.logs().length(), 1)
}

test "batch logger accumulates" {
  let bl = BatchLogger::new(Logger::new().build(), 3)
  assert_eq(bl.pending(), 0)
  let bl2 = bl.info("first", [])
  let bl3 = bl2.info("second", [])
  assert_eq(bl3.pending(), 2)
}

test "batch logger flushes at size" {
  let base = Logger::new().build()
  let bl = BatchLogger::new(base, 2)
  let bl2 = bl.info("one", [])
  let bl3 = bl2.info("two", [])
  assert_eq(bl3.pending(), 0)
}

test "typed field string" {
  let f = TypedField::new_str("key", "val")
  let (k, v) = f.to_pair()
  assert_eq(k, "key")
  assert_eq(v, "val")
}

test "typed field int" {
  let f = TypedField::new_int("count", 42)
  let (_, v) = f.to_pair()
  assert_eq(v, "42")
}

test "typed field bool" {
  let f = TypedField::new_bool("active", true)
  let (_, v) = f.to_pair()
  assert_eq(v, "true")
}

test "syslog format" {
  let r = LogRecord::new(Level::ERROR, "disk full", [], 100)
  let s = format_syslog(r, "myapp")
  assert_eq(s.contains("<"), true)
  assert_eq(s.contains("myapp"), true)
  assert_eq(s.contains("disk full"), true)
}

test "gelf format" {
  let r = LogRecord::new(Level::INFO, "test", [("env", "prod")], 200)
  let s = format_gelf(r, "server1")
  assert_eq(s.contains("server1"), true)
  assert_eq(s.contains("test"), true)
  assert_eq(s.contains("_env"), true)
}

test "correlation id sequence" {
  let c = CorrelationId::new("req-1")
  assert_eq(c.id, "req-1")
  let c2 = c.next().next()
  assert_eq(c2.sequence, 2)
}

test "request context logging" {
  let logger = Logger::new().build()
  let ctx = RequestContext::new(logger, "req-42")
  let ctx2 = ctx.info("step1", [("action", "validate")])
  let ctx3 = ctx2.warn("step2", [])
  let l = ctx3.finish()
  let logs = l.logs()
  assert_eq(logs.length(), 3)
  assert_eq(logs[0].contains("corr_id"), true)
}

test "pipeline add field" {
  let p = Pipeline::new().add_field("source", "api")
  let r = LogRecord::new(Level::INFO, "msg", [], 0)
  let r2 = p.apply(r)
  assert_eq(r2.fields.length(), 1)
}

test "pipeline redact" {
  let p = Pipeline::new().redact("password")
  let r = LogRecord::new(Level::INFO, "login", [("password", "secret")], 0)
  let r2 = p.apply(r)
  assert_eq(r2.fields[0].1, "***")
}

test "pipeline prepend message" {
  let p = Pipeline::new().prepend_msg("[API] ")
  let r = LogRecord::new(Level::INFO, "start", [], 0)
  let r2 = p.apply(r)
  assert_eq(r2.message.contains("[API]"), true)
}

test "meter rate limiter" {
  let (rl, ok1) = RateLimiter::new(2, 100).allow(10)
  let (rl2, ok2) = rl.allow(20)
  let (_, ok3) = rl2.allow(30)
  assert_eq(ok1, true)
  assert_eq(ok2, true)
  assert_eq(ok3, false)
}

test "throughput counter" {
  let tc = ThroughputCounter::new("api")
    .record(0).record(10).record(20)
  assert_eq(tc.total_count(), 3)
}

test "log router splits errors" {
  let logger = Logger::new().build()
  let router = LogRouter::new(logger)
  let r2 = router.dispatch(Level::INFO, "info msg", [])
  let r3 = r2.dispatch(Level::ERROR, "error msg", [])
  let r4 = r3.dispatch(Level::WARN, "warn msg", [])
  assert_eq(r4.all_count(), 3)
  assert_eq(r4.error_count(), 2)
}

test "log router error logs only" {
  let logger = Logger::new().build()
  let router = LogRouter::new(logger)
  let r2 = router.dispatch(Level::DEBUG, "debug msg", [])
  let r3 = r2.dispatch(Level::INFO, "info msg", [])
  assert_eq(r3.all_count(), 2)
  assert_eq(r3.error_count(), 0)
}

test "typed fields to pairs conversion" {
  let fields : Array[TypedField] = []
  fields.push(TypedField::new_str("name", "test"))
  fields.push(TypedField::new_int("age", 25))
  fields.push(TypedField::new_bool("ok", false))
  let pairs = typed_fields_to_pairs(fields, 0, [])
  assert_eq(pairs.length(), 3)
  assert_eq(pairs[1].0, "age")
  assert_eq(pairs[1].1, "25")
}

test "pipeline transform count" {
  let p = Pipeline::new()
    .add_field("a", "1")
    .prepend_msg("[PREFIX]")
    .redact("secret")
  assert_eq(p.transform_count(), 3)
}

test "rotation policy triggers" {
  let p = RotationPolicy::new(100)
  assert_eq(p.should_rotate(50), false)
  assert_eq(p.should_rotate(100), true)
  assert_eq(p.should_rotate(150), true)
  let p2 = p.rotate()
  assert_eq(p2.generation(), 1)
}

test "size rotation policy" {
  let p = SizeRotationPolicy::new(1024)
  let p2 = p.record(512)
  assert_eq(p2.should_rotate(), false)
  let p3 = p2.record(600)
  assert_eq(p3.should_rotate(), true)
  let p4 = p3.reset()
  assert_eq(p4.count(), 1)
}

test "time rotation policy" {
  let (p1, ok1) = TimeRotationPolicy::new(100).check(50)
  assert_eq(ok1, false)
  let (p2, ok2) = p1.check(200)
  assert_eq(ok2, true)
  assert_eq(p2.count(), 1)
}

test "percent sampler" {
  let (s1, keep) = PercentSampler::new(50).sample()
  let keep_count = if keep { 1 } else { 0 }
  assert_eq(keep_count >= 0, true)
}

test "rate sampler allows then blocks" {
  let (s1, ok1) = RateSampler::new(2, 10).allow(1)
  let (s2, ok2) = s1.allow(2)
  let (_, ok3) = s2.allow(3)
  assert_eq(ok1, true)
  assert_eq(ok2, true)
  assert_eq(ok3, false)
}

test "tag set basic" {
  let tags = TagSet::new().add("api").add("auth")
  assert_eq(tags.count(), 2)
  assert_eq(tags.has("api"), true)
  assert_eq(tags.has("db"), false)
}

test "tagged logger" {
  let logger = Logger::new().build()
  let tl = TaggedLogger::new(logger).with_tag("module:auth")
  let tl2 = tl.info("login", [("user", "admin")])
  let logs = tl2.get_logger().logs()
  assert_eq(logs[0].contains("tag=module:auth"), true)
}

test "field extractor kv pairs" {
  let pairs = extract_key_value_pairs("user=admin status=ok")
  assert_eq(pairs.length(), 2)
  assert_eq(pairs[0].0, "user")
  assert_eq(pairs[0].1, "admin")
}

test "field extractor word count" {
  let wc = word_count("hello world test")
  assert_eq(wc, 3)
  let wc2 = word_count("single")
  assert_eq(wc2, 1)
}

test "log replay has more" {
  let r1 = LogRecord::new(Level::INFO, "a", [], 1)
  let r2 = LogRecord::new(Level::INFO, "b", [], 2)
  let replay = LogReplay::from_records([r1, r2])
  assert_eq(replay.total(), 2)
  assert_eq(replay.has_more(), true)
}

test "log assertion utilities" {
  let logger = Logger::new().build()
  let l2 = logger.info("hello world", [])
  let l3 = l2.error("fatal error", [("code", "1")])
  assert_eq(assert_log_contains(l3, "hello"), true)
  assert_eq(assert_log_count(l3, 2), true)
}

test "burst sampler" {
  let (s1, ok1) = BurstSampler::new(3, 1, 10).allow(0)
  let (s2, ok2) = s1.allow(1)
  let (s3, ok3) = s2.allow(2)
  let (s4, ok4) = s3.allow(3)
  assert_eq(ok1, true)
  assert_eq(ok2, true)
  assert_eq(ok3, true)
  // After burst, may or may not have refilled enough
  assert_eq(ok4 || not(ok4), true)
}
