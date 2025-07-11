include Entity
include Event
include Default
include Message_utils
module Guard = Entity_guard
module VersionHistory = Version_history
module Queue = Pool_queue

let src = Logs.Src.create "message_template"

module History = struct
  open Queue.History

  let user_uuid user = user.Pool_user.id |> Pool_user.Id.to_common
  let admin_item { Admin.user; _ } = User, user_uuid user
  let assignment_item { Assignment.id; _ } = Assignment, Assignment.(id |> Id.to_common)
  let contact_item { Contact.user; _ } = User, user_uuid user

  let experiment_item experiment =
    Experiment, Experiment.(experiment.Experiment.id |> Id.to_common)
  ;;

  let public_experiment_item experiment =
    Experiment, Experiment.(Experiment.Public.id experiment |> Id.to_common)
  ;;

  let invitation_item invitation = Invitation, invitation.Invitation.id |> Id.to_common
  let session_item session = Session, Session.(session.Session.id |> Id.to_common)
end

let create_email_job ?smtp_auth_id label mapping_uuids email =
  Email.Service.Job.create ?smtp_auth_id email
  |> Email.create_dispatch
       ~message_template:(Label.show label)
       ~job_ctx:(Queue.job_ctx_create mapping_uuids)
;;

let create_text_message_job ?message_template ?(entity_uuids = []) =
  Text_message.create_job
    ?message_template:(CCOption.map Label.show message_template)
    ~job_ctx:(Queue.job_ctx_create entity_uuids)
;;

let find = Repo.find

let find_default_by_label_and_language pool language label =
  let open Utils.Lwt_result.Infix in
  Repo.find_default_by_label_and_language pool language label
  ||> CCOption.get_exn_or
        Pool_common.(
          Utils.error_to_string
            Language.En
            Pool_message.(Error.NotFound Field.MessageTemplate))
;;

let find_default_by_label = Repo.find_default_by_label
let all_default = Repo.all_default
let find_all_of_entity_by_label = Repo.find_all_of_entity_by_label
let find_by_label_and_language_to_send = Repo.find_by_label_and_language_to_send
let find_all_by_label_to_send = Repo.find_all_by_label_to_send
let find_entity_defaults_by_label = Repo.find_entity_defaults_by_label
let default_sender_of_pool = Email.Service.default_sender_of_pool

let to_absolute_path layout path =
  path |> Sihl.Web.externalize_path |> Format.asprintf "%s%s" layout.link
;;

let sender_of_experiment pool experiment =
  Experiment.contact_email experiment
  |> CCOption.map_or ~default:(default_sender_of_pool pool) Lwt.return
;;

let sender_of_public_experiment pool experiment =
  let open Utils.Lwt_result.Infix in
  experiment |> Experiment.Public.id |> Experiment.find pool |>> sender_of_experiment pool
;;

let filter_languages ?(exclude = []) available templates =
  let exclude = exclude @ (templates |> CCList.map (fun { language; _ } -> language)) in
  available |> CCList.filter CCFun.(flip CCList.mem exclude %> not)
;;

let missing_template_languages database_label entity_id label ?exclude languages =
  let%lwt existing = find_all_of_entity_by_label database_label entity_id label in
  filter_languages ?exclude languages existing |> Lwt.return
;;

let prepare_email ?optout_link language template sender email layout params =
  let open Sihl_email in
  let { Entity.email_subject; email_text; plain_text; _ } = template in
  let mail =
    { sender = Pool_user.EmailAddress.value sender
    ; recipient = Pool_user.EmailAddress.value email
    ; subject = email_subject
    ; text = combine_plain_text language layout plain_text optout_link
    ; html = Some (combine_html ?optout_link language layout (Some email_subject))
    ; cc = []
    ; bcc = []
    }
  in
  let params = [ "emailText", email_text ] @ layout_params layout @ params in
  Message_utils.render_email_params params mail
;;

let prepare_manual_email
      { ManualMessage.recipient; language; email_subject; email_text; plain_text }
      layout
      params
      sender
  =
  let open Sihl_email in
  let mail =
    { sender = Pool_user.EmailAddress.value sender
    ; recipient = Pool_user.EmailAddress.value recipient
    ; subject = email_subject
    ; text = PlainText.value plain_text
    ; html = Some (combine_html language layout (Some email_subject))
    ; cc = []
    ; bcc = []
    }
  in
  let params = [ "emailText", email_text ] @ layout_params layout @ params in
  Message_utils.render_email_params params mail
;;

let layout_params layout = [ "siteTitle", layout.site_title; "siteUrl", layout.link ]

let global_params layout user =
  Pool_user.
    [ "contactId", user.Pool_user.id |> Pool_user.Id.value
    ; "name", user |> fullname
    ; "firstname", user |> firstname |> Firstname.value
    ; "lastname", user |> lastname |> Lastname.value
    ]
  @ layout_params layout
;;

let public_experiment_params layout experiment =
  let open Experiment in
  let experiment_id = experiment |> Public.id |> Id.value in
  let experiment_url =
    Format.asprintf "experiments/%s" experiment_id |> to_absolute_path layout
  in
  let online_experiment_params =
    let open OnlineExperiment in
    experiment
    |> Public.online_experiment
    |> function
    | Some online ->
      [ "experimentSurveyRedirectUrl", experiment_url ^ "/start"
      ; "experimentSurveyUrl", SurveyUrl.value online.survey_url
      ]
    | None -> []
  in
  [ "experimentId", experiment_id
  ; "experimentPublicTitle", experiment |> Public.public_title |> PublicTitle.value
  ; ( "experimentPublicDescription"
    , experiment
      |> Public.description
      |> CCOption.map_or ~default:"" PublicDescription.value )
  ; "experimentUrl", experiment_url
  ]
  @ online_experiment_params
