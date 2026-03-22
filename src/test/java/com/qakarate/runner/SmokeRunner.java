package com.qakarate.runner;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Smoke Test Runner
 * Executes the smoke test suite against httpbin.org
 *
 * Run: mvn test -Psmoke
 *   or: mvn test -Dtest=SmokeRunner
 */
public class SmokeRunner {

    @Test
    public void testSmoke() {
        Results results = Runner
                .path("classpath:features/smoke")
                .outputCucumberJson(true)
                .outputHtmlReport(true)
                .parallel(3);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
