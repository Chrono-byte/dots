
import { SiteverifyError, errorResponse } from './errors.js';
import { logSiteverify } from './observability.js';
import { validate } from './validate.js';
import type { Env, SiteverifyRequest } from './types.js';

export const WORKER_VERSION = '1.0.0';

function corsHeaders(env: Env): Record<string, string> {
	return {
		'Access-Control-Allow-Origin': env.ALLOWED_ORIGIN || '*',
		'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
		'Access-Control-Allow-Headers': 'Content-Type, Idempotency-Key',
		'Access-Control-Max-Age': '86400',
		Vary: 'Origin',
	};
}

function jsonResponse(body: unknown, status: number, env: Env): Response {
	return new Response(JSON.stringify(body, null, 2), {
		status,
		headers: {
			'Content-Type': 'application/json; charset=utf-8',
			...corsHeaders(env),
		},
	});
}

async function parseBody(request: Request): Promise<SiteverifyRequest> {
	const contentType = request.headers.get('content-type') || '';

	if (contentType.includes('application/json')) {
		const body = (await request.json()) as Record<string, unknown>;
		return {
			token: String(body.token ?? body['cf-turnstile-response'] ?? body.response ?? ''),
			remoteip: body.remoteip ? String(body.remoteip) : undefined,
			idempotency_key: body.idempotency_key ? String(body.idempotency_key) : undefined,
		};
	}

	if (contentType.includes('application/x-www-form-urlencoded') || contentType.includes('multipart/form-data')) {
		const form = await request.formData();
		return {
			token: String(form.get('token') ?? form.get('cf-turnstile-response') ?? form.get('response') ?? ''),
			remoteip: form.get('remoteip') ? String(form.get('remoteip')) : undefined,
			idempotency_key: form.get('idempotency_key') ? String(form.get('idempotency_key')) : undefined,
		};
	}

	throw new SiteverifyError(
		415,
		'invalid-content-type',
		`Unsupported Content-Type: ${contentType || '(missing)'}. Use application/json or application/x-www-form-urlencoded.`,
	);
}

async function handleSiteverify(request: Request, env: Env): Promise<Response> {
	const startedAt = Date.now();
	let parsed: SiteverifyRequest;
	try {
		parsed = await parseBody(request);
	} catch (err) {
		if (err instanceof SiteverifyError) {
			const body = errorResponse(err.code, Date.now() - startedAt, WORKER_VERSION);
			logSiteverify('error', {
				durationMs: Date.now() - startedAt,
				errorCodes: [err.code],
				remoteipPresent: false,
				idempotencyKeyPresent: false,
			});
			return jsonResponse(body, err.status, env);
		}
		const body = errorResponse('bad-request', Date.now() - startedAt, WORKER_VERSION);
		logSiteverify('error', {
			durationMs: Date.now() - startedAt,
			errorCodes: ['bad-request'],
			remoteipPresent: false,
			idempotencyKeyPresent: false,
		});
		return jsonResponse(body, 400, env);
	}

	const remoteip = parsed.remoteip ?? request.headers.get('CF-Connecting-IP') ?? undefined;
	const requestForValidate: SiteverifyRequest = { ...parsed, remoteip };

	try {
		const { response, upstreamStatus, durationMs } = await validate(requestForValidate, env, WORKER_VERSION);

		logSiteverify(response.success ? 'ok' : 'fail', {
			durationMs,
			upstreamStatus,
			errorCodes: response['error-codes'],
			cdataValue: response.cdata,
			remoteipPresent: !!remoteip,
			idempotencyKeyPresent: !!parsed.idempotency_key,
		});

		return jsonResponse(response, 200, env);
	} catch (err) {
		if (err instanceof SiteverifyError) {
			const body = errorResponse(err.code, Date.now() - startedAt, WORKER_VERSION);
			logSiteverify('error', {
				durationMs: Date.now() - startedAt,
				errorCodes: [err.code],
				remoteipPresent: !!remoteip,
				idempotencyKeyPresent: !!parsed.idempotency_key,
			});
			return jsonResponse(body, err.status, env);
		}
		const body = errorResponse('internal-error', Date.now() - startedAt, WORKER_VERSION);
		logSiteverify('error', {
			durationMs: Date.now() - startedAt,
			errorCodes: ['internal-error'],
			remoteipPresent: !!remoteip,
			idempotencyKeyPresent: !!parsed.idempotency_key,
		});
		return jsonResponse(body, 500, env);
	}
}

function handleHealth(env: Env): Response {
	return jsonResponse(
		{
			ok: true,
			version: WORKER_VERSION,
			service: 'turnstile-siteverify',
			docs: 'https://developers.cloudflare.com/turnstile/spin/',
		},
		200,
		env,
	);
}

export default {
	async fetch(request: Request, env: Env): Promise<Response> {
		if (request.method === 'OPTIONS') {
			return new Response(null, { status: 204, headers: corsHeaders(env) });
		}

		const url = new URL(request.url);

		if (request.method === 'GET' && (url.pathname === '/' || url.pathname === '/health' || url.pathname === '/healthz')) {
			return handleHealth(env);
		}

		if (request.method === 'GET' && url.pathname === '/post-deploy') {
			if (env.ASSETS) {
				return env.ASSETS.fetch(new Request(new URL('/post-deploy.html', url.origin)));
			}
		}

		const isSiteverifyPath = url.pathname === '/' || url.pathname === '/siteverify';
		if (request.method === 'POST' && isSiteverifyPath) {
			return handleSiteverify(request, env);
		}

		return jsonResponse(
			{
				success: false,
				'error-codes': ['bad-request'],
				hint: 'POST a Turnstile token to / (or /siteverify) as JSON or form-encoded body.',
			},
			404,
			env,
		);
	},
} satisfies ExportedHandler<Env>;
