Printexc.record_backtrace true

let () =
  let open Alcotest in
  run
    "cqrs commands"
    [ ( "contact"
      , [ test_case
            "sign up not allowed suffix"
            `Quick
            Contact_test.sign_up_not_allowed_suffix
        ; test_case "sign up" `Quick Contact_test.sign_up
        ; test_case
            "delete with unverified email"
            `Quick
            Contact_test.delete_unverified
        ; test_case
            "try delete with verified email"
            `Quick
            Contact_test.delete_verified
        ; test_case
            "update language of user"
            `Quick
            Contact_test.update_language
        ; test_case "update password" `Quick Contact_test.update_password
        ; test_case
            "update password with wrong current password"
            `Quick
            Contact_test.update_password_wrong_current_password
        ; test_case
            "update to short password according to policy"
            `Quick
            Contact_test.update_password_wrong_policy
        ; test_case
            "update password with wrong confirmation"
            `Quick
            Contact_test.update_password_wrong_confirmation
        ; test_case
            "request validation for new email address"
            `Quick
            Contact_test.request_email_validation
        ; test_case
            "request validation for wrong email suffix"
            `Quick
            Contact_test.request_email_validation_wrong_suffix
        ; test_case "update email" `Quick Contact_test.update_email
        ; test_case "verify email" `Quick Contact_test.verify_email
        ; test_case
            "accept terms and condition"
            `Quick
            Contact_test.accept_terms_and_conditions
        ] )
    ; ( "tenant"
      , [ test_case
            "create tenant smtp auth"
            `Quick
            Tenant_test.create_smtp_auth
        ; test_case "create tenant" `Quick Tenant_test.create_tenant
        ; test_case
            "update tenant details"
            `Quick
            Tenant_test.update_tenant_details
        ; test_case
            "update tenant database"
            `Quick
            Tenant_test.update_tenant_database
        ; test_case "create operator" `Quick Tenant_test.create_operator
        ] )
    ; ( "root"
      , [ test_case "create root" `Quick Root_test.create_root
        ; test_case
            "create root with invalid password"
            `Quick
            Root_test.create_root_with_invalid_password
        ] )
    ; ( "i18n"
      , [ test_case "create translation" `Quick I18n_test.create
        ; test_case
            "update terms and conditions"
            `Quick
            I18n_test.update_terms_and_conditions
        ] )
    ; ( "assignment"
      , [ test_case "create assignment" `Quick Assignment_test.create
        ; test_case
            "mark assignment as canceled"
            `Quick
            Assignment_test.canceled
        ; test_case
            "mark assignment as canceled with closed session"
            `Quick
            Assignment_test.canceled_with_closed_session
        ; test_case
            "set attendance on assignment"
            `Quick
            Assignment_test.set_attendance
        ; test_case
            "set invalid attendance on assignment"
            `Quick
            Assignment_test.set_invalid_attendance
        ; test_case
            "assign to fully booked session"
            `Quick
            Assignment_test.assign_to_fully_booked_session
        ; test_case
            "assign to session contact is already assigned"
            `Quick
            Assignment_test.assign_to_session_contact_is_already_assigned
        ; test_case
            "assign to experiment with direct registration disabled"
            `Quick
            Assignment_test
            .assign_to_experiment_with_direct_registration_disabled
        ; test_case
            "assign user from waiting list"
            `Quick
            Assignment_test.assign_contact_from_waiting_list
        ; test_case
            "assign contact from waiting_list to disabled experiment"
            `Quick
            Assignment_test
            .assign_contact_from_waiting_list_to_disabled_experiment
        ] )
    ; ( "invitation"
      , [ test_case "create invitation" `Quick Invitation_test.create
        ; test_case "resend invitation" `Quick Invitation_test.resend
        ] )
    ; ( "experiment"
      , [ test_case "create experiment" `Quick Experiment_test.create
        ; test_case
            "create experiment without title"
            `Quick
            Experiment_test.create_without_title
        ; test_case "upate experiment" `Quick Experiment_test.update
        ; test_case
            "delete experiment with sessions"
            `Quick
            Experiment_test.delete_with_sessions
        ; test_case
            "delete experiment with filter"
            `Quick
            Experiment_test.delete_with_filter
        ] )
    ; ( "waiting list"
      , [ test_case "sign up" `Quick Waiting_list_test.create
        ; test_case "sign off" `Quick Waiting_list_test.delete
        ; test_case
            "create with direct registration enabled"
            `Quick
            Waiting_list_test.create_with_direct_registration_enabled
        ; test_case "update comment" `Quick Waiting_list_test.update
        ] )
    ; "location", [ test_case "create location" `Quick Location_test.create ]
    ; ( "mailing"
      , [ test_case "create mailing" `Quick Mailing_test.create
        ; test_case
            "create mailing with distribution"
            `Quick
            Mailing_test.create_with_distribution
        ; test_case
            "create mailing with end before start"
            `Quick
            Mailing_test.create_end_before_start
        ] )
    ; ( "session"
      , [ test_case
            "create session empty data fails"
            `Quick
            Session_test.create_empty_data
        ; test_case
            "create session invalid data fails"
            `Quick
            Session_test.create_invalid_data
        ; test_case
            "create session min participants greater than max participants \
             fails"
            `Quick
            Session_test.create_min_gt_max
        ; test_case
            "create session optionals omitted succeeds"
            `Quick
            Session_test.create_no_optional
        ; test_case
            "create session all info succeeds"
            `Quick
            Session_test.create_full
        ; test_case
            "create session min participants equal max participants succeeds"
            `Quick
            Session_test.create_min_eq_max
        ; test_case
            "update session empty data fails"
            `Quick
            Session_test.update_empty_data
        ; test_case
            "update session invalid data fails"
            `Quick
            Session_test.update_invalid_data
        ; test_case
            "update session min participants greater than max participants \
             fails"
            `Quick
            Session_test.update_min_gt_max
        ; test_case
            "update session optionals omitted succeeds"
            `Quick
            Session_test.update_no_optional
        ; test_case
            "update session all info succeeds"
            `Quick
            Session_test.update_full
        ; test_case
            "update session min participants greater than max participants \
             succeeds"
            `Quick
            Session_test.update_min_eq_max
        ; test_case "delete session succeeds" `Quick Session_test.delete
        ; test_case
            "delete closed session fails"
            `Quick
            Session_test.delete_closed_session
        ; test_case
            "delete session with assignments fails"
            `Quick
            Session_test.delete_session_with_assignments
        ; test_case
            "cancel session without reason fails"
            `Quick
            Session_test.cancel_no_reason
        ; test_case
            "cancel session without message channels fails"
            `Quick
            Session_test.cancel_no_message_channels
        ; test_case
            "cancel session in past fails"
            `Quick
            Session_test.cancel_in_past
        ; test_case
            "cancel session already canceled fails"
            `Quick
            Session_test.cancel_already_canceled
        ; test_case "cancel session succeeds" `Quick Session_test.cancel_valid
        ; test_case
            "send reminders for session succeeds"
            `Quick
            Session_test.send_reminder
        ; test_case
            "create follow up earlier than parent fails"
            `Quick
            Session_test.create_follow_up_earlier
        ; test_case
            "create follow up later than parent succeeds"
            `Quick
            Session_test.create_follow_up_later
        ; test_case
            "update follow up earlier than parent fails"
            `Quick
            Session_test.update_follow_up_earlier
        ; test_case
            "update follow up later than parent succeeds"
            `Quick
            Session_test.update_follow_up_later
        ; test_case
            "update with follow ups earlier fails"
            `Quick
            Session_test.update_follow_ups_earlier
        ; test_case
            "update with follow ups later succeeds"
            `Quick
            Session_test.update_follow_ups_later
        ; test_case
            "reschedule session to past"
            `Quick
            Session_test.reschedule_to_past
        ] )
    ; ( "custom_field"
      , [ test_case "create custom field" `Quick Custom_field_test.create
        ; test_case
            "create custom field with missing name"
            `Quick
            Custom_field_test.create_with_missing_name
        ; test_case "update custom field" `Quick Custom_field_test.update
        ; test_case
            "update field type of published field"
            `Quick
            Custom_field_test.update_type_of_published_field
        ; test_case
            "crate custom field option"
            `Quick
            Custom_field_test.create_option
        ; test_case
            "create with missing admin option"
            `Quick
            Custom_field_test.create_with_missing_admin_option
        ; test_case
            "delete published field"
            `Quick
            Custom_field_test.delete_published_field
        ; test_case
            "delete published field option"
            `Quick
            Custom_field_test.delete_published_option
        ] )
    ; ( "matcher"
      , [ test_case
            "create invitations"
            `Quick
            Matcher_test.create_invitations_model
        ] )
    ; ( "message template"
      , [ test_case
            "create message template"
            `Quick
            Message_template_test.create
        ; test_case
            "create message template with invalid language"
            `Quick
            Message_template_test.create_with_unavailable_language
        ] )
    ]
;;
