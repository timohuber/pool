module Id : sig
  include module type of Pool_common.Id

  val to_common : t -> Pool_common.Id.t
  val of_common : Pool_common.Id.t -> t
end

module Title : sig
  include Pool_model.Base.StringSig
end

module PublicTitle : sig
  include Pool_model.Base.StringSig

  val schema : ?default:t -> unit -> (Pool_message.Error.t, t) Pool_conformist.Field.t
end

module InternalDescription : sig
  include Pool_model.Base.StringSig
end

module PublicDescription : sig
  include Pool_model.Base.StringSig
end

module CostCenter : sig
  include Pool_model.Base.StringSig
end

module ContactEmail : sig
  val schema
    :  unit
    -> (Pool_message.Error.t, Pool_user.EmailAddress.t) Pool_conformist.Field.t
end

module DirectRegistrationDisabled : sig
  include Pool_model.Base.BooleanSig
end

module RegistrationDisabled : sig
  include Pool_model.Base.BooleanSig
end

module AllowUninvitedSignup : sig
  include Pool_model.Base.BooleanSig
end

module ExternalDataRequired : sig
  include Pool_model.Base.BooleanSig
end

module ShowExternalDataIdLinks : sig
  include Pool_model.Base.BooleanSig
end

module AssignmentWithoutSession : sig
  include Pool_model.Base.BooleanSig
end

module SurveyUrl : sig
  include Pool_model.Base.StringSig
end

module OnlineExperiment : sig
  type t = { survey_url : SurveyUrl.t }

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string
  val survey_url : t -> SurveyUrl.t
  val create : survey_url:SurveyUrl.t -> t

  val create_opt
    :  assignment_without_session:AssignmentWithoutSession.t
    -> survey_url:SurveyUrl.t option
    -> t option

  val callback_url
    :  Pool_tenant.t
    -> experiment_id:Id.t
    -> assignment_id:Pool_common.Id.t
    -> string

  val url_params
    :  Pool_tenant.t
    -> experiment_id:Id.t
    -> assignment_id:Pool_common.Id.t
    -> (string * string) list

  val render_survey_url
    :  Pool_tenant.t
    -> experiment_id:Id.t
    -> assignment_id:Pool_common.Id.t
    -> SurveyUrl.t
    -> string
end

module MatcherNotificationSent : sig
  type t

  val value : t -> bool
  val create : bool -> t
end

type t =
  { id : Id.t
  ; title : Title.t
  ; public_title : PublicTitle.t
  ; internal_description : InternalDescription.t option
  ; public_description : PublicDescription.t option
  ; language : Pool_common.Language.t option
  ; cost_center : CostCenter.t option
  ; organisational_unit : Organisational_unit.t option
  ; filter : Filter.t option
  ; contact_email : Pool_user.EmailAddress.t option
  ; smtp_auth_id : Email.SmtpAuth.Id.t option
  ; direct_registration_disabled : DirectRegistrationDisabled.t
  ; registration_disabled : RegistrationDisabled.t
  ; allow_uninvited_signup : AllowUninvitedSignup.t
  ; external_data_required : ExternalDataRequired.t
  ; show_external_data_id_links : ShowExternalDataIdLinks.t
  ; experiment_type : Pool_common.ExperimentType.t option
  ; online_experiment : OnlineExperiment.t option
  ; email_session_reminder_lead_time : Pool_common.Reminder.EmailLeadTime.t option
  ; text_message_session_reminder_lead_time :
      Pool_common.Reminder.TextMessageLeadTime.t option
  ; matcher_notification_sent : MatcherNotificationSent.t
  ; created_at : Pool_common.CreatedAt.t
  ; updated_at : Pool_common.UpdatedAt.t
  }

