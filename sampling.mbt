// Log sampling — reduce log volume while keeping valuable data

pub(all) struct PercentSampler {
  rate : Int   // 0-100, percentage of logs to keep
  counter : Int
}

pub fn PercentSampler::new(rate : Int) -> PercentSampler {
  PercentSampler::{ rate, counter: 0 }
}

pub fn PercentSampler::sample(self : PercentSampler) -> (PercentSampler, Bool) {
  let next = self.counter + 1
  let keep = (next % 100) < self.rate
  (PercentSampler::{ ..self, counter: next }, keep)
}

// Rate-limited sampler — at most N logs per time window
pub(all) struct RateSampler {
  max_per_window : Int
  window_size : Int
  events : Array[Int]
}

pub fn RateSampler::new(max_per_window : Int, window_size : Int) -> RateSampler {
  RateSampler::{ max_per_window, window_size, events: [] }
}

pub fn RateSampler::allow(self : RateSampler, tick : Int) -> (RateSampler, Bool) {
  let cutoff = tick - self.window_size
  let trimmed = trim_old_events(self.events, cutoff, 0, [])
  if trimmed.length() < self.max_per_window {
    let new_events = trimmed
    new_events.push(tick)
    (RateSampler::{ ..self, events: new_events }, true)
  } else {
    (RateSampler::{ ..self, events: trimmed }, false)
  }
}

fn trim_old_events(src : Array[Int], cutoff : Int, idx : Int, result : Array[Int]) -> Array[Int] {
  if idx >= src.length() { result }
  else if src[idx] >= cutoff {
    result.push(src[idx])
    trim_old_events(src, cutoff, idx + 1, result)
  } else {
    trim_old_events(src, cutoff, idx + 1, result)
  }
}

pub fn RateSampler::count(self : RateSampler) -> Int {
  self.events.length()
}

// Burst sampler — allow bursts up to N, then throttle
pub(all) struct BurstSampler {
  max_burst : Int
  sustained_rate : Int
  window_size : Int
  bucket : Int
  last_refill : Int
}

pub fn BurstSampler::new(max_burst : Int, sustained_rate : Int, window_size : Int) -> BurstSampler {
  BurstSampler::{ max_burst, sustained_rate, window_size, bucket: max_burst, last_refill: 0 }
}

pub fn BurstSampler::allow(self : BurstSampler, tick : Int) -> (BurstSampler, Bool) {
  // Refill tokens
  let elapsed = tick - self.last_refill
  let new_tokens = elapsed * self.sustained_rate / self.window_size
  let refilled = if self.bucket + new_tokens > self.max_burst {
    self.max_burst
  } else {
    self.bucket + new_tokens
  }

  if refilled > 0 {
    (BurstSampler::{
      ..self,
      bucket: refilled - 1,
      last_refill: tick,
    }, true)
  } else {
    (BurstSampler::{ ..self, bucket: 0, last_refill: tick }, false)
  }
}
