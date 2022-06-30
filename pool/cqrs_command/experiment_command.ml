open Experiment
module Conformist = Pool_common.Utils.PoolConformist
module Id = Pool_common.Id

let default_schema command =
  Pool_common.Utils.PoolConformist.(
    make
      Field.
        [ Title.schema ()
        ; PublicTitle.schema ()
        ; Description.schema ()
        ; DirectRegistrationDisabled.schema ()
        ; RegistrationDisabled.schema ()
        ; Conformist.optional @@ InvitationTemplate.Subject.schema ()
        ; Conformist.optional @@ InvitationTemplate.Text.schema ()
        ; Conformist.optional @@ Pool_common.Reminder.LeadTime.schema ()
        ; Conformist.optional @@ Pool_common.Reminder.Subject.schema ()
        ; Conformist.optional @@ Pool_common.Reminder.Text.schema ()
        ]
      command)
;;

let default_command
    title
    public_title
    description
    direct_registration_disabled
    registration_disabled
    invitation_subject
    invitation_text
    session_reminder_lead_time
    session_reminder_subject
    session_reminder_text
  =
  { title
  ; public_title
  ; description
  ; direct_registration_disabled
  ; registration_disabled
  ; invitation_subject
  ; invitation_text
  ; session_reminder_lead_time
  ; session_reminder_subject
  ; session_reminder_text
  }
;;

module Create : sig
  type t = create

  val handle : t -> (Pool_event.t list, Pool_common.Message.error) result

  val decode
    :  (string * string list) list
    -> (t, Pool_common.Message.error) result

  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  type t = create

  let handle (command : t) =
    let open CCResult in
    let* experiment =
      Experiment.create
        command.title
        command.public_title
        command.description
        command.direct_registration_disabled
        command.registration_disabled
        command.invitation_subject
        command.invitation_text
        command.session_reminder_lead_time
        command.session_reminder_subject
        command.session_reminder_text
    in
    Ok [ Experiment.Created experiment |> Pool_event.experiment ]
  ;;

  let decode data =
    Conformist.decode_and_validate (default_schema default_command) data
    |> CCResult.map_err Pool_common.Message.to_conformist_error
  ;;

  let can user _ =
    Permission.can user ~any_of:[ Permission.Create Permission.Experiment ]
  ;;
end

module Update : sig
  type t = create

  val handle
    :  Experiment.t
    -> t
    -> (Pool_event.t list, Pool_common.Message.error) result

  val decode
    :  (string * string list) list
    -> (t, Pool_common.Message.error) result

  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  type t = create

  let handle experiment (command : t) =
    let open CCResult in
    let* experiment =
      Experiment.create
        ~id:experiment.Experiment.id
        command.title
        command.public_title
        command.description
        command.direct_registration_disabled
        command.registration_disabled
        command.invitation_subject
        command.invitation_text
        command.session_reminder_lead_time
        command.session_reminder_subject
        command.session_reminder_text
    in
    Ok [ Experiment.Updated experiment |> Pool_event.experiment ]
  ;;

  let decode data =
    Conformist.decode_and_validate (default_schema default_command) data
    |> CCResult.map_err Pool_common.Message.to_conformist_error
  ;;

  let can user _ =
    Permission.can user ~any_of:[ Permission.Create Permission.Experiment ]
  ;;
end

module Delete : sig
  type t =
    { experiment_id : Id.t
    ; session_count : int
    }

  val handle : t -> (Pool_event.t list, Pool_common.Message.error) result
  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  (* Only when no sessions added *)

  type t =
    { experiment_id : Id.t
    ; session_count : int
    }

  let handle { experiment_id; session_count } =
    match session_count > 0 with
    | true -> Error Pool_common.Message.ExperimentSessionCountNotZero
    | false ->
      Ok [ Experiment.Destroyed experiment_id |> Pool_event.experiment ]
  ;;

  let can user command =
    Permission.can
      user
      ~any_of:
        [ Permission.Destroy (Permission.Experiment, Some command.experiment_id)
        ]
  ;;
end

module UpdateFilter : sig end = struct
  (* Update 'match_filter' flag in currently existing assignments *)
end

module AddExperimenter : sig
  type t = { user_id : Id.t }

  val handle
    :  Experiment.t
    -> Admin.experimenter Admin.t
    -> (Pool_event.t list, 'a) result

  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  type t = { user_id : Id.t }

  let handle experiment user =
    Ok
      [ Experiment.ExperimenterAssigned (experiment, user)
        |> Pool_event.experiment
      ]
  ;;

  let can user _ =
    Permission.can user ~any_of:[ Permission.Manage (Permission.System, None) ]
  ;;
end

module DivestExperimenter : sig
  type t =
    { user_id : Id.t
    ; experiment_id : Id.t
    }

  val handle
    :  Experiment.t
    -> Admin.experimenter Admin.t
    -> (Pool_event.t list, 'a) result

  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  type t =
    { user_id : Id.t
    ; experiment_id : Id.t
    }

  let handle experiment user =
    Ok
      [ Experiment.ExperimenterDivested (experiment, user)
        |> Pool_event.experiment
      ]
  ;;

  let can user command =
    Permission.can
      user
      ~any_of:
        [ Permission.Manage (Permission.System, None)
        ; Permission.Manage (Permission.Experiment, Some command.experiment_id)
        ]
  ;;
end

module AddAssistant : sig
  type t = { user_id : Id.t }

  val handle
    :  Experiment.t
    -> Admin.assistant Admin.t
    -> (Pool_event.t list, 'a) result

  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  type t = { user_id : Id.t }

  let handle experiment user =
    Ok
      [ Experiment.AssistantAssigned (experiment, user) |> Pool_event.experiment
      ]
  ;;

  let can user _ =
    Permission.can user ~any_of:[ Permission.Manage (Permission.System, None) ]
  ;;
end

module DivestAssistant : sig
  type t =
    { user_id : Id.t
    ; experiment_id : Id.t
    }

  val handle
    :  Experiment.t
    -> Admin.assistant Admin.t
    -> (Pool_event.t list, 'a) result

  val can : Sihl_user.t -> t -> bool Lwt.t
end = struct
  type t =
    { user_id : Id.t
    ; experiment_id : Id.t
    }

  let handle experiment user =
    Ok
      [ Experiment.AssistantDivested (experiment, user) |> Pool_event.experiment
      ]
  ;;

  let can user command =
    Permission.can
      user
      ~any_of:
        [ Permission.Manage (Permission.System, None)
        ; Permission.Manage (Permission.Experiment, Some command.experiment_id)
        ]
  ;;
end
