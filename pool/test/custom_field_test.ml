module CustomFieldCommand = Cqrs_command.Custom_field_command

let boolean_fields =
  Custom_field.boolean_fields |> CCList.map Pool_common.Message.Field.show
;;

module Data = struct
  open Custom_field

  let sys_languages = Pool_common.Language.[ En; De ]
  let id = Id.create ()
  let model = Model.Contact
  let field_type = FieldType.Text
  let admin_hint = "hint"
  let name = CCList.map (fun l -> l, "name") sys_languages
  let hint = CCList.map (fun l -> l, "hint") sys_languages
  let validation_data = [ "text_length_max", "20" ]
  let disabled = false |> Disabled.create
  let required = false |> Required.create

  let data =
    Pool_common.Message.
      [ Field.(Model |> show), model |> Model.show
      ; Field.(FieldType |> show), field_type |> FieldType.show
      ; Field.(AdminHint |> show), admin_hint
      ]
    |> CCList.map (fun (f, l) -> f, l |> CCList.pure)
  ;;

  let custom_field =
    let get = CCResult.get_exn in
    let name = Name.create sys_languages name |> get in
    let hint = Hint.create hint |> get in
    let admin_hint = Admin.Hint.create admin_hint |> get in
    let admin =
      Admin.{ hint = Some admin_hint; overwrite = Overwrite.create false }
    in
    Custom_field.create
      ~id
      field_type
      model
      name
      hint
      validation_data
      required
      disabled
      admin
    |> CCResult.get_exn
  ;;

  let answer_id = Answer.Id.create ()

  let to_public (m : Custom_field.t) =
    let open Custom_field in
    let validation_schema schema =
      let validation = validation_to_yojson m in
      Custom_field.(Validation.(validation |> raw_list_of_yojson |> schema))
    in
    let field_type = get_field_type m in
    let id = get_id m in
    let hint = get_hint m in
    let name = get_name m in
    let answer_version = 0 |> Pool_common.Version.of_int in
    match field_type with
    | FieldType.Number ->
      let answer =
        Answer.{ id = answer_id; version = answer_version; value = 3 }
        |> CCOption.pure
      in
      let validation = validation_schema Validation.Number.schema in
      Public.(Public.Number { id; name; hint; validation; required; answer })
    | FieldType.Text ->
      let answer =
        Answer.{ id = answer_id; version = answer_version; value = "test" }
        |> CCOption.pure
      in
      let validation = validation_schema Validation.Text.schema in
      Public.(Text { id; name; hint; validation; required; answer })
  ;;
end

let database_label = Test_utils.Data.database_label

let create () =
  let open CCResult in
  let events =
    Data.data
    |> Http_utils.format_request_boolean_values boolean_fields
    |> CustomFieldCommand.base_decode
    >>= CustomFieldCommand.Create.handle
          ~id:Data.id
          Data.sys_languages
          Data.name
          Data.hint
          Data.validation_data
  in
  let expected =
    Ok [ Custom_field.Created Data.custom_field |> Pool_event.custom_field ]
  in
  Alcotest.(
    check
      (result (list Test_utils.event) Test_utils.error)
      "succeeds"
      expected
      events)
;;

let create_with_missing_name () =
  let open CCResult in
  let events =
    Data.data
    |> Http_utils.format_request_boolean_values boolean_fields
    |> CustomFieldCommand.base_decode
    >>= CustomFieldCommand.Create.handle
          ~id:Data.id
          Data.sys_languages
          (Data.name |> CCList.hd |> CCList.pure)
          Data.hint
          Data.validation_data
  in
  let expected = Error Pool_common.Message.(AllLanguagesRequired Field.Name) in
  Alcotest.(
    check
      (result (list Test_utils.event) Test_utils.error)
      "succeeds"
      expected
      events)
;;

let update () =
  let open CCResult in
  let events =
    Data.data
    |> Http_utils.format_request_boolean_values boolean_fields
    |> CustomFieldCommand.base_decode
    >>= CustomFieldCommand.Update.handle
          Data.sys_languages
          Data.custom_field
          Data.name
          Data.hint
          Data.validation_data
  in
  let expected =
    Ok [ Custom_field.Updated Data.custom_field |> Pool_event.custom_field ]
  in
  Alcotest.(
    check
      (result (list Test_utils.event) Test_utils.error)
      "succeeds"
      expected
      events)
;;
