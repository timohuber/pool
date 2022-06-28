open Tyxml.Html
open Component
module Message = Pool_common.Message

let session_title (s : Session.t) =
  Pool_common.I18n.SessionDetailTitle (s.Session.start |> Session.Start.value)
;;

let location_select options selected ?(attributes = []) () =
  let open Pool_location in
  let name = Message.Field.(show Location) in
  div
    ~a:[ a_class [ "form-group" ] ]
    [ label [ txt (name |> CCString.capitalize_ascii) ]
    ; div
        ~a:[ a_class [ "select" ] ]
        [ select
            ~a:([ a_name name ] @ attributes)
            (CCList.map
               (fun l ->
                 let is_selected =
                   selected
                   |> CCOption.map (fun selected ->
                          if Pool_location.equal selected l
                          then [ a_selected () ]
                          else [])
                   |> CCOption.value ~default:[]
                 in
                 option
                   ~a:
                     ([ a_value (l.id |> Pool_location.Id.value) ] @ is_selected)
                   (txt (l.name |> Pool_location.Name.value)))
               options)
        ]
    ]
;;

let create csrf language experiment_id locations ~flash_fetcher =
  div
    [ h1
        ~a:[ a_class [ "heading-2" ] ]
        [ txt
            Pool_common.(
              Utils.control_to_string
                language
                Message.(Create (Some Field.Session)))
        ]
    ; form
        ~a:
          [ a_class [ "stack" ]
          ; a_method `Post
          ; a_action
              (Format.asprintf "/admin/experiments/%s/sessions"
               @@ Pool_common.Id.value experiment_id
              |> Sihl.Web.externalize_path)
          ]
        [ Component.csrf_element csrf ()
        ; flatpicker_element
            language
            `Datetime_local
            Pool_common.Message.Field.Start
            ~required:true
            ~flash_fetcher
            ~warn_past:true
        ; flatpicker_element
            language
            ~required:true
            `Time
            Pool_common.Message.Field.Duration
            ~help:Pool_common.I18n.TimeSpanPickerHint
            ~flash_fetcher
        ; textarea_element
            language
            Pool_common.Message.Field.Description
            ~flash_fetcher
        ; location_select locations None ()
        ; input_element
            language
            `Number
            Pool_common.Message.Field.MaxParticipants
            ~required:true
            ~flash_fetcher
        ; input_element
            language
            `Number
            Pool_common.Message.Field.MinParticipants
            ~required:true
            ~flash_fetcher
            ~value:"0"
        ; input_element
            language
            `Number
            Pool_common.Message.Field.Overbook
            ~required:true
            ~flash_fetcher
        ; submit_element language Message.(Create (Some Field.Session)) ()
        ]
    ]
;;

