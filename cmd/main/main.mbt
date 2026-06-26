fn main {
  println("=== MoonLogTrace Demo ===\n")

  // 1. Basic logging
  println("--- 1. Basic Logging ---")
  let logger = @MoonLogTrace.Logger::new().console().build()
  let l2 = logger.info("App started", [("version", "0.1.0")])
  let l3 = l2.warn("High CPU", [("pct", "92")])
  let _ = l3.error("Crash", [("code", "500")])

  // 2. Level filtering
  println("\n--- 2. Level Filtering ---")
  let fl = @MoonLogTrace.Logger::new()
    .level(@MoonLogTrace.Level::WARN).console().build()
  let _ = fl.info("FILTERED", [])
  let _ = fl.warn("VISIBLE", [])

  // 3. Context
  println("\n--- 3. Context ---")
  let cl = @MoonLogTrace.Logger::new()
    .add_context("env", "demo")
    .console()
    .build()
  let _ = cl.info("With context", [("user", "admin")])

  // 4. Span tracing
  println("\n--- 4. Span Tracing ---")
  let sl = @MoonLogTrace.Logger::new().console().build()
  let (l4, outer) = @MoonLogTrace.Span::enter(sl, "handle_request", [])
  let (l5, inner) = @MoonLogTrace.Span::enter(l4, "db_query", [("table", "users")])
  let l6 = inner.exit(l5)
  let _ = outer.exit(l6)

  // 5. Config presets
  println("\n--- 5. Config Presets ---")
  let dev = @MoonLogTrace.create_dev_logger()
  let d2 = dev.info("dev mode logging", [])
  println("Dev logger entries: " + d2.logs().length().to_string())

  // 6. Counters
  println("\n--- 6. Counter ---")
  let c = @MoonLogTrace.Counter::new("requests")
    .increment().increment().add(3)
  println("requests: " + c.read().to_string())

  println("\n=== All 6 demos complete ===")
}
