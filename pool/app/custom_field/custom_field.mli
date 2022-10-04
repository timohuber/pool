module Answer : sig
  module Id : sig
    include Pool_common.Model.IdSig
  end

  type 'a t =
    { id : Id.t
    ; value : 'a
    ; version : Pool_common.Version.t
    }

  val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
  val pp : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit
  val show : (Format.formatter -> 'a -> unit) -> 'a t -> string
  val create : ?id:Id.t -> ?version:Pool_common.Version.t -> 'a -> 'a t
  val id : 'a t -> Id.t
  val version : 'a t -> Pool_common.Version.t
  val increment_version : 'a t -> 'a t
end

module Id : sig
  include Pool_common.Model.IdSig
end

module Model : sig
  type t =
    | Contact
    | Experiment
    | Session

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string
  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val all : t list

  val schema
    :  unit
    -> (Pool_common.Message.error, t) Pool_common.Utils.PoolConformist.Field.t
end

module Name : sig
  type name

  val equal_name : name -> name -> bool
  val pp_name : Format.formatter -> name -> unit
  val show_name : name -> string
  val name_of_yojson : Yojson.Safe.t -> name
  val yojson_of_name : name -> Yojson.Safe.t
  val value_name : name -> string

  type t

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> name
  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val find_opt : Pool_common.Language.t -> t -> name option

  val create
    :  Pool_common.Language.t list
    -> (Pool_common.Language.t * string) list
    -> (t, Pool_common.Message.error) result
end

module Hint : sig
  type hint

  val equal_hint : hint -> hint -> bool
  val pp_hint : Format.formatter -> hint -> unit
  val show_hint : hint -> string
  val hint_of_yojson : Yojson.Safe.t -> hint
  val yojson_of_hint : hint -> Yojson.Safe.t
  val value_hint : hint -> string

  type t

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> hint
  val t_of_yojson : Yojson.Safe.t -> t
  val yojson_of_t : t -> Yojson.Safe.t
  val find_opt : Pool_common.Language.t -> t -> hint option

  val create
    :  (Pool_common.Language.t * string) list
    -> (t, Pool_common.Message.error) result
end

module FieldType : sig
  type t =
    | Number
    | Select
    | Text

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string
  val all : t list

  val schema
    :  unit
    -> (Pool_common.Message.error, t) Pool_common.Utils.PoolConformist.Field.t
end

module Required : sig
  include Pool_common.Model.BooleanSig
end

module Disabled : sig
  include Pool_common.Model.BooleanSig
end

module Admin : sig
  module Hint : sig
    include Pool_common.Model.StringSig
  end

  module Overwrite : sig
    include Pool_common.Model.BooleanSig
  end

  type t =
    { hint : Hint.t option
    ; overwrite : Overwrite.t
    }
end

module Validation : sig
  type raw = string * string
  type raw_list = raw list

  module Number : sig
    val schema
      :  (string * string) list
      -> ((int -> (int, Pool_common.Message.error) result) * raw) list
  end

  module Text : sig
    val schema
      :  (string * string) list
      -> ((string -> (string, Pool_common.Message.error) result) * raw) list
  end

  val raw_list_of_yojson : Yojson.Safe.t -> raw_list
  val all : (string * [> `Number ] * FieldType.t) list
end

type 'a validation =
  ('a -> ('a, Pool_common.Message.error) result) * Validation.raw

type 'a custom_field =
  { id : Id.t
  ; model : Model.t
  ; name : Name.t
  ; hint : Hint.t
  ; validation : 'a validation list
  ; required : Required.t
  ; disabled : Disabled.t
  ; admin : Admin.t
  }

module SelectOption : sig
  module Id : sig
    type t = Id.t

    val equal : t -> t -> bool
    val pp : Format.formatter -> t -> unit
    val show : t -> string
    val create : unit -> t
    val of_string : string -> t
    val value : t -> string
  end

  type t =
    { id : Id.t
    ; name : Name.t
    }

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string
  val show_id : t -> string
  val name : Pool_common.Language.t -> t -> string
  val create : ?id:Id.t -> Name.t -> t
end

type t =
  | Number of int custom_field
  | Select of SelectOption.t custom_field * SelectOption.t list
  | Text of string custom_field

val equal : t -> t -> bool
val pp : Format.formatter -> t -> unit
val show : t -> string

val create
  :  ?id:Id.t
  -> ?select_options:SelectOption.t list
  -> FieldType.t
  -> Model.t
  -> Name.t
  -> Hint.t
  -> (string * string) list
  -> Required.t
  -> Disabled.t
  -> Admin.t
  -> (t, Pool_common.Message.error) result

module Public : sig
  type 'a public =
    { id : Id.t
    ; name : Name.t
    ; hint : Hint.t
    ; validation : 'a validation list
    ; required : Required.t
    ; answer : 'a Answer.t option
    }

  val equal_public : ('a -> 'a -> bool) -> 'a public -> 'a public -> bool

  val pp_public
    :  (Format.formatter -> 'a -> unit)
    -> Format.formatter
    -> 'a public
    -> unit

  val show_public : (Format.formatter -> 'a -> unit) -> 'a public -> string

  type t =
    | Number of int public
    | Select of SelectOption.t public * SelectOption.t list
    | Text of string public

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string
  val validate : string -> t -> (t, Pool_common.Message.error) result
  val id : t -> Id.t
  val name_value : Pool_common.Language.t -> t -> string
  val hint : Pool_common.Language.t -> t -> Hint.hint option
  val version : t -> Pool_common.Version.t option
  val required : t -> Required.t

  val to_common_field
    :  Pool_common.Language.t
    -> t
    -> Pool_common.Message.Field.t

  val to_common_hint
    :  Pool_common.Language.t
    -> t
    -> Pool_common.I18n.hint option
end

val boolean_fields : Pool_common.Message.Field.t list
val id : t -> Id.t
val model : t -> Model.t
val name : t -> Name.t
val hint : t -> Hint.t
val required : t -> Required.t
val disabled : t -> Disabled.t
val admin : t -> Admin.t
val field_type : t -> FieldType.t
val validation_strings : t -> (string * string) list
val validation_to_yojson : t -> Yojson.Safe.t

type event =
  | AnswerUpserted of Public.t * Pool_common.Id.t
  | Created of t
  | OptionCreated of (Id.t * SelectOption.t)
  | OptionDestroyed of SelectOption.t
  | OptionUpdated of SelectOption.t
  | OptionsSorted of SelectOption.t list
  | Updated of t

val equal_event : event -> event -> bool
val pp_event : Format.formatter -> event -> unit
val show_event : event -> string
val handle_event : Pool_database.Label.t -> event -> unit Lwt.t
val find_all : Pool_database.Label.t -> unit -> t list Lwt.t

val find
  :  Pool_database.Label.t
  -> Id.t
  -> (t, Pool_common.Message.error) result Lwt.t

val find_public
  :  Pool_database.Label.t
  -> Id.t
  -> (Public.t, Pool_common.Message.error) result Lwt.t

val find_all_by_contact
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> Public.t list Lwt.t

val find_all_required_by_contact
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> Public.t list Lwt.t

val find_multiple_by_contact
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> Pool_common.Id.t list
  -> Public.t list Lwt.t

val find_by_contact
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> Id.t
  -> (Public.t, Pool_common.Message.error) result Lwt.t

val upsert_answer
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> Public.t
  -> unit Lwt.t

val all_required_answered
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> bool Lwt.t

val find_option
  :  Pool_database.Label.t
  -> Id.t
  -> (SelectOption.t, Pool_common.Message.error) result Lwt.t

val find_option_by_field
  :  Pool_database.Label.t
  -> Id.t
  -> SelectOption.t list Lwt.t
