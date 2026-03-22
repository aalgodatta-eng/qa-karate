@regression @response-inspection
Feature: Response Inspection - Inspect response data (caching and headers)
  Validates httpbin.org endpoints for cache control, ETags, and response header manipulation.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET /cache - Cache-Control with conditional request headers
  # ═══════════════════════════════════════════════════════════

  @positive @cache
  Scenario: [RESI-001] GET /cache - Without conditional headers returns 200
    Given path '/cache'
    When method GET
    Then status 200
    And match response contains { headers: '#object', url: '#string' }

  @positive @cache
  Scenario: [RESI-002] GET /cache - With If-Modified-Since header returns 304 Not Modified
    Given path '/cache'
    And header If-Modified-Since = 'Mon, 01 Jan 2024 00:00:00 GMT'
    When method GET
    Then status 304

  @positive @cache
  Scenario: [RESI-003] GET /cache - With If-None-Match header returns 304 Not Modified
    Given path '/cache'
    And header If-None-Match = '"some-etag-value"'
    When method GET
    Then status 304

  @negative @cache
  Scenario: [RESI-004] GET /cache - Without conditional headers does NOT return 304
    Given path '/cache'
    When method GET
    Then status 200
    And assert responseStatus != 304

  # ═══════════════════════════════════════════════════════════
  # GET /cache/{value} - Sets Cache-Control max-age
  # ═══════════════════════════════════════════════════════════

  @positive @cache-control
  Scenario: [RESI-005] GET /cache/60 - Sets Cache-Control max-age=60
    Given path '/cache/60'
    When method GET
    Then status 200
    And match responseHeaders['Cache-Control'][0] contains 'max-age=60'

  @positive @cache-control
  Scenario: [RESI-006] GET /cache/3600 - Sets Cache-Control max-age=3600
    Given path '/cache/3600'
    When method GET
    Then status 200
    And match responseHeaders['Cache-Control'][0] contains 'max-age=3600'

  @positive @cache-control
  Scenario: [RESI-007] GET /cache/0 - Cache-Control with max-age=0 (no cache)
    Given path '/cache/0'
    When method GET
    Then status 200
    And match responseHeaders['Cache-Control'][0] contains 'max-age=0'

  @positive @cache-control
  Scenario Outline: [RESI-008] GET /cache/<seconds> - Correct Cache-Control header is set
    Given path '/cache/<seconds>'
    When method GET
    Then status 200
    And match responseHeaders['Cache-Control'][0] contains 'max-age=<seconds>'

    Examples:
      | seconds |
      | 10      |
      | 300     |
      | 86400   |

  # ═══════════════════════════════════════════════════════════
  # GET /etag/{etag} - ETag response header support
  # ═══════════════════════════════════════════════════════════

  @positive @etag
  Scenario: [RESI-009] GET /etag/{etag} - Without If-None-Match header returns 200 with ETag
    Given path '/etag/test-etag-value'
    When method GET
    Then status 200
    And match responseHeaders['ETag'] != null

  @positive @etag
  Scenario: [RESI-010] GET /etag/{etag} - With matching If-None-Match returns 304
    Given path '/etag/my-etag-12345'
    And header If-None-Match = '"my-etag-12345"'
    When method GET
    Then status 304

  @positive @etag
  Scenario: [RESI-011] GET /etag/{etag} - With non-matching If-None-Match returns 200
    Given path '/etag/actual-etag'
    And header If-None-Match = '"different-etag"'
    When method GET
    Then status 200

  @positive @etag
  Scenario: [RESI-012] GET /etag/{etag} - With matching If-Match returns 200
    Given path '/etag/matching-etag'
    And header If-Match = '"matching-etag"'
    When method GET
    Then status 200

  @negative @etag
  Scenario: [RESI-013] GET /etag/{etag} - With non-matching If-Match returns 412 Precondition Failed
    Given path '/etag/actual-etag'
    And header If-Match = '"wrong-etag"'
    When method GET
    Then status 412

  # ═══════════════════════════════════════════════════════════
  # GET /response-headers - Custom response headers
  # ═══════════════════════════════════════════════════════════

  @positive @response-headers
  Scenario: [RESI-014] GET /response-headers - Custom response header is returned
    Given path '/response-headers'
    And param X-Custom-Response = 'hello-karate'
    When method GET
    Then status 200
    And match responseHeaders['X-Custom-Response'][0] == 'hello-karate'

  @positive @response-headers
  Scenario: [RESI-015] GET /response-headers - Multiple custom headers are returned
    Given path '/response-headers'
    And param X-First-Header = 'value1'
    And param X-Second-Header = 'value2'
    When method GET
    Then status 200
    And match responseHeaders['X-First-Header'][0] == 'value1'
    And match responseHeaders['X-Second-Header'][0] == 'value2'

  @positive @response-headers
  Scenario: [RESI-016] GET /response-headers - Content-Type can be set via query param
    Given path '/response-headers'
    And param Content-Type = 'application/json'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @positive @response-headers
  Scenario: [RESI-017] GET /response-headers - Response body also contains the requested headers as JSON
    Given path '/response-headers'
    And param X-Test-Value = 'test123'
    When method GET
    Then status 200
    And match response['X-Test-Value'] == 'test123'

  @negative @response-headers
  Scenario: [RESI-018] GET /response-headers - Without query params returns 200 with basic headers
    Given path '/response-headers'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'] != null
