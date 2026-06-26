// MoonLogTrace — Structured Logging & Tracing Library for MoonBit
//
// ## Quick Start
//
//   let logger = Logger::new()
//     .level(Level::INFO)
//     .console()
//     .build()
//   let l2 = logger.info("Server started", [("port", "8080")])
//   let l3 = l2.warn("Slow query", [("duration_ms", "230")])
//
//   // Span tracing
//   let (l4, span) = Span::enter(l3, "db_query", [("table", "users")])
//   let l5 = span.exit(l4)
//
// Supports 5 log levels, Console/Memory appenders, Text/JSON formatting,
// level filtering, and Span-based tracing with elapsed time tracking.
