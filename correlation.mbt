// Correlation ID — trace a request across multiple log entries

pub(all) struct CorrelationId {
  id : String
  sequence : Int
}

pub fn CorrelationId::new(id : String) -> CorrelationId {
  CorrelationId::{ id, sequence: 0 }
}

// Generate a unique-ish ID from a prefix and sequence number
pub fn CorrelationId::generate(prefix : String, seq : Int) -> CorrelationId {
  CorrelationId::{ id: prefix + "-" + seq.to_string(), sequence: 0 }
}

pub fn CorrelationId::next(self : CorrelationId) -> CorrelationId {
  CorrelationId::{ ..self, sequence: self.sequence + 1 }
}

pub fn CorrelationId::to_field(self : CorrelationId, key : String) -> (String, String) {
  let value = self.id + "[" + self.sequence.to_string() + "]"
  (key, value)
}

// Attach correlation ID to log fields
pub fn with_correlation(fields : Array[(String, String)], corr : CorrelationId, key : String) -> Array[(String, String)] {
  let new_fields = fields
  new_fields.push(corr.to_field(key))
  new_fields
}

// RequestContext — combines LogContext + CorrelationId + Span tracking
pub(all) struct RequestContext {
  context : LogContext
  correlation : CorrelationId
  logger : Logger
}

pub fn RequestContext::new(logger : Logger, request_id : String) -> RequestContext {
  let corr = CorrelationId::new(request_id)
  let ctx = LogContext::new().add("trace_id", request_id)
  RequestContext::{ context: ctx, correlation: corr, logger }
}

pub fn RequestContext::with_field(self : RequestContext, key : String, value : String) -> RequestContext {
  RequestContext::{ ..self, context: self.context.add(key, value) }
}

pub fn RequestContext::info(self : RequestContext, msg : String, fields : Array[(String, String)]) -> RequestContext {
  let next_corr = self.correlation.next()
  let merged = self.context.merge(fields)
  let with_corr = with_correlation(merged, next_corr, "corr_id")
  let new_logger = self.logger.info(msg, with_corr)
  RequestContext::{ ..self, correlation: next_corr, logger: new_logger }
}

pub fn RequestContext::warn(self : RequestContext, msg : String, fields : Array[(String, String)]) -> RequestContext {
  let next_corr = self.correlation.next()
  let merged = self.context.merge(fields)
  let with_corr = with_correlation(merged, next_corr, "corr_id")
  let new_logger = self.logger.warn(msg, with_corr)
  RequestContext::{ ..self, correlation: next_corr, logger: new_logger }
}

pub fn RequestContext::error(self : RequestContext, msg : String, fields : Array[(String, String)]) -> RequestContext {
  let next_corr = self.correlation.next()
  let merged = self.context.merge(fields)
  let with_corr = with_correlation(merged, next_corr, "corr_id")
  let new_logger = self.logger.error(msg, with_corr)
  RequestContext::{ ..self, correlation: next_corr, logger: new_logger }
}

pub fn RequestContext::finish(self : RequestContext) -> Logger {
  self.logger.info("Request complete", [("trace_id", self.correlation.id), ("total_steps", self.correlation.sequence.to_string())])
}
