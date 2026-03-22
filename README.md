# qa-karate

Karate BDD API Test Automation Framework for [httpbin.org](https://httpbin.org)

## Framework

- **Karate** 1.5.1 (io.karatelabs)
- **Java** 17
- **Maven** 3.9+
- **JUnit 5**

## Project Structure

```
qa-karate/
├── pom.xml
└── src/test/
    ├── java/com/qakarate/runner/
    │   ├── SmokeRunner.java          # Runs smoke suite
    │   └── RegressionRunner.java     # Runs regression suite
    └── resources/
        ├── karate-config.js          # Global config (baseUrl, timeouts)
        └── features/
            ├── smoke/
            │   └── SmokeSuite.feature           # 20 critical path tests
            └── regression/
                ├── http_methods/
                │   └── HttpMethods.feature      # GET, POST, PUT, PATCH, DELETE
                ├── auth/
                │   └── Auth.feature             # Basic, Bearer, Hidden, Digest
                ├── status_codes/
                │   └── StatusCodes.feature      # 1xx-5xx status codes
                ├── request_inspection/
                │   └── RequestInspection.feature # headers, IP, user-agent
                ├── response_inspection/
                │   └── ResponseInspection.feature # cache, ETag, response-headers
                ├── response_formats/
                │   └── ResponseFormats.feature  # JSON, HTML, XML, gzip, deflate, brotli
                ├── dynamic_data/
                │   └── DynamicData.feature      # UUID, base64, bytes, delay, links
                ├── cookies/
                │   └── Cookies.feature          # set, read, delete cookies
                ├── images/
                │   └── Images.feature           # PNG, JPEG, WebP, SVG
                ├── redirects/
                │   └── Redirects.feature        # absolute, relative, redirect-to
                └── anything/
                    └── Anything.feature         # echo endpoint (all methods)
```

## Running Tests

### Run All Tests (Smoke + Regression)
```bash
mvn test
```

### Run Smoke Suite Only
```bash
mvn test -Psmoke
# or
mvn test -Dtest=SmokeRunner
```

### Run Regression Suite Only
```bash
mvn test -Pregression
# or
mvn test -Dtest=RegressionRunner
```

### Run Specific Feature Category (by tag)
```bash
mvn test -Dkarate.options="--tags @http-methods"
mvn test -Dkarate.options="--tags @auth"
mvn test -Dkarate.options="--tags @positive"
mvn test -Dkarate.options="--tags @negative"
```

## Test Coverage

### Smoke Suite (20 tests)
Critical path tests verifying core API functionality across all categories.

### Regression Suite

| Category             | Feature File              | Scenarios |
|----------------------|---------------------------|-----------|
| HTTP Methods         | HttpMethods.feature       | 24+       |
| Authentication       | Auth.feature              | 21+       |
| Status Codes         | StatusCodes.feature       | 35+       |
| Request Inspection   | RequestInspection.feature | 16+       |
| Response Inspection  | ResponseInspection.feature| 18+       |
| Response Formats     | ResponseFormats.feature   | 20+       |
| Dynamic Data         | DynamicData.feature       | 22+       |
| Cookies              | Cookies.feature           | 15+       |
| Images               | Images.feature            | 14+       |
| Redirects            | Redirects.feature         | 18+       |
| Anything (Echo)      | Anything.feature          | 18+       |

## Test Tags

- `@smoke` - Smoke test scenarios
- `@regression` - Regression test scenarios
- `@positive` - Expected success scenarios
- `@negative` - Expected failure/edge case scenarios
- `@http-methods`, `@auth`, `@status-codes`, `@request-inspection`, etc. - Category tags

## Reports

HTML reports are generated in `target/karate-reports/` after each run.

## Base URL

Tests target: `https://httpbin.org`

Configurable via `src/test/resources/karate-config.js` or by setting system property:
```bash
mvn test -DbaseUrl=https://httpbin.org
```
