module SaveManualProfileVersionMutation = %relay(`
  mutation ProfileVersionMutationsSaveManualProfileVersionMutation(
    $input: SaveManualProfileVersionInput!
  ) {
    saveManualProfileVersion(input: $input) {
      __typename
      ... on ProfileVersionMutationSucceeded {
        summary
        warnings
        profile {
          id
          currentVersion {
            id
            revisionNumber
            html
            css
            summary
            createdAt
          }
        }
        profileVersion {
          id
          revisionNumber
          html
          css
          source
          summary
          validationStatus
          validationErrors
          createdBy {
            id
            displayName
          }
          createdAt
        }
      }
      ... on ProfileVersionMutationFailed {
        message
        summary
        validationErrors
        profile {
          id
        }
      }
    }
  }
`)

module RestoreProfileVersionMutation = %relay(`
  mutation ProfileVersionMutationsRestoreProfileVersionMutation(
    $input: RestoreProfileVersionInput!
  ) {
    restoreProfileVersion(input: $input) {
      __typename
      ... on ProfileVersionMutationSucceeded {
        summary
        warnings
        profile {
          id
          currentVersion {
            id
            revisionNumber
            html
            css
            summary
            createdAt
          }
        }
        profileVersion {
          id
          revisionNumber
          html
          css
          source
          summary
          validationStatus
          validationErrors
          createdBy {
            id
            displayName
          }
          createdAt
        }
      }
      ... on ProfileVersionMutationFailed {
        message
        summary
        validationErrors
        profile {
          id
        }
      }
    }
  }
`)

module StartAgentEditMutation = %relay(`
  mutation ProfileVersionMutationsStartAgentEditMutation(
    $input: SubmitAgentEditInput!
  ) {
    startAgentEdit(input: $input) {
      __typename
      ... on ProfileEditSessionMutationSucceeded {
        providerConversationId
        resultVersionId
        summary
        warnings
        validationErrors
        succeededEditSession: editSession {
          id
          prompt
          status
          progressPhase
          summary
          warnings
          error
          resultVersionId
          selectionSnapshot {
            id
            label
          }
          resultVersion {
            id
            revisionNumber
            html
            css
            source
            summary
            validationStatus
            validationErrors
            createdBy {
              id
              displayName
            }
            createdAt
          }
          createdAt
          updatedAt
        }
      }
      ... on ProfileEditSessionMutationFailed {
        message
        providerConversationId
        resultVersionId
        summary
        warnings
        validationErrors
        failedEditSession: editSession {
          id
          prompt
          status
          progressPhase
          summary
          warnings
          error
          resultVersionId
          selectionSnapshot {
            id
            label
          }
          resultVersion {
            id
            revisionNumber
            html
            css
            source
            summary
            validationStatus
            validationErrors
            createdBy {
              id
              displayName
            }
            createdAt
          }
          createdAt
          updatedAt
        }
      }
    }
  }
`)

module ProfileEditSessionPollQuery = %relay(`
  query ProfileVersionMutationsProfileEditSessionPollQuery($id: ID!) {
    profileEditSessionById(id: $id) {
      id
      prompt
      status
      progressPhase
      summary
      warnings
      error
      resultVersionId
      selectionSnapshot {
        id
        label
      }
      resultVersion {
        id
        revisionNumber
        html
        css
        source
        summary
        validationStatus
        validationErrors
        createdBy {
          id
          displayName
        }
        createdAt
      }
      createdAt
      updatedAt
    }
  }
`)

type polledProfileEditSession =
  ProfileVersionMutationsProfileEditSessionPollQuery_graphql.Types.response_profileEditSessionById

type profileEditSessionPollResponse = ProfileVersionMutationsProfileEditSessionPollQuery_graphql.Types.response

let fetchProfileEditSession = (~id): promise<option<polledProfileEditSession>> =>
  RescriptRelay_QueryNonReact.fetchPromised(
    ~node=ProfileVersionMutationsProfileEditSessionPollQuery_graphql.node,
    ~convertResponse=ProfileVersionMutationsProfileEditSessionPollQuery_graphql.Internal.convertResponse,
    ~convertVariables=ProfileVersionMutationsProfileEditSessionPollQuery_graphql.Internal.convertVariables,
  )(
    ~environment=RelayEnv.environment,
    ~variables={id},
    ~fetchPolicy=NetworkOnly,
  )->Promise.then((response: profileEditSessionPollResponse) =>
    response.profileEditSessionById->Promise.resolve
  )

