open Entity_i18n

let capitalize = CCString.capitalize_ascii
let error_to_string = Locales_en.error_to_string

let to_string = function
  | Activity -> "activity"
  | Address -> "address"
  | AdminComment -> "admin comment"
  | AnnouncementsListTitle -> "Announcements"
  | AnnouncementsTenantSelect ->
    "Select on which tenants the announcement should be displayed."
  | ApiKeys -> "API Keys"
  | Assigned -> "assigned"
  | AssignmentEditTagsWarning ->
    "Please note that editing the assignment does not assign or remove any tags from the \
     contact that may have been assigned by participating in this session. If this is \
     required, please get in touch with a person with the necessary permissions."
  | AssignmentListEmpty -> "There are no assignments for this session."
  | Available -> "available"
  | AvailableSpots -> "Available spots"
  | Canceled -> "Canceled"
  | CanceledSessionsTitle -> "Your canceled sessions"
  | Closed -> "Closed"
  | ContactWaitingListEmpty -> "You are currently not on any waiting list."
  | CustomFieldsSettings ->
    "In the following list, you can determine in which table the custom data should be \
     displayed in addition to the contact details."
  | CustomFieldsSettingsCloseScreen ->
    "This view is displayed when a session is closed. Users with the authorization to \
     end a session can see this information."
  | CustomFieldsSettingsDetailScreen ->
    "This information is displayed on the details page of all sessions. Users with read \
     permission for a session can see this information."
  | DashboardProfileCompletionText ->
    "Your profile is incomplete. To be invited to more experiments, fulfill your profile."
  | DashboardProfileCompletionTitle -> "Profile completion"
  | DashboardTitle -> "Dashboard"
  | DeletedAssignments -> "Deleted assignments"
  | Disabled ->
    Locales_en.field_to_string Pool_message.Field.Disabled |> CCString.capitalize_ascii
  | DontHaveAnAccount -> "Don't have an account?"
  | EmailConfirmationNote -> "Please check your emails and confirm your address first."
  | EmailConfirmationTitle -> "Email confirmation"
  | EmptyListGeneric -> "No entries were found."
  | EmtpyList field ->
    Format.asprintf
      "Currently, there are no %s available."
      (Locales_en.field_to_string field)
  | EnrollInExperiment -> "Enroll in experiment"
  | ExperimentHistory -> "Experiment history"
  | ExperimentListEmpty -> "Currently, there are no experiments you can participate in."
  | ExperimentListPublicTitle -> "Registering for experiment sessions"
  | ExperimentOnlineListEmpty ->
    "Currently, there are no online surveys you can participate in."
  | ExperimentOnlineListPublicTitle -> "Available online surveys"
  | ExperimentOnlineParticiated submitted ->
    Format.asprintf
      "You completed this survey on %s."
      (Utils.Ptime.formatted_date submitted)
  | ExperimentOnlineParticipationDeadline end_at ->
    Format.asprintf
      "You can participate in this experiment until %s."
      (Pool_model.Time.formatted_date_time end_at)
  | ExperimentOnlineParticipationUpcoming start_at ->
    Format.asprintf
      "The next window for participation in this survey begins on %s."
      (Pool_model.Time.formatted_date_time start_at)
  | ExperimentOnlineParticipationNoUpcoming ->
    "There are currently no further time windows for participation in this survey are \
     planned."
  | ExperimentListTitle -> "Experiments"
  | ExperimentMessagingSubtitle -> "Identities"
  | ExperimentNewTitle -> "Create new experiment"
  | ExperimentSessionReminderHint ->
    "These are default settings for the sessions of this experiment. These settings can \
     be overwritten for each session."
  | ExperimentStatistics -> "Experiment statistics"
  | ExperimentWaitingListTitle -> "Waiting list"
  | Files -> "Files"
  | FilterContactsDescription ->
    {|<p>To start inviting contacts to this experiment, follow those steps:</p>
    <ol>
      <li>Create a filter using one or multiple conditions to define which contacts you would like to include in this experiment.</li>
      <li>Create the sessions on which you want to perform the experiment.</li>
      <li>Create one or more mailings to start sending out emails to these participants.</li>
    </ol>|}
  | FilterNrOfContacts -> "Number of contacts meeting the criteria of this filter:"
  | FilterNrOfSentInvitations -> "Number of contacts already invited:"
  | FilterNrOfUnsuitableAssignments ->
    "Number of assigned contacts not meeting the criteria of this filter:"
  | FilterNuberMatchingUninvited -> "Possible new invitations:"
  | FollowUpSessionFor -> "Follow-up for:"
  | HasGlobalRole role -> Format.asprintf "Has global %s role" role
  | Help -> "Help"
  | ImportConfirmationNote ->
    "Please enter a new password. The rest of your data has been automatically taken \
     over."
  | ImportConfirmationTitle -> "New password"
  | ImportPendingNote ->
    "The import of your user is not completed yet. Please check your inbox or contact an \
     administrator."
  | ImportPendingTitle -> "Pending import"
  | IncompleteSessions -> "Incomplete sessions"
  | InvitationsStatistics -> "Invitation statistics"
  | InvitationsStatisticsIntro ->
    "This table shows how often contacts received the invitation to this experiment."
  | Iteration -> "Iteration"
  | JobCloneOf -> "This job is a clone of"
  | LocationDetails -> "Location details"
  | LocationFileNew -> "Add file to location"
  | LocationListTitle -> "Location"
  | LocationNewTitle -> "Create new location"
  | LocationNoFiles -> "There are no files for this location."
  | LocationNoSessions -> "No sessions found for this location."
  | LocationStatistics -> "Location statistics"
  | LoginTitle -> "Login"
  | MailingDetailTitle start ->
    Format.asprintf "Mailing at %s" (Pool_model.Time.formatted_date_time start)
  | MailingDistributionDescription ->
    {|<ol>
    <li>Select by which field and in which order you want to sort the contacts.</li>
    <li>Press the 'add' button to add the sorting parameter.</li>
    <li>Repeat that to add more parameters. You can sort them by dragging and dropping them.</li>
  </ol>
<br>
<strong>Entries with identical sort values ('field') are used in random order.</strong>|}
  | MailingExperimentNoUpcomingSession ->
    "There are no sessions to which contacts can sign up. No invitations will be sent. \
     Create new sessions before you start the mailing."
  | MailingExperimentNoUpcomingTimewindow ->
    "There is no active or future time window during which participants can answer the \
     survey. No invitations will be sent. Create a time window first."
  | MailingExperimentSessionFullyBooked ->
    "All sessions are fully booked. No invitations will be sent (independent if mailings \
     are active at the moment).\n\n\
     Add additional sessions to the experiment."
  | MailingNewTitle -> "Create new mailing"
  | MatchesFilterChangeReasonFilter ->
    "This message was triggered by an update to the experiment filter."
  | MatchesFilterChangeReasonManually -> "The message was manually triggered."
  | MatchesFilterChangeReasonWorker ->
    "This message was triggered by a background job that repeatedly checks if future \
     assignments match the experiments filter."
  | MessageHistory name -> Format.asprintf "Message history of %s" name
  | NoEntries field ->
    Format.asprintf "There are no %s yet." (Locales_en.field_to_string field)
  | Note -> "Note"
  | NotMatchingFilter ->
    "The contact does not meet the criteria specified in the filter for this experiment."
  | NoInvitationsSent -> "No invitations have been sent yet."
  | OurPartners -> "Our partners"
  | Past -> "Past"
  | PastSessionsTitle -> "Your past sessions"
  | PoolStatistics -> "Pool statistics"
  | ProfileCompletionText ->
    {|The following information is required to be invited to experiments. Further information can be entered in your profile afterwards.

    You will be considered for more experiments, the more complete your profile is.|}
  | Reminder -> "Reminder"
  | ResendReminders -> "Resend reminders"
  | Reset -> "Reset"
  | ResetPasswordLink | ResetPasswordTitle -> "Reset password"
  | RoleApplicableToAssign -> "Applicable users"
  | RoleCurrentlyAssigned -> "Currently assigned"
  | RoleCurrentlyNoneAssigned field ->
    Format.asprintf
      "Currently, there are no %s assigned."
      (Locales_en.field_to_string field)
  | RolesGranted -> "Granted roles"
  | SelectedTags -> "Currently assigned tags"
  | SelectedTagsEmpty -> "No tags assigned"
  | SessionCloseScreen -> "Session close screen"
  | SessionDetailScreen -> "Session detail screen"
  | SessionDetailTitle start ->
    Format.asprintf "Session at %s" (Pool_model.Time.formatted_date_time start)
  | SessionIndent -> "Indentations group follow-up sessions."
  | SessionRegistrationTitle -> "Registering for this session"
  | SessionReminder -> "Session reminder"
  | SignUpAcceptTermsAndConditions -> "I accept the terms and conditions."
  | SignUpTitle -> "Sign up"
  | SortUngroupedFields -> "Sort ungrouped fields"
  | SwapSessionsListEmpty ->
    "No sessions were found to which you can assign this contact."
  | SwitchChronological -> "Switch to chronological view"
  | SwitchGrouped -> "Switch to grouped view"
  | System -> "System"
  | TermsAndConditionsLastUpdated ptime ->
    Format.asprintf "Last updated: %s" (Pool_model.Time.formatted_date ptime)
  | TermsAndConditionsTitle -> "Terms and Conditions"
  | TermsAndConditionsUpdated ->
    "We have recently changed our terms and conditions. Please read and accept them to \
     continue."
  | TenantMaintenanceText -> "Please try again shortly."
  | TenantMaintenanceTitle -> "Maintenance"
  | TextTemplates -> "text templates"
  | TimeWindowDetailTitle string -> string
  | TotalSentInvitations -> "Total invited contacts"
  | UpcomingSessionsListEmpty ->
    "You are not currently enrolled in any upcoming sessions."
  | UpcomingSessionsTitle -> "Your upcoming sessions"
  | UserLoginBlockedUntil blocked_until ->
    Format.asprintf
      "Due to too many failed login attempts, this account is blocked until %s."
      (Pool_model.Time.formatted_date_time blocked_until)
  | UserProfileDetailsSubtitle -> "Personal details"
  | UserProfileLoginSubtitle -> "Login information"
  | UserProfilePausedNote ->
    "You paused all notifications for your user! (Click 'edit' to update this setting)"
  | Validation -> "Validation"
  | VersionsListTitle -> "Release notes"
  | WaitingListIsDisabled -> "The waiting list is disabled."