val equal : t -> t -> bool
val pp : Format.formatter -> t -> unit
val show : t -> string
val compare : t -> t -> int
val yojson_of_t : t -> Yojson.Safe.t
val id : t -> Id.t
val title : t -> Title.t
val public_title : t -> PublicTitle.t
val internal_description : t -> InternalDescription.t option
val public_description : t -> PublicDescription.t option
val language : t -> Pool_common.Language.t option
val cost_center : t -> CostCenter.t option
val organisational_unit : t -> Organisational_unit.t option
val filter : t -> Filter.t option
val contact_email : t -> Pool_user.EmailAddress.t option
val smtp_auth_id : t -> Email.SmtpAuth.Id.t option
val direct_registration_disabled : t -> DirectRegistrationDisabled.t
val registration_disabled : t -> RegistrationDisabled.t
val allow_uninvited_signup : t -> AllowUninvitedSignup.t
val external_data_required : t -> ExternalDataRequired.t
val show_external_data_id_links : t -> ShowExternalDataIdLinks.t
val experiment_type : t -> Pool_common.ExperimentType.t option
val email_session_reminder_lead_time : t -> Pool_common.Reminder.EmailLeadTime.t option

val text_message_session_reminder_lead_time
  :  t
  -> Pool_common.Reminder.TextMessageLeadTime.t option

val created_at : t -> Pool_common.CreatedAt.t
val updated_at : t -> Pool_common.UpdatedAt.t

val create
  :  ?id:Id.t
  -> ?contact_email:Pool_user.EmailAddress.t
  -> ?cost_center:CostCenter.t
  -> ?internal_description:InternalDescription.t
  -> ?public_description:PublicDescription.t
  -> ?language:Pool_common.Language.t
  -> ?email_session_reminder_lead_time:Pool_common.Reminder.EmailLeadTime.t
  -> ?experiment_type:Pool_common.ExperimentType.t
  -> ?filter:Filter.t
  -> ?organisational_unit:Organisational_unit.t
  -> ?smtp_auth_id:Email.SmtpAuth.Id.t
  -> ?text_message_session_reminder_lead_time:Pool_common.Reminder.TextMessageLeadTime.t
  -> ?online_experiment:OnlineExperiment.t
  -> Title.t
  -> PublicTitle.t
  -> DirectRegistrationDisabled.t
  -> RegistrationDisabled.t
  -> AllowUninvitedSignup.t
  -> ExternalDataRequired.t
  -> ShowExternalDataIdLinks.t
  -> (t, Pool_message.Error.t) result

module SendingInvitations : sig
  type t =
    | No
    | Sending
    | Scheduled

  val show : t -> string
  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val field : Pool_message.Field.t
  val hint : Pool_common.I18n.hint
end

module Public : sig
  type t

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string

  val create
    :  ?description:PublicDescription.t
    -> ?language:Pool_common.Language.t
    -> ?experiment_type:Pool_common.ExperimentType.t
    -> ?smtp_auth_id:Email.SmtpAuth.Id.t
    -> ?online_experiment:OnlineExperiment.t
    -> Id.t
    -> PublicTitle.t
    -> DirectRegistrationDisabled.t
    -> t

  val id : t -> Id.t
  val public_title : t -> PublicTitle.t
  val description : t -> PublicDescription.t option
  val language : t -> Pool_common.Language.t option
  val direct_registration_disabled : t -> DirectRegistrationDisabled.t
  val experiment_type : t -> Pool_common.ExperimentType.t option
  val smtp_auth_id : t -> Email.SmtpAuth.Id.t option
  val online_experiment : t -> OnlineExperiment.t option
  val is_sessionless : t -> bool
  val update_direct_registration_disabled : t -> DirectRegistrationDisabled.t -> t
  val contact_matches_filter : Database.Label.t -> t -> Contact.t -> bool Lwt.t
  val column_public_title : Query.Column.t
  val filterable_by : Query.Filter.human option
  val searchable_by : Query.Column.t list
  val sortable_by : Query.Column.t list
  val default_query : Query.t
end

val to_public : t -> Public.t

type assignment_counts =
  { show_up_count : int
  ; no_show_count : int
  ; participation_count : int
  }

