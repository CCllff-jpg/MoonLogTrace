// Whitebox tests run within the package scope.
// Use them to validate internal helpers or invariants.
// Keep them focused; public behavior belongs in `_test.mbt`.

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
