// Log rotation — automatic log file/count management

pub(all) struct RotationPolicy {
  max_entries : Int
  rotation_count : Int
  current_index : Int
}

pub fn RotationPolicy::new(max_entries : Int) -> RotationPolicy {
  RotationPolicy::{ max_entries, rotation_count: 0, current_index: 0 }
}

pub fn RotationPolicy::should_rotate(self : RotationPolicy, current_count : Int) -> Bool {
  current_count >= self.max_entries
}

pub fn RotationPolicy::rotate(self : RotationPolicy) -> RotationPolicy {
  RotationPolicy::{
    ..self,
    rotation_count: self.rotation_count + 1,
    current_index: self.current_index + 1,
  }
}

pub fn RotationPolicy::generation(self : RotationPolicy) -> Int {
  self.current_index
}

// Size-based rotation trigger
pub(all) struct SizeRotationPolicy {
  max_bytes : Int
  current_bytes : Int
  rotation_count : Int
}

pub fn SizeRotationPolicy::new(max_bytes : Int) -> SizeRotationPolicy {
  SizeRotationPolicy::{ max_bytes, current_bytes: 0, rotation_count: 0 }
}

pub fn SizeRotationPolicy::record(self : SizeRotationPolicy, bytes : Int) -> SizeRotationPolicy {
  let new_total = self.current_bytes + bytes
  SizeRotationPolicy::{ ..self, current_bytes: new_total }
}

pub fn SizeRotationPolicy::should_rotate(self : SizeRotationPolicy) -> Bool {
  self.current_bytes >= self.max_bytes
}

pub fn SizeRotationPolicy::reset(self : SizeRotationPolicy) -> SizeRotationPolicy {
  SizeRotationPolicy::{
    ..self,
    current_bytes: 0,
    rotation_count: self.rotation_count + 1,
  }
}

pub fn SizeRotationPolicy::count(self : SizeRotationPolicy) -> Int {
  self.rotation_count
}

// Time-based rotation (simple tick-based)
pub(all) struct TimeRotationPolicy {
  max_ticks : Int
  last_rotate_tick : Int
  rotation_count : Int
}

pub fn TimeRotationPolicy::new(max_ticks : Int) -> TimeRotationPolicy {
  TimeRotationPolicy::{ max_ticks, last_rotate_tick: 0, rotation_count: 0 }
}

pub fn TimeRotationPolicy::check(self : TimeRotationPolicy, current_tick : Int) -> (TimeRotationPolicy, Bool) {
  let elapsed = current_tick - self.last_rotate_tick
  if elapsed >= self.max_ticks {
    (TimeRotationPolicy::{
      ..self,
      last_rotate_tick: current_tick,
      rotation_count: self.rotation_count + 1,
    }, true)
  } else {
    (self, false)
  }
}

pub fn TimeRotationPolicy::count(self : TimeRotationPolicy) -> Int {
  self.rotation_count
}