module DirectEnrollment : sig
  type t =
    { id : Id.t
    ; title : Title.t
    ; public_title : PublicTitle.t
    ; filter : Filter.query option
    ; allow_uninvited_signup : AllowUninvitedSignup.t
    ; direct_registration_disabled : DirectRegistrationDisabled.t
    ; registration_disabled : RegistrationDisabled.t
    ; available_spots : bool
    ; matches_filter : bool
    ; contact_already_assigned : bool
    }

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val show : t -> string
  val assignable : t -> bool
end

module InvitationReset : sig
  val insert : Database.Label.t -> t -> unit Lwt.t

  type t =
    { created_at : Pool_common.CreatedAt.t
    ; iteration : int
    ; contacts_matching_filter : int
    ; invitations_sent : int
    }

  val show : t -> string
  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val find_by_experiment : Database.Label.t -> Id.t -> t list Lwt.t
  val find_latest_by_experiment : Database.Label.t -> Id.t -> t option Lwt.t
  val invitations_sent_since_last_reset : Database.Label.t -> Id.t -> int Lwt.t
end

type event =
  | Created of t
  | Updated of t * t
  | ResetInvitations of t
  | Deleted of Id.t

val handle_event : ?user_uuid:Pool_common.Id.t -> Database.Label.t -> event -> unit Lwt.t
val equal_event : event -> event -> bool
val pp_event : Format.formatter -> event -> unit
val show_event : event -> string
val created : t -> event
val updated : t -> t -> event
val deleted : Pool_common.Id.t -> event
val boolean_fields : Pool_message.Field.t list
val contact_meets_criteria : Database.Label.t -> t -> Contact.t -> bool Lwt.t
val find : Database.Label.t -> Id.t -> (t, Pool_message.Error.t) result Lwt.t
val all : Database.Label.t -> t list Lwt.t

val list_by_user
  :  ?query:Query.t
  -> Database.Label.t
  -> Guard.Actor.t
  -> (t list * Query.t) Lwt.t

val find_all_ids_of_contact_id : Database.Label.t -> Contact.Id.t -> Id.t list Lwt.t

val find_public
  :  Database.Label.t
  -> Id.t
  -> Contact.t
  -> (Public.t, Pool_message.Error.t) Lwt_result.t

val find_full_by_contact
  :  Database.Label.t
  -> Id.t
  -> Contact.t
  -> (t, Pool_message.Error.t) Lwt_result.t

val find_of_session
  :  Database.Label.t
  -> Pool_common.Id.t
  -> (t, Pool_message.Error.t) Lwt_result.t

val find_of_mailing
  :  Database.Label.t
  -> Pool_common.Id.t
  -> (t, Pool_message.Error.t) Lwt_result.t

val find_upcoming_to_register
  :  Database.Label.t
  -> Contact.t
  -> [ `OnSite | `Online ]
  -> Public.t list Lwt.t

val find_upcoming
  :  Database.Label.t
  -> [< `Dashboard of int | `Query of Query.t ]
  -> Contact.t
  -> [ `OnSite | `Online ]
  -> (Public.t list * Query.t) Lwt.t

val find_pending_waitinglists_by_contact
  :  Database.Label.t
  -> Contact.t
  -> Public.t list Lwt.t

val invitation_count : Database.Label.t -> Id.t -> int Lwt.t
val session_count : Database.Label.t -> Id.t -> int Lwt.t

val search
  :  ?conditions:string
  -> ?dyn:Database.Dynparam.t
  -> ?exclude:Id.t list
  -> ?joins:string
  -> ?limit:int
  -> Database.Label.t
  -> string
  -> (Id.t * Title.t) list Lwt.t

val search_multiple_by_id
  :  Database.Label.t
  -> Pool_common.Id.t list
  -> (Id.t * Title.t) list Lwt.t

