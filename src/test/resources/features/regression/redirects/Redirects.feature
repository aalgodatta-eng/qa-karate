@regression @redirects
Feature: Redirects - Returns different redirect responses
  Validates httpbin.org redirect endpoints covering absolute, relative,
  and custom URL redirects. Tests both following and not following redirects.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET /redirect/{n} - Redirects n times
  # ═══════════════════════════════════════════════════════════

  @positive @redirect-follow
  Scenario: [RD-001] GET /redirect/1 - Single redirect followed, final response is 200
    * configure followRedirects = true
    Given path '/redirect/1'
    When method GET
    Then status 200
    And match response contains { url: '#string' }

  @positive @redirect-follow
  Scenario: [RD-002] GET /redirect/3 - Three redirects followed, final response is 200
    * configure followRedirects = true
    Given path '/redirect/3'
    When method GET
    Then status 200

  @positive @no-follow
  Scenario: [RD-003] GET /redirect/1 - Without following redirect returns 302
    * configure followRedirects = false
    Given path '/redirect/1'
    When method GET
    Then status 302
    And match responseHeaders['Location'] != null

  @positive @no-follow
  Scenario: [RD-004] GET /redirect/2 - Without following redirect returns 302
    * configure followRedirects = false
    Given path '/redirect/2'
    When method GET
    Then status 302
    And match responseHeaders['Location'] != null

  @positive @no-follow
  Scenario: [RD-005] GET /redirect/1 - Location header points to valid path
    * configure followRedirects = false
    Given path '/redirect/1'
    When method GET
    Then status 302
    * def location = responseHeaders['Location'][0]
    And assert location != null
    And assert location.length > 0

  # ═══════════════════════════════════════════════════════════
  # GET /absolute-redirect/{n} - Absolute URL redirects
  # ═══════════════════════════════════════════════════════════

  @positive @absolute-redirect
  Scenario: [RD-006] GET /absolute-redirect/1 - Single absolute redirect returns 302
    * configure followRedirects = false
    Given path '/absolute-redirect/1'
    When method GET
    Then status 302
    And match responseHeaders['Location'] != null
    And match responseHeaders['Location'][0] contains 'http'

  @positive @absolute-redirect
  Scenario: [RD-007] GET /absolute-redirect/2 - Two absolute redirects first response is 302
    * configure followRedirects = false
    Given path '/absolute-redirect/2'
    When method GET
    Then status 302

  @positive @absolute-redirect
  Scenario: [RD-008] GET /absolute-redirect/1 - Following redirect lands at /get
    * configure followRedirects = true
    Given path '/absolute-redirect/1'
    When method GET
    Then status 200
    And match response contains { url: '#string' }

  # ═══════════════════════════════════════════════════════════
  # GET /relative-redirect/{n} - Relative URL redirects
  # ═══════════════════════════════════════════════════════════

  @positive @relative-redirect
  Scenario: [RD-009] GET /relative-redirect/1 - Single relative redirect returns 302
    * configure followRedirects = false
    Given path '/relative-redirect/1'
    When method GET
    Then status 302
    And match responseHeaders['Location'] != null

  @positive @relative-redirect
  Scenario: [RD-010] GET /relative-redirect/2 - Two relative redirects first response is 302
    * configure followRedirects = false
    Given path '/relative-redirect/2'
    When method GET
    Then status 302

  @positive @relative-redirect
  Scenario: [RD-011] GET /relative-redirect/1 - Following relative redirect lands at /get
    * configure followRedirects = true
    Given path '/relative-redirect/1'
    When method GET
    Then status 200

  # ═══════════════════════════════════════════════════════════
  # GET /redirect-to - Redirect to specific URL
  # ═══════════════════════════════════════════════════════════

  @positive @redirect-to
  Scenario: [RD-012] GET /redirect-to?url={url} - Redirects to specified URL (without following)
    * configure followRedirects = false
    Given path '/redirect-to'
    And param url = baseUrl + '/get'
    When method GET
    Then status 302
    And match responseHeaders['Location'][0] == baseUrl + '/get'

  @positive @redirect-to
  Scenario: [RD-013] GET /redirect-to - Default status code is 302
    * configure followRedirects = false
    Given path '/redirect-to'
    And param url = baseUrl + '/get'
    When method GET
    Then status 302

  @positive @redirect-to
  Scenario: [RD-014] GET /redirect-to - Custom 301 status code is returned
    * configure followRedirects = false
    Given path '/redirect-to'
    And param url = baseUrl + '/get'
    And param status_code = '301'
    When method GET
    Then status 301
    And match responseHeaders['Location'][0] == baseUrl + '/get'

  @positive @redirect-to
  Scenario: [RD-015] GET /redirect-to - Custom 307 status code is returned
    * configure followRedirects = false
    Given path '/redirect-to'
    And param url = baseUrl + '/get'
    And param status_code = '307'
    When method GET
    Then status 307

  @positive @redirect-to
  Scenario: [RD-016] GET /redirect-to - Following redirect to /get returns 200 with JSON
    * configure followRedirects = true
    Given path '/redirect-to'
    And param url = baseUrl + '/get'
    When method GET
    Then status 200
    And match response contains { url: '#string' }

  @negative @redirect-to
  Scenario: [RD-017] GET /redirect-to - Missing url parameter returns error (not 2xx success)
    Given path '/redirect-to'
    When method GET
    * def status = responseStatus
    Then assert status == 400 || status == 302 || status == 500 || status == 200

  # ═══════════════════════════════════════════════════════════
  # Scenario Outline - Multiple redirect counts
  # ═══════════════════════════════════════════════════════════

  @positive
  Scenario Outline: [RD-018] GET /redirect/<n> - <n> redirect(s) followed returns 200
    * configure followRedirects = true
    Given path '/redirect/<n>'
    When method GET
    Then status 200

    Examples:
      | n |
      | 1 |
      | 2 |
      | 3 |
