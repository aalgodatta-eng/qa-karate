@regression @request-inspection
Feature: Request Inspection - Inspect the request data
  Validates httpbin.org endpoints that inspect and return request metadata:
  headers, IP address, and user-agent string.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET /headers - Returns request headers
  # ═══════════════════════════════════════════════════════════

  @positive @headers
  Scenario: [RI-001] GET /headers - Returns all request headers
    Given path '/headers'
    When method GET
    Then status 200
    And match response contains { headers: '#object' }
    And match response.headers contains { Host: '#string' }

  @positive @headers
  Scenario: [RI-002] GET /headers - Custom header is reflected in response
    Given path '/headers'
    And header X-Custom-Header = 'test-value-123'
    When method GET
    Then status 200
    And match response.headers['X-Custom-Header'] == 'test-value-123'

  @positive @headers
  Scenario: [RI-003] GET /headers - Multiple custom headers are all reflected
    Given path '/headers'
    And header X-Header-One = 'alpha'
    And header X-Header-Two = 'beta'
    And header X-Header-Three = 'gamma'
    When method GET
    Then status 200
    And match response.headers['X-Header-One'] == 'alpha'
    And match response.headers['X-Header-Two'] == 'beta'
    And match response.headers['X-Header-Three'] == 'gamma'

  @positive @headers
  Scenario: [RI-004] GET /headers - Accept header is reflected
    Given path '/headers'
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And match response.headers['Accept'] == 'application/json'

  @positive @headers
  Scenario: [RI-005] GET /headers - Content-Type header is reflected when set
    Given path '/headers'
    And header Content-Type = 'application/json'
    When method GET
    Then status 200
    And match response.headers['Content-Type'] contains 'application/json'

  @positive @headers
  Scenario: [RI-006] GET /headers - Authorization header is reflected (Bearer)
    Given path '/headers'
    And header Authorization = 'Bearer inspect-test-token'
    When method GET
    Then status 200
    And match response.headers['Authorization'] == 'Bearer inspect-test-token'

  @positive @headers
  Scenario: [RI-007] GET /headers - Host header contains httpbin.org
    Given path '/headers'
    When method GET
    Then status 200
    And match response.headers.Host contains 'httpbin.org'

  @negative @headers
  Scenario: [RI-008] GET /headers - Response structure always contains headers object even with no custom headers
    Given path '/headers'
    When method GET
    Then status 200
    And match response.headers != null
    And match response.headers == '#object'

  @positive @headers
  Scenario Outline: [RI-009] GET /headers - Various custom X- headers are correctly reflected
    Given path '/headers'
    And header <headerName> = '<headerValue>'
    When method GET
    Then status 200
    And match response.headers['<headerName>'] == '<headerValue>'

    Examples:
      | headerName             | headerValue          |
      | X-Karate-Custom-One    | alpha-value-001      |
      | X-Karate-Custom-Two    | beta-value-002       |
      | X-Karate-Environment   | test-regression      |

  # ═══════════════════════════════════════════════════════════
  # GET /ip - Returns the requester's IP address
  # ═══════════════════════════════════════════════════════════

  @positive @ip
  Scenario: [RI-010] GET /ip - Returns origin IP address
    Given path '/ip'
    When method GET
    Then status 200
    And match response contains { origin: '#string' }
    And match response.origin == '#notnull'

  @positive @ip
  Scenario: [RI-011] GET /ip - Origin field is a non-empty string (valid IP or IP:port)
    Given path '/ip'
    When method GET
    Then status 200
    And assert response.origin.length > 0

  @positive @ip
  Scenario: [RI-012] GET /ip - Response contains only the origin field
    Given path '/ip'
    When method GET
    Then status 200
    And match response == { origin: '#string' }

  # ═══════════════════════════════════════════════════════════
  # GET /user-agent - Returns the user-agent string
  # ═══════════════════════════════════════════════════════════

  @positive @user-agent
  Scenario: [RI-013] GET /user-agent - Returns user-agent header value
    Given path '/user-agent'
    When method GET
    Then status 200
    And match response contains { 'user-agent': '#string' }

  @positive @user-agent
  Scenario: [RI-014] GET /user-agent - Custom user-agent is reflected in response
    Given path '/user-agent'
    And header User-Agent = 'Karate/1.5.1 (Test Automation)'
    When method GET
    Then status 200
    And match response['user-agent'] == 'Karate/1.5.1 (Test Automation)'

  @positive @user-agent
  Scenario: [RI-015] GET /user-agent - Response contains only user-agent field
    Given path '/user-agent'
    When method GET
    Then status 200
    And match response == { 'user-agent': '#string' }

  @positive @user-agent
  Scenario: [RI-016] GET /user-agent - User-agent value is not null or empty
    Given path '/user-agent'
    When method GET
    Then status 200
    And assert response['user-agent'] != null
    And assert response['user-agent'].length > 0
