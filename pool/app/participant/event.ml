module User = Common_user
module Id = Pool_common.Id
open Entity

type create =
  { email : Email.Address.t
  ; password : User.Password.t
  ; firstname : User.Firstname.t
  ; lastname : User.Lastname.t
  ; recruitment_channel : RecruitmentChannel.t
  ; terms_accepted_at : User.TermsAccepted.t
  }
[@@deriving eq, show]

type update =
  { firstname : User.Firstname.t
  ; lastname : User.Lastname.t
  ; paused : User.Paused.t
  }
[@@deriving eq, show]

let set_password
    :  Pool_common.Database.Label.t -> t -> string -> string
    -> (unit, string) result Lwt.t
  =
 fun db_pool { user; _ } password password_confirmation ->
  let open Lwt_result.Infix in
  Service.User.set_password
    ~ctx:[ "pool", Pool_common.Database.Label.value db_pool ]
    user
    ~password
    ~password_confirmation
  >|= ignore
;;

type event =
  | Created of create
  | DetailsUpdated of t * update
  | PasswordUpdated of t * User.Password.t * User.PasswordConfirmed.t
  | Disabled of t
  | Verified of t

let handle_event pool : event -> unit Lwt.t = function
  | Created participant ->
    let%lwt user =
      Service.User.create_user
        ~ctx:[ "pool", Pool_common.Database.Label.value pool ]
        ~name:(participant.firstname |> User.Firstname.value)
        ~given_name:(participant.lastname |> User.Lastname.value)
        ~password:(participant.password |> User.Password.to_sihl)
      @@ Email.Address.value participant.email
    in
    { user
    ; recruitment_channel = participant.recruitment_channel
    ; terms_accepted_at = participant.terms_accepted_at
    ; paused = User.Paused.create false
    ; disabled = User.Disabled.create false
    ; verified = User.Verified.create None
    ; created_at = Ptime_clock.now ()
    ; updated_at = Ptime_clock.now ()
    }
    |> Repo.insert pool
    |> CCFun.const Lwt.return_unit
  | DetailsUpdated (params, person) -> Repo.update person params
  | PasswordUpdated (person, password, confirmed) ->
    let%lwt _ =
      set_password
        pool
        person
        (password |> User.Password.to_sihl)
        (confirmed |> User.PasswordConfirmed.to_sihl)
    in
    Lwt.return_unit
  | Disabled _ -> Utils.todo ()
  | Verified _ -> Utils.todo ()
;;

let[@warning "-4"] equal_event (one : event) (two : event) : bool =
  match one, two with
  | Created m, Created p -> equal_create m p
  | DetailsUpdated (p1, one), DetailsUpdated (p2, two) ->
    equal p1 p2 && equal_update one two
  | PasswordUpdated (p1, one, _), PasswordUpdated (p2, two, _) ->
    equal p1 p2 && User.Password.equal one two
  | Disabled p1, Disabled p2 -> equal p1 p2
  | Verified p1, Verified p2 -> equal p1 p2
  | _ -> false
;;

let pp_event formatter (event : event) : unit =
  let person_pp = pp formatter in
  match event with
  | Created m -> pp_create formatter m
  | DetailsUpdated (p1, updated) ->
    person_pp p1;
    pp_update formatter updated
  | PasswordUpdated (person, password, _) ->
    person_pp person;
    User.Password.pp formatter password
  | Disabled p1 | Verified p1 -> person_pp p1
;;