;;

let experiment_params layout experiment =
  public_experiment_params layout (Experiment.to_public experiment)
;;

let location_params
      language
      layout
      ({ Pool_location.id; address; description; _ } as location)
  =
  let open Pool_location in
  let location_url =
    id |> Id.value |> Format.asprintf "location/%s" |> to_absolute_path layout
  in
  let location_link = Human.link_with_default ~default:location_url location in
  let location_details = Human.detailed language location in
  let location_description =
    CCOption.bind description (Description.find_opt language)
    |> CCOption.value ~default:""
  in
  let institution, building, room, street, zip, city =
    let open Address in
    match address with
    | Virtual -> "", "", "", "", "", ""
    | Physical { Mail.institution; building; room; street; zip; city } ->
      let open Mail in
      let default fnc = CCOption.map_or ~default:"" fnc in
      let institution = institution |> default Institution.value in
      let building = building |> default Building.value in
      let room = room |> default Room.value in
      let street = street |> Street.value in
      let zip = zip |> Zip.value in
      let city = city |> City.value in
      institution, building, room, street, zip, city
  in
  [ "locationUrl", location_url
  ; "locationDetails", location_details
  ; "locationLink", location_link
  ; "locationInstitution", institution
  ; "locationBuilding", building
  ; "locationRoom", room
  ; "locationStreet", street
  ; "locationZip", zip
  ; "locationCity", city
  ; "locationDescription", location_description
  ]
;;

let session_params
      layout
      ?follow_up_sessions
      ?prefix
      lang
      ({ Session.start; duration; location; _ } as session : Session.t)
  =
  let open Session in
  let session_id = session.Session.id |> Id.value in
  let session_overview =
    let main_session = Session.to_email_text lang session in
    match follow_up_sessions with
    | None | Some ([], _) -> main_session
    | Some (sessions, i18n) ->
      let follow_ups =
        [ Pool_common.(Utils.hint_to_string lang i18n)
        ; follow_up_sessions_to_email_list sessions
        ]
        |> CCString.concat "\n"
      in
      [ main_session; follow_ups ] |> CCString.concat "\n\n"
  in
  let start = start |> Start.value |> Pool_model.Time.formatted_date_time in
  let duration = duration |> Duration.value |> Pool_model.Time.formatted_timespan in
  let description =
    session.public_description |> CCOption.map_or ~default:"" PublicDescription.value
  in
  let session_params =
    [ "sessionId", session_id
    ; "sessionStart", start
    ; "sessionDateTime", Session.start_end_with_duration_human session
    ; "sessionDuration", duration
    ; "sessionOverview", session_overview
    ; "sessionPublicDescription", description
    ]
  in
  match prefix with
  | None -> session_params @ location_params lang layout location
  | Some prefix ->
    session_params
    |> CCList.map (fun (label, value) ->
      Format.asprintf "%s%s" prefix (CCString.capitalize_ascii label), value)
;;

let assignment_params { Assignment.id; external_data_id; _ } =
  let open Assignment in
  let external_data_id =
    CCOption.map_or ExternalDataId.value ~default:"" external_data_id
  in
  let assignment_id = Id.value id in
  [ "assignmentId", assignment_id; "externalDataId", external_data_id ]
;;

let user_message_uuids user = History.[ Queue.History.User, user_uuid user ]

let invitation_message_uuids experiment contact invitation =
  History.[ contact_item contact; experiment_item experiment; invitation_item invitation ]
;;

let public_experiment_message_uuids experiment contact =
  History.[ contact_item contact; public_experiment_item experiment ]
;;

let session_message_uuids experiment session contact =
  History.[ contact_item contact; session_item session; experiment_item experiment ]
;;

module AccountSuspensionNotification = struct
  let email_params = global_params
  let label = Label.AccountSuspensionNotification

  let create ({ Pool_tenant.database_label; _ } as tenant) user =
    let open Message_utils in
    let open Utils.Lwt_result.Infix in
    let%lwt system_languages = Settings.find_languages database_label in
    let email = user.Pool_user.email in
    let* language =
      match Pool_user.is_admin user with
      | true -> Lwt_result.return Pool_common.Language.En
      | false ->
        email
        |> Contact.find_by_email database_label
        >|+ contact_language system_languages
    in
    let%lwt template = find_by_label_and_language_to_send database_label label language in
    let%lwt sender = default_sender_of_pool database_label in
    let layout = layout_from_tenant tenant in
    let params = email_params layout user in
    let email = prepare_email language template sender email layout params in
    create_email_job label (user_message_uuids user) email |> Lwt_result.return
  ;;
end

