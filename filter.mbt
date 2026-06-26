// Advanced filtering for log records

pub(all) struct LevelFilter {
  threshold : Level
}

pub fn LevelFilter::new(threshold : Level) -> LevelFilter {
  LevelFilter::{ threshold }
}

pub fn LevelFilter::check(self : LevelFilter, level : Level) -> Bool {
  level_ordinal(level) >= level_ordinal(self.threshold)
}

// Filter by message substring match
pub(all) struct MessageFilter {
  substring : String
}

pub fn MessageFilter::new(substring : String) -> MessageFilter {
  MessageFilter::{ substring }
}

pub fn MessageFilter::check(self : MessageFilter, record : LogRecord) -> Bool {
  record.message.contains(self.substring)
}

// Filter by field key-value match
pub(all) struct FieldFilter {
  key : String
  value : String
}

pub fn FieldFilter::new(key : String, value : String) -> FieldFilter {
  FieldFilter::{ key, value }
}

pub fn FieldFilter::check(self : FieldFilter, record : LogRecord) -> Bool {
  field_matches(record.fields, self.key, self.value, 0)
}

fn field_matches(fields : Array[(String, String)], key : String, value : String, idx : Int) -> Bool {
  if idx >= fields.length() { false }
  else {
    let (k, v) = fields[idx]
    if k == key && v == value { true }
    else { field_matches(fields, key, value, idx + 1) }
  }
}

// Allow-list filter: only log if level is in the allowed set
pub(all) struct AllowListFilter {
  allowed : Array[Level]
}

pub fn AllowListFilter::new(allowed : Array[Level]) -> AllowListFilter {
  AllowListFilter::{ allowed }
}

pub fn AllowListFilter::check(self : AllowListFilter, level : Level) -> Bool {
  level_in_list(self.allowed, level, 0)
}

fn level_in_list(allowed : Array[Level], level : Level, idx : Int) -> Bool {
  if idx >= allowed.length() { false }
  else if level_ordinal(allowed[idx]) == level_ordinal(level) { true }
  else { level_in_list(allowed, level, idx + 1) }
}

// Deny-list filter: exclude specific levels
pub(all) struct DenyListFilter {
  denied : Array[Level]
}

pub fn DenyListFilter::new(denied : Array[Level]) -> DenyListFilter {
  DenyListFilter::{ denied }
}

pub fn DenyListFilter::check(self : DenyListFilter, level : Level) -> Bool {
  not(level_in_list(self.denied, level, 0))
}
