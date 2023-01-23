module TemplateCommand = Cqrs_command.Message_template_command
module Field = Pool_common.Message.Field

module Data = struct
  let urlencoded =
    Field.
      [ Language |> show, [ "DE" ]
      ; EmailSubject |> show, [ "Subject" ]
      ; EmailText |> show, [ "Lorem ipsum" ]
      ; SmsText |> show, [ "Lorem ipsum" ]
      ]
  ;;

  let label = Message_template.Label.ExperimentInvitation

  let create id entity_uuid =
    let open TemplateCommand.Create in
    urlencoded
    |> decode
    |> CCResult.get_exn
    |> fun { language; email_subject; email_text; sms_text } ->
    Message_template.
      { id
      ; label
      ; entity_uuid = Some entity_uuid
      ; language
      ; email_subject
      ; email_text
      ; sms_text
      }
  ;;
end

let test_create ?id ?entity_id available_languages expected =
  let open TemplateCommand.Create in
  let open CCResult in
  let entity_id =
    entity_id |> CCOption.value ~default:(Pool_common.Id.create ())
  in
  let events =
    Data.urlencoded
    |> decode
    >>= handle ?id Data.label entity_id available_languages
  in
  Test_utils.check_result expected events
;;

let create () =
  let entity_id = Pool_common.Id.create () in
  let id = Message_template.Id.create () in
  let template = Data.create id entity_id in
  let available_languages = Pool_common.Language.all in
  let expected =
    Ok Message_template.[ Created template |> Pool_event.message_template ]
  in
  test_create ~id ~entity_id available_languages expected
;;

let create_with_unavailable_language () =
  let available_languages = Pool_common.Language.[ En ] in
  let expected = Error Pool_common.Message.(Invalid Field.Language) in
  test_create available_languages expected
;;