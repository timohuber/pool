type t =
  | DashboardTitle
  | EmailConfirmationNote
  | EmailConfirmationTitle
  | ExperimentNewTitle
  | ExperimentListTitle
  | ExperimentWaitingListTitle
  | ExperimentContactEnrolledNote
  | HomeTitle
  | I18nTitle
  | InvitationListTitle
  | InvitationNewTitle
  | LoginTitle
  | NumberIsDaysHint
  | NumberIsWeeksHint
  | ResetPasswordLink
  | ResetPasswordTitle
  | SessionListTitle
  | SessionNewTitle
  | SessionUpdateTitle
  | SessionSignUpTitle
  | SignUpAcceptTermsAndConditions
  | SignUpTitle
  | TermsAndConditionsTitle
  | UserProfileLoginSubtitle
  | UserProfileDetailsSubtitle
  | UserProfileTitle
  | UserProfilePausedNote
  | WaitingListIsDisabled

type nav_link =
  | Dashboard
  | Experiments
  | I18n
  | Profile
  | Invitations
  | Sessions
  | Settings
  | Tenants
  | WaitingList
