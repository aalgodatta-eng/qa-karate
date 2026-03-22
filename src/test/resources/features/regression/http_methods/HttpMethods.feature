@regression @http-methods
Feature: HTTP Methods - Testing all HTTP verbs
  Validates GET, POST, PUT, PATCH, DELETE HTTP methods against httpbin.org.
  Covers positive scenarios (valid requests) and negative scenarios (edge cases).

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET Tests
  # ═══════════════════════════════════════════════════════════

  @positive @get
  Scenario: [HTTP-001] GET /get - Basic GET returns 200 with correct response structure
    Given path '/get'
    When method GET
    Then status 200
    And match response.url == baseUrl + '/get'
    And match response contains
      """
      {
        args: '#object',
        headers: '#object',
        origin: '#string',
        url: '#string'
      }
      """
    And match response.headers contains { Host: '#string' }

  @positive @get
  Scenario: [HTTP-002] GET /get - GET with single query parameter echoes args
    Given path '/get'
    And param foo = 'bar'
    When method GET
    Then status 200
    And match response.args == { foo: 'bar' }

  @positive @get
  Scenario: [HTTP-003] GET /get - GET with multiple query parameters echoes all args
    Given path '/get'
    And param key1 = 'value1'
    And param key2 = 'value2'
    And param key3 = '123'
    When method GET
    Then status 200
    And match response.args == { key1: 'value1', key2: 'value2', key3: '123' }

  @positive @get
  Scenario: [HTTP-004] GET /get - GET with custom headers reflects them in response
    Given path '/get'
    And header X-Custom-Header = 'karate-test'
    And header X-Test-Id = 'HTTP-004'
    When method GET
    Then status 200
    And match response.headers['X-Custom-Header'] == 'karate-test'
    And match response.headers['X-Test-Id'] == 'HTTP-004'

  @positive @get
  Scenario: [HTTP-005] GET /get - GET with Accept header is reflected
    Given path '/get'
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And match response.headers['Accept'] == 'application/json'

  @negative @get
  Scenario: [HTTP-006] GET /get - GET with no query params returns empty args
    Given path '/get'
    When method GET
    Then status 200
    And match response.args == {}

  @positive @get
  Scenario: [HTTP-007] GET /get - Response contains origin IP (not null/empty)
    Given path '/get'
    When method GET
    Then status 200
    And match response.origin == '#notnull'
    And assert response.origin.length > 0

  # ═══════════════════════════════════════════════════════════
  # POST Tests
  # ═══════════════════════════════════════════════════════════

  @positive @post
  Scenario: [HTTP-008] POST /post - POST with JSON body returns 200 and echoes body
    Given path '/post'
    And header Content-Type = 'application/json'
    And request { name: 'karate', version: '1.5.1', active: true }
    When method POST
    Then status 200
    And match response.json == { name: 'karate', version: '1.5.1', active: true }
    And match response.url == baseUrl + '/post'

  @positive @post
  Scenario: [HTTP-009] POST /post - POST with form-encoded data echoes form fields
    Given path '/post'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field username = 'testuser'
    And form field password = 'testpass'
    And form field role = 'admin'
    When method POST
    Then status 200
    And match response.form == { username: 'testuser', password: 'testpass', role: 'admin' }

  @positive @post
  Scenario: [HTTP-010] POST /post - POST with query parameters are echoed in args
    Given path '/post'
    And param source = 'karate'
    And param env = 'test'
    And header Content-Type = 'application/json'
    And request {}
    When method POST
    Then status 200
    And match response.args contains { source: 'karate', env: 'test' }

  @positive @post
  Scenario: [HTTP-011] POST /post - POST with nested JSON object
    Given path '/post'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "user": {
          "name": "John Doe",
          "age": 30,
          "address": {
            "city": "Test City",
            "zip": "12345"
          }
        },
        "active": true
      }
      """
    When method POST
    Then status 200
    And match response.json.user.name == 'John Doe'
    And match response.json.user.age == 30
    And match response.json.user.address.city == 'Test City'

  @positive @post
  Scenario: [HTTP-012] POST /post - POST with JSON array
    Given path '/post'
    And header Content-Type = 'application/json'
    And request [1, 2, 3, "four", true]
    When method POST
    Then status 200
    And match response.json == [1, 2, 3, 'four', true]

  @negative @post
  Scenario: [HTTP-013] POST /post - POST with empty string body
    Given path '/post'
    And header Content-Type = 'application/json'
    And request ''
    When method POST
    Then status 200
    And match response contains { url: '#string' }

  @negative @post
  Scenario: [HTTP-014] POST /post - POST with large payload
    * def payload = { data: '#(new Array(100).fill("x").join(""))', count: 100 }
    Given path '/post'
    And header Content-Type = 'application/json'
    And request payload
    When method POST
    Then status 200
    And match response.json.count == 100

  # ═══════════════════════════════════════════════════════════
  # PUT Tests
  # ═══════════════════════════════════════════════════════════

  @positive @put
  Scenario: [HTTP-015] PUT /put - Basic PUT request with JSON body
    Given path '/put'
    And header Content-Type = 'application/json'
    And request { id: 42, name: 'updated-resource', status: 'active' }
    When method PUT
    Then status 200
    And match response.json == { id: 42, name: 'updated-resource', status: 'active' }
    And match response.url == baseUrl + '/put'

  @positive @put
  Scenario: [HTTP-016] PUT /put - PUT with query parameters
    Given path '/put'
    And param id = '100'
    And param version = '2'
    And header Content-Type = 'application/json'
    And request { status: 'updated' }
    When method PUT
    Then status 200
    And match response.args == { id: '100', version: '2' }
    And match response.json == { status: 'updated' }

  @positive @put
  Scenario: [HTTP-017] PUT /put - PUT with custom headers
    Given path '/put'
    And header Content-Type = 'application/json'
    And header X-Request-Id = 'put-test-123'
    And request { updated: true }
    When method PUT
    Then status 200
    And match response.headers['X-Request-Id'] == 'put-test-123'

  # ═══════════════════════════════════════════════════════════
  # PATCH Tests
  # ═══════════════════════════════════════════════════════════

  @positive @patch
  Scenario: [HTTP-018] PATCH /patch - Basic PATCH request with partial update payload
    Given path '/patch'
    And header Content-Type = 'application/json'
    And request { field: 'updated-value', timestamp: '2026-03-22' }
    When method PATCH
    Then status 200
    And match response.json == { field: 'updated-value', timestamp: '2026-03-22' }
    And match response.url == baseUrl + '/patch'

  @positive @patch
  Scenario: [HTTP-019] PATCH /patch - PATCH returns full request metadata
    Given path '/patch'
    And header Content-Type = 'application/json'
    And header X-Patch-Id = 'patch-001'
    And request { patch: true }
    When method PATCH
    Then status 200
    And match response contains { args: '#object', headers: '#object', json: '#object', url: '#string' }
    And match response.headers['X-Patch-Id'] == 'patch-001'

  # ═══════════════════════════════════════════════════════════
  # DELETE Tests
  # ═══════════════════════════════════════════════════════════

  @positive @delete
  Scenario: [HTTP-020] DELETE /delete - Basic DELETE request returns 200
    Given path '/delete'
    When method DELETE
    Then status 200
    And match response contains { url: '#string', args: '#object', headers: '#object' }
    And match response.url == baseUrl + '/delete'

  @positive @delete
  Scenario: [HTTP-021] DELETE /delete - DELETE with query parameters
    Given path '/delete'
    And param id = '999'
    And param reason = 'cleanup'
    When method DELETE
    Then status 200
    And match response.args == { id: '999', reason: 'cleanup' }

  @positive @delete
  Scenario: [HTTP-022] DELETE /delete - DELETE with JSON body
    Given path '/delete'
    And header Content-Type = 'application/json'
    And request { id: 42, reason: 'expired' }
    When method DELETE
    Then status 200
    And match response.json == { id: 42, reason: 'expired' }

  @positive @delete
  Scenario: [HTTP-023] DELETE /delete - DELETE with custom headers
    Given path '/delete'
    And header X-Delete-Reason = 'test-cleanup'
    When method DELETE
    Then status 200
    And match response.headers['X-Delete-Reason'] == 'test-cleanup'

  # ═══════════════════════════════════════════════════════════
  # Cross-Method Validation
  # ═══════════════════════════════════════════════════════════

  @positive
  Scenario Outline: [HTTP-024] All HTTP methods return 200 and echo the URL correctly
    Given path '/<endpoint>'
    And header Content-Type = 'application/json'
    And request {}
    When method <method>
    Then status 200
    And match response.url contains '/<endpoint>'

    Examples:
      | method | endpoint |
      | POST   | post     |
      | PUT    | put      |
      | PATCH  | patch    |
      | DELETE | delete   |