module SubmitAgentEditMutation = %relay(`
  mutation ProfileVersionMutationsSubmitAgentEditMutation(
    $input: SubmitAgentEditInput!
  ) {
    submitAgentEdit(input: $input) {
      __typename
      ... on ProfileEditSessionMutationSucceeded {
        providerConversationId
        resultVersionId
        summary
        warnings
        validationErrors
        succeededEditSession: editSession {
          id
          prompt
          status
          progressPhase
          summary
          warnings
          error
          resultVersionId
          selectionSnapshot {
            id
            label
          }
          resultVersion {
            id
            revisionNumber
            html
            css
            source
            summary
            validationStatus
            validationErrors
            createdBy {
              id
              displayName
            }
            createdAt
          }
          createdAt
          updatedAt
        }
      }
      ... on ProfileEditSessionMutationFailed {
        message
        providerConversationId
        resultVersionId
        summary
        warnings
        validationErrors
        failedEditSession: editSession {
          id
          prompt
          status
          progressPhase
          summary
          warnings
          error
          resultVersionId
          selectionSnapshot {
            id
            label
          }
          resultVersion {
            id
            revisionNumber
            html
            css
            source
            summary
            validationStatus
            validationErrors
            createdBy {
              id
              displayName
            }
            createdAt
          }
          createdAt
          updatedAt
        }
      }
    }
  }
`)

module CancelProfileEditSessionMutation = %relay(`
  mutation ProfileVersionMutationsCancelProfileEditSessionMutation(
    $input: CancelProfileEditSessionInput!
  ) {
    cancelProfileEditSession(input: $input) {
      __typename
      ... on ProfileEditSessionMutationSucceeded {
        providerConversationId
        resultVersionId
        summary
        warnings
        validationErrors
        succeededEditSession: editSession {
          id
          prompt
          status
          progressPhase
          summary
          warnings
          error
          resultVersionId
          selectionSnapshot {
            id
            label
          }
          createdAt
          updatedAt
        }
      }
      ... on ProfileEditSessionMutationFailed {
        message
        providerConversationId
        resultVersionId
        summary
        warnings
        validationErrors
        failedEditSession: editSession {
          id
          prompt
          status
          progressPhase
          summary
          warnings
          error
          resultVersionId
          selectionSnapshot {
            id
            label
          }
          createdAt
          updatedAt
        }
      }
    }
  }
`)

module RedeemInviteMutation = %relay(`
  mutation ProfileVersionMutationsRedeemInviteMutation(
    $input: RedeemInviteInput!
  ) {
    redeemInvite(input: $input) {
      __typename
      ... on RedeemInviteSucceeded {
        sessionToken
        invite {
          id
          code
          status
        }
        user {
          id
          handle
          displayName
        }
        friendConnection {
          id
          status
        }
        profile {
          id
          title
          slug
        }
      }
      ... on MutationFailed {
        message
      }
    }
  }
`)

module AdminCreateInviteMutation = %relay(`
  mutation ProfileVersionMutationsAdminCreateInviteMutation(
    $input: AdminCreateInviteInput!
  ) {
    adminCreateInvite(input: $input) {
      __typename
      ... on AdminCreateInviteSucceeded {
        invite {
          id
          code
          status
        }
      }
      ... on MutationFailed {
        message
      }
    }
  }
`)

module AdminCreateSeedUserMutation = %relay(`
  mutation ProfileVersionMutationsAdminCreateSeedUserMutation(
    $input: AdminCreateSeedUserInput!
  ) {
    adminCreateSeedUser(input: $input) {
      __typename
      ... on AdminCreateSeedUserSucceeded {
        sessionToken
        user {
          id
          handle
          displayName
        }
        invite {
          id
          code
          status
        }
        warnings
      }
      ... on AdminCreateSeedUserValidationFailed {
        message
        fields
      }
      ... on AdminCreateSeedUserUnavailable {
        message
      }
    }
  }
`)

module ReactivateUsedInviteMutation = %relay(`
  mutation ProfileVersionMutationsReactivateUsedInviteMutation(
    $input: ReactivateUsedInviteInput!
  ) {
    reactivateUsedInvite(input: $input) {
      __typename
      ... on ReactivateUsedInviteSucceeded {
        invite {
          id
          code
          inviterUserId
          inviteeUserId
          status
          redeemedAt
        }
        user {
          id
          handle
          displayName
          status
        }
      }
      ... on MutationFailed {
        message
      }
    }
  }
`)

module DisableUserMutation = %relay(`
  mutation ProfileVersionMutationsDisableUserMutation(
    $input: DisableUserInput!
  ) {
    disableUser(input: $input) {
      __typename
      ... on DisableUserSucceeded {
        user {
          id
          handle
          displayName
          status
        }
      }
      ... on MutationFailed {
        message
      }
    }
  }
`)

module DisableProfileMutation = %relay(`
  mutation ProfileVersionMutationsDisableProfileMutation(
    $input: DisableProfileInput!
  ) {
    disableProfile(input: $input) {
      __typename
      ... on DisableProfileSucceeded {
        profile {
          id
          title
          slug
          visibility
          disabledAt
          disabledReason
        }
      }
      ... on MutationFailed {
        message
      }
    }
  }
`)
