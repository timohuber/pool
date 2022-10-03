open Tyxml.Html
open Component
module Message = Pool_common.Message

let make_link language field url control =
  let url =
    Format.asprintf
      "/admin/custom-fields/%s/%s"
      Custom_field.(field |> id |> Id.value)
      url
    |> Sihl.Web.externalize_path
  in
  a
    ~a:[ a_href url ]
    [ txt Pool_common.(control |> Utils.control_to_string language) ]
;;

let form
  ?(custom_field_option : Custom_field.SelectOption.t option)
  custom_field
  Pool_context.{ language; csrf; _ }
  tenant_languages
  =
  let open Custom_field in
  let base_path =
    Format.asprintf
      "/admin/custom-fields/%s/options"
      Custom_field.(custom_field |> id |> Id.value)
  in
  let action =
    match custom_field_option with
    | None -> base_path
    | Some o -> Format.asprintf "%s/%s" base_path (o.SelectOption.id |> Id.value)
  in
  let name_inputs =
    Page_admin_custom_fields.input_by_lang
      ~required:true
      language
      tenant_languages
      Message.Field.Name
      (fun lang ->
      let open CCOption in
      custom_field_option
      >|= (fun f -> f.SelectOption.name)
      >>= Name.find_opt lang
      >|= Name.value_name
      |> value ~default:"")
  in
  form
    ~a:
      [ a_method `Post
      ; a_action (Sihl.Web.externalize_path action)
      ; a_class [ "stack-lg" ]
      ]
    [ csrf_element csrf ()
    ; div ~a:[ a_class [ "stack" ] ] name_inputs
    ; submit_element
        language
        Message.(
          let field = Some Field.CustomField in
          match custom_field_option with
          | None -> Create field
          | Some _ -> Update field)
        ~submit_type:`Success
        ()
    ]
;;

let detail
  ?custom_field_option
  custom_field
  (Pool_context.{ language; _ } as context)
  sys_languages
  =
  let title =
    Pool_common.(
      Utils.control_to_string
        language
        Message.(
          if CCOption.is_none custom_field_option
          then Create (Some Field.CustomFieldOption)
          else Update (Some Field.CustomFieldOption)))
  in
  div
    ~a:[ a_class [ "trim"; "safety-margin"; "measure" ] ]
    [ h1 [ txt title ]
    ; div
        ~a:[ a_class [ "stack" ] ]
        [ form ?custom_field_option custom_field context sys_languages
        ; p
            [ make_link language custom_field "edit" Pool_common.Message.(Back)
            ]
        ]
    ]
;;
