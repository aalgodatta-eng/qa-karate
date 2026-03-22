@regression @cookies
Feature: Cookies - Creates, reads and deletes Cookies
  Validates httpbin.org cookie management endpoints:
  reading cookies, setting cookies, and deleting cookies.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET /cookies - Returns cookie data
  # ═══════════════════════════════════════════════════════════

  @positive @read-cookies
  Scenario: [CK-001] GET /cookies - Without cookies returns empty cookies object
    Given path '/cookies'
    When method GET
    Then status 200
    And match response == { cookies: {} }

  @positive @read-cookies
  Scenario: [CK-002] GET /cookies - Response structure always contains cookies object
    Given path '/cookies'
    When method GET
    Then status 200
    And match response contains { cookies: '#object' }

  @positive @read-cookies
  Scenario: [CK-003] GET /cookies - With manually set Cookie header reflects cookies
    Given path '/cookies'
    And header Cookie = 'manual-cookie=test-value'
    When method GET
    Then status 200
    And match response.cookies['manual-cookie'] == 'test-value'

  @positive @read-cookies
  Scenario: [CK-004] GET /cookies - Multiple cookies in Cookie header are all reflected
    Given path '/cookies'
    And header Cookie = 'cookie1=val1; cookie2=val2; cookie3=val3'
    When method GET
    Then status 200
    And match response.cookies['cookie1'] == 'val1'
    And match response.cookies['cookie2'] == 'val2'
    And match response.cookies['cookie3'] == 'val3'

  # ═══════════════════════════════════════════════════════════
  # GET /cookies/set/{name}/{value} - Sets a cookie via redirect
  # ═══════════════════════════════════════════════════════════

  @positive @set-cookies
  Scenario: [CK-005] GET /cookies/set/{name}/{value} - Sets cookie and redirects to /cookies (follow redirect)
    * configure followRedirects = true
    Given path '/cookies/set/test-cookie/hello-karate'
    When method GET
    Then status 200
    And match response.cookies contains { 'test-cookie': 'hello-karate' }

  @positive @set-cookies
  Scenario: [CK-006] GET /cookies/set - Without following redirect returns 302 with Set-Cookie header
    * configure followRedirects = false
    Given path '/cookies/set/my-cookie/my-value'
    When method GET
    Then status 302
    And match responseHeaders['Set-Cookie'] != null

  @positive @set-cookies
  Scenario: [CK-007] GET /cookies/set/{name}/{value} - Set-Cookie header contains correct name=value
    * configure followRedirects = false
    Given path '/cookies/set/session-id/abc-123-xyz'
    When method GET
    Then status 302
    And match responseHeaders['Set-Cookie'][0] contains 'session-id=abc-123-xyz'

  @positive @set-cookies
  Scenario: [CK-008] GET /cookies/set via query params - Sets cookie via query parameter
    * configure followRedirects = true
    Given path '/cookies/set'
    And param param-cookie = 'param-value'
    When method GET
    Then status 200
    And match response.cookies contains { 'param-cookie': 'param-value' }

  @positive @set-cookies
  Scenario: [CK-009] GET /cookies/set - Multiple cookies set at once via query params
    * configure followRedirects = true
    Given path '/cookies/set'
    And param cookie-a = 'alpha'
    And param cookie-b = 'beta'
    When method GET
    Then status 200
    And match response.cookies['cookie-a'] == 'alpha'
    And match response.cookies['cookie-b'] == 'beta'

  @positive @set-cookies
  Scenario Outline: [CK-010] GET /cookies/set/{name}/{value} - Various cookie name/value pairs
    * configure followRedirects = true
    Given path '/cookies/set/<name>/<value>'
    When method GET
    Then status 200
    And match response.cookies contains { '<name>': '<value>' }

    Examples:
      | name         | value           |
      | username     | john-doe        |
      | session      | sess-abc-123    |
      | theme        | dark            |

  # ═══════════════════════════════════════════════════════════
  # GET /cookies/delete - Deletes cookies
  # ═══════════════════════════════════════════════════════════

  @positive @delete-cookies
  Scenario: [CK-011] GET /cookies/delete - Deletes cookie via query param and redirects to /cookies
    * configure followRedirects = true
    Given path '/cookies/delete'
    And param del-cookie = ''
    When method GET
    Then status 200
    And match response contains { cookies: '#object' }
    And match response.cookies['del-cookie'] == '#notpresent'

  @positive @delete-cookies
  Scenario: [CK-012] GET /cookies/delete - Without following redirect returns 302
    * configure followRedirects = false
    Given path '/cookies/delete'
    And param some-cookie = ''
    When method GET
    Then status 302

  # ═══════════════════════════════════════════════════════════
  # Cookie Lifecycle (Set → Read → Delete)
  # ═══════════════════════════════════════════════════════════

  @positive @cookie-lifecycle
  Scenario: [CK-013] Cookie lifecycle - Set cookie, verify it exists, then delete it
    # Step 1: Set cookie via /cookies/set path (no redirect follow, check 302)
    * configure followRedirects = false
    Given path '/cookies/set/lifecycle-cookie/lifecycle-value'
    When method GET
    Then status 302
    And match responseHeaders['Set-Cookie'][0] contains 'lifecycle-cookie=lifecycle-value'

    # Step 2: Read cookies with the cookie header set manually
    Given path '/cookies'
    And header Cookie = 'lifecycle-cookie=lifecycle-value'
    When method GET
    Then status 200
    And match response.cookies['lifecycle-cookie'] == 'lifecycle-value'

  @positive @cookie-values
  Scenario: [CK-014] GET /cookies/set - Cookie with special characters in value
    * configure followRedirects = false
    Given path '/cookies/set/special/value-with-dashes'
    When method GET
    Then status 302
    And match responseHeaders['Set-Cookie'][0] contains 'special=value-with-dashes'

  @negative @cookies
  Scenario: [CK-015] GET /cookies - Cookie header with no value still shows key
    Given path '/cookies'
    And header Cookie = 'empty-cookie='
    When method GET
    Then status 200
    And match response.cookies contains { 'empty-cookie': '' }
