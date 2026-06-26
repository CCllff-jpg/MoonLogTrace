// Event meter — tracks event rates over time windows

pub(all) struct EventMeter {
  name : String
  events : Array[Int]   // timestamps of events
  window_size : Int     // size of sliding window
}

pub fn EventMeter::new(name : String, window_size : Int) -> EventMeter {
  EventMeter::{ name, events: [], window_size }
}

pub fn EventMeter::record(self : EventMeter, ts : Int) -> EventMeter {
  let new_events = self.events
  new_events.push(ts)
  // Trim events outside window
  let cutoff = ts - self.window_size
  let trimmed = trim_events(new_events, cutoff, 0, [])
  EventMeter::{ ..self, events: trimmed }
}

fn trim_events(src : Array[Int], cutoff : Int, idx : Int, result : Array[Int]) -> Array[Int] {
  if idx >= src.length() { result }
  else if src[idx] >= cutoff {
    // All remaining are within window
    copy_remaining(src, idx, result)
  } else {
    trim_events(src, cutoff, idx + 1, result)
  }
}

fn copy_remaining(src : Array[Int], idx : Int, result : Array[Int]) -> Array[Int] {
  if idx >= src.length() { result }
  else {
    result.push(src[idx])
    copy_remaining(src, idx + 1, result)
  }
}

pub fn EventMeter::count(self : EventMeter) -> Int {
  self.events.length()
}

pub fn EventMeter::rate(self : EventMeter) -> Int {
  // Events per window_size ticks
  self.events.length()
}

// Rate limiter — allows up to N events per window
pub(all) struct RateLimiter {
  max_per_window : Int
  meter : EventMeter
}

pub fn RateLimiter::new(max_per_window : Int, window_size : Int) -> RateLimiter {
  RateLimiter::{ max_per_window, meter: EventMeter::new("limiter", window_size) }
}

pub fn RateLimiter::allow(self : RateLimiter, ts : Int) -> (RateLimiter, Bool) {
  let new_meter = self.meter.record(ts)
  let allowed = new_meter.count() <= self.max_per_window
  (RateLimiter::{ ..self, meter: new_meter }, allowed)
}

// Throughput counter — counts total events and computes average rate
pub(all) struct ThroughputCounter {
  name : String
  total : Int
  first_ts : Int
  last_ts : Int
}

pub fn ThroughputCounter::new(name : String) -> ThroughputCounter {
  ThroughputCounter::{ name, total: 0, first_ts: 0, last_ts: 0 }
}

pub fn ThroughputCounter::record(self : ThroughputCounter, ts : Int) -> ThroughputCounter {
  if self.total == 0 {
    ThroughputCounter::{ name: self.name, total: 1, first_ts: ts, last_ts: ts }
  } else {
    ThroughputCounter::{ ..self, total: self.total + 1, last_ts: ts }
  }
}

pub fn ThroughputCounter::avg_rate(self : ThroughputCounter) -> Int {
  let duration = self.last_ts - self.first_ts
  if duration <= 0 { 0 }
  else { self.total / duration }
}

pub fn ThroughputCounter::total_count(self : ThroughputCounter) -> Int {
  self.total
}
