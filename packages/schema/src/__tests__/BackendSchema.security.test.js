import { describe, expect, it } from "vitest";
import * as BackendSchema from "../BackendSchema.res.js";
import * as InviteCode from "../InviteCode.js";

const validHtml = BackendSchema.fixtureHtml;
const validCss = BackendSchema.fixtureCss;

function lazyLoader(load) {
  return {
    LAZY_DONE: true,
    VAL: { load },
  };
}

function dataLoadersForUnitProfile() {
  return {
    users: {
      byId: lazyLoader(async (key) =>
        key === BackendSchema.fixtureViewerId ? BackendSchema.fixtureViewer : BackendSchema.fixtureFriend,
      ),
    },
    profiles: {
      byId: lazyLoader(async () => BackendSchema.fixtureProfile),
      byOwnerId: lazyLoader(async () => BackendSchema.fixtureProfile),
    },
    profileVersions: {
      byId: lazyLoader(async () => BackendSchema.fixtureVersion2),
      currentByProfileId: lazyLoader(async () => BackendSchema.fixtureVersion2),
    },
  };
}

function emptyDataLoaders() {
  return {
    users: {
      byId: lazyLoader(async () => undefined),
    },
    profiles: {
      byId: lazyLoader(async () => undefined),
      byOwnerId: lazyLoader(async () => undefined),
    },
    profileVersions: {
      byId: lazyLoader(async () => undefined),
      currentByProfileId: lazyLoader(async () => undefined),
    },
  };
}

function dbContext(currentUserId) {
  return {
    currentUserId,
    isDevAdmin: false,
    databaseUrl: "postgres://unit-test-only",
    dataLoaders: dataLoadersForUnitProfile(),
  };
}

function contextWithoutDatabase() {
  return {
    currentUserId: undefined,
    isDevAdmin: false,
    databaseUrl: undefined,
    dataLoaders: emptyDataLoaders(),
  };
}

function contextWithDatabaseButNoRows() {
  return {
    currentUserId: undefined,
    isDevAdmin: false,
    databaseUrl: "postgres://unit-test-only",
    dataLoaders: emptyDataLoaders(),
  };
}

function restoreVibespaceEnv(value) {
  if (value === undefined) {
    delete process.env.VIBESPACE_ENV;
  } else {
    process.env.VIBESPACE_ENV = value;
  }
}

describe("BackendSchema profile write authorization", () => {
  it("only returns a write actor id for the profile owner", () => {
    expect(BackendSchema.profileWriteActorId(dbContext(BackendSchema.fixtureViewerId), BackendSchema.fixtureProfile)).toBe(
      BackendSchema.fixtureViewerId,
    );
    expect(
      BackendSchema.profileWriteActorId(dbContext(`User:${BackendSchema.fixtureViewerId}`), BackendSchema.fixtureProfile),
    ).toBe(BackendSchema.fixtureViewerId);
    expect(BackendSchema.profileWriteActorId(dbContext(BackendSchema.fixtureFriendId), BackendSchema.fixtureProfile)).toBe(
      undefined,
    );
    expect(BackendSchema.profileWriteActorId(dbContext(undefined), BackendSchema.fixtureProfile)).toBe(undefined);
  });

  it("rejects manual saves from non-owners before persistence", async () => {
    const result = await BackendSchema.saveManualProfileVersion(
      undefined,
      {
        profileId: BackendSchema.fixtureProfileId,
        html: validHtml,
        css: validCss,
        summary: "unauthorized save",
      },
      dbContext(BackendSchema.fixtureFriendId),
    );

    expect(result.TAG).toBe("SaveManualProfileVersionFailed");
    expect(result._0.message).toContain("profile owner");
  });

  it("rejects restores from non-owners before persistence", async () => {
    const result = await BackendSchema.restoreProfileVersion(
      undefined,
      {
        profileId: BackendSchema.fixtureProfileId,
        versionId: BackendSchema.fixtureVersion1Id,
      },
      dbContext(BackendSchema.fixtureFriendId),
    );

    expect(result.TAG).toBe("RestoreProfileVersionFailed");
    expect(result._0.message).toContain("profile owner");
  });

  it("rejects agent edits from non-owners before model execution", async () => {
    const result = await BackendSchema.submitAgentEdit(
      undefined,
      {
        profileId: BackendSchema.fixtureProfileId,
        currentVersionId: BackendSchema.fixtureVersion2Id,
        prompt: "Make this page safer.",
      },
      dbContext(BackendSchema.fixtureFriendId),
    );

    expect(result.TAG).toBe("SubmitAgentEditFailed");
    expect(result._0.message).toContain("profile owner");
  });
});

