include Entity
include Event

let find = Repo.find Database.root
let find_full = Repo.find_full Database.root
let find_by_label = Repo.find_by_label Database.root
let find_all = Repo.find_all Database.root
let find_databases = Repo.find_databases Database.root

type handle_list_recruiters = unit -> Sihl_user.t list Lwt.t
type handle_list_tenants = unit -> t list Lwt.t

module Selection = struct
  include Selection

  let find_all = Repo.find_selectable Database.root
end

(* Logo mappings *)
module LogoMapping = struct
  include LogoMapping
end

(* MONITORING AND MANAGEMENT *)

(* The system should proactively report degraded health to operators *)
type generate_status_report = StatusReport.t Lwt.t
