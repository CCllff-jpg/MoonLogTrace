pub(all) struct Span {
  name : String
  fields : Array[(String, String)]
  start_seq : Int
}

pub fn Span::enter(logger : Logger, name : String, fields : Array[(String, String)]) -> (Logger, Span) {
  let l2 = logger.info("-> " + name, fields)
  let span = Span::{ name, fields, start_seq: l2.seq }
  (l2, span)
}

pub fn Span::exit(self : Span, logger : Logger) -> Logger {
  let elapsed = logger.seq - self.start_seq
  let exit_fields : Array[(String, String)] = []
  for i = 0; i < self.fields.length(); i = i + 1 {
    exit_fields.push(self.fields[i])
  }
  exit_fields.push(("duration", elapsed.to_string() + "ticks"))
  logger.info("<- " + self.name, exit_fields)
}
