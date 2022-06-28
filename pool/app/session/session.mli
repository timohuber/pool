(* TODO [aerben] maybe can extract even more? *)
module type Base = sig
  type t

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string

  val schema
    :  unit
    -> (Pool_common.Message.error, t) Pool_common.Utils.PoolConformist.Field.t
end

module Description : sig
  include Base

  val value : t -> string
  val create : string -> (t, Pool_common.Message.error) result
end

module ParticipantAmount : sig
  include Base

  val value : t -> int
  val create : int -> (t, Pool_common.Message.error) result

  val schema
    :  Pool_common.Message.Field.t
    -> (Pool_common.Message.error, t) Pool_common.Utils.PoolConformist.Field.t
end

module Start : sig
  include Base

  val value : t -> Ptime.t
  val create : Ptime.t -> t
end

module Duration : sig
  include Base

  val value : t -> Ptime.Span.t
  val create : Ptime.Span.t -> (t, Pool_common.Message.error) result
end

module AssignmentCount : sig
  type t

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val value : t -> int
  val create : int -> (t, Pool_common.Message.error) result
end

type t =
  { id : Pool_common.Id.t
  ; follow_up_to : Pool_common.Id.t option
  ; start : Start.t
  ; duration : Duration.t
  ; description : Description.t option
  ; location : Pool_location.t
  ; max_participants : ParticipantAmount.t
  ; min_participants : ParticipantAmount.t
  ; overbook : ParticipantAmount.t
  ; assignment_count : AssignmentCount.t
  ; (* TODO [aerben] make type for canceled_at? *)
    canceled_at : Ptime.t option
  ; created_at : Pool_common.CreatedAt.t
  ; updated_at : Pool_common.UpdatedAt.t
  }

val equal : t -> t -> bool
val pp : Format.formatter -> t -> unit
val show : t -> string
val is_fully_booked : t -> bool
val session_date_to_human : t -> string

type base =
  { start : Start.t
  ; duration : Duration.t
  ; description : Description.t option
  ; max_participants : ParticipantAmount.t
  ; min_participants : ParticipantAmount.t
  ; overbook : ParticipantAmount.t
  }

(* TODO [aerben] this should be experiment id type *)
(* TODO [aerben] maybe Experiment.t Pool_common.Id.t *)
type event =
  | Created of
      (base * Pool_common.Id.t option * Pool_common.Id.t * Pool_location.t)
  | Canceled of t
  | Deleted of t
  | Updated of (base * Pool_location.t * t)

val handle_event : Pool_database.Label.t -> event -> unit Lwt.t
val equal_event : event -> event -> bool
val pp_event : Format.formatter -> event -> unit

module Public : sig
  type t =
    { id : Pool_common.Id.t
    ; follow_up_to : Pool_common.Id.t option
    ; start : Start.t
    ; duration : Duration.t
    ; description : Description.t option
    ; location : Pool_location.t
    ; max_participants : ParticipantAmount.t
    ; min_participants : ParticipantAmount.t
    ; overbook : ParticipantAmount.t
    ; assignment_count : AssignmentCount.t
    ; canceled_at : Ptime.t option
    }

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string
  val is_fully_booked : t -> bool
end

val group_and_sort : t list -> (t * t list) list

(* TODO [aerben] this should be experiment id type *)
val find
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> (t, Pool_common.Message.error) Lwt_result.t

val find_public
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> Contact.t
  -> (Public.t, Pool_common.Message.error) Lwt_result.t

val find_all_public_by_location
  :  Pool_database.Label.t
  -> Pool_location.Id.t
  -> (Public.t list, Pool_common.Message.error) result Lwt.t

val find_all_for_experiment
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> (t list, Pool_common.Message.error) result Lwt.t

val find_all_public_for_experiment
  :  Pool_database.Label.t
  -> Contact.t
  -> Pool_common.Id.t
  -> (Public.t list, Pool_common.Message.error) result Lwt.t

val find_public_by_assignment
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> (Public.t, Pool_common.Message.error) result Lwt.t

val find_experiment_id_and_title
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> (Pool_common.Id.t * string, Pool_common.Message.error) result Lwt.t

val find_follow_ups
  :  Pool_database.Label.t
  -> Pool_common.Id.t
  -> (t list, Pool_common.Message.error) result Lwt.t

val to_email_text
  :  Pool_common.Language.t
  -> Start.t
  -> Duration.t
  -> Pool_location.t
  -> string