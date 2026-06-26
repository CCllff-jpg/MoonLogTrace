// Blackbox tests — end-to-end logging workflow verification

test "full logging workflow" {
  let logger = @MoonLogTrace.Logger::new()
    .level(@MoonLogTrace.Level::INFO)
    .console()
    .build()
  let l2 = logger.info("App started", [("version", "1.0")])
  let l3 = l2.warn("Disk usage", [("pct", "85")])
  let l4 = l3.error("Crash", [("signal", "11")])
  let logs = l4.logs()
  assert_eq(logs.length(), 3)
  assert_eq(logs[0].contains("App started"), true)
  assert_eq(logs[1].contains("Disk usage"), true)
  assert_eq(logs[2].contains("Crash"), true)
}

test "span tracing workflow" {
  let logger = @MoonLogTrace.Logger::new().build()
  let (l2, span) = @MoonLogTrace.Span::enter(logger, "request", [("method", "GET")])
  let l3 = span.exit(l2)
  assert_eq(l3.logs().length(), 2)
}
