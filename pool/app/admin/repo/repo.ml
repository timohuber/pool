open Entity
module RepoPerson = Repo_person

let extract : type a. a Entity.carrier -> a Entity.t Caqti_type.t * string =
  let open Repo_person in
  let open Utils.Stringify in
  function
  | AssistantC -> assistant, person `Assistant
  | ExperimenterC -> experimenter, person `Experimenter
  | LocationManagerC -> location_manager, person `LocationManager
  | RecruiterC -> recruiter, person `Recruiter
  | OperatorC -> operator, person `Operator
  | RootC -> root, person `Root
;;

let find = Utils.todo
let insert = Utils.todo
let update _ = Utils.todo

let set_password
    : type person. person t -> string -> string -> (unit, string) result Lwt.t
  =
 fun person password password_confirmation ->
  let open Lwt_result.Infix in
  match person with
  | Assistant { user; _ }
  | Experimenter { user; _ }
  | LocationManager { user; _ }
  | Recruiter { user; _ }
  | Operator { user; _ }
  | Root { user; _ } ->
    Service.User.set_password user ~password ~password_confirmation
    >|= CCFun.const ()
;;
