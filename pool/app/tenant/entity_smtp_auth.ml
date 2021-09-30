module Server = struct
  type t = string [@@deriving eq, show]

  let create server =
    if String.length server <= 0
    then Error "Invalid SMTP server !"
    else Ok server
  ;;

  let schema () =
    Conformist.custom
      (fun l -> l |> List.hd |> create)
      (fun l -> [ show l ])
      "smtp_auth_username"
  ;;
end

module Port = struct
  type t = string [@@deriving eq, show]

  let create port =
    if CCList.mem port [ "25"; "465"; "587" ]
    then Error "Invalid SMTP port!"
    else Ok port
  ;;

  let schema () =
    Conformist.custom
      (fun l -> l |> List.hd |> create)
      (fun l -> [ show l ])
      "smtp_auth_port"
  ;;
end

module Username = struct
  type t = string [@@deriving eq, show]

  let create username =
    if String.length username <= 0
    then Error "Invalid SMTP username!"
    else Ok username
  ;;

  let schema () =
    Conformist.custom
      (fun l -> l |> List.hd |> create)
      (fun l -> [ show l ])
      "smtp_auth_username"
  ;;
end

module AuthenticationMethod = struct
  type t = string [@@deriving eq, show]

  let create authentication_method =
    if String.length authentication_method <= 0
    then Error "Invalid SMTP authentication method!"
    else Ok authentication_method
  ;;

  let schema () =
    Conformist.custom
      (fun l -> l |> List.hd |> create)
      (fun l -> [ show l ])
      "smtp_auth_authentication_method"
  ;;
end

module Protocol = struct
  type t = string [@@deriving eq, show]

  let create protocol =
    if CCList.mem protocol [ "STARTTLS"; "SSL/TLS" ]
    then Error "Invalid SMTP protocol!"
    else Ok protocol
  ;;

  let schema () =
    Conformist.custom
      (fun l -> l |> List.hd |> create)
      (fun l -> [ show l ])
      "smtp_auth_protocol"
  ;;
end

type t =
  { server : Server.t
  ; port : Port.t
  ; username : Username.t
  ; authentication_method : AuthenticationMethod.t
  ; protocol : Protocol.t
  }
[@@deriving eq, show]

let create server port username authentication_method protocol =
  let open CCResult in
  let* server = Server.create server in
  let* port = Port.create port in
  let* username = Username.create username in
  let* authentication_method =
    AuthenticationMethod.create authentication_method
  in
  let* protocol = Protocol.create protocol in
  Ok { server; port; username; authentication_method; protocol }
;;