'use strict';

exports.handler = async (event) => {
	return new Promise((resolve) => {

		const response = event.Records[0].cf.response;
		const headers = response.headers;

		headers['Strict-Transport-Security'] = [{ key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' }];
		headers['X-XSS-Protection'] = [{ key: 'X-XSS-Protection', value: '1; mode=block' }];
		headers['X-Content-Type-Options'] = [{ key: 'X-Content-Type-Options', value: 'nosniff' }];
		headers['X-Frame-Options'] = [{ key: 'X-Frame-Options', value: 'DENY' }];
		headers['Referrer-Policy'] = [{	key: 'Referrer-Policy',	value: 'no-referrer' }];
		headers['Content-Security-Policy'] = [{	key: 'Content-Security-Policy',	value: "default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self';" }];
		headers['Feature-Policy'] = [{ key: 'Feature-Policy', value: 'geolocation none; midi none; notifications none; push none; sync-xhr none; microphone none; camera none; magnetometer none; gyroscope none; speaker self; vibrate none; fullscreen self; payment none;' }];

		resolve(response);

	});
};
