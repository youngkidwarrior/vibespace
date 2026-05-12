import { randomBytes } from "node:crypto";

const inviteSelect = `
  id AS "id",
  code_hash AS "codeHash",
  inviter_user_id AS "inviterUserId",
  invitee_user_id AS "inviteeUserId",
  status AS "status",
  created_at::text AS "createdAt",
  redeemed_at::text AS "redeemedAt",
  expires_at::text AS "expiresAt"
`;

export function generateInviteCode() {
  return randomBytes(16).toString("hex");
}

export function inviteCodeNeedsRotation(code) {
  const value = String(code || "");
  return (
    value.startsWith("invite-") ||
    value.startsWith("seed-invite-") ||
    value.startsWith("manual-invite-")
  );
}

export async function insertRandomInviteForUser(client, inviterUserId) {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const code = generateInviteCode();
    const result = await client.query(
      `
        INSERT INTO vibespace.invites (
          code_hash,
          inviter_user_id,
          status
        )
        VALUES ($1, $2, 'available')
        ON CONFLICT (code_hash) DO NOTHING
        RETURNING ${inviteSelect}
      `,
      [code, inviterUserId],
    );

    if (result.rows[0]) return result.rows[0];
  }

  throw new Error("Unable to allocate a unique invite code.");
}

export async function rotateAvailableInviteCode(client, inviteId) {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const code = generateInviteCode();
    const result = await client.query(
      `
        UPDATE vibespace.invites i
        SET code_hash = $1
        WHERE i.id = $2
          AND i.status = 'available'
          AND NOT EXISTS (
            SELECT 1
            FROM vibespace.invites existing_invite
            WHERE existing_invite.code_hash = $1
              AND existing_invite.id <> i.id
          )
        RETURNING ${inviteSelect}
      `,
      [code, inviteId],
    );

    if (result.rows[0]) return result.rows[0];
  }

  return undefined;
}
