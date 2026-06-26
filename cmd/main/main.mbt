fn main {
  println("=== MoonLogTrace Demo ===\n")

  // Basic logging
  println("--- Basic Logging ---")
  let logger = @MoonLogTrace.Logger::new().console().build()
  let l2 = logger.info("App started", [("version", "0.1.0")])
  let l3 = l2.warn("High CPU", [("pct", "92")])
  let _ = l3.error("Crash", [("code", "500")])

  // Level filtering
  println("\n--- Level Filtering ---")
  let f_logger = @MoonLogTrace.Logger::new().level(@MoonLogTrace.Level::WARN).console().build()
  let _ = f_logger.info("FILTERED - should not appear", [])
  let _ = f_logger.warn("VISIBLE - should appear", [])

  // Context
  println("\n--- Context ---")
  let c_logger = @MoonLogTrace.Logger::new()
    .add_context("app", "demo")
    .console()
    .build()
  let _ = c_logger.info("With context", [("user", "admin")])

  // Span tracing
  println("\n--- Span Tracing ---")
  let s_logger = @MoonLogTrace.Logger::new().console().build()
  let (l4, span) = @MoonLogTrace.Span::enter(s_logger, "work", [])
  let _ = span.exit(l4)

  println("\n=== Done ===")
}
