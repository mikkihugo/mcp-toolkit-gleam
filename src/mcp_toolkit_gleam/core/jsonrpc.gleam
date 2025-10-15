//// Vendored JSON-RPC implementation compatible with gleam_json 3.0+
//// Based on jsonrpc 1.0.0 package
////
//// JSON-RPC is a stateless, light-weight remote procedure call (RPC) protocol.
//// This implementation provides the core types and functions needed for MCP.

import gleam/dynamic/decode.{type Decoder, type Dynamic}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}

/// A union of the JSON-RPC message types.
pub type Message {
  RequestMessage(Request(Dynamic))
  NotificationMessage(Notification(Dynamic))
  ResponseMessage(Response(Dynamic))
  ErrorResponseMessage(ErrorResponse(Dynamic))
}

pub fn message_decoder() -> Decoder(Message) {
  let request = request_decoder(decode.dynamic) |> decode.map(RequestMessage)
  let notification =
    notification_decoder(decode.dynamic) |> decode.map(NotificationMessage)
  let response = response_decoder(decode.dynamic) |> decode.map(ResponseMessage)
  let error_response =
    error_response_decoder(decode.dynamic) |> decode.map(ErrorResponseMessage)

  decode.one_of(request, [notification, response, error_response])
}

/// Specifies the version of the JSON-RPC protocol. Only 2.0 is supported.
pub type Version {
  V2
}

pub fn version_to_json(_version: Version) -> Json {
  json.string("2.0")
}

pub fn version_decoder() -> Decoder(Version) {
  use v <- decode.then(decode.string)
  case v {
    "2.0" -> decode.success(V2)
    _ -> decode.failure(V2, "unsupported JSON-RPC version: " <> v)
  }
}

/// An identifier established by the Client that MUST contain a String, Number,
/// or NULL value. The value SHOULD normally not be Null.
pub type Id {
  StringId(String)
  IntId(Int)
  NullId
}

/// Creates an Int ID
pub fn id(id: Int) -> Id {
  IntId(id)
}

pub fn id_to_json(id: Id) -> Json {
  case id {
    IntId(id) -> json.int(id)
    NullId -> json.null()
    StringId(id) -> json.string(id)
  }
}

pub fn id_decoder() -> Decoder(Id) {
  let string_decoder = decode.string |> decode.map(StringId)
  let others =
    decode.optional(decode.int |> decode.map(IntId))
    |> decode.map(option.unwrap(_, NullId))

  decode.one_of(string_decoder, [others])
}

/// An RPC call to a server
pub type Request(params) {
  Request(
    /// Specifies the version of the JSON-RPC protocol. MUST be exactly "2.0".
    jsonrpc: Version,
    /// A String containing the name of the method to be invoked.
    method: String,
    /// An identifier established by the Client.
    id: Id,
    /// Parameter values to be used during the invocation of the method.
    params: Option(params),
  )
}

/// Creates a new request with empty params
pub fn request(method method: String, id id: Id) -> Request(params) {
  Request(jsonrpc: V2, method:, id:, params: None)
}

