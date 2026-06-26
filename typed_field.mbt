// Typed field values — beyond String:String pairs

pub(all) enum FieldValue {
  Str(String)
  IntVal(Int)
  FloatVal(Float)
  BoolVal(Bool)
}

pub fn field_value_to_string(v : FieldValue) -> String {
  match v {
    FieldValue::Str(s) => s
    FieldValue::IntVal(i) => i.to_string()
    FieldValue::FloatVal(f) => f.to_string()
    FieldValue::BoolVal(b) => if b { "true" } else { "false" }
  }
}

pub(all) struct TypedField {
  key : String
  value : FieldValue
}

pub fn TypedField::new_str(key : String, v : String) -> TypedField {
  TypedField::{ key, value: FieldValue::Str(v) }
}

pub fn TypedField::new_int(key : String, v : Int) -> TypedField {
  TypedField::{ key, value: FieldValue::IntVal(v) }
}

pub fn TypedField::new_float(key : String, v : Float) -> TypedField {
  TypedField::{ key, value: FieldValue::FloatVal(v) }
}

pub fn TypedField::new_bool(key : String, v : Bool) -> TypedField {
  TypedField::{ key, value: FieldValue::BoolVal(v) }
}

pub fn TypedField::to_pair(self : TypedField) -> (String, String) {
  (self.key, field_value_to_string(self.value))
}

// Convert typed fields to string pairs
pub fn typed_fields_to_pairs(fields : Array[TypedField], idx : Int, result : Array[(String, String)]) -> Array[(String, String)] {
  if idx >= fields.length() { result }
  else {
    let (k, v) = fields[idx].to_pair()
    result.push((k, v))
    typed_fields_to_pairs(fields, idx + 1, result)
  }
}
