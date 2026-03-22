@smoke
Feature: Smoke Test Suite - httpbin.org
  Critical path smoke tests to verify httpbin.org API is accessible and functioning.
  Covers the most important endpoints across all categories.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ─────────────────────────────────────────────
  # HTTP Methods
  # ─────────────────────────────────────────────

  @smoke @get
  Scenario: [SMOKE-001] GET /get - Basic GET request returns 200
    Given path '/get'
    When method GET
    Then status 200
    And match response contains { args: '#object', headers: '#object', url: '#string' }
    And match response.url == baseUrl + '/get'

  @smoke @post
  Scenario: [SMOKE-002] POST /post - POST with JSON body returns echoed data
    Given path '/post'
    And header Content-Type = 'application/json'
    And request { name: 'smoke-test', framework: 'karate' }
    When method POST
    Then status 200
    And match response.json contains { name: 'smoke-test', framework: 'karate' }
    And match response.url == baseUrl + '/post'

  @smoke @put
  Scenario: [SMOKE-003] PUT /put - PUT request returns 200 with echoed body
    Given path '/put'
    And header Content-Type = 'application/json'
    And request { updated: true }
    When method PUT
    Then status 200
    And match response.json contains { updated: true }

  @smoke @delete
  Scenario: [SMOKE-004] DELETE /delete - DELETE request returns 200
    Given path '/delete'
    When method DELETE
    Then status 200
    And match response contains { url: '#string', args: '#object' }

  @smoke @patch
  Scenario: [SMOKE-005] PATCH /patch - PATCH request returns 200 with echoed body
    Given path '/patch'
    And header Content-Type = 'application/json'
    And request { patched: true }
    When method PATCH
    Then status 200
    And match response.json contains { patched: true }

  # ─────────────────────────────────────────────
  # Status Codes
  # ─────────────────────────────────────────────

  @smoke @status
  Scenario: [SMOKE-006] GET /status/200 - Status endpoint returns requested code
    Given path '/status/200'
    When method GET
    Then status 200

  @smoke @status
  Scenario: [SMOKE-007] GET /status/404 - Status endpoint returns 404
    Given path '/status/404'
    When method GET
    Then status 404

  @smoke @status
  Scenario: [SMOKE-008] GET /status/500 - Status endpoint returns 500
    Given path '/status/500'
    When method GET
    Then status 500

  # ─────────────────────────────────────────────
  # Authentication
  # ─────────────────────────────────────────────

  @smoke @auth
  Scenario: [SMOKE-009] Basic Auth - Valid credentials return 200
    * def token = java.util.Base64.getEncoder().encodeToString('user:passwd'.getBytes('UTF-8'))
    Given path '/basic-auth/user/passwd'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 200
    And match response == { authenticated: true, user: 'user' }

  @smoke @auth
  Scenario: [SMOKE-010] Bearer Auth - Valid token returns 200
    Given path '/bearer'
    And header Authorization = 'Bearer smoke-test-token-abc123'
    When method GET
    Then status 200
    And match response contains { authenticated: true, token: 'smoke-test-token-abc123' }

  # ─────────────────────────────────────────────
  # Request Inspection
  # ─────────────────────────────────────────────

  @smoke @inspection
  Scenario: [SMOKE-011] GET /headers - Custom request header is reflected in response
    Given path '/headers'
    And header X-Smoke-Test = 'karate-smoke'
    When method GET
    Then status 200
    And match response.headers['X-Smoke-Test'] == 'karate-smoke'

  @smoke @inspection
  Scenario: [SMOKE-012] GET /ip - Returns requester IP address
    Given path '/ip'
    When method GET
    Then status 200
    And match response contains { origin: '#string' }
    And match response.origin == '#notnull'

  # ─────────────────────────────────────────────
  # Response Formats
  # ─────────────────────────────────────────────

  @smoke @format
  Scenario: [SMOKE-013] GET /json - Returns valid JSON with slideshow structure
    Given path '/json'
    When method GET
    Then status 200
    And match response contains { slideshow: '#object' }

  @smoke @format
  Scenario: [SMOKE-014] GET /html - Returns HTML content
    Given path '/html'
    And header Accept = 'text/html'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text/html'

  @smoke @format
  Scenario: [SMOKE-015] GET /xml - Returns XML content
    Given path '/xml'
    And header Accept = 'application/xml'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'xml'

  # ─────────────────────────────────────────────
  # Dynamic Data
  # ─────────────────────────────────────────────

  @smoke @dynamic
  Scenario: [SMOKE-016] GET /uuid - Returns a valid UUID v4
    Given path '/uuid'
    When method GET
    Then status 200
    And match response.uuid == '#uuid'

  # ─────────────────────────────────────────────
  # Cookies
  # ─────────────────────────────────────────────

  @smoke @cookies
  Scenario: [SMOKE-017] GET /cookies - Returns cookie data structure
    Given path '/cookies'
    When method GET
    Then status 200
    And match response contains { cookies: '#object' }

  # ─────────────────────────────────────────────
  # Images
  # ─────────────────────────────────────────────

  @smoke @images
  Scenario: [SMOKE-018] GET /image/png - Returns PNG image with correct content-type
    Given path '/image/png'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] == 'image/png'

  # ─────────────────────────────────────────────
  # Anything (Echo)
  # ─────────────────────────────────────────────

  @smoke @anything
  Scenario: [SMOKE-019] GET /anything - Echoes request information
    Given path '/anything'
    And header X-Test-Header = 'smoke-anything'
    When method GET
    Then status 200
    And match response contains { method: 'GET', url: '#string', headers: '#object' }
    And match response.headers['X-Test-Header'] == 'smoke-anything'

  @smoke @anything
  Scenario: [SMOKE-020] POST /anything - Echoes POST body and method
    Given path '/anything'
    And header Content-Type = 'application/json'
    And request { smoke: true, test: 'anything' }
    When method POST
    Then status 200
    And match response.method == 'POST'
    And match response.json contains { smoke: true, test: 'anything' }
