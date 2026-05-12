/* TypeScript file generated from WebContext.resi by genType. */

/* eslint-disable */
/* tslint:disable */

export type resolvedItem = {
  readonly title: string; 
  readonly description: string; 
  readonly canonicalUrl: string; 
  readonly provider: string; 
  readonly itemType: string
};

export type safeFrame = {
  readonly origin: string; 
  readonly title: string; 
  readonly canonicalUrl: string; 
  readonly frameUrl: string; 
  readonly frameKind: string; 
  readonly autoplaySupported: boolean
};

export type safeEmbed = {
  readonly provider: string; 
  readonly title: string; 
  readonly canonicalUrl: string; 
  readonly embedUrl: string; 
  readonly embedKind: string; 
  readonly autoplaySupported: boolean
};

export type safeImage = {
  readonly origin: string; 
  readonly title: string; 
  readonly source: string; 
  readonly creator: string; 
  readonly license: string; 
  readonly licenseUrl: string; 
  readonly imageUrl: string; 
  readonly canonicalUrl: string; 
  readonly altText: string; 
  readonly subjectTags: string[]; 
  readonly visualCues: string[]
};

export type fact = {
  readonly label: string; 
  readonly value: string; 
  readonly sourceUrl: string
};

export type citation = { readonly title: string; readonly url: string };

export type webContext = {
  readonly status: string; 
  readonly intentKind: string; 
  readonly summary: string; 
  readonly resolvedItems: resolvedItem[]; 
  readonly safeFrames: safeFrame[]; 
  readonly safeEmbeds: safeEmbed[]; 
  readonly safeImages: safeImage[]; 
  readonly facts: fact[]; 
  readonly warnings: string[]; 
  readonly citations: citation[]
};
