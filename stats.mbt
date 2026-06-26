// Performance counters and statistics tracking

pub(all) struct Counter {
  name : String
  value : Int
}

pub fn Counter::new(name : String) -> Counter {
  Counter::{ name, value: 0 }
}

pub fn Counter::increment(self : Counter) -> Counter {
  Counter::{ ..self, value: self.value + 1 }
}

pub fn Counter::add(self : Counter, n : Int) -> Counter {
  Counter::{ ..self, value: self.value + n }
}

pub fn Counter::read(self : Counter) -> Int { self.value }

// Timer — measure elapsed ticks between start and stop
pub(all) struct Timer {
  name : String
  start_seq : Int
}

pub fn Timer::start(name : String, current_seq : Int) -> Timer {
  Timer::{ name, start_seq: current_seq }
}

pub fn Timer::stop(self : Timer, current_seq : Int) -> (String, Int) {
  (self.name, current_seq - self.start_seq)
}

// Histogram — track distribution of values
pub(all) struct Histogram {
  name : String
  values : Array[Int]
}

pub fn Histogram::new(name : String) -> Histogram {
  Histogram::{ name, values: [] }
}

pub fn Histogram::record(self : Histogram, value : Int) -> Histogram {
  let new_values = self.values
  new_values.push(value)
  Histogram::{ ..self, values: new_values }
}

pub fn Histogram::count(self : Histogram) -> Int { self.values.length() }

pub fn Histogram::sum(self : Histogram) -> Int {
  histo_sum(self.values, 0, 0)
}

fn histo_sum(values : Array[Int], idx : Int, acc : Int) -> Int {
  if idx >= values.length() { acc }
  else { histo_sum(values, idx + 1, acc + values[idx]) }
}

pub fn Histogram::avg(self : Histogram) -> Int {
  if self.values.length() == 0 { 0 }
  else { self.sum() / self.values.length() }
}

pub fn Histogram::min_val(self : Histogram) -> Int {
  histo_min(self.values, 0, 2147483647)
}

fn histo_min(values : Array[Int], idx : Int, cur_min : Int) -> Int {
  if idx >= values.length() { cur_min }
  else if values[idx] < cur_min { histo_min(values, idx + 1, values[idx]) }
  else { histo_min(values, idx + 1, cur_min) }
}

pub fn Histogram::max_val(self : Histogram) -> Int {
  histo_max(self.values, 0, 0)
}

fn histo_max(values : Array[Int], idx : Int, cur_max : Int) -> Int {
  if idx >= values.length() { cur_max }
  else if values[idx] > cur_max { histo_max(values, idx + 1, values[idx]) }
  else { histo_max(values, idx + 1, cur_max) }
}