;;

let nav_link_to_string = function
  | ActorPermissions -> "Personal Permissions"
  | Admins -> "Admins"
  | Announcements -> "Announcements"
  | ApiKeys -> "API Keys"
  | Assignments -> "Assignments"
  | ContactInformation -> "Contact information"
  | Contacts -> "Contacts"
  | Credits -> "Credits"
  | CustomFields -> "Fields"
  | Dashboard -> "Dashboard"
  | Experiments -> "Experiments"
  | ExperimentsCustom str -> str
  | ExternalDataIds -> "External data ids"
  | Field field -> Locales_en.field_to_string field |> CCString.capitalize_ascii
  | Filter -> "Filter"
  | I18n -> "Texts"
  | Invitations -> "Invitations"
  | Locations -> "Locations"
  | Login -> "Login"
  | LoginInformation -> "Login information"
  | ManageDuplicates -> "Manage duplicates"
  | Logout -> "Logout"
  | Mailings -> "Mailings"
  | MessageHistory -> "Message history"
  | MessageTemplates -> "Message templates"
  | OrganisationalUnits -> "Organisational units"
  | Overview -> "Overview"
  | ParticipationTags -> "Participation tags"
  | PersonalDetails -> "Personal details"
  | Pools -> "Pools"
  | PrivacyPolicy -> "Privacy policy"
  | Profile -> "Profile"
  | Queue -> "Queued jobs"
  | QueueHistory -> "Job history"
  | RolePermissions -> "Role permission"
  | Schedules -> "Schedules"
  | SentInvitations -> "Sent invitations"
  | Sessions -> "Sessions"
  | Settings -> "Settings"
  | Smtp -> "Email Server (SMTP)"
  | SystemSettings -> "System settings"
  | SignupCodes -> "Signup Codes"
  | Tags -> "Tags"
  | TextMessages -> "Text messages"
  | TimeWindows -> "Time windows"
  | Users -> "Users"
  | WaitingList -> "Waiting list"
  | Versions -> "Release notes"