pub fn request_to_json(
  request: Request(params),
  encode_params: fn(params) -> Json,
) -> Json {
  let Request(jsonrpc:, method:, id:, params:) = request
  let params = case params {
    Some(params) -> [#("params", encode_params(params))]
    None -> []
  }
  json.object([
    #("jsonrpc", version_to_json(jsonrpc)),
    #("method", json.string(method)),
    #("id", id_to_json(id)),
    ..params
  ])
}

pub fn request_decoder(
  params_decoder: Decoder(params),
) -> Decoder(Request(params)) {
  use jsonrpc <- decode.field("jsonrpc", version_decoder())
  use method <- decode.field("method", decode.string)
  use id <- decode.field("id", id_decoder())
  use params <- decode.optional_field(
    "params",
    None,
    decode.optional(params_decoder),
  )
  decode.success(Request(jsonrpc:, method:, id:, params:))
}

/// A type that can help with type inference for RPC objects that omit optional
/// fields.
pub opaque type Nothing {
  Nothing
}

/// Encode json for the Nothing type.
pub fn nothing_to_json(_nothing: Nothing) -> Json {
  json.null()
}

/// A notification signifies the Client's lack of interest in the corresponding
/// Response object.
pub type Notification(params) {
  Notification(
    /// Specifies the version of the JSON-RPC protocol. MUST be exactly "2.0".
    jsonrpc: Version,
    /// A String containing the name of the method to be invoked.
    method: String,
    /// Parameter values to be used during the invocation of the method.
    params: Option(params),
  )
}

/// Creates a new notification with empty params
pub fn notification(method: String) -> Notification(params) {
  Notification(jsonrpc: V2, method:, params: None)
}

pub fn notification_to_json(
  notification: Notification(params),
  encode_params: fn(params) -> Json,
) -> Json {
  let Notification(jsonrpc:, method:, params:) = notification
  let params = case params {
    Some(params) -> [#("params", encode_params(params))]
    None -> []
  }

  json.object([
    #("jsonrpc", version_to_json(jsonrpc)),
    #("method", json.string(method)),
    ..params
  ])
}

pub fn notification_decoder(
  params_decoder: Decoder(params),
) -> Decoder(Notification(params)) {
  use jsonrpc <- decode.field("jsonrpc", version_decoder())
  use method <- decode.field("method", decode.string)
  use params <- decode.optional_field(
    "params",
    None,
    decode.optional(params_decoder),
  )
  decode.success(Notification(jsonrpc:, method:, params:))
}

/// A successful response to an RPC call.
pub type Response(result) {
  Response(
    /// Specifies the version of the JSON-RPC protocol. MUST be exactly "2.0".
    jsonrpc: Version,
    /// It MUST be the same as the value of the id member in the Request Object.
    id: Id,
    /// The value of this member is determined by the method invoked on the Server.
    result: result,
  )
}

/// Creates a new response
pub fn response(result result: result, id id: Id) -> Response(result) {
  Response(jsonrpc: V2, id:, result:)
}

pub fn response_to_json(
  response: Response(result),
  encode_result: fn(result) -> Json,
) -> Json {
  let Response(jsonrpc:, id:, result:) = response
  json.object([
    #("jsonrpc", version_to_json(jsonrpc)),
    #("id", id_to_json(id)),
    #("result", encode_result(result)),
  ])
}

pub fn response_decoder(
  result_decoder: Decoder(result),
) -> Decoder(Response(result)) {
  use jsonrpc <- decode.field("jsonrpc", version_decoder())
  use id <- decode.field("id", id_decoder())
  use result <- decode.field("result", result_decoder)
  decode.success(Response(jsonrpc:, id:, result:))
}

/// An error response when an RPC call encounters an error.
pub type ErrorResponse(data) {
  ErrorResponse(
    /// Specifies the version of the JSON-RPC protocol. MUST be exactly "2.0".
    jsonrpc: Version,
    /// It MUST be the same as the value of the id member in the Request Object.
    id: Id,
    /// The error details.
    error: ErrorBody(data),
  )
}

/// Creates a new error response with empty data.
pub fn error_response(
  error error: JsonRpcError,
  id id: Id,
) -> ErrorResponse(data) {
  ErrorResponse(
    jsonrpc: V2,
    id:,
    error: ErrorBody(code: error.code, message: error.message, data: None),
  )
}

pub fn error_response_to_json(
  error_response: ErrorResponse(data),
  encode_data: fn(data) -> Json,
) -> Json {
  let ErrorResponse(jsonrpc:, id:, error:) = error_response
  json.object([
    #("jsonrpc", version_to_json(jsonrpc)),
    #("id", id_to_json(id)),
    #("error", error_to_json(error, encode_data)),
  ])
}

pub fn error_response_decoder(
  data_decoder: Decoder(data),
) -> Decoder(ErrorResponse(data)) {
  use jsonrpc <- decode.field("jsonrpc", version_decoder())
  use id <- decode.field("id", id_decoder())
  use error <- decode.field("error", error_decoder(data_decoder))
  decode.success(ErrorResponse(jsonrpc:, id:, error:))
}

/// Error details in an error response.
pub type ErrorBody(data) {
  ErrorBody(
    /// A Number that indicates the error type that occurred.
    code: Int,
    /// A String providing a short description of the error.
    message: String,
    /// Additional information about the error.
    data: Option(data),
  )
}

pub fn error_to_json(
  error: ErrorBody(data),
  encode_data: fn(data) -> Json,
) -> Json {
  let ErrorBody(code:, message:, data:) = error
  let data = case data {
    Some(data) -> [#("data", encode_data(data))]
    None -> []
  }
  json.object([
    #("code", json.int(code)),
    #("message", json.string(message)),
    ..data
  ])
}

pub fn error_decoder(data_decoder: Decoder(data)) -> Decoder(ErrorBody(data)) {
  use code <- decode.field("code", decode.int)
  use message <- decode.field("message", decode.string)
  use data <- decode.optional_field("data", None, decode.optional(data_decoder))
  decode.success(ErrorBody(code:, message:, data:))
}

/// Represents the error code and associated message.
pub opaque type JsonRpcError {
  JsonRpcError(code: Int, message: String)
}

/// Invalid JSON was received by the server.
pub const parse_error = JsonRpcError(-32_700, "Parse error")

/// The JSON sent is not a valid Request object.
pub const invalid_request = JsonRpcError(-32_600, "Invalid Request")

/// The method does not exist / is not available.
pub const method_not_found = JsonRpcError(-32_601, "Method not found")

/// Invalid method parameter(s).
pub const invalid_params = JsonRpcError(-32_602, "Invalid params")

/// Internal JSON-RPC error.
pub const internal_error = JsonRpcError(-32_603, "Internal error")

/// Get the appropriate `JsonRpcError` based on a request's `json.DecodeError`.
pub fn json_error(error: json.DecodeError) -> JsonRpcError {
  case error {
    json.UnableToDecode(errors) -> decode_errors(errors)
    _ -> parse_error
  }
}

/// Get the appropriate `JsonRpcError` based on `decode.DecodeError`s.
pub fn decode_errors(errors: List(decode.DecodeError)) -> JsonRpcError {
  case list.all(errors, param_error) {
    True -> invalid_params
    False -> invalid_request
  }
}

fn param_error(error: decode.DecodeError) {
  list.first(error.path) == Ok("params")
}
