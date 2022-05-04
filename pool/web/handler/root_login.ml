module HttpUtils = Http_utils
module Message = HttpUtils.Message
module Database = Pool_database

let ctx = Pool_tenant.(to_ctx Database.root)
let root_login_path = "/root/login"
let root_entrypoint_path = "/root/tenants"
let redirect_to_entrypoint = HttpUtils.redirect_to root_entrypoint_path

let login_get req =
  let open Lwt.Infix in
  let result context =
    Service.User.Web.user_from_session ~ctx req
    >>= function
    | Some _ -> redirect_to_entrypoint |> Lwt_result.ok
    | None ->
      let open Sihl.Web in
      Page.Root.Login.login context |> Response.of_html |> Lwt_result.return
  in
  result |> HttpUtils.extract_happy_path req
;;

let login_post req =
  let%lwt urlencoded = Sihl.Web.Request.to_urlencoded req in
  let result _ =
    Lwt_result.map_err (fun err -> err, root_login_path)
    @@
    let open Lwt_result.Syntax in
    let* params =
      HttpUtils.urlencoded_to_params urlencoded [ "email"; "password" ]
      |> CCOption.to_result Pool_common.Message.LoginProvideDetails
      |> Lwt_result.lift
    in
    let email = List.assoc "email" params in
    let password = List.assoc "password" params in
    let* user =
      Service.User.login ~ctx email ~password
      |> Lwt_result.map_err Pool_common.Message.handle_sihl_login_error
    in
    HttpUtils.redirect_to_with_actions
      root_entrypoint_path
      [ Sihl.Web.Session.set [ "user_id", user.Sihl_user.id ] ]
    |> Lwt_result.ok
  in
  result |> HttpUtils.extract_happy_path req
;;

let request_reset_password_get req =
  let result context =
    Lwt_result.map_err (fun err -> err, root_entrypoint_path)
    @@
    let open Utils.Lwt_result.Infix in
    let open Sihl.Web in
    Service.User.Web.user_from_session ~ctx req
    >|> function
    | Some _ -> redirect_to_entrypoint |> Lwt_result.ok
    | None ->
      Page.Root.Login.request_reset_password context
      |> Response.of_html
      |> Lwt.return_ok
  in
  result |> HttpUtils.extract_happy_path req
;;

let request_reset_password_post req =
  let%lwt result =
    let open Lwt_result.Syntax in
    let open Utils.Lwt_result.Infix in
    let open Pool_common.Message in
    let* context = Pool_context.find req |> Lwt_result.lift in
    let* email =
      Sihl.Web.Request.urlencoded Field.(Email |> show) req
      ||> CCOption.to_result (NotFound Field.Email)
    in
    let* user =
      Service.User.find_by_email_opt ~ctx email
      ||> CCOption.to_result PasswordResetFailMessage
    in
    let language = context.Pool_context.language in
    Email.Helper.PasswordReset.create Database.root language ~user
    >|= Service.Email.send ~ctx
  in
  match result with
  | Ok _ | Error _ ->
    HttpUtils.redirect_to_with_actions
      "/root/request-reset-password"
      [ Message.set ~success:[ Pool_common.Message.PasswordResetSuccessMessage ]
      ]
;;

let reset_password_get req =
  let result context =
    let open Sihl.Web in
    let open Lwt_result.Syntax in
    Lwt_result.map_err (fun err -> err, "/root/request-reset-password/")
    @@ let* token =
         let open Pool_common.Message in
         Request.query Field.(Token |> show) req
         |> CCOption.to_result (NotFound Field.Token)
         |> Lwt_result.lift
       in
       Page.Root.Login.reset_password token context
       |> Response.of_html
       |> Lwt_result.return
  in
  result |> HttpUtils.extract_happy_path req
;;

let reset_password_post req =
  let%lwt urlencoded = Sihl.Web.Request.to_urlencoded req in
  let result _ =
    let open Lwt_result.Syntax in
    let open Pool_common.Message in
    let* params =
      Field.[ Token; Password; PasswordConfirmation ]
      |> CCList.map Field.show
      |> HttpUtils.urlencoded_to_params urlencoded
      |> CCOption.to_result (PasswordResetInvalidData, "/root/reset-password/")
      |> Lwt_result.lift
    in
    let go field = field |> Field.show |> CCFun.flip List.assoc params in
    let token = go Field.Token in
    let* () =
      Service.PasswordReset.reset_password
        ~ctx
        ~token
        (go Field.Password)
        (go Field.PasswordConfirmation)
      |> Lwt_result.map_err (fun _ ->
             ( PasswordResetInvalidData
             , Format.asprintf "/root/reset-password/?token=%s" token ))
    in
    HttpUtils.redirect_to_with_actions
      root_login_path
      [ Message.set ~success:[ PasswordReset ] ]
    |> Lwt_result.ok
  in
  result |> HttpUtils.extract_happy_path req
;;

let logout _ =
  HttpUtils.redirect_to_with_actions
    root_login_path
    [ Sihl.Web.Session.set [ "user_id", "" ] ]
;;
