// Simple timestamp formatting utility.
// MoonBit has no system clock access, so timestamps are
// user-provided integers (e.g. monotonic sequence counters).

pub fn format_timestamp(ts : Int) -> String {
  "[" + ts.to_string() + "]"
}
