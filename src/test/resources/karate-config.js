function fn() {
    var env = karate.env;
    karate.log('karate.env =', env);

    if (!env) {
        env = 'dev';
    }

    // Base configuration
    var config = {
        baseUrl: 'https://httpbin.org',
        env: env
    };

    // HTTP client timeouts
    karate.configure('connectTimeout', 30000);
    karate.configure('readTimeout', 60000);

    // SSL - accept all certificates
    karate.configure('ssl', true);

    // Follow redirects by default (override per-feature when needed)
    karate.configure('followRedirects', true);

    // Log pretty-printed responses
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);

    return config;
}