module AssignmentCancellation = struct
  open Assignment

  let label = Label.AssignmentCancellation
  let base_params layout contact = contact.Contact.user |> global_params layout

  let email_params ?follow_up_sessions language layout experiment session assignment =
    let follow_up_sessions =
      CCOption.map
        (fun lst -> lst, Pool_common.I18n.AssignmentCancellationMessageFollowUps)
        follow_up_sessions
    in
    base_params layout assignment.contact
    @ experiment_params layout experiment
    @ session_params ?follow_up_sessions layout language session
    @ assignment_params assignment
  ;;

  let template pool experiment language =
    find_by_label_and_language_to_send
      ~entity_uuids:[ Experiment.Id.to_common experiment.Experiment.id ]
      pool
      label
      language
  ;;

  let create ?follow_up_sessions tenant experiment session assignment =
    let pool = tenant.Pool_tenant.database_label in
    let%lwt sys_langs = Settings.find_languages pool in
    let language = experiment_message_language sys_langs experiment assignment.contact in
    let%lwt template = template pool experiment language in
    let layout = layout_from_tenant tenant in
    let%lwt sender = sender_of_experiment pool experiment in
    let smtp_auth_id = experiment.Experiment.smtp_auth_id in
    let params =
      email_params ?follow_up_sessions language layout experiment session assignment
    in
    let email_address = assignment.contact |> Contact.email_address in
    let email = prepare_email language template sender email_address layout params in
    let entity_uuids = session_message_uuids experiment session assignment.contact in
    create_email_job ?smtp_auth_id label entity_uuids email |> Lwt.return
  ;;
end

module AssignmentConfirmation = struct
  open Assignment

  let label = Label.AssignmentConfirmation
  let base_params layout contact = contact.Contact.user |> global_params layout

  let email_params ?follow_up_sessions language layout experiment session assignment =
    let follow_up_sessions =
      CCOption.map
        (fun lst -> lst, Pool_common.I18n.AssignmentConfirmationMessageFollowUps)
        follow_up_sessions
    in
    base_params layout assignment.contact
    @ experiment_params layout experiment
    @ session_params ?follow_up_sessions layout language session
    @ assignment_params assignment
  ;;

  let template pool experiment language =
    find_by_label_and_language_to_send
      ~entity_uuids:[ Experiment.Id.to_common experiment.Experiment.id ]
      pool
      label
      language
  ;;

  let prepare ?follow_up_sessions tenant contact experiment session =
    let pool = tenant.Pool_tenant.database_label in
    let%lwt sys_langs = Settings.find_languages pool in
    let language = experiment_message_language sys_langs experiment contact in
    let%lwt template = template pool experiment language in
    let layout = layout_from_tenant tenant in
    let%lwt sender = sender_of_experiment pool experiment in
    let smtp_auth_id = experiment.Experiment.smtp_auth_id in
    let fnc assignment =
      let params =
        email_params ?follow_up_sessions language layout experiment session assignment
      in
      let email_address = assignment.contact |> Contact.email_address in
      let email = prepare_email language template sender email_address layout params in
      let entity_uuids = session_message_uuids experiment session assignment.contact in
      create_email_job ?smtp_auth_id label entity_uuids email
    in
    Lwt.return fnc
  ;;
end

module AssignmentSessionChange = struct
  let label = Label.AssignmentSessionChange

  let message_uuids experiment new_session old_session { Assignment.contact; _ } =
    History.
      [ experiment_item experiment
      ; session_item new_session
      ; session_item old_session
      ; contact_item contact
      ]
  ;;

  let base_params layout contact = contact.Contact.user |> global_params layout

  let email_params language layout experiment ~new_session ~old_session assignment =
    base_params layout assignment.Assignment.contact
    @ experiment_params layout experiment
    @ session_params layout language new_session
    @ session_params ~prefix:"old" layout language old_session
    @ assignment_params assignment
  ;;

  let create message tenant experiment ~new_session ~old_session assignment =
    let pool = tenant.Pool_tenant.database_label in
    let layout = layout_from_tenant tenant in
    let%lwt sender = sender_of_experiment pool experiment in
    let smtp_auth_id = experiment.Experiment.smtp_auth_id in
    let params =
      email_params
        message.ManualMessage.language
        layout
        experiment
        ~new_session
        ~old_session
        assignment
    in
    let email = prepare_manual_email message layout params sender in
    let entity_uuids = message_uuids experiment new_session old_session assignment in
    create_email_job ?smtp_auth_id label entity_uuids email |> Lwt.return
  ;;
end

module ContactEmailChangeAttempt = struct
  let label = Label.ContactEmailChangeAttempt

  let email_params layout tenant_url user =
    let reset_url = create_public_url tenant_url "/request-reset-password" in
    global_params layout user
    @ [ "tenantUrl", Pool_tenant.Url.value tenant_url
      ; "resetUrl", reset_url
      ; "emailAddress", Pool_user.EmailAddress.value (Pool_user.email user)
      ]
  ;;

  let create tenant user =
    let open Utils.Lwt_result.Infix in
    let pool = tenant.Pool_tenant.database_label in
    let* message_language =
      let%lwt sys_langs = Settings.find_languages pool in
      match%lwt Admin.user_is_admin pool user with
      | true -> Lwt_result.return Pool_common.Language.En
      | false ->
        let* contact = Contact.find_by_user pool user in
        contact_language sys_langs contact |> Lwt_result.return
    in
    let%lwt template =
      find_by_label_and_language_to_send
        pool
        Label.ContactEmailChangeAttempt
        message_language
    in
    let layout = layout_from_tenant tenant in
    let tenant_url = tenant.Pool_tenant.url in
    let%lwt sender = default_sender_of_pool pool in
    let email =
      prepare_email
        message_language
        template
        sender
        (Pool_user.email user)
        layout
        (email_params layout tenant_url user)
    in
    let entity_uuids = user_message_uuids user in
    create_email_job label entity_uuids email |> Lwt.return_ok
  ;;
end