;;

let rec hint_to_string = function
  | AdminOverwriteContactValues ->
    {|If you overwrite one of the following values, this is not apparent to the contact. If a value entered by the contact is overridden, the overridden value is displayed below the input field.

When inviting contacts, the filter will prefer the overriding value if both are available.|}
  | AllowUninvitedSignup ->
    "All contacts (invited or not) will be able to sign up for the experiment."
  | AssignContactFromWaitingList ->
    "Select the session to which you want to assign the contact."
  | AssignmentCancellationMessageFollowUps ->
    "Your assignments to the following sessions have also been cancelled:"
  | AssignmentConfirmationMessageFollowUps ->
    "You also have been assigned to the following followup sessions:"
  | AssignmentsMarkedAsClosed ->
    "These assignments have been marked as deleted. Provided that the contacts still \
     meet the experiment criteria, they can register for sessions again."
  | AssignmentsNotMatchingFilerSession count ->
    Format.asprintf "%s die Kriterien dieses Experiments nicht."
    @@
      (match count with
      | 1 -> "1 Kontakt erfüllt"
      | count -> Format.asprintf "%i Kontakte erfüllen" count)
  | AssignmentWithoutSession ->
    "Activate this option if participation in the experiment is not tied to a session, \
     e.g. in an online survey."
  | ContactAccountPaused ->
    "Your account is paused. You will not be invited to any further experiments. You can \
     reactivate your account in your user profile"
  | ContactCurrentCellPhone cell_phone ->
    Format.asprintf "Your current phone number is %s." cell_phone
  | ContactEnrollmentDoesNotMatchFilter ->
    "The contact does not meet the criteria specified in the filter for this experiment, \
     but can still be enrolled."
  | ContactEnrollmentRegistrationDisabled ->
    "Registration for this experiment is currently disabled. Contacts cannot enroll \
     themselves for this experiment."
  | ContactEnterCellPhoneToken cell_phone ->
    Format.asprintf
      "Please enter the verification code we sent yout to %s. The code is valid for one \
       hour."
      cell_phone
  | ContactExperimentNotMatchingFilter ->
    "You no longer fulfill the conditions for participating in this experiment."
  | ContactExperimentHistory -> "All experiments you have participated in."
  | ContactInformationEmailHint ->
    "To change your e-mail address, please follow this link."
  | ContactLanguage ->
    "Some experiments choose to communicate in a different language, disregarding your \
     contact language."
  | ContactNoCellPhone -> "You have not yet verified a phone number."
  | ContactOnWaitingList ->
    "You are on the waiting list. The recruitment team will assign you to a session."
  | ContactPhoneNumberVerificationWasReset ->
    "You can enter a different phone number now."
  | ContactProfileVisibleOverride ->
    "If you overwrite these values, the changes will be visible to the contact."
  | ContactsWithoutCellPhone -> "The following contacts do not have a cell phone saved:"
  | CustomFieldAdminInputOnly ->
    Format.asprintf
      "This option excludes \"%s\"."
      (Locales_en.field_to_string Pool_message.Field.Required |> CCString.capitalize_ascii)
  | CustomFieldAdminOverride ->
    "Allows administrators to override the answers specified by the contact. Contacts \
     cannot view the overridden answers."
  | CustomFieldAdminOverrideUpdate ->
    "Unchecking this option will make the filter ignore all currently existing \
     overridden answers."
  | CustomFieldAdminViewOnly ->
    Format.asprintf
      "This option implies \"%s\"."
      (Locales_en.field_to_string Pool_message.Field.AdminInputOnly
       |> CCString.capitalize_ascii)
  | CustomFieldAnsweredOnRegistration ->
    "This field has already been answered by the contact during registration and can no \
     longer be changed by the contact him- or herself."
  | CustomFieldContactModel ->
    "Questions that contacts can, or must, answer. Based on this information, contacts \
     are invited to take part in experiments."
  | CustomFieldDuplicateWeight ->
    "The weighting when comparing contacts in the search for possible duplicates. Can be \
     a value between 1 and 10. If the field is left empty, this custom field is not used \
     for duplicate detection."
  | CustomFieldExperimentModel -> "Customziable attributes for experiments."
  | CustomFieldGroups ->
    {|Groups to group custom fields by. Grouping custom fields does not have any effect on their functionality. It only has a graphical impact.|}
  | CustomFieldNoContactValue -> "Not answered by contact"
  | CustomFieldOptionsCompleteness ->
    "Make sure this list is complete or add an option to select if none of the others \
     are applicable."
  | CustomFieldPromptOnRegistration ->
    "If this option is enabled, this field is already prompted during registration, but \
     is no longer displayed to the contact in the user profile."
  | CustomFieldSessionModel -> "Customziable attributes for sessions."
  | CustomFieldSort field ->
    Format.asprintf
      "The %s will be displayed to the contacts in this order."
      (Locales_en.field_to_string field)
  | CustomFieldTypeMultiSelect -> hint_to_string CustomFieldTypeSelect
  | CustomFieldTypeSelect ->
    "You will be able to create the available options in the section 'Option' after the \
     custom field is created."
  | CustomFieldTypeText ->
    "Please take into account that the data quality is lower for text entries. If the \
     data can be collected in another form, this is preferable."
  | CustomHtmx s -> s
  | DashboardDuplicateContactsNotification count ->
    Format.asprintf
      "%i possible duplicate %s been found. Please take the necessary measures."
      count
      (if count = 1 then "contact has" else "contacts have")
  | DefaultReminderLeadTime lead_time ->
    Format.asprintf
      "If left blank, the default lead time of %s is applied."
      (lead_time |> Pool_model.Time.formatted_timespan)
  | DeleteContact ->
    "The user is marked as deleted and can no longer log in. This action cannot be \
     undone."
  | DirectRegistrationDisbled ->
    "If this option is enabled, contacts can join the waiting list but cannot directly \
     enroll in the experiment."
  | Distribution ->
    "The distribution can be used to influence which invitations are sent first."
  | DuplicateSession ->
    "The session will be duplicated with all its follow-up sessions. The information of \
     the session and its follow-ups will be transferred to its corresponding clone."
  | DuplicateSessionList -> "The following sessions will be cloned:"
  | EmailPlainText ->
    {|Using plain text email as a fallback ensures universal readability and accessibility. You can copy the rich text from above by using the button on the top right corner of this textarea.
Make sure to show links and URLs as plain text.
  |}
  | ExperimentAssignment ->
    "All assignments of contacts to sessions of this experiment, sorted by session."
  | ExperimentCallbackUrl ->
    "Participants in an online survey should be redirected to this URL after completing \
     the survey so that the assignment can be completed. If the contact is not \
     redirected, the participated flag will not be set."
  | ExperimentContactPerson default ->
    Format.asprintf
      "This email address will be used as 'reply-to' address for all experiment-related \
       emails. The default 'reply-to' address is '%s'."
      default
  | ExperimentLanguage ->
    "If an experiment language is defined, all messages regarding this experiment will \
     be sent in this language, disregarding the contact language."
  | ExperimentMailings ->
    {|Invitation mailings of this experiment. The limit defines the number of invitations sent by the mailing withing it's duration.

    Check the No. Invitations to see how many of the invitations where already sent/handled.
    In case there are multiple mailings running at the same time, the server might has to reduce the amount and thus doesn't reach the desired limit.

    Started mailings can no longer be deleted.|}
  | ExperimentMailingsRegistrationDisabled ->
    {|Registration to this experiment is currently disabled. Invitations will still be sent out if a mailing is created, but contacts won't be able to sign up for a session.|}
  | ExperimentMessageTemplates ->
    {|Messages sent to contacts regarding this experiment or session can be customized if you want to add or remove information. The template is selected in the following hierarchy: session-specific > experiment-specific > default.

If an experiment language is specified, all messages will be sent in this language. The messages will be sent in the contact display language if no experiment-specific language is defined.

By clicking on the template labels below you can open the default text message:
|}
  | ExperimentSessions ->
    {|All existing session of this experiment.
Once someone has registered for the session, it can no longer be deleted.
    |}
  | ExperimentTimewindows ->
    {|All existing timewindows of this experiment.
Once someone started the survey, it can no longer be deleted.|}
  | ExperimentSessionsCancelDelete ->
    {|Canceling an assignment will inform the contact. The concat will be able to sign up for this experiment again.
  Marking an assignment as deleted will not inform the contact. The contact will not be able to sign up for this experiment again.|}
  | ExperimentSessionsPublic ->
    "Please note: Sessions or completed experiments may no longer be displayed, although \
     listed in your email. Once all the available seats are assigned, a session is no \
     longer displayed."
  | ExperimentSmtp default ->
    Format.asprintf
      "The email account that will be used to send all experiment-related emails. The \
       default account is '%s'."
      default
  | ExperimentStatisticsRegistrationPossible ->
    "This is considered true if registration is not disabled and there are future \
     sessions with available slots."
  | ExperimentStatisticsSendingInvitations ->
    {|Sending: A mailing is currently running.

Scheduled: No mailing is running, but future mailings are scheduled.|}
  | ExperimentWaitingList ->
    "Contacts that have been invited to this experiment and have placed themselves on \
     the waiting list. They have to be manually assigned to a session."
  | ExperimentSurveyRedirectUrl ->
    "<strong>Use for online surveys only.</strong> This URL creates an assignment for \
     the experiment and forwards the contact directly to the URL of the online survey. \
     Alternatively, {experimentUrl} can be used, with the difference that the contact \
     must also confirm the participation and forwarding."
  | ExperimentSurveyUrl ->
    "<strong>Use for online surveys only.</strong> The external URL of the online \
     survey. If the URL of the survey is sent in the invitation, invited contacts can \
     start it without creating an assignment. You cannot see who participated in the \
     survey in the assignment overview.<br/><strong>Dynamic URL parameters in your \
     survey URL, like the <code>callbackUrl</code>, will not be replaced by actual \
     values.</strong>"
  | ExternalDataRequired ->
    "An external data identifier is required for every assignement (latest when a \
     session is closed)."
  | FileUploadAcceptMime types ->
    types
    |> CCString.concat ", "
    |> Format.asprintf "The following mime types are accepted: %s"
  | FilterTemplates ->
    "Changes to one of these filters will affect all experiment filters that contain \
     this template."
  | GtxKeyMissing -> "No GTX Api key is stored, which is why no text messages are sent."
  | GtxKeyStored -> "A GTX Api key is stored. Text message service is running."
  | GtxSender -> "The displayed sender of text messages. Max. 11 characters."
  | I18nText str -> str
  | LocationFiles ->
    "Additional information about the location, such as directions. Contacts who are \
     participating in a session at this location can access access these files."
  | LocationsIndex ->
    "Locations, where experiments are conducted. Every session has to have a location."
  | LoginTokenSent email ->
    Format.asprintf
      "A verification token was sent to the email address %s. Please check your inbox."
      email
  | MailingLimit -> "Max. generated Invitations during the mailing."
  | MailingLimitExceedsMatchingContacts ->
    "The given limit is larger than the number of contacts meeting the criteria of this \
     experiment."
  | MergeContacts ->
    {|Select which attributes are to be transferred from which contact.

  The fields that are considered to be the same are marked. If an admin value exists, this is taken into account before the contact value.|}
  | MessageTemplateAccountSuspensionNotification ->
    "This message will be sent to a user after the account has been temporarily \
     suspended because of too many failed login attempts."
  | MessageTemplateInactiveContactWarning ->
    "This message is sent to contacts who have not logged in for a long time to inform \
     them that their account will soon be deactivated."
  | MessageTemplateInactiveContactDeactivation ->
    "This message is sent to contacts whose account has been deactivated due to \
     inactivity."
  | MessageTemplateLogin2FAToken ->
    "This message contains the 2-factor authentication token sent to all users after \
     logging in with their email and password"
  | MessageTemplateAssignmentCancellation ->
    "This message is used to notify contacts about the cancellation of an assignment."
  | MessageTemplateAssignmentConfirmation ->
    "This message will be sent to contacts after successfully registering for a session."
  | MessageTemplateAssignmentSessionChange ->
    "This message will be sent to contacts after they have been assigned to another \
     session by an administrator."
  | MessageTemplateContactEmailChangeAttempt ->
    "This message will be sent to a user after someone tries to change their email \
     address to an existing one."
  | MessageTemplateContactRegistrationAttempt ->
    "This message will be sent to a user after a registration attempt using an existing \
     email address."
  | MessageTemplateEmailVerification ->
    "This email is used to verify new email addresses after changing an account email \
     address. You can ignore the SMS text input."
  | MessageTemplateExperimentInvitation ->
    "This message is sent to invite contacts to experiments."
  | MessageTemplateManualSessionMessage ->
    "This template serves as a template for manually sent messages in the context of a \
     session."
  | MessageTemplateMatcherNotification ->
    "This message is sent to inform administrators that no further contacts have been \
     found who can be invited to an experiment."
  | MessageTemplateMatchFilterUpdateNotification ->
    "This message is sent to inform admins when contacts no longer meet the criteria \
     defined in the filter."
  | MessageTemplatePasswordChange ->
    "This message is sent to notify users that the account password has been changed."
  | MessageTemplatePasswordReset ->
    "This message sends the password reset token to the given address."
  | MessageTemplatePhoneVerification ->
    "This message sends the phone number verification token to the contact's phone. You \
     can ignore the email and plain text."
  | MessageTemplateProfileUpdateTrigger ->
    "This message is used to notify contacts who last updated their profile a while ago \
     and request them to control their personal information."
  | MessageTemplateSessionCancellation ->
    "This message is used to notify contacts about the cancellation of a session."
  | MessageTemplateSessionReminder ->
    "This message reminds contacts about upcoming sessions they are signed up for."
  | MessageTemplateSessionReschedule ->
    "This message is used to notify contacts about the rescheduling of a session."
  | MessageTemplateSignupVerification ->
    "This email is used to verify new email addresses after signing up. You can ignore \
     the SMS text input."
  | MessageTemplateTextTemplates ->
    "<strong>Important:</strong> Do not use the example values in the template, but the \
     placeholder elements. Some values are not real but only sample content."
  | MessageTemplateUserImport ->
    "This message informs imported contacts about the migration to the Z-Pool-Tool and \
     contains the token they need to reset their password."
  | MessageTemplateWaitingListConfirmation ->
    "This message confirms the successful enrollment to an experiment waiting list."
  | MissingMessageTemplates ->
    "The following message templates are missing. The default message will be sent to \
     contacts who selected one of those languages as their communication language."
  | NumberIsDaysHint -> "Nr. of days"
  | NumberIsSecondsHint -> "Nr. of seconds"
  | NumberIsWeeksHint -> "Nr. of weeks"
  | NumberMax i -> error_to_string (Pool_message.Error.NumberMax i)
  | NumberMin i -> error_to_string (Pool_message.Error.NumberMin i)
  | OnlineExperiment ->
    Format.asprintf
      "Instead of sessions, you can define time windows in which you can take part in \
       the survey. Under %s, enter the external URL of the survey to which the contacts \
       should be forwarded."
      (Locales_en.field_to_string Pool_message.Field.SurveyUrl)
  | Overbook ->
    "Number of subjects that can enroll in a session in addition to the maximum number \
     of contacts."
  | PartialUpdate ->
    "The following form will save the changed values immediately. You do not need to \
     submit the form."
  | ParticipationTagsHint ->
    "Tags, which are automatically assigned to participants after they have participated \
     in a session of this experiment."
  | PauseAccountAdmin ->
    "As long the account is paused, the contact will not be invited to any further \
     experiments."
  | PauseAccountContact ->
    "As long as your account is paused, you will not be invited to any further \
     experiments."
  | PermissionManage -> "Includes Create, Read, Update and Delete"
  | PermissionsExplanationLink -> "Open the permissions explanation"
  | PromoteContact ->
    "Attention: one-time action. The contact is promoted to an admin, who is \
     subsequently no longer invited for experiments and can no longer register for such."
  | RateDependencyWith ->
    "There are other mailings running at the same time. See its details below. If the \
     sum of all reaches the server's maximum, they will automatically get reduced."
  | RateDependencyWithout ->
    "There are currently no other mailings running in the specified time range."
  | RateNumberPerMinutes (per_n_minutes, number) ->
    Format.asprintf
      "Generates max %i new invitations every %d minutes"
      (number +. 0.5 |> CCFloat.round |> CCInt.of_float)
      per_n_minutes
  | RegistrationDisabled ->
    "If this option is activated, contacts can neither register nor join the waiting \
     list. The experiment is not visible to the contacts."
  | RescheduleSession ->
    "When you reschedule a session, all registered contacts are automatically informed."
  | ResendRemindersChannel ->
    "If you choose to resend the reminders as text messages, contacts without a verified \
     cell phone number will receive the reminder via email."
  | ResendRemindersWarning ->
    {|No automatic reminders have been sent for this session yet. Make sure that the message template is correct if you want to trigger the reminders now.

If you trigger the reminders manually now, no more automatic reminders will be sent via the selected message channel.|}
  | ResetInvitations ->
    "Resets invitations, all previous invitations up to the now will be ignored."
  | ResetInvitationsLastReset reset_at ->
    Format.asprintf
      "The invitations were last reset on <strong>%s</strong>."
      (Pool_model.Time.formatted_date_time reset_at)
  | ReleaseNotesHint repo_url ->
    Format.asprintf
      "Here you can find the changes relevant to you for each version of the tool. You \
       can find a complete changelog on <a href=\"%s\" target=\"_blank\">github.com</a>."
      repo_url
  | RoleIntro (singular, plural) ->
    Format.asprintf
      "If no %s is specified, the role includes all %s."
      (Locales_en.field_to_string singular)
      (Locales_en.field_to_string plural)
  | RolePermissionsModelList ->
    "Select the target for which you want to adjust the permissions."
  | RolePermissionsRoleList -> "All customizable roles of the tenant."
  | ScheduleAt time ->
    time |> Pool_model.Time.formatted_date_time |> Format.asprintf "at %s"
  | ScheduledIntro ->
    {|Information about all periodic background processes.

      Note: When the application restarts all active schedules get stopped.
      |}
  | ScheduleEvery sec ->
    sec |> Pool_model.Time.formatted_timespan |> Format.asprintf "every %s"
  | SearchByFields fields ->
    Format.asprintf
      "Search by: %s"
      (fields |> CCList.map Locales_en.field_to_string |> CCString.concat ", ")
  | SelectedDateIsPast -> "The selected date is in the past."
  | SelectedOptionsCountMax i ->
    error_to_string (Pool_message.Error.SelectedOptionsCountMax i)
  | SelectedOptionsCountMin i ->
    error_to_string (Pool_message.Error.SelectedOptionsCountMin i)
  | SessionCancellationMessageFollowUps ->
    "Associated follow-up sessions were canceled as well:"
  | SessionCancellationWithFollowups ->
    {|Cancelling this session will also cancel all follow-up sessions.

  The following follow-up sessions exist:|}
  | SessionCancelMessage ->
    "This reason will be provided to all contacts assigned to this session."
  | SessionCloseHints ->
    Format.asprintf
      {|<strong>%s</strong> and <strong>%s</strong> are mutually exclusive.<br>
    If none of the two checkboxes is checked, it equals to 'show up but did not participate'|}
      (Locales_en.field_to_string Pool_message.Field.NoShow |> capitalize)
      (Locales_en.field_to_string Pool_message.Field.Participated |> capitalize)
  | SessionCloseLegendNoShow -> "the contact did not show up"
  | SessionCloseLegendParticipated -> "the contact participated in the experiment"
  | SessionCloseLegendVerified -> "the contact was verified"
  | SessionCloseNoParticipationTagsSelected ->
    "No tags were selected to be assigned to the participants who participated in this \
     experiment."
  | SessionCloseParticipationTagsSelected ->
    "The following tags are assigned to all participants who took part in this \
     experiment:"
  | SessionRegistrationFollowUpHint ->
    "The registration for a session incl. all follow up sessions is binding."
  | SessionRegistrationHint -> "The registration for a session is binding."
  | SessionReminderLanguageHint ->
    "If you provide a custom reminder text, select its language here."
  | SettigsInactiveUsers ->
    "The durations specified here are totaled. This means that an account is only \
     deactivated after the total of 'Warn inactive users' and 'Deactivate inactive \
     users'."
  | SessionReminderLeadTime ->
    "The lead time determines how long before the start of the session the reminders are \
     sent to the contacts"
  | SettingsContactEmail ->
    "The default sender address for emails. This address can be overwritten for \
     experiment-related emails."
  | SettingsNoEmailSuffixes ->
    "There are no email suffixes defined that are allowed. This means that all email \
     suffixes are allowed."
  | SettingsPageScripts ->
    "Here you can insert HTML code that is rendered on every page in the head or body \
     tag, e.g. a Matomo analytics code."
  | SignUpCodeHint ->
    Format.asprintf
      "URLs with codes can be sent to track the channels through which contacts register \
       with the pool. The codes can be freely selected, but must be sent as URL \
       parameters with the key '%s'. You can use the form below to build a URL you can \
       send to new contacts."
      Pool_message.Field.(human_url SignUpCode)
  | SmtpMissing ->
    "No SMTP configuration has been stored, which is why no e-mails can be sent."
  | SignUpForWaitingList ->
    "The recruitment team will contact you, to assign you to a session, if there is a \
     free place."
  | SmtpSettingsDefaultFlag ->
    "Attention: If another SMTP configuration is marked as default, it will be \
     overwritten. Only one configuration can be marked as default."
  | SmtpSettingsIntro ->
    {|The following configuration is used by the email service.

    Note: When using the mechanism "LOGIN" a username and password are required.
    |}
  | SmtpValidation ->
    "Please provide an email address to which a test message can be sent to validate the \
     SMTP settings."
  | SwapSessions ->
    {|Changing the session will only change the session of this assignment. If follow-up assignments exists, they must be updated manually.

Only sessions with open spots can be selected.|}
  | SurveyUrl ->
    "A URL incl. protocol. You can pass information to your survey by adding query \
     parameters. E.g: https://www.domain.com/survey/id?callbackUrl={callbackUrl}"
  | TagsIntro ->
    "The defined tags can be added to several types (e.g. contacts). The tags can be \
     used by the experiment filter to eighter include or exclude them."
  | TemplateTextElementsHint ->
    "The following text elements can be used inside the templates. Click on the labels \
     to copy them to the clipboard."
  | TenantDatabaseLabel ->
    "A label that is an identifier for the tenant, e.g. 'econ-uzh'. The label must be \
     unique."
  | TenantDatabaseUrl ->
    {|The database URL, according to the following scheme:
     mariadb://<user>:<pw>@<host>:<port>/<database>|}
  | TenantUrl -> "The URL of the tenant without protocol, e.g.: pool.uzh.ch"
  | TestPhoneNumber ->
    "Please provide a phone number where we can send a single test message to verify the \
     api key. The number must have the format +41791234567."
  | TextLengthMax i -> error_to_string (Pool_message.Error.TextLengthMax i)
  | TextLengthMin i -> error_to_string (Pool_message.Error.TextLengthMin i)
  | UserImportInterval ->
    {|<p>Define after how many days a reminder will be sent to contacts that have not confirmed the import yet.</p>
<p><strong>The 'second reminder' setting defines how long after the first reminder the second reminder is sent.</strong></p>|}
  | VerifyContact -> "Mark the contact as verified."
  | WaitingListPhoneMissingContact ->
    "You have not entered a phone number in your profile yet. Please provide a phone \
     number so that the recruitment team can contact you."
;;

let confirmable_to_string confirmable =
  (match confirmable with
   | CancelAssignment -> "assignment", "cancel", None
   | CancelAssignmentWithFollowUps ->
     ( "assignment"
     , "cancel"
     , Some "Assignments to follow-up sessions will be canceled as well." )
   | CancelSession -> "session", "cancel", None
   | CloseSession -> "session", "close", Some "This action cannot be undone."
   | DeleteContact -> "contact", "delete", Some "This action cannot be undone."
   | DeleteCustomField -> "field", "delete", None
   | DeleteCustomFieldOption -> "option", "delete", None
   | DeleteExperiment -> "experiment", "delete", None
   | DeleteExperimentFilter -> "filter", "delete", None
   | DeleteFile -> " file", "delete", None
   | DeleteGtxApiKey ->
     ( "GTX Api key"
     , "delete"
     , Some
         "Text messages can no longer be sent without a GTX Api key. This action will \
          disable any sending of text messages." )
   | DeleteMailing -> "mailing", "delete", None
   | DeleteMessageTemplate -> "message template", "delete", None
   | DeleteSession -> "session", "delete", None
   | DeleteSmtpServer -> "email Server", "delete", None
   | DisableApiKey -> "API key", "disable", None
   | LoadDefaultTemplate ->
     "default template", "load", Some "The current content is overwritten."
   | MarkAssignmentAsDeleted -> "assignment as deleted", "mark", None
   | MarkAssignmentWithFollowUpsAsDeleted ->
     ( "assignment as deleted"
     , "mark"
     , Some "Assignments to follow-up sessions will be marked as deleted as well." )
   | PauseAccount -> "account", "pause", None
   | PromoteContact ->
     ( "contact"
     , "promote"
     , Some
         "The contact will no longer be invited for experiments and can no longer \
          register for them." )
   | PublishCustomField ->
     ( "field and all associated options"
     , "publish"
     , Some "You will not be able to delete the field anymore." )
   | PublishCustomFieldOption ->
     "option", "publish", Some "You will not be able to delete the it anymore."
   | ReactivateAccount -> "account", "reactivate", None
   | RemovePermission -> "permission", "delete", None
   | RemoveRule -> "rule", "delete", None
   | RemoveTag -> "tag", "remove", None
   | RescheduleSession -> "session", "reschedule", None
   | ResetInvitations ->
     ( "invitations"
     , "reset"
     , Some
         "Subsequently, all previous invitations up to the now are ignored, i.e. \
          contacts who have already been invited will receive a further invitation." )
   | RevokeRole -> "role", "revoke", None
   | StopMailing -> "mailing", "stop", None)
  |> fun (obj, action, additive) ->
  Format.asprintf "Are you sure you want to %s the %s?" action obj
  |> fun msg -> additive |> CCOption.map_or ~default:msg (Format.asprintf "%s %s" msg)
;;
