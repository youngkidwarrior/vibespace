/* TypeScript file generated from DocumentEditPrompt.res by genType. */

/* eslint-disable */
/* tslint:disable */

import * as DocumentEditPromptJS from './DocumentEditPrompt.res.js';

import type {webContext as WebContext_webContext} from './WebContext.gen';

export type profileEditPromptInput = {
  readonly instruction: string; 
  readonly documentHtml: string; 
  readonly documentCss: string; 
  readonly selectedContext: string; 
  readonly selectedRegionScreenshotDataUrl: string; 
  readonly fullPageScreenshotDataUrl: string; 
  readonly previousFailedHtml: string; 
  readonly previousFailedCss: string; 
  readonly previousFailedSummary: string; 
  readonly previousFailedWarnings: string; 
  readonly previousFailedValidationMessage: string; 
  readonly webContext: WebContext_webContext
};

export const composeProfileEditPrompt: (input:profileEditPromptInput) => string = DocumentEditPromptJS.composeProfileEditPrompt as any;