describe("BackendSchema agent service nullability", () => {
  it("treats a null failed-session resultVersionId as no result version", async () => {
    const session = BackendSchema.profileEditSessionFromAgentService({
      id: "unit-edit-session",
      profileId: BackendSchema.fixtureProfileId,
      userId: BackendSchema.fixtureViewerId,
      providerConversationId: null,
      status: "failed",
      progressPhase: "validating",
      prompt: "Make this page safer.",
      selectionSnapshotId: null,
      resultVersionId: null,
      summary: "Assistant output failed validation.",
      warnings: [],
      error: "Invalid profile output.",
      createdAt: undefined,
      updatedAt: undefined,
    });

    expect(session.resultVersionId).toBe(undefined);
    await expect(BackendSchema.resultVersion(session, contextWithoutDatabase())).resolves.toBe(undefined);
  });
});

describe("InviteCode", () => {
  it("generates opaque URL-safe invite codes instead of handle-derived codes", () => {
    const first = InviteCode.generateInviteCode();
    const second = InviteCode.generateInviteCode();

    expect(first).toMatch(/^[0-9a-f]{32}$/);
    expect(second).toMatch(/^[0-9a-f]{32}$/);
    expect(second).not.toBe(first);
    expect(first).not.toMatch(/^invite-\d+$/);
  });

  it("detects legacy predictable invite codes for lazy rotation", () => {
    expect(InviteCode.inviteCodeNeedsRotation("invite-1")).toBe(true);
    expect(InviteCode.inviteCodeNeedsRotation("seed-invite-vic")).toBe(true);
    expect(InviteCode.inviteCodeNeedsRotation("manual-invite-12345678-1")).toBe(true);
    expect(InviteCode.inviteCodeNeedsRotation("a".repeat(32))).toBe(false);
  });
});

describe("BackendSchema production fixture safety", () => {
  it("keeps local no-database fixture mode available outside production", async () => {
    const previousEnv = process.env.VIBESPACE_ENV;
    process.env.VIBESPACE_ENV = "localnet";

    try {
      await expect(BackendSchema.viewer(undefined, contextWithoutDatabase())).resolves.toMatchObject({
        id: BackendSchema.fixtureViewerId,
      });
    } finally {
      restoreVibespaceEnv(previousEnv);
    }
  });

  it("does not fall back to fixture data when a database is configured", async () => {
    const result = await BackendSchema.profileByHandle(
      undefined,
      BackendSchema.fixtureProfile.slug,
      contextWithDatabaseButNoRows(),
    );

    expect(result).toBe(undefined);
  });

  it("does not fall back to fixture data in production without a database", async () => {
    const previousEnv = process.env.VIBESPACE_ENV;
    process.env.VIBESPACE_ENV = "production";

    try {
      await expect(BackendSchema.viewer(undefined, contextWithoutDatabase())).resolves.toBe(undefined);
      await expect(
        BackendSchema.profileByHandle(undefined, BackendSchema.fixtureProfile.slug, contextWithoutDatabase()),
      ).resolves.toBe(undefined);
    } finally {
      restoreVibespaceEnv(previousEnv);
    }
  });
});