let index
    Pool_context.{ language; csrf; _ }
    experiment
    grouped_sessions
    chronological
    locations
    flash_fetcher
  =
  let experiment_id = experiment.Experiment.id in
  let rows =
    CCList.flat_map
      (fun (parent, follow_ups) ->
        let open Session in
        let session_row session =
          let cancel_form =
            match CCOption.is_some session.Session.canceled_at with
            | true ->
              submit_element
                ~submit_type:`Disabled
                language
                Message.(Cancel None)
                ()
            | false ->
              form
                ~a:
                  [ a_method `Post
                  ; a_action
                      (Format.asprintf
                         "/admin/experiments/%s/sessions/%s/cancel"
                         (Pool_common.Id.value experiment_id)
                         (Pool_common.Id.value session.id)
                      |> Sihl.Web.externalize_path)
                  ; a_user_data
                      "confirmable"
                      Pool_common.(
                        Utils.confirmable_to_string language I18n.CancelSession)
                  ]
                [ Component.csrf_element csrf ()
                ; submit_element language Message.(Cancel None) ()
                ]
          in
          let indent =
            if CCOption.is_some session.follow_up_to && not chronological
            then 30
            else 0
          in
          (* TODO [aerben] replace with econ framework class, once exists *)
          [ div
              ~a:[ a_style @@ Format.asprintf "padding-left: %ipx" indent ]
              [ txt (session |> Session.session_date_to_human) ]
          ; txt
              (CCInt.to_string
                 (session.Session.assignment_count
                 |> Session.AssignmentCount.value))
          ; session.Session.canceled_at
            |> CCOption.map_or ~default:"" (fun t ->
                   Pool_common.Utils.Time.formatted_date_time t)
            |> txt
          ; a
              ~a:
                [ a_href
                    (Format.asprintf
                       "/admin/experiments/%s/sessions/%s"
                       (Pool_common.Id.value experiment_id)
                       (Pool_common.Id.value session.id)
                    |> Sihl.Web.externalize_path)
                ]
              [ txt
                  Pool_common.(Utils.control_to_string language Message.(More))
              ]
          ; cancel_form
          ; form
              ~a:
                [ a_method `Post
                ; a_action
                    (Format.asprintf
                       "/admin/experiments/%s/sessions/%s/delete"
                       (Pool_common.Id.value experiment_id)
                       (Pool_common.Id.value session.id)
                    |> Sihl.Web.externalize_path)
                ; a_user_data
                    "confirmable"
                    Pool_common.(
                      Utils.confirmable_to_string language I18n.DeleteSession)
                ]
              [ Component.csrf_element csrf ()
              ; submit_element
                  language
                  Message.(Delete None)
                  ~submit_type:`Error
                  ()
              ]
          ]
        in
        session_row parent :: CCList.map session_row follow_ups)
      grouped_sessions
  in
  let thead =
    Pool_common.Message.Field.
      [ Some Date; Some AssignmentCount; Some CanceledAt; None; None; None ]
  in
  let html =
    div
      ~a:[ a_class [ "stack-lg" ] ]
      ((if CCList.is_empty rows
       then
         [ p
             [ txt
                 Pool_common.(
                   Utils.text_to_string
                     language
                     (I18n.EmtpyList Message.Field.Sessions))
             ]
         ]
       else
         [ p
             [ Pool_common.I18n.SessionIndent
               |> Pool_common.Utils.text_to_string language
               |> txt
             ]
         ; a
             ~a:
               [ a_href
                   (Format.asprintf
                      "/admin/experiments/%s/sessions%s"
                      (Pool_common.Id.value experiment_id)
                      (if chronological then "" else "?chronological=true")
                   |> Sihl.Web.externalize_path)
               ]
             [ p
                 [ (if chronological
                   then Pool_common.I18n.SwitchGrouped
                   else Pool_common.I18n.SwitchChronological)
                   |> Pool_common.Utils.text_to_string language
                   |> txt
                 ]
             ]
           (* TODO [aerben] allow tables to be sorted generally? *)
         ; Table.horizontal_table `Striped language ~thead rows
         ])
      @ [ create csrf language experiment_id locations ~flash_fetcher ])
  in
  Page_admin_experiments.experiment_layout
    language
    (Page_admin_experiments.NavLink Pool_common.I18n.Sessions)
    experiment.Experiment.id
    ~active:Pool_common.I18n.Sessions
    html
;;

(* TODO [aerben] in parent session, link to follow up session *)
let detail
    (Pool_context.{ language; _ } as context)
    experiment_id
    (session : Session.t)
    assignments
  =
  let open Session in
  let session_overview =
    div
      ~a:[ a_class [ "stack" ] ]
      [ (let open Message in
        let parent =
          CCOption.map
            (fun follow_up_to ->
              ( Field.MainSession
              , a
                  ~a:
                    [ a_href
                        (Format.asprintf
                           "/admin/experiments/%s/sessions/%s"
                           (Pool_common.Id.value experiment_id)
                           (Pool_common.Id.value follow_up_to)
                        |> Sihl.Web.externalize_path)
                    ]
                  [ Message.Show
                    |> Pool_common.Utils.control_to_string language
                    |> CCString.capitalize_ascii
                    |> txt
                  ] ))
            session.follow_up_to
        in
        let rows =
          let amount amt = amt |> ParticipantAmount.value |> string_of_int in
          [ ( Field.Start
            , session.start
              |> Start.value
              |> Pool_common.Utils.Time.formatted_date_time
              |> txt )
          ; ( Field.Duration
            , session.duration
              |> Duration.value
              |> Pool_common.Utils.Time.formatted_timespan
              |> txt )
          ; ( Field.Description
            , CCOption.map_or ~default:"" Description.value session.description
              |> Http_utils.add_line_breaks )
          ; ( Field.Location
            , Partials.location_to_html language session.Session.location )
          ; Field.MaxParticipants, amount session.max_participants |> txt
          ; Field.MinParticipants, amount session.min_participants |> txt
          ; Field.Overbook, amount session.overbook |> txt
          ]
          |> fun rows ->
          match session.canceled_at with
          | None -> rows
          | Some canceled ->
            rows
            @ [ ( Field.CanceledAt
                , Pool_common.Utils.Time.formatted_date_time canceled |> txt )
              ]
        in
        Table.vertical_table `Striped language ~align_top:true
        @@ CCOption.map_or ~default:rows (CCList.cons' rows) parent)
      ; p
          ~a:[ a_class [ "flexrow"; "flex-gap" ] ]
          ([ a
               ~a:
                 [ a_href
                     (Format.asprintf
                        "/admin/experiments/%s/sessions/%s/edit"
                        (Pool_common.Id.value experiment_id)
                        (Pool_common.Id.value session.id)
                     |> Sihl.Web.externalize_path)
                 ]
               [ Message.(Edit (Some Field.Session))
                 |> Pool_common.Utils.control_to_string language
                 |> txt
               ]
           ]
          @
          (* TODO [aerben] should follow up be created on follow up? *)
          if CCOption.is_none session.follow_up_to
          then
            [ a
                ~a:
                  [ a_href
                      (Format.asprintf
                         "/admin/experiments/%s/sessions/%s/follow-up"
                         (Pool_common.Id.value experiment_id)
                         (Pool_common.Id.value session.id)
                      |> Sihl.Web.externalize_path)
                  ]
                [ Message.(Create (Some Field.FollowUpSession))
                  |> Pool_common.Utils.control_to_string language
                  |> txt
                ]
            ]
          else [])
      ]
  in
  let assignments_html =
    let assignment_list =
      Page_admin_assignments.Partials.overview_list
        context
        experiment_id
        assignments
    in
    div
      [ h2
          ~a:[ a_class [ "heading-2" ] ]
          [ txt Pool_common.(Utils.nav_link_to_string language I18n.Assignments)
          ]
      ; assignment_list
      ]
  in
  let html =
    div ~a:[ a_class [ "stack-lg" ] ] [ session_overview; assignments_html ]
  in
  Page_admin_experiments.experiment_layout
    language
    (Page_admin_experiments.I18n (session_title session))
    experiment_id
    html
;;

let edit_helper
    (title, subtitle, path, button)
    Pool_context.{ language; csrf; _ }
    experiment_id
    (session : Session.t)
    locations
    flash_fetcher
  =
  let open Session in
  let html =
    div
      [ p [ txt subtitle ]
      ; (let amount amt = amt |> ParticipantAmount.value |> string_of_int in
         form
           ~a:
             [ a_class [ "stack" ]
             ; a_method `Post
             ; a_action (Sihl.Web.externalize_path path)
             ]
           [ Component.csrf_element csrf ()
             (* TODO [aerben] use better formatted date *)
           ; flatpicker_element
               language
               `Datetime_local
               Pool_common.Message.Field.Start
               ~required:true
               ~value:(session.start |> Start.value |> Ptime.to_rfc3339)
               ~flash_fetcher
               ~warn_past:true
           ; flatpicker_element
               language
               `Time
               Pool_common.Message.Field.Duration
               ~help:Pool_common.I18n.TimeSpanPickerHint
               ~value:
                 (session.duration
                 |> Duration.value
                 |> Pool_common.Utils.Time.timespan_spanpicker)
               ~required:true
               ~flash_fetcher
           ; textarea_element
               language
               Pool_common.Message.Field.Description
               ~value:
                 (CCOption.map_or
                    ~default:""
                    Description.value
                    session.description)
               ~flash_fetcher
           ; location_select locations (Some session.location) ()
           ; input_element
               language
               `Number
               Pool_common.Message.Field.MaxParticipants
               ~required:true
               ~value:(amount session.max_participants)
               ~flash_fetcher
           ; input_element
               language
               `Number
               Pool_common.Message.Field.MinParticipants
               ~required:true
               ~value:(amount session.min_participants)
               ~flash_fetcher
           ; input_element
               language
               `Number
               ~help:Pool_common.I18n.Overbook
               Pool_common.Message.Field.Overbook
               ~required:true
               ~value:(amount session.overbook)
               ~flash_fetcher
           ; submit_element language button ~submit_type:`Success ()
           ])
      ]
  in
  Page_admin_experiments.experiment_layout
    language
    (Page_admin_experiments.Control title)
    experiment_id
    html
;;

let edit (Pool_context.{ language; _ } as ctx) eid (session : Session.t) =
  edit_helper
    ( Pool_common.Message.(Edit (Some Field.Session))
    , session |> session_title |> Pool_common.Utils.text_to_string language
    , Format.asprintf
        "/admin/experiments/%s/sessions/%s"
        (Pool_common.Id.value eid)
        (Pool_common.Id.value session.Session.id)
      |> Sihl.Web.externalize_path
    , Message.(Update (Some Field.Session)) )
    ctx
    eid
    session
;;

let follow_up (Pool_context.{ language; _ } as ctx) eid (session : Session.t) =
  edit_helper
    ( Message.(Create (Some Field.FollowUpSession))
    , Pool_common.Utils.(
        session
        |> session_title
        |> text_to_string language
        |> CCFormat.asprintf
             "%s %s"
             (Pool_common.I18n.FollowUpSessionFor |> text_to_string language))
    , Format.asprintf
        "/admin/experiments/%s/sessions/%s/follow-up"
        (Pool_common.Id.value eid)
        (Pool_common.Id.value session.Session.id)
      |> Sihl.Web.externalize_path
    , Message.(Create (Some Field.Session)) )
    ctx
    eid
    session
;;