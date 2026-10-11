
export interface Env {
	TURNSTILE_SECRET_KEY: string;
	ALLOWED_ORIGIN: string;
	EXPECTED_HOSTNAME?: string;
	LOG_LEVEL?: 'debug' | 'info' | 'warn' | 'error';
	ASSETS?: Fetcher;
}

export interface SiteverifyRequest {
	token: string;
	remoteip?: string;
	idempotency_key?: string;
}

export interface SiteverifyResponse {
	success: boolean;
	challenge_ts?: string;
	hostname?: string;
	action?: string;
	cdata?: string;
	'error-codes': ErrorCode[];
	_worker?: WorkerMetadata;
}

export interface WorkerMetadata {
	duration_ms: number;
	worker_version: string;
}

export type ErrorCode =
	| 'missing-input-secret'
	| 'invalid-input-secret'
	| 'missing-input-response'
	| 'invalid-input-response'
	| 'bad-request'
	| 'timeout-or-duplicate'
	| 'internal-error'
	| 'missing-token'
	| 'invalid-content-type'
	| 'upstream-unreachable'
	| 'upstream-timeout'
	| 'hostname-mismatch';

export interface SiteverifyLogEntry {
	level: 'info' | 'warn' | 'error';
	event: 'siteverify';
	outcome: 'ok' | 'fail' | 'error';
	duration_ms: number;
	upstream_status?: number;
	error_codes: ErrorCode[];
	cdata_present: boolean;
	cdata_value?: string;
	remoteip_present: boolean;
	idempotency_key_present: boolean;
	ts: string;
}