val find_to_enroll_directly
  :  ?actor:Guard.Actor.t
  -> Database.Label.t
  -> Contact.t
  -> query:string
  -> DirectEnrollment.t list Lwt.t

val contact_is_enrolled : Database.Label.t -> Id.t -> Contact.Id.t -> bool Lwt.t

val find_targets_grantable_by_target
  :  ?exclude:Id.t list
  -> Database.Label.t
  -> Guard.Uuid.Target.t
  -> Role.Role.t
  -> string
  -> (Id.t * Title.t) list Lwt.t

val get_default_public_title : Database.Label.t -> PublicTitle.t Lwt.t

val query_participation_history_by_contact
  :  ?query:Query.t
  -> Database.Label.t
  -> Contact.t
  -> ((t * bool) list * Query.t) Lwt.t

val registration_possible : Database.Label.t -> Id.t -> bool Lwt.t

val sending_invitations
  :  Database.Label.t
  -> Id.t
  -> (SendingInvitations.t, Pool_message.Error.t) Lwt_result.t

val assignment_counts : Database.Label.t -> Id.t -> assignment_counts Lwt.t

val find_admins_to_notify_about_invitations
  :  Database.Label.t
  -> Id.t
  -> Admin.t list Lwt.t

val invited_contacts_count : Database.Label.t -> Id.t -> int Lwt.t
val possible_participant_count : t -> int Lwt.t
val possible_participants : t -> Contact.t list Lwt.t
val title_value : t -> string
val public_title_value : t -> string
val email_session_reminder_lead_time_value : t -> Ptime.span option
val text_message_session_reminder_lead_time_value : t -> Ptime.span option
val assignment_without_session_value : t -> bool
val survey_url_value : t -> string option
val direct_registration_disabled_value : t -> bool
val registration_disabled_value : t -> bool
val allow_uninvited_signup_value : t -> bool
val external_data_required_value : t -> bool
val show_external_data_id_links_value : t -> bool

val smtp_auth
  :  Database.Label.t
  -> t
  -> (Email.SmtpAuth.t option, Pool_message.Error.t) Lwt_result.t

val is_sessionless : t -> bool

module Repo : sig
  val sql_select_columns : string list
  val joins : string

  val find_request_sql
    :  ?distinct:bool
    -> ?additional_joins:string list
    -> ?count:bool
    -> string
    -> string

  module Public : sig
    val select_from_experiments_sql : ?distinct:bool -> string -> string

    module Entity : sig
      val t : Public.t Caqti_type.t
    end
  end

  module Entity : sig
    module Id : Pool_model.Base.CaqtiSig with type t = Id.t
    module Title : Pool_model.Base.CaqtiSig with type t = Title.t
    module PublicTitle : Pool_model.Base.CaqtiSig with type t = PublicTitle.t

    val t : t Caqti_type.t
  end
end

module Guard : sig
  module Target : sig
    val to_authorizable
      :  ?ctx:(string * string) list
      -> t
      -> (Guard.Target.t, Pool_message.Error.t) Lwt_result.t

    type t

    val equal : t -> t -> bool
    val pp : Format.formatter -> t -> unit
    val show : t -> string
  end

  module Access : sig
    val index_permission : Guard.Permission.t
    val index : Guard.ValidationSet.t
    val create : Guard.ValidationSet.t
    val read : ?model:Role.Target.t -> Id.t -> Guard.ValidationSet.t

    val update_permission_on_target
      :  ?model:Role.Target.t
      -> Id.t
      -> Guard.PermissionOnTarget.t

    val update : ?model:Role.Target.t -> Id.t -> Guard.ValidationSet.t
    val delete : ?model:Role.Target.t -> Id.t -> Guard.ValidationSet.t
  end
end

val column_title : Query.Column.t
val column_public_title : Query.Column.t
val default_query : Query.t
val filterable_by : Query.Filter.human option
val searchable_by : Query.Column.t list
val sortable_by : Query.Column.t list

module VersionHistory : Changelog.TSig with type record = t
