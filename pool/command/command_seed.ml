let root_data =
  let name = "seed.root" in
  let description = "Seed development data to root database" in
  Command_utils.make_no_args name description (fun () ->
    Database.Root.setup ();
    let%lwt () = Database.Root.Seed.create () in
    Lwt.return_some ())
;;

let root_data_clean =
  let name = "seed.root.clean" in
  let description =
    "Clean database and seed development data to root database"
  in
  Command_utils.make_no_args name description (fun () ->
    Database.Root.setup ();
    let%lwt () = Utils.Database.clean_all Database.Root.label in
    let%lwt () = Database.Root.Seed.create () in
    Lwt.return_some ())
;;

let tenant_data =
  let name = "seed.tenant" in
  let description = "Seed development data to tenant databases" in
  Command_utils.make_no_args name description (fun () ->
    let%lwt db_pools = Command_utils.setup_databases () in
    let%lwt () = Database.Tenant.Seed.create db_pools () in
    Lwt.return_some ())
;;

let tenant_data_clean =
  let name = "seed.tenant.clean" in
  let description =
    "Clean database and seed development data to tenant database"
  in
  Command_utils.make_no_args name description (fun () ->
    let%lwt db_pools = Command_utils.setup_databases () in
    let%lwt () =
      Lwt_list.iter_s
        (fun pool -> Utils.Database.clean_all (Pool_database.Label.value pool))
        db_pools
    in
    let%lwt () = Database.Tenant.Seed.create db_pools () in
    Lwt.return_some ())
;;

let tenant_seed_default =
  Command_utils.make_pool_specific
    "seed.tenant.default"
    "Seed default tables (without clean)"
    (fun pool ->
    let%lwt () =
      [ Settings.(DefaultRestored default_values) |> Pool_event.settings
      ; I18n.(DefaultRestored default_values) |> Pool_event.i18n
      ; Email.(DefaultRestored default_values_tenant |> Pool_event.email)
      ; Guard.(DefaultRestored root_permissions) |> Pool_event.guard
      ]
      |> Pool_event.handle_events pool
    in
    Lwt.return_some ())
;;
