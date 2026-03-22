@regression @anything
Feature: Anything - Returns anything that is passed to request
  Validates the /anything endpoint which echoes back everything passed in the request:
  method, URL, headers, query params, body, and form data.
  Tests all HTTP methods and various request configurations.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET /anything - Echo GET request
  # ═══════════════════════════════════════════════════════════

  @positive @anything-get
  Scenario: [ANY-001] GET /anything - Returns method and URL in response
    Given path '/anything'
    When method GET
    Then status 200
    And match response.method == 'GET'
    And match response.url == baseUrl + '/anything'

  @positive @anything-get
  Scenario: [ANY-002] GET /anything - Returns complete response structure
    Given path '/anything'
    When method GET
    Then status 200
    And match response contains
      """
      {
        args: '#object',
        data: '#string',
        files: '#object',
        form: '#object',
        headers: '#object',
        json: '#ignore',
        method: 'GET',
        origin: '#string',
        url: '#string'
      }
      """

  @positive @anything-get
  Scenario: [ANY-003] GET /anything - Query parameters are echoed in args
    Given path '/anything'
    And param key = 'value'
    And param test = 'karate'
    When method GET
    Then status 200
    And match response.args == { key: 'value', test: 'karate' }
    And match response.method == 'GET'

  @positive @anything-get
  Scenario: [ANY-004] GET /anything - Custom headers are echoed in headers
    Given path '/anything'
    And header X-Test-Header = 'anything-test'
    And header X-Karate-Version = '1.5.1'
    When method GET
    Then status 200
    And match response.headers['X-Test-Header'] == 'anything-test'
    And match response.headers['X-Karate-Version'] == '1.5.1'

  # ═══════════════════════════════════════════════════════════
  # POST /anything - Echo POST request
  # ═══════════════════════════════════════════════════════════

  @positive @anything-post
  Scenario: [ANY-005] POST /anything - Returns POST method and echoes JSON body
    Given path '/anything'
    And header Content-Type = 'application/json'
    And request { name: 'anything-test', value: 42, active: true }
    When method POST
    Then status 200
    And match response.method == 'POST'
    And match response.json == { name: 'anything-test', value: 42, active: true }

  @positive @anything-post
  Scenario: [ANY-006] POST /anything - Echoes nested JSON body
    Given path '/anything'
    And header Content-Type = 'application/json'
    And request
      """
      {
        "level1": {
          "level2": {
            "level3": "deep-value"
          }
        }
      }
      """
    When method POST
    Then status 200
    And match response.method == 'POST'
    And match response.json.level1.level2.level3 == 'deep-value'

  @positive @anything-post
  Scenario: [ANY-007] POST /anything - Echoes form data in form field
    Given path '/anything'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field field1 = 'formValue1'
    And form field field2 = 'formValue2'
    When method POST
    Then status 200
    And match response.method == 'POST'
    And match response.form == { field1: 'formValue1', field2: 'formValue2' }

  @positive @anything-post
  Scenario: [ANY-008] POST /anything - Echoes raw string data in data field
    Given path '/anything'
    And header Content-Type = 'text/plain'
    And request 'raw text data from karate test'
    When method POST
    Then status 200
    And match response.method == 'POST'
    And match response.data == 'raw text data from karate test'

  # ═══════════════════════════════════════════════════════════
  # PUT /anything - Echo PUT request
  # ═══════════════════════════════════════════════════════════

  @positive @anything-put
  Scenario: [ANY-009] PUT /anything - Returns PUT method and echoes body
    Given path '/anything'
    And header Content-Type = 'application/json'
    And request { updated: true, id: 99 }
    When method PUT
    Then status 200
    And match response.method == 'PUT'
    And match response.json == { updated: true, id: 99 }

  # ═══════════════════════════════════════════════════════════
  # PATCH /anything - Echo PATCH request
  # ═══════════════════════════════════════════════════════════

  @positive @anything-patch
  Scenario: [ANY-010] PATCH /anything - Returns PATCH method and echoes body
    Given path '/anything'
    And header Content-Type = 'application/json'
    And request { field: 'patched-value' }
    When method PATCH
    Then status 200
    And match response.method == 'PATCH'
    And match response.json == { field: 'patched-value' }

  # ═══════════════════════════════════════════════════════════
  # DELETE /anything - Echo DELETE request
  # ═══════════════════════════════════════════════════════════

  @positive @anything-delete
  Scenario: [ANY-011] DELETE /anything - Returns DELETE method
    Given path '/anything'
    When method DELETE
    Then status 200
    And match response.method == 'DELETE'

  @positive @anything-delete
  Scenario: [ANY-012] DELETE /anything - DELETE with body is echoed
    Given path '/anything'
    And header Content-Type = 'application/json'
    And request { reason: 'cleanup', id: 1 }
    When method DELETE
    Then status 200
    And match response.method == 'DELETE'
    And match response.json == { reason: 'cleanup', id: 1 }

  # ═══════════════════════════════════════════════════════════
  # GET /anything/{path} - Sub-path routing
  # ═══════════════════════════════════════════════════════════

  @positive @anything-path
  Scenario: [ANY-013] GET /anything/custom-path - Returns URL with custom path
    Given path '/anything/custom-path'
    When method GET
    Then status 200
    And match response.url == baseUrl + '/anything/custom-path'
    And match response.method == 'GET'

  @positive @anything-path
  Scenario: [ANY-014] GET /anything/nested/deep/path - Returns URL with nested path
    Given path '/anything/nested/deep/path'
    When method GET
    Then status 200
    And match response.url == baseUrl + '/anything/nested/deep/path'

  @positive @anything-path
  Scenario: [ANY-015] POST /anything/resource/123 - Echoes path with resource ID
    Given path '/anything/resource/123'
    And header Content-Type = 'application/json'
    And request { action: 'create' }
    When method POST
    Then status 200
    And match response.url == baseUrl + '/anything/resource/123'
    And match response.method == 'POST'
    And match response.json.action == 'create'

  # ═══════════════════════════════════════════════════════════
  # Scenario Outline - All HTTP methods with /anything
  # ═══════════════════════════════════════════════════════════

  @positive
  Scenario Outline: [ANY-016] <method> /anything - Returns correct method in response
    Given path '/anything'
    And header Content-Type = 'application/json'
    And request {}
    When method <method>
    Then status 200
    And match response.method == '<method>'
    And match response.url == baseUrl + '/anything'

    Examples:
      | method |
      | POST   |
      | PUT    |
      | PATCH  |
      | DELETE |

  # ═══════════════════════════════════════════════════════════
  # Comprehensive echo test
  # ═══════════════════════════════════════════════════════════

  @positive @anything-comprehensive
  Scenario: [ANY-017] POST /anything - Full echo test with headers, params, and body
    Given path '/anything'
    And param action = 'test'
    And param env = 'regression'
    And header Content-Type = 'application/json'
    And header X-Trace-Id = 'trace-karate-001'
    And header Accept = 'application/json'
    And request { test: 'comprehensive', framework: 'karate', version: '1.5.1' }
    When method POST
    Then status 200
    And match response.method == 'POST'
    And match response.args == { action: 'test', env: 'regression' }
    And match response.headers['X-Trace-Id'] == 'trace-karate-001'
    And match response.json == { test: 'comprehensive', framework: 'karate', version: '1.5.1' }

  @negative @anything
  Scenario: [ANY-018] GET /anything - Response origin field is always present
    Given path '/anything'
    When method GET
    Then status 200
    And match response.origin == '#notnull'
    And assert response.origin.length > 0
