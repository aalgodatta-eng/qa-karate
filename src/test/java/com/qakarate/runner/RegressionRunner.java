package com.qakarate.runner;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Regression Test Runner
 * Executes the full regression suite against httpbin.org covering:
 *  - HTTP Methods (GET, POST, PUT, PATCH, DELETE)
 *  - Authentication (Basic, Bearer, Digest)
 *  - Status Codes (1xx-5xx)
 *  - Request Inspection (headers, IP, user-agent)
 *  - Response Inspection (cache, ETag, response-headers)
 *  - Response Formats (JSON, HTML, XML, gzip, deflate, brotli)
 *  - Dynamic Data (UUID, base64, bytes, delay, links, range)
 *  - Cookies (set, get, delete)
 *  - Images (PNG, JPEG, WebP, SVG)
 *  - Redirects (absolute, relative, redirect-to)
 *  - Anything (echo endpoint)
 *
 * Run: mvn test -Pregression
 *   or: mvn test -Dtest=RegressionRunner
 */
public class RegressionRunner {

    @Test
    public void testRegression() {
        Results results = Runner
                .path("classpath:features/regression")
                .outputCucumberJson(true)
                .outputHtmlReport(true)
                .parallel(5);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