module ContactRegistrationAttempt = struct
  let label = Label.ContactRegistrationAttempt

  let email_params layout tenant_url user =
    let reset_url = create_public_url tenant_url "/request-reset-password" in
    global_params layout user
    @ [ "tenantUrl", Pool_tenant.Url.value tenant_url
      ; "resetUrl", reset_url
      ; "emailAddress", Pool_user.EmailAddress.value (Pool_user.email user)
      ]
  ;;

  let create message_language tenant user =
    let pool = tenant.Pool_tenant.database_label in
    let%lwt template = find_by_label_and_language_to_send pool label message_language in
    let layout = layout_from_tenant tenant in
    let tenant_url = tenant.Pool_tenant.url in
    let%lwt sender = default_sender_of_pool pool in
    let email =
      prepare_email
        message_language
        template
        sender
        (Pool_user.email user)
        layout
        (email_params layout tenant_url user)
    in
    let entity_uuids = user_message_uuids user in
    create_email_job label entity_uuids email |> Lwt.return
  ;;
end

module EmailVerification = struct
  let label = Label.EmailVerification

  let email_params layout validation_url contact =
    global_params layout contact.Contact.user @ [ "verificationUrl", validation_url ]
  ;;

  let create pool language layout contact email_address token =
    let%lwt template =
      find_by_label_and_language_to_send pool Label.EmailVerification language
    in
    let layout = create_layout layout in
    let%lwt url = Pool_tenant.Url.of_pool pool in
    let validation_url =
      Pool_common.
        [ ( Pool_message.Field.Language
          , language |> Language.show |> CCString.lowercase_ascii )
        ; Pool_message.Field.Token, Email.Token.value token
        ]
      |> create_public_url_with_params url "/email-verified"
    in
    let%lwt sender = default_sender_of_pool pool in
    let email =
      prepare_email
        language
        template
        sender
        email_address
        layout
        (email_params layout validation_url contact)
    in
    let entity_uuids = user_message_uuids (Contact.user contact) in
    create_email_job label entity_uuids email |> Lwt.return
  ;;
end

module ExperimentInvitation = struct
  let label = Label.ExperimentInvitation
  let optout_link = Verified

  let email_params layout experiment contact =
    global_params layout contact.Contact.user @ experiment_params layout experiment
  ;;

  let prepare tenant experiment =
    let open Message_utils in
    let pool = tenant.Pool_tenant.database_label in
    let%lwt sys_langs = Settings.find_languages pool in
    let%lwt templates =
      find_all_by_label_to_send
        pool
        ~entity_uuids:[ Experiment.(Id.to_common experiment.Experiment.id) ]
        sys_langs
        Label.ExperimentInvitation
    in
    let smtp_auth_id = experiment.Experiment.smtp_auth_id in
    let%lwt sender = sender_of_experiment pool experiment in
    let layout = layout_from_tenant tenant in
    let fnc ({ Invitation.contact; _ } as invitation) =
      let open CCResult in
      let message_language = experiment_message_language sys_langs experiment contact in
      let* lang, template = find_template_by_language templates message_language in
      let params = email_params layout experiment contact in
      let email =
        prepare_email
          ~optout_link
          lang
          template
          sender
          (Contact.email_address contact)
          layout
          params
      in
      let entity_uuids = invitation_message_uuids experiment contact invitation in
      Ok (create_email_job ?smtp_auth_id label entity_uuids email)
    in
    Lwt.return fnc
  ;;

  let create
        ({ Pool_tenant.database_label; _ } as tenant)
        experiment
        ({ Invitation.contact; _ } as invitation)
    =
    let open Message_utils in
    let%lwt sys_langs = Settings.find_languages database_label in
    let language = experiment_message_language sys_langs experiment contact in
    let%lwt template = find_by_label_and_language_to_send database_label label language in
    let smtp_auth_id = experiment.Experiment.smtp_auth_id in
    let%lwt sender = sender_of_experiment database_label experiment in
    let layout = layout_from_tenant tenant in
    let params = email_params layout experiment contact in
    let email =
      prepare_email
        ~optout_link
        language
        template
        sender
        (Contact.email_address contact)
        layout
        params
    in
    let entity_uuids = invitation_message_uuids experiment contact invitation in
    create_email_job ?smtp_auth_id label entity_uuids email |> Lwt.return
  ;;
end

module InactiveContactWarning = struct
  let label = Label.InactiveContactWarning

  let email_params layout contact ~last_login =
    global_params layout contact.Contact.user
    @ [ "lastLogin", Pool_model.Time.formatted_date last_login ]
  ;;

  let prepare pool =
    let open Utils.Lwt_result.Infix in
    let open Message_utils in
    let* tenant = Pool_tenant.find_by_label pool in
    let%lwt sys_langs = Settings.find_languages pool in
    let%lwt templates = find_all_by_label_to_send pool sys_langs label in
    let%lwt sender = default_sender_of_pool pool in
    let layout = layout_from_tenant tenant in
    let fnc (contact : Contact.t) =
      let open Utils.Lwt_result.Infix in
      let message_language = contact_language sys_langs contact in
      let* lang, template =
        find_template_by_language templates message_language |> Lwt_result.lift
      in
      let%lwt last_login = Contact.find_last_signin_at pool contact in
      let params = email_params layout contact ~last_login in
      let email =
        prepare_email lang template sender (Contact.email_address contact) layout params
      in
      let entity_uuids = user_message_uuids (Contact.user contact) in
      Lwt_result.return (create_email_job label entity_uuids email)
    in
    Lwt_result.return fnc
  ;;
end

