open Tyxml.Html
open Statistics
module Field = Pool_common.Message.Field

let create
  language
  ( period
  , { active_contacts
    ; pending_contact_imports
    ; login_count
    ; sign_up_count
    ; assignments_created
    ; invitations_sent
    ; reminders_sent
    } )
  =
  let open Pool_common in
  let open Statistics in
  let to_txt value = txt (CCInt.to_string value) in
  let period_select =
    let attributes =
      [ a_user_data "hx-get" (Sihl.Web.externalize_path "/admin/statistics")
      ; a_user_data "hx-swap" "outerHTML"
      ; a_user_data "hx-target" "closest [data-statistics]"
      ]
    in
    Component_input.selector
      ~option_formatter:(period_to_human language)
      ~attributes
      language
      Field.Period
      show_period
      all_periods
      period
      ()
  in
  let create_table title figures =
    [ h3
        ~a:[ a_class [ "heading-3" ] ]
        [ txt (Utils.nav_link_to_string language title) ]
    ; Component_table.vertical_table
        ~classnames:[ "fixed" ]
        `Striped
        language
        figures
    ]
  in
  let user_figures =
    [ ActiveContacts.(field, to_txt (value active_contacts))
    ; PendingContactImports.(field, to_txt (value pending_contact_imports))
    ; LoginCount.(field, to_txt (value login_count))
    ; SignUpCount.(field, to_txt (value sign_up_count))
    ]
  in
  let experiment_figures =
    [ AssignmentsCreated.(field, to_txt (value assignments_created))
    ; InvitationsSent.(field, to_txt (value invitations_sent))
    ; RemindersSent.(field, to_txt (value reminders_sent))
    ]
  in
  div
    Pool_common.I18n.(
      create_table Contacts user_figures
      @ create_table Experiments experiment_figures)
  |> fun table ->
  div
    ~a:[ a_class [ "flexcolumn"; "stack" ]; a_user_data "statistics" "" ]
    [ period_select; table ]
;;