@regression @auth
Feature: Authentication - Testing all auth methods
  Validates HTTP Basic Auth, Bearer Token, Hidden Basic Auth, and Digest Auth
  against httpbin.org. Covers positive (valid credentials) and negative (invalid/missing) scenarios.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # HTTP Basic Authentication
  # ═══════════════════════════════════════════════════════════

  @positive @basic-auth
  Scenario: [AUTH-001] Basic Auth - Valid credentials return 200 with authenticated=true
    * def token = java.util.Base64.getEncoder().encodeToString('user:passwd'.getBytes('UTF-8'))
    Given path '/basic-auth/user/passwd'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 200
    And match response == { authenticated: true, user: 'user' }

  @positive @basic-auth
  Scenario: [AUTH-002] Basic Auth - Valid credentials with different username/password
    * def creds = 'admin:secret123'
    * def token = java.util.Base64.getEncoder().encodeToString(creds.getBytes('UTF-8'))
    Given path '/basic-auth/admin/secret123'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 200
    And match response == { authenticated: true, user: 'admin' }

  @negative @basic-auth
  Scenario: [AUTH-003] Basic Auth - Wrong password returns 401 Unauthorized
    * def token = java.util.Base64.getEncoder().encodeToString('user:wrongpassword'.getBytes('UTF-8'))
    Given path '/basic-auth/user/passwd'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 401

  @negative @basic-auth
  Scenario: [AUTH-004] Basic Auth - Wrong username returns 401 Unauthorized
    * def token = java.util.Base64.getEncoder().encodeToString('wronguser:passwd'.getBytes('UTF-8'))
    Given path '/basic-auth/user/passwd'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 401

  @negative @basic-auth
  Scenario: [AUTH-005] Basic Auth - No Authorization header returns 401
    Given path '/basic-auth/user/passwd'
    When method GET
    Then status 401

  @negative @basic-auth
  Scenario: [AUTH-006] Basic Auth - Malformed Authorization header returns 401
    Given path '/basic-auth/user/passwd'
    And header Authorization = 'Basic not-valid-base64!!!'
    When method GET
    Then status 401

  @negative @basic-auth
  Scenario: [AUTH-007] Basic Auth - Empty credentials return 401
    * def token = java.util.Base64.getEncoder().encodeToString(':'.getBytes('UTF-8'))
    Given path '/basic-auth/user/passwd'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 401

  @positive @basic-auth
  Scenario Outline: [AUTH-008] Basic Auth - Various valid username/password combinations
    * def token = java.util.Base64.getEncoder().encodeToString(('<username>:<password>').getBytes('UTF-8'))
    Given path '/basic-auth/<username>/<password>'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 200
    And match response.authenticated == true
    And match response.user == '<username>'

    Examples:
      | username  | password    |
      | alice     | pass123     |
      | bob       | mypassword  |
      | testuser  | testpass    |

  # ═══════════════════════════════════════════════════════════
  # Hidden Basic Authentication
  # ═══════════════════════════════════════════════════════════

  @positive @hidden-auth
  Scenario: [AUTH-009] Hidden Basic Auth - Valid credentials return 200
    * def token = java.util.Base64.getEncoder().encodeToString('hiddenuser:hiddenpass'.getBytes('UTF-8'))
    Given path '/hidden-basic-auth/hiddenuser/hiddenpass'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 200
    And match response == { authenticated: true, user: 'hiddenuser' }

  @negative @hidden-auth
  Scenario: [AUTH-010] Hidden Basic Auth - No credentials return 404 (not 401, hides endpoint existence)
    Given path '/hidden-basic-auth/hiddenuser/hiddenpass'
    When method GET
    Then status 404

  @negative @hidden-auth
  Scenario: [AUTH-011] Hidden Basic Auth - Wrong credentials return 404
    * def token = java.util.Base64.getEncoder().encodeToString('wronguser:wrongpass'.getBytes('UTF-8'))
    Given path '/hidden-basic-auth/hiddenuser/hiddenpass'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 404

  # ═══════════════════════════════════════════════════════════
  # Bearer Token Authentication
  # ═══════════════════════════════════════════════════════════

  @positive @bearer-auth
  Scenario: [AUTH-012] Bearer Auth - Valid bearer token returns 200 with authenticated=true
    Given path '/bearer'
    And header Authorization = 'Bearer my-valid-token-karate-test'
    When method GET
    Then status 200
    And match response == { authenticated: true, token: 'my-valid-token-karate-test' }

  @positive @bearer-auth
  Scenario: [AUTH-013] Bearer Auth - Any non-empty bearer token is accepted
    Given path '/bearer'
    And header Authorization = 'Bearer abc123XYZ'
    When method GET
    Then status 200
    And match response.authenticated == true
    And match response.token == 'abc123XYZ'

  @positive @bearer-auth
  Scenario: [AUTH-014] Bearer Auth - Token with special characters is echoed correctly
    Given path '/bearer'
    And header Authorization = 'Bearer token.with-special_chars.123'
    When method GET
    Then status 200
    And match response.token == 'token.with-special_chars.123'

  @negative @bearer-auth
  Scenario: [AUTH-015] Bearer Auth - No Authorization header returns 401
    Given path '/bearer'
    When method GET
    Then status 401

  @negative @bearer-auth
  Scenario: [AUTH-016] Bearer Auth - Wrong auth scheme (Basic instead of Bearer) returns 401
    * def token = java.util.Base64.getEncoder().encodeToString('user:pass'.getBytes('UTF-8'))
    Given path '/bearer'
    And header Authorization = 'Basic ' + token
    When method GET
    Then status 401

  @negative @bearer-auth
  Scenario: [AUTH-017] Bearer Auth - Invalid auth type returns 401
    Given path '/bearer'
    And header Authorization = 'InvalidScheme sometoken'
    When method GET
    Then status 401

  @negative @bearer-auth
  Scenario: [AUTH-018] Bearer Auth - Missing token value returns 401
    Given path '/bearer'
    And header Authorization = 'Bearer '
    When method GET
    Then status 401

  # ═══════════════════════════════════════════════════════════
  # Digest Authentication
  # ═══════════════════════════════════════════════════════════

  @negative @digest-auth
  Scenario: [AUTH-019] Digest Auth - No credentials returns 401 with WWW-Authenticate header
    Given path '/digest-auth/auth/digestuser/digestpass'
    When method GET
    Then status 401
    * def wwwAuth = responseHeaders['Www-Authenticate'] || responseHeaders['www-authenticate'] || responseHeaders['WWW-Authenticate']
    And assert wwwAuth != null

  @negative @digest-auth
  Scenario: [AUTH-020] Digest Auth endpoint (MD5 qop=auth) - No credentials returns 401
    Given path '/digest-auth/auth/md5user/md5pass/MD5'
    When method GET
    Then status 401

  @negative @digest-auth
  Scenario: [AUTH-021] Digest Auth - SHA-256 algorithm - No credentials returns 401
    Given path '/digest-auth/auth/shauser/shapass/SHA-256'
    When method GET
    Then status 401
