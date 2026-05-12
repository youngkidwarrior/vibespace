/* TypeScript file generated from GenerativeUi.res by genType. */

/* eslint-disable */
/* tslint:disable */

import * as GenerativeUiJS from './GenerativeUi.res.js';

import type {profileEditPromptInput as DocumentEditPrompt_profileEditPromptInput} from './DocumentEditPrompt.gen';

import type {webContext as WebContext_webContext} from './WebContext.gen';

export const composeProfileEditPrompt: (_1:DocumentEditPrompt_profileEditPromptInput) => string = GenerativeUiJS.composeProfileEditPrompt as any;

export const sanitizeWebContext: (_1:unknown) => WebContext_webContext = GenerativeUiJS.sanitizeWebContext as any;

export const emptyWebContext: (_1:(null | undefined | string), _2:(null | undefined | string)) => WebContext_webContext = GenerativeUiJS.emptyWebContext as any;

export const capabilityPolicyForPrompt: () => string = GenerativeUiJS.capabilityPolicyForPrompt as any;
