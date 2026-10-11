
import type { ErrorCode, SiteverifyResponse } from './types.js';

export class SiteverifyError extends Error {
	constructor(
		public readonly status: number,
		public readonly code: ErrorCode,
		message: string,
	) {
		super(message);
		this.name = 'SiteverifyError';
	}
}

export function errorResponse(code: ErrorCode, durationMs: number, workerVersion: string): SiteverifyResponse {
	return {
		success: false,
		'error-codes': [code],
		_worker: {
			duration_ms: durationMs,
			worker_version: workerVersion,
		},
	};
}
