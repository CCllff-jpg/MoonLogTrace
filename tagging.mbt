// Tagged logging — categorize logs by module/feature tags

pub(all) struct TagSet {
  tags : Array[String]
}

pub fn TagSet::new() -> TagSet {
  TagSet::{ tags: [] }
}

pub fn TagSet::add(self : TagSet, tag : String) -> TagSet {
  let new_tags = self.tags
  new_tags.push(tag)
  TagSet::{ ..self, tags: new_tags }
}

pub fn TagSet::has(self : TagSet, tag : String) -> Bool {
  tag_in_set(self.tags, tag, 0)
}

fn tag_in_set(tags : Array[String], target : String, idx : Int) -> Bool {
  if idx >= tags.length() { false }
  else if tags[idx] == target { true }
  else { tag_in_set(tags, target, idx + 1) }
}

pub fn TagSet::to_fields(self : TagSet) -> Array[(String, String)] {
  tags_to_fields(self.tags, 0, [])
}

fn tags_to_fields(tags : Array[String], idx : Int, result : Array[(String, String)]) -> Array[(String, String)] {
  if idx >= tags.length() { result }
  else {
    result.push(("tag", tags[idx]))
    tags_to_fields(tags, idx + 1, result)
  }
}

pub fn TagSet::count(self : TagSet) -> Int {
  self.tags.length()
}

// Tagged logger — wraps Logger with a TagSet for automatic tag attachment
pub(all) struct TaggedLogger {
  logger : Logger
  tags : TagSet
}

pub fn TaggedLogger::new(logger : Logger) -> TaggedLogger {
  TaggedLogger::{ logger, tags: TagSet::new() }
}

pub fn TaggedLogger::with_tag(self : TaggedLogger, tag : String) -> TaggedLogger {
  TaggedLogger::{ ..self, tags: self.tags.add(tag) }
}

pub fn TaggedLogger::info(self : TaggedLogger, msg : String, fields : Array[(String, String)]) -> TaggedLogger {
  let merged = merge_fields(self.tags.to_fields(), fields, 0)
  let new_logger = self.logger.info(msg, merged)
  TaggedLogger::{ ..self, logger: new_logger }
}

fn merge_fields(tag_fields : Array[(String, String)], user_fields : Array[(String, String)], idx : Int) -> Array[(String, String)] {
  if idx >= tag_fields.length() { user_fields }
  else {
    let field = tag_fields[idx]
    let new_user = user_fields
    new_user.push(field)
    merge_fields(tag_fields, new_user, idx + 1)
  }
}

pub fn TaggedLogger::warn(self : TaggedLogger, msg : String, fields : Array[(String, String)]) -> TaggedLogger {
  let merged = merge_fields(self.tags.to_fields(), fields, 0)
  let new_logger = self.logger.warn(msg, merged)
  TaggedLogger::{ ..self, logger: new_logger }
}

pub fn TaggedLogger::error(self : TaggedLogger, msg : String, fields : Array[(String, String)]) -> TaggedLogger {
  let merged = merge_fields(self.tags.to_fields(), fields, 0)
  let new_logger = self.logger.error(msg, merged)
  TaggedLogger::{ ..self, logger: new_logger }
}

pub fn TaggedLogger::get_logger(self : TaggedLogger) -> Logger {
  self.logger
}
