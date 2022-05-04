module HttpUtils = Http_utils
module Message = HttpUtils.Message

let create_layout = Subject_general.create_layout

let create req =
  let open Utils.Lwt_result.Infix in
  let experiment_id =
    Sihl.Web.Router.param req Pool_common.Message.Field.(Experiment |> show)
    |> Pool_common.Id.of_string
  in
  let redirect_path =
    Format.asprintf "/experiments/%s" (Pool_common.Id.value experiment_id)
  in
  let result context =
    let open Lwt_result.Syntax in
    Lwt_result.map_err (fun err -> err, redirect_path)
    @@
    let tenant_db = context.Pool_context.tenant_db in
    let* experiment = Experiment.find tenant_db experiment_id in
    let* subject =
      Service.User.Web.user_from_session ~ctx:(Pool_tenant.to_ctx tenant_db) req
      ||> CCOption.to_result Pool_common.Message.(NotFound Field.User)
      >>= Subject.find_by_user tenant_db
    in
    let events =
      Cqrs_command.Waiting_list_command.Create.handle
        Waiting_list.{ subject; experiment }
      |> Lwt.return
    in
    let handle events =
      let%lwt (_ : unit list) =
        Lwt_list.map_s (Pool_event.handle_event tenant_db) events
      in
      Http_utils.redirect_to_with_actions
        redirect_path
        [ Message.set ~success:[ Pool_common.Message.(AddedToWaitingList) ] ]
    in
    events |>> handle
  in
  result |> HttpUtils.extract_happy_path req
;;
