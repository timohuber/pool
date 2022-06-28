module Conformist = Pool_common.Utils.PoolConformist

let session_command
    start
    duration
    description
    max_participants
    min_participants
    overbook
  =
  Session.
    { start
    ; duration
    ; description
    ; max_participants
    ; min_participants
    ; overbook
    }
;;

let session_schema =
  Conformist.(
    make
      Field.
        [ Session.Start.schema ()
        ; Session.Duration.schema ()
        ; Conformist.optional @@ Session.Description.schema ()
        ; Session.ParticipantAmount.schema
            Pool_common.Message.Field.MaxParticipants
        ; Session.ParticipantAmount.schema
            Pool_common.Message.Field.MinParticipants
        ; Session.ParticipantAmount.schema Pool_common.Message.Field.Overbook
        ]
      session_command)
;;

(* TODO [aerben] create sigs *)
module Create = struct
  type t = Session.base

  let command = session_command
  let schema = session_schema

  let handle
      ?parent_session
      experiment_id
      location
      (Session.
         { start
         ; duration
         ; description
         ; max_participants
         ; min_participants
         ; (* TODO [aerben] find a better name *)
           overbook
         } :
        Session.base)
    =
    (* If session is follow-up, make sure it's later than parent *)
    let follow_up_is_ealier =
      let open Session in
      CCOption.map_or
        ~default:false
        (fun (s : Session.t) ->
          Ptime.is_earlier ~than:(Start.value s.start) (Start.value start))
        parent_session
    in
    let validations =
      [ follow_up_is_ealier, Pool_common.Message.FollowUpIsEarlierThanMain
      ; ( max_participants < min_participants
        , Pool_common.Message.(
            Smaller (Field.MaxParticipants, Field.MinParticipants)) )
      ]
    in
    let open CCResult in
    let* () =
      validations
      |> CCList.filter fst
      |> CCList.map (fun (_, err) -> Error err)
      |> flatten_l
      |> map ignore
    in
    let (session : Session.base) =
      Session.
        { start
        ; duration
        ; description
        ; max_participants
        ; min_participants
        ; overbook
        }
    in
    Ok
      [ Session.Created
          ( session
          , CCOption.map (fun s -> s.Session.id) parent_session
          , experiment_id
          , location )
        |> Pool_event.session
      ]
  ;;

  let decode data =
    Conformist.decode_and_validate schema data
    |> CCResult.map_err Pool_common.Message.to_conformist_error
  ;;

  let can user _ =
    Permission.can user ~any_of:[ Permission.Manage (Permission.System, None) ]
  ;;
end

module Update = struct
  type t = Session.base

  let command = session_command
  let schema = session_schema

  let handle
      ?parent_session
      follow_up_sessions
      session
      location
      (Session.
         { start
         ; duration
         ; description
         ; max_participants
         ; min_participants
         ; overbook
         } :
        Session.base)
    =
    (* If session has follow-ups, make sure they are all later *)
    let open Session in
    let follow_ups_are_ealier =
      CCList.exists
        (fun (follow_up : Session.t) ->
          Ptime.is_earlier
            ~than:(Start.value start)
            (Start.value follow_up.start))
        follow_up_sessions
    in
    (* If session is follow-up, make sure it's later than parent *)
    let follow_up_is_ealier =
      CCOption.map_or
        ~default:false
        (fun (s : Session.t) ->
          Ptime.is_earlier ~than:(Start.value s.start) (Start.value start))
        parent_session
    in
    print_endline @@ string_of_bool follow_up_is_ealier;
    let validations =
      [ ( follow_up_is_ealier || follow_ups_are_ealier
        , Pool_common.Message.FollowUpIsEarlierThanMain )
      ; ( max_participants < min_participants
        , Pool_common.Message.(
            Smaller (Field.MaxParticipants, Field.MinParticipants)) )
      ]
    in
    let open CCResult in
    let* () =
      validations
      |> CCList.filter fst
      |> CCList.map (fun (_, err) -> Error err)
      |> flatten_l
      |> map ignore
    in
    let (session_cmd : Session.base) =
      Session.
        { start
        ; duration
        ; description
        ; max_participants
        ; min_participants
        ; overbook
        }
    in
    Ok
      [ Session.Updated (session_cmd, location, session) |> Pool_event.session ]
  ;;

  let decode data =
    Conformist.decode_and_validate schema data
    |> CCResult.map_err Pool_common.Message.to_conformist_error
  ;;

  let can user _ =
    Permission.can user ~any_of:[ Permission.Manage (Permission.System, None) ]
  ;;
end

module Delete : sig
  type t = { session : Session.t }

  val handle
    :  Session.t
    -> (Pool_event.t list, Pool_common.Message.error) result

  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  type t = { session : Session.t }

  let handle session =
    (* TODO [aerben] only when no assignments added *)
    (* TODO [aerben] how to deal with follow-ups? currently they just disappear *)
    Ok [ Session.Deleted session |> Pool_event.session ]
  ;;

  let can user _ =
    Permission.can user ~any_of:[ Permission.Manage (Permission.System, None) ]
  ;;
end

module Cancel : sig
  type t =
    { session : Session.t
    ; notify_via : string
    }

  val handle
    :  Session.t
    -> (Pool_event.t list, Pool_common.Message.error) result

  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  (* TODO issue #90 step 2 *)
  (* notify_via: Email, SMS *)
  type t =
    { session : Session.t
    ; notify_via : string
    }

  let handle session = Ok [ Session.Canceled session |> Pool_event.session ]

  let can user _ =
    Permission.can user ~any_of:[ Permission.Manage (Permission.System, None) ]
  ;;
end