module InactiveContactDeactivation = struct
  let label = Label.InactiveContactDeactivation
  let email_params layout contact = global_params layout contact.Contact.user

  let prepare pool =
    let open Utils.Lwt_result.Infix in
    let open Message_utils in
    let* tenant = Pool_tenant.find_by_label pool in
    let%lwt sys_langs = Settings.find_languages pool in
    let%lwt templates = find_all_by_label_to_send pool sys_langs label in
    let%lwt sender = default_sender_of_pool pool in
    let layout = layout_from_tenant tenant in
    let fnc (contact : Contact.t) =
      let open CCResult in
      let message_language = contact_language sys_langs contact in
      let* lang, template = find_template_by_language templates message_language in
      let params = email_params layout contact in
      let email =
        prepare_email lang template sender (Contact.email_address contact) layout params
      in
      let entity_uuids = user_message_uuids (Contact.user contact) in
      Ok (create_email_job label entity_uuids email)
    in
    Lwt_result.return fnc
  ;;
end

module Login2FAToken = struct
  let label = Label.Login2FAToken

  let email_params layout user token =
    global_params layout user @ [ "token", Authentication.Token.to_human token ]
  ;;

  let prepare pool language layout =
    let%lwt template = find_by_label_and_language_to_send pool label language in
    let%lwt sender = default_sender_of_pool pool in
    let layout = create_layout layout in
    let fnc user auth =
      let email =
        prepare_email
          language
          template
          sender
          (Pool_user.email user)
          layout
          (email_params layout user auth.Authentication.token)
      in
      create_email_job label [] email
    in
    Lwt.return fnc
  ;;
end

module ManualSessionMessage = struct
  let label = Label.ManualSessionMessage
  let base_params layout contact = contact.Contact.user |> global_params layout

  let email_params language layout experiment session assignment =
    base_params layout assignment.Assignment.contact
    @ experiment_params layout experiment
    @ session_params layout language session
    @ assignment_params assignment
  ;;

  let prepare tenant session =
    let pool = tenant.Pool_tenant.database_label in
    let experiment = session.Session.experiment in
    let layout = layout_from_tenant tenant in
    let%lwt sender = sender_of_experiment pool experiment in
    let smtp_auth_id = experiment.Experiment.smtp_auth_id in
    Lwt.return
    @@ fun assignment message ->
    let params =
      email_params message.ManualMessage.language layout experiment session assignment
    in
    let email = prepare_manual_email message layout params sender in
    let entity_uuids =
      session_message_uuids experiment session assignment.Assignment.contact
    in
    create_email_job ?smtp_auth_id label entity_uuids email
  ;;

  let prepare_text_message (tenant : Pool_tenant.t) session =
    let experiment = session.Session.experiment in
    let%lwt gtx_config = Gtx_config.find_exn tenant.Pool_tenant.database_label in
    let open Text_message in
    let fnc language assignment message cell_phone =
      let params =
        let layout = layout_from_tenant tenant in
        email_params language layout experiment session assignment
      in
      let content = SmsText.value message in
      let entity_uuids =
        session_message_uuids experiment session assignment.Assignment.contact
      in
      render_and_create cell_phone gtx_config.Gtx_config.sender (content, params)
      |> create_text_message_job ~entity_uuids ~message_template:label
    in
    Lwt.return fnc
  ;;
end

module MatcherNotification = struct
  let label = Label.MatcherNotification

  let email_params layout user experiment =
    global_params layout user @ experiment_params layout experiment
  ;;

  let create tenant language experiment admin =
    let pool = tenant.Pool_tenant.database_label in
    let%lwt template = find_by_label_and_language_to_send pool label language in
    let layout = layout_from_tenant tenant in
    let%lwt sender = default_sender_of_pool pool in
    let params = email_params layout (Admin.user admin) experiment in
    let email_address = Admin.email_address admin in
    let email = prepare_email language template sender email_address layout params in
    let entity_uuids = [ History.experiment_item experiment ] in
    create_email_job label entity_uuids email |> Lwt.return
  ;;
end

module MatchFilterUpdateNotification = struct
  let label = Label.MatchFilterUpdateNotification

  let message_uuids experiment sessions admin =
    let open History in
    [ experiment_item experiment; admin_item admin ]
    @ (sessions
       |> CCList.fold_left
            (fun acc (session, assignments) ->
               let session_item = session_item session in
               let assignment_items = CCList.map assignment_item assignments in
               acc @ (session_item :: assignment_items))
            [])
  ;;

  let assignment_list assignments =
    let data =
      assignments
      |> CCList.map (fun (session, assignments) ->
        let session_title = Session.start_end_with_duration_human session in
        let assignment_title { Assignment.contact; _ } =
          Format.asprintf "- %s" (Contact.fullname contact)
        in
        session_title :: CCList.map assignment_title assignments |> CCString.concat "\n")
      |> CCString.concat "\n\n"
    in
    [ "assignments", data ]
  ;;

  let email_params layout language trigger user experiment assignments =
    let trigger = Pool_common.Utils.text_to_string language trigger in
    global_params layout user
    @ experiment_params layout experiment
    @ assignment_list assignments
    @ [ "trigger", trigger ]
  ;;

  let template pool language = find_by_label_and_language_to_send pool label language

  let create tenant trigger admin experiment assignments =
    let pool = tenant.Pool_tenant.database_label in
    let language = Pool_common.Language.En in
    let%lwt template = template pool language in
    let layout = layout_from_tenant tenant in
    let%lwt sender = sender_of_experiment pool experiment in
    let params =
      email_params layout language trigger (Admin.user admin) experiment assignments
    in
    let email =
      prepare_email language template sender (Admin.email_address admin) layout params
    in
    let entity_uuids = message_uuids experiment assignments admin in
    create_email_job label entity_uuids email |> Lwt.return
  ;;
