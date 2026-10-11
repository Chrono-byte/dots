
import { describe, expect, it } from 'vitest';
import worker from '../src/index.js';
import type { Env } from '../src/types.js';

const PASSING_SECRET = '1x0000000000000000000000000000000AA';
const FAILING_SECRET = '2x0000000000000000000000000000000AA';
const SPENT_TOKEN_SECRET = '3x0000000000000000000000000000000AA';

const FAKE_TOKEN = 'XXXX.DUMMY.TOKEN.XXXX';

function envWith(secret: string): Env {
	return {
		TURNSTILE_SECRET_KEY: secret,
		ALLOWED_ORIGIN: '*',
	};
}

describe('integration: real siteverify with test secrets', () => {
	it('passing-secret returns success=true', async () => {
		const res = await worker.fetch(
			new Request('https://w/', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ token: FAKE_TOKEN }),
			}),
			envWith(PASSING_SECRET),
		);
		expect(res.status).toBe(200);
		const body = (await res.json()) as { success: boolean; _worker?: { duration_ms: number } };
		expect(body.success).toBe(true);
		expect(body._worker?.duration_ms).toBeGreaterThan(0);
	}, 15_000);

	it('failing-secret returns success=false', async () => {
		const res = await worker.fetch(
			new Request('https://w/', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ token: FAKE_TOKEN }),
			}),
			envWith(FAILING_SECRET),
		);
		expect(res.status).toBe(200);
		const body = (await res.json()) as { success: boolean; 'error-codes': string[] };
		expect(body.success).toBe(false);
		expect(body['error-codes'].length).toBeGreaterThan(0);
	}, 15_000);

	it('spent-token secret returns timeout-or-duplicate', async () => {
		const res = await worker.fetch(
			new Request('https://w/', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ token: FAKE_TOKEN }),
			}),
			envWith(SPENT_TOKEN_SECRET),
		);
		expect(res.status).toBe(200);
		const body = (await res.json()) as { success: boolean; 'error-codes': string[] };
		expect(body.success).toBe(false);
		expect(body['error-codes']).toContain('timeout-or-duplicate');
	}, 15_000);
});
