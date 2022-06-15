type t =
  | DashboardTitle
  | EmailConfirmationNote
  | EmailConfirmationTitle
  | EmtpyList of Entity_message.Field.t
  | ExperimentContactEnrolledNote
  | ExperimentListTitle
  | ExperimentWaitingListTitle
  | Files
  | HomeTitle
  | I18nTitle
  | LocationFileNew
  | LocationListTitle
  | LocationNewTitle
  | LocationNoFiles
  | LocationNoSessions
  | LoginTitle
  | MailingDetailTitle of Ptime.t
  | MailingNewTitle
  | RateTotalSent of int
  | ResetPasswordLink
  | ResetPasswordTitle
  | SessionDetailTitle of Ptime.t
  | SessionSignUpTitle
  | SignUpAcceptTermsAndConditions
  | SignUpTitle
  | TermsAndConditionsTitle
  | UserProfileDetailsSubtitle
  | UserProfileLoginSubtitle
  | UserProfilePausedNote
  | UserProfileTitle
  | WaitingListIsDisabled

type nav_link =
  | Assignments
  | Dashboard
  | Experiments
  | I18n
  | Invitations
  | Locations
  | LoginInformation
  | Logout
  | Mailings
  | Overview
  | PersonalDetails
  | Profile
  | Sessions
  | Settings
  | Tenants
  | WaitingList
[@@deriving eq]

type hint =
  | AssignContactFromWaitingList
  | DirectRegistrationDisbled
  | Distribution
  | NumberIsDaysHint
  | NumberIsSecondsHint
  | NumberIsWeeksHint
  | Overbook
  | Rate
  | RateDependencyWith
  | RateDependencyWithout
  | RateNumberPerMinutes of int * float
  | RegistrationDisabled
  | SignUpForWaitingList

type confirmable =
  | CancelSession
  | DeleteEmailSuffix
  | DeleteExperiment
  | DeleteFile
  | DeleteSession