end

module PasswordChange = struct
  let email_params = global_params
  let label = Label.PasswordChange

  let create language tenant user =
    let pool = tenant.Pool_tenant.database_label in
    let%lwt template = find_by_label_and_language_to_send pool label language in
    let layout = layout_from_tenant tenant in
    let email_address = Pool_user.email user in
    let%lwt sender = default_sender_of_pool pool in
    let email =
      prepare_email
        language
        template
        sender
        email_address
        layout
        (email_params layout user)
    in
    let entity_uuids = user_message_uuids user in
    create_email_job label entity_uuids email |> Lwt.return
  ;;
end

module PasswordReset = struct
  let label = Label.PasswordReset

  let email_params layout reset_url user =
    global_params layout user @ [ "resetUrl", reset_url ]
  ;;

  let create pool language layout user =
    let open Utils.Lwt_result.Infix in
    let email = Pool_user.email user in
    let%lwt template =
      find_by_label_and_language_to_send pool Label.PasswordReset language
    in
    let%lwt url = Pool_tenant.Url.of_pool pool in
    let%lwt sender = default_sender_of_pool pool in
    let open Pool_common in
    let* reset_token =
      Pool_user.Password.Reset.create_token pool email
      ||> function
      | None ->
        Logs.err ~src (fun m ->
          m ~tags:(Database.Logger.Tags.create pool) "Reset token not found");
        Error Pool_message.Error.PasswordResetFailMessage
      | Some token -> Ok token
    in
    let layout = create_layout layout in
    let reset_url =
      Pool_message.
        [ Field.Token, reset_token
        ; Field.Language, language |> Language.show |> CCString.lowercase_ascii
        ]
      |> create_public_url_with_params
           url
           (prepend_root_directory pool "/reset-password/")
    in
    let email =
      prepare_email
        language
        template
        sender
        email
        layout
        (email_params layout reset_url user)
    in
    let entity_uuids = user_message_uuids user in
    create_email_job label entity_uuids email |> Lwt.return_ok
  ;;
end

module PhoneVerification = struct
  let label = Label.PhoneVerification
  let message_params token = [ "token", Pool_common.VerificationCode.value token ]

  let create_text_message
        pool
        message_language
        (tenant : Pool_tenant.t)
        contact
        cell_phone
        token
    =
    let open Text_message in
    let%lwt gtx_config = Gtx_config.find_exn tenant.Pool_tenant.database_label in
    let%lwt { sms_text; _ } =
      find_by_label_and_language_to_send pool label message_language
    in
    let message =
      render_and_create
        cell_phone
        gtx_config.Gtx_config.sender
        (sms_text, message_params token)
    in
    let entity_uuids = user_message_uuids (Contact.user contact) in
    create_text_message_job ~entity_uuids ~message_template:label message
    |> Lwt_result.return
  ;;
end

module ProfileUpdateTrigger = struct
  let label = Label.ProfileUpdateTrigger

  let email_params layout tenant_url contact =
    let profile_url = create_public_url tenant_url "/user/personal-details" in
    global_params layout contact.Contact.user @ [ "profileUrl", profile_url ]
  ;;

  let prepare pool tenant =
    let open Message_utils in
    let%lwt sys_langs = Settings.find_languages pool in
    let%lwt templates =
      find_all_by_label_to_send pool sys_langs Label.SessionReschedule
    in
    let%lwt url = Pool_tenant.Url.of_pool pool in
    let%lwt sender = default_sender_of_pool pool in
    let layout = layout_from_tenant tenant in
    let fnc contact =
      let open CCResult in
      let message_langauge = contact_language sys_langs contact in
      let* lang, template = find_template_by_language templates message_langauge in
      let email =
        prepare_email
          lang
          template
          sender
          (Contact.email_address contact)
          layout
          (email_params layout url contact)
      in
      let entity_uuids = user_message_uuids (Contact.user contact) in
      Ok (create_email_job label entity_uuids email)
    in
    Lwt.return fnc
  ;;
end

module SessionCancellation = struct
  let label = Label.SessionCancellation

  let email_params
        language
        layout
        (experiment : Experiment.t)
        session
        follow_up_sessions
        reason
        contact
    =
    let follow_up_sessions =
      follow_up_sessions, Pool_common.I18n.SessionCancellationMessageFollowUps
    in
    global_params layout contact.Contact.user
    @ [ "reason", reason |> Session.CancellationReason.value ]
    @ experiment_params layout experiment
    @ session_params ~follow_up_sessions layout language session
  ;;

  let prepare pool tenant experiment sys_langs session follow_up_sessions =
    let open Message_utils in
    let%lwt templates =
      find_all_by_label_to_send pool sys_langs Label.SessionCancellation
    in
    let%lwt sender = sender_of_experiment pool experiment in
    let layout = layout_from_tenant tenant in
    let fnc reason (contact : Contact.t) =
      let open CCResult in
      let message_language = experiment_message_language sys_langs experiment contact in
      let* lang, template = find_template_by_language templates message_language in
      let params =
        email_params lang layout experiment session follow_up_sessions reason contact
      in
      let email =
        prepare_email lang template sender (Contact.email_address contact) layout params
      in
      let smtp_auth_id = experiment.Experiment.smtp_auth_id in
      let entity_uuids = session_message_uuids experiment session contact in
      Ok (create_email_job ?smtp_auth_id label entity_uuids email)
    in
    Lwt.return fnc
  ;;

  let prepare_text_message
        pool
        (tenant : Pool_tenant.t)
        experiment
        sys_langs
        session
        follow_up_sessions
    =
    let open Message_utils in
    let%lwt templates =
      find_all_by_label_to_send pool sys_langs Label.SessionCancellation
    in
    let%lwt gtx_config = Gtx_config.find_exn pool in
    let layout = layout_from_tenant tenant in
    let fnc reason (contact : Contact.t) cell_phone =
      let open CCResult in
      let message_language = experiment_message_language sys_langs experiment contact in
      let* lang, template = find_template_by_language templates message_language in
      let params =
        email_params lang layout experiment session follow_up_sessions reason contact
      in
      let message =
        Text_message.render_and_create
          cell_phone
          gtx_config.Gtx_config.sender
          (template.sms_text, params)
      in
      let entity_uuids = session_message_uuids experiment session contact in
      create_text_message_job ~entity_uuids ~message_template:label message
      |> CCResult.return
    in
    Lwt.return fnc
  ;;
