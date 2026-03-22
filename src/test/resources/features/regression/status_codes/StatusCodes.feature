@regression @status-codes
Feature: Status Codes - Generates responses with given status code
  Validates that httpbin.org /status/{code} endpoint returns the exact HTTP status code requested.
  Covers all major 2xx, 3xx, 4xx, and 5xx status codes.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # 2xx - Success
  # ═══════════════════════════════════════════════════════════

  @positive @2xx
  Scenario: [SC-001] Status 200 - OK
    Given path '/status/200'
    When method GET
    Then status 200

  @positive @2xx
  Scenario: [SC-002] Status 201 - Created
    Given path '/status/201'
    When method GET
    Then status 201

  @positive @2xx
  Scenario: [SC-003] Status 202 - Accepted
    Given path '/status/202'
    When method GET
    Then status 202

  @positive @2xx
  Scenario: [SC-004] Status 203 - Non-Authoritative Information
    Given path '/status/203'
    When method GET
    Then status 203

  @positive @2xx
  Scenario: [SC-005] Status 204 - No Content
    Given path '/status/204'
    When method GET
    Then status 204

  @positive @2xx
  Scenario: [SC-006] Status 206 - Partial Content
    Given path '/status/206'
    When method GET
    Then status 206

  # ═══════════════════════════════════════════════════════════
  # 3xx - Redirection
  # ═══════════════════════════════════════════════════════════

  @positive @3xx
  Scenario: [SC-007] Status 301 - Moved Permanently (redirect not followed)
    * configure followRedirects = false
    Given path '/status/301'
    When method GET
    Then status 301

  @positive @3xx
  Scenario: [SC-008] Status 302 - Found (redirect not followed)
    * configure followRedirects = false
    Given path '/status/302'
    When method GET
    Then status 302

  @positive @3xx
  Scenario: [SC-009] Status 304 - Not Modified
    Given path '/status/304'
    When method GET
    Then status 304

  @positive @3xx
  Scenario: [SC-010] Status 307 - Temporary Redirect (redirect not followed)
    * configure followRedirects = false
    Given path '/status/307'
    When method GET
    Then status 307

  @positive @3xx
  Scenario: [SC-011] Status 308 - Permanent Redirect (redirect not followed)
    * configure followRedirects = false
    Given path '/status/308'
    When method GET
    Then status 308

  # ═══════════════════════════════════════════════════════════
  # 4xx - Client Error
  # ═══════════════════════════════════════════════════════════

  @negative @4xx
  Scenario: [SC-012] Status 400 - Bad Request
    Given path '/status/400'
    When method GET
    Then status 400

  @negative @4xx
  Scenario: [SC-013] Status 401 - Unauthorized
    Given path '/status/401'
    When method GET
    Then status 401

  @negative @4xx
  Scenario: [SC-014] Status 403 - Forbidden
    Given path '/status/403'
    When method GET
    Then status 403

  @negative @4xx
  Scenario: [SC-015] Status 404 - Not Found
    Given path '/status/404'
    When method GET
    Then status 404

  @negative @4xx
  Scenario: [SC-016] Status 405 - Method Not Allowed
    Given path '/status/405'
    When method GET
    Then status 405

  @negative @4xx
  Scenario: [SC-017] Status 406 - Not Acceptable
    Given path '/status/406'
    When method GET
    Then status 406

  @negative @4xx
  Scenario: [SC-018] Status 408 - Request Timeout
    Given path '/status/408'
    When method GET
    Then status 408

  @negative @4xx
  Scenario: [SC-019] Status 409 - Conflict
    Given path '/status/409'
    When method GET
    Then status 409

  @negative @4xx
  Scenario: [SC-020] Status 410 - Gone
    Given path '/status/410'
    When method GET
    Then status 410

  @negative @4xx
  Scenario: [SC-021] Status 412 - Precondition Failed
    Given path '/status/412'
    When method GET
    Then status 412

  @negative @4xx
  Scenario: [SC-022] Status 415 - Unsupported Media Type
    Given path '/status/415'
    When method GET
    Then status 415

  @negative @4xx
  Scenario: [SC-023] Status 418 - I'm a Teapot
    Given path '/status/418'
    When method GET
    Then status 418

  @negative @4xx
  Scenario: [SC-024] Status 422 - Unprocessable Entity
    Given path '/status/422'
    When method GET
    Then status 422

  @negative @4xx
  Scenario: [SC-025] Status 425 - Too Early
    Given path '/status/425'
    When method GET
    Then status 425

  @negative @4xx
  Scenario: [SC-026] Status 429 - Too Many Requests
    Given path '/status/429'
    When method GET
    Then status 429

  # ═══════════════════════════════════════════════════════════
  # 5xx - Server Error
  # ═══════════════════════════════════════════════════════════

  @negative @5xx
  Scenario: [SC-027] Status 500 - Internal Server Error
    Given path '/status/500'
    When method GET
    Then status 500

  @negative @5xx
  Scenario: [SC-028] Status 501 - Not Implemented
    Given path '/status/501'
    When method GET
    Then status 501

  @negative @5xx
  Scenario: [SC-029] Status 502 - Bad Gateway
    Given path '/status/502'
    When method GET
    Then status 502

  @negative @5xx
  Scenario: [SC-030] Status 503 - Service Unavailable
    Given path '/status/503'
    When method GET
    Then status 503

  @negative @5xx
  Scenario: [SC-031] Status 504 - Gateway Timeout
    Given path '/status/504'
    When method GET
    Then status 504

  @negative @5xx
  Scenario: [SC-032] Status 599 - Network Connect Timeout Error
    Given path '/status/599'
    When method GET
    Then status 599

  # ═══════════════════════════════════════════════════════════
  # Scenario Outline - Multiple success codes
  # ═══════════════════════════════════════════════════════════

  @positive
  Scenario Outline: [SC-033] Success status codes - <code> returned correctly
    Given path '/status/<code>'
    When method GET
    Then status <code>

    Examples:
      | code |
      | 200  |
      | 201  |
      | 202  |
      | 204  |

  # ═══════════════════════════════════════════════════════════
  # Scenario Outline - Multiple error codes
  # ═══════════════════════════════════════════════════════════

  @negative
  Scenario Outline: [SC-034] Error status codes - <code> returned correctly
    Given path '/status/<code>'
    When method GET
    Then status <code>

    Examples:
      | code |
      | 400  |
      | 401  |
      | 403  |
      | 404  |
      | 500  |
      | 503  |

  # ═══════════════════════════════════════════════════════════
  # Multiple status codes in single request (comma-separated)
  # ═══════════════════════════════════════════════════════════

  @positive
  Scenario: [SC-035] Multiple status codes comma-separated - returns one of the listed codes
    Given path '/status/200,201,202'
    When method GET
    * def validCodes = [200, 201, 202]
    Then assert validCodes.indexOf(responseStatus) >= 0