end

module SessionReminder = struct
  let label = Label.SessionReminder

  let email_params lang layout experiment session assignment =
    global_params layout assignment.Assignment.contact.Contact.user
    @ experiment_params layout experiment
    @ session_params layout lang session
    @ assignment_params assignment
  ;;

  let find_template pool experiment session language =
    find_by_label_and_language_to_send
      ~entity_uuids:
        [ Session.Id.to_common session.Session.id
        ; Experiment.Id.to_common experiment.Experiment.id
        ]
      pool
      label
      language
  ;;

  let create
        pool
        tenant
        system_languages
        experiment
        session
        ({ Assignment.contact; _ } as assignment)
    =
    let open Message_utils in
    let language = experiment_message_language system_languages experiment contact in
    let%lwt template = find_template pool experiment session language in
    let%lwt sender = sender_of_experiment pool experiment in
    let layout = layout_from_tenant tenant in
    let params = email_params language layout experiment session assignment in
    let email =
      prepare_email language template sender (Contact.email_address contact) layout params
    in
    let entity_uuids = session_message_uuids experiment session contact in
    let smtp_auth_id = experiment.Experiment.smtp_auth_id in
    create_email_job ?smtp_auth_id label entity_uuids email |> Lwt.return
  ;;

  let prepare_emails pool tenant sys_langs experiment session =
    let open Message_utils in
    let%lwt templates =
      find_all_by_label_to_send
        ~entity_uuids:
          [ Session.Id.to_common session.Session.id
          ; Experiment.Id.to_common experiment.Experiment.id
          ]
        pool
        sys_langs
        label
    in
    let%lwt sender = sender_of_experiment pool experiment in
    let layout = layout_from_tenant tenant in
    let fnc ({ Assignment.contact; _ } as assignment) =
      let open CCResult in
      let message_language = experiment_message_language sys_langs experiment contact in
      let* lang, template = find_template_by_language templates message_language in
      let params = email_params lang layout experiment session assignment in
      let email =
        prepare_email lang template sender (Contact.email_address contact) layout params
      in
      let entity_uuids = session_message_uuids experiment session contact in
      let smtp_auth_id = experiment.Experiment.smtp_auth_id in
      Ok (create_email_job ?smtp_auth_id label entity_uuids email)
    in
    Lwt.return fnc
  ;;

  let prepare_text_messages pool (tenant : Pool_tenant.t) sys_langs experiment session =
    let open Message_utils in
    let%lwt templates =
      find_all_by_label_to_send
        ~entity_uuids:
          [ Session.Id.to_common session.Session.id
          ; Experiment.Id.to_common experiment.Experiment.id
          ]
        pool
        sys_langs
        Label.SessionReminder
    in
    let%lwt gtx_config = Gtx_config.find_exn pool in
    let layout = layout_from_tenant tenant in
    let fnc ({ Assignment.contact; _ } as assignment) cell_phone =
      let open CCResult in
      let message_language = experiment_message_language sys_langs experiment contact in
      let* lang, template = find_template_by_language templates message_language in
      let params = email_params lang layout experiment session assignment in
      let message =
        Text_message.render_and_create
          cell_phone
          gtx_config.Gtx_config.sender
          (template.sms_text, params)
      in
      let entity_uuids =
        session_message_uuids experiment session assignment.Assignment.contact
      in
      create_text_message_job ~entity_uuids ~message_template:label message
      |> CCResult.return
    in
    Lwt.return fnc
  ;;
end

module SessionReschedule = struct
  let label = Label.SessionReschedule

  let email_params lang layout experiment session new_start new_duration contact =
    let open Pool_model.Time in
    let open Session in
    global_params layout contact.Contact.user
    @ [ "newStart", new_start |> Start.value |> formatted_date_time
      ; "newDuration", new_duration |> Duration.value |> formatted_timespan
      ]
    @ experiment_params layout experiment
    @ session_params layout lang session
  ;;

  let prepare pool tenant experiment sys_langs session =
    let open Message_utils in
    let%lwt templates = find_all_by_label_to_send pool sys_langs label in
    let%lwt sender = sender_of_experiment pool experiment in
    let layout = layout_from_tenant tenant in
    let fnc (contact : Contact.t) new_start new_duration =
      let open CCResult in
      let message_language = experiment_message_language sys_langs experiment contact in
      let* lang, template = find_template_by_language templates message_language in
      let params =
        email_params lang layout experiment session new_start new_duration contact
      in
      let email =
        prepare_email lang template sender (Contact.email_address contact) layout params
      in
      let entity_uuids = session_message_uuids experiment session contact in
      let smtp_auth_id = experiment.Experiment.smtp_auth_id in
      Ok (create_email_job ?smtp_auth_id label entity_uuids email)
    in
    Lwt.return fnc
  ;;
end

module SignUpVerification = struct
  let label = Label.SignUpVerification

  let email_params layout verification_url firstname lastname =
    let firstname = firstname |> Pool_user.Firstname.value in
    let lastname = lastname |> Pool_user.Lastname.value in
    [ "name", Format.asprintf "%s %s" firstname lastname
    ; "firstname", firstname
    ; "lastname", lastname
    ; "verificationUrl", verification_url
    ]
    @ layout_params layout
  ;;

  let create
        ?signup_code
        pool
        language
        tenant
        email_address
        token
        firstname
        lastname
        user_id
    =
    let%lwt template = find_by_label_and_language_to_send pool label language in
    let%lwt url = Pool_tenant.Url.of_pool pool in
    let%lwt sender = default_sender_of_pool pool in
    let verification_url =
      let params =
        let signup_code =
          let open Signup_code in
          signup_code
          |> CCOption.map_or ~default:[] (fun code -> [ url_key, Code.value code ])
        in
        Pool_common.
          [ ( Pool_message.Field.Language
            , language |> Language.show |> CCString.lowercase_ascii )
          ; Pool_message.Field.Token, Email.Token.value token
          ]
        @ signup_code
      in
      create_public_url_with_params url "/email-verified" params
    in
    let layout = layout_from_tenant tenant in
    let entity_uuids =
      [ Queue.History.User, user_id |> Pool_user.Id.to_common |> Id.of_common ]
    in
    let email =
      prepare_email
        language
        template
        sender
        email_address
        layout
        (email_params layout verification_url firstname lastname)
    in
    create_email_job label entity_uuids email |> Lwt.return
  ;;
end

module UserImport = struct
  let label = Label.UserImport

  let to_user = function
    | `Admin admin -> Admin.user admin
    | `Contact contact -> Contact.user contact
  ;;

  let email_address = function
    | `Admin admin -> Admin.email_address admin
    | `Contact contact -> Contact.email_address contact
  ;;

  let language default_language = function
    | `Admin _ -> Pool_common.Language.En
    | `Contact (contact : Contact.t) ->
      contact.Contact.language |> CCOption.value ~default:default_language
  ;;

  let email_params layout confirmation_url user =
    let user = to_user user in
    global_params layout user @ [ "confirmationUrl", confirmation_url ]
  ;;

  let prepare pool tenant =
    let languages = Pool_common.Language.all in
    let templates = Hashtbl.create (CCList.length languages) in
    let%lwt () =
      find_all_by_label_to_send pool Pool_common.Language.all label
      |> Lwt.map
           (CCList.iter (fun ({ Entity.language; _ } as t) ->
              Hashtbl.add templates language t))
    in
    let%lwt url = Pool_tenant.Url.of_pool pool in
    let%lwt default_language = Settings.default_language pool in
    let%lwt sender = default_sender_of_pool pool in
    let layout = layout_from_tenant tenant in
    Lwt.return
    @@ fun user token ->
    let language = language default_language user in
    let confirmation_url =
      Pool_common.
        [ ( Pool_message.Field.Language
          , language |> Language.show |> CCString.lowercase_ascii )
        ; Pool_message.Field.Token, token
        ]
      |> create_public_url_with_params url "/import-confirmation"
    in
    let optout_link =
      match user with
      | `Contact _ -> Some (Unverified token)
      | `Admin _ -> None
    in
    let template = Hashtbl.find templates language in
    let email =
      prepare_email
        ?optout_link
        language
        template
        sender
        (email_address user)
        layout
        (email_params layout confirmation_url user)
    in
    let entity_uuids = user_message_uuids (to_user user) in
    create_email_job label entity_uuids email
  ;;
end

module WaitingListConfirmation = struct
  let label = Label.WaitingListConfirmation
  let base_params layout contact = contact.Contact.user |> global_params layout

  let email_params layout contact experiment =
    base_params layout contact @ public_experiment_params layout experiment
  ;;

  let create ({ Pool_tenant.database_label; _ } as tenant) contact experiment =
    let open Utils.Lwt_result.Infix in
    let open Message_utils in
    let%lwt system_languages = Settings.find_languages database_label in
    let language =
      public_experiment_message_language system_languages experiment contact
    in
    let* sender = sender_of_public_experiment database_label experiment in
    let layout = layout_from_tenant tenant in
    let%lwt template =
      find_by_label_and_language_to_send
        ~entity_uuids:Experiment.[ experiment |> Public.id |> Id.to_common ]
        database_label
        label
        language
    in
    let email_address = contact |> Contact.email_address in
    let params = email_params layout contact experiment in
    let email = prepare_email language template sender email_address layout params in
    let entity_uuids = public_experiment_message_uuids experiment contact in
    let smtp_auth_id = Experiment.Public.smtp_auth_id experiment in
    create_email_job ?smtp_auth_id label entity_uuids email |> Lwt.return_ok
  ;;
end

let sms_text_to_email sms_text =
  let sms_text = SmsText.value sms_text in
  let plain_text = PlainText.of_string sms_text in
  let email_text = EmailText.of_string plain_text in
  email_text, plain_text
;;
