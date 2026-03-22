@regression @dynamic-data
Feature: Dynamic Data - Generates random and dynamic data
  Validates httpbin.org endpoints that generate dynamic data:
  UUID, base64 decoding, random bytes, delays, links, and range streaming.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET /uuid - Returns a UUID4
  # ═══════════════════════════════════════════════════════════

  @positive @uuid
  Scenario: [DD-001] GET /uuid - Returns a valid UUID v4
    Given path '/uuid'
    When method GET
    Then status 200
    And match response == { uuid: '#uuid' }

  @positive @uuid
  Scenario: [DD-002] GET /uuid - UUID matches UUID v4 regex format
    Given path '/uuid'
    When method GET
    Then status 200
    And match response.uuid == '#regex [0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}'

  @positive @uuid
  Scenario: [DD-003] GET /uuid - Each call returns a different UUID (randomness check)
    Given path '/uuid'
    When method GET
    Then status 200
    * def uuid1 = response.uuid
    Given path '/uuid'
    When method GET
    Then status 200
    * def uuid2 = response.uuid
    And assert uuid1 != uuid2

  # ═══════════════════════════════════════════════════════════
  # GET /base64/{value} - Decodes base64 value
  # ═══════════════════════════════════════════════════════════

  @positive @base64
  Scenario: [DD-004] GET /base64 - Decodes known base64 string (SFRUUEJJTiBpcyBhd2Vzb21l = 'HTTPBIN is awesome')
    Given path '/base64/SFRUUEJJTiBpcyBhd2Vzb21l'
    When method GET
    Then status 200
    And match response == 'HTTPBIN is awesome'

  @positive @base64
  Scenario: [DD-005] GET /base64 - Decodes 'SGVsbG8gV29ybGQ=' (Hello World)
    Given path '/base64/SGVsbG8gV29ybGQ='
    When method GET
    Then status 200
    And match response == 'Hello World'

  @positive @base64
  Scenario: [DD-006] GET /base64 - Decodes 'a2FyYXRl' (karate)
    Given path '/base64/a2FyYXRl'
    When method GET
    Then status 200
    And match response == 'karate'

  @negative @base64
  Scenario: [DD-007] GET /base64 - Invalid base64 string (Incorrect padding) returns non-5xx
    Given path '/base64/invalidbase64string'
    When method GET
    Then assert responseStatus == 200 || responseStatus == 400

  # ═══════════════════════════════════════════════════════════
  # GET /bytes/{n} - Returns n random bytes
  # ═══════════════════════════════════════════════════════════

  @positive @bytes
  Scenario: [DD-008] GET /bytes/10 - Returns 200 with binary content
    Given path '/bytes/10'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/octet-stream'

  @positive @bytes
  Scenario: [DD-009] GET /bytes/1 - Returns minimum 1 byte with correct content-type
    Given path '/bytes/1'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/octet-stream'

  @positive @bytes
  Scenario: [DD-010] GET /bytes/100 - Returns binary data (larger payload)
    Given path '/bytes/100'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/octet-stream'

  @negative @bytes
  Scenario: [DD-011] GET /bytes/0 - Zero bytes returns 200
    Given path '/bytes/0'
    When method GET
    Then status 200

  # ═══════════════════════════════════════════════════════════
  # GET /delay/{delay} - Delays response by n seconds
  # ═══════════════════════════════════════════════════════════

  @positive @delay
  Scenario: [DD-012] GET /delay/1 - Returns 200 after ~1 second delay
    Given path '/delay/1'
    When method GET
    Then status 200
    And match response contains { url: '#string', headers: '#object' }

  @positive @delay
  Scenario: [DD-013] GET /delay/2 - Returns 200 after ~2 second delay
    Given path '/delay/2'
    When method GET
    Then status 200
    And match response contains { url: '#string', headers: '#object' }

  @positive @delay
  Scenario: [DD-014] GET /delay/0 - Returns 200 immediately (0 second delay)
    Given path '/delay/0'
    When method GET
    Then status 200
    And match response contains { url: '#string' }

  # ═══════════════════════════════════════════════════════════
  # GET /links/{n}/{offset} - Generates a page with n links
  # ═══════════════════════════════════════════════════════════

  @positive @links
  Scenario: [DD-015] GET /links/5/0 - Returns HTML page with links
    Given path '/links/5/0'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text/html'

  @positive @links
  Scenario: [DD-016] GET /links/1/0 - Returns HTML page with a single link
    Given path '/links/1/0'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text/html'

  @positive @links
  Scenario: [DD-017] GET /links/10/0 - Returns HTML page with 10 links
    Given path '/links/10/0'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text/html'

  # ═══════════════════════════════════════════════════════════
  # GET /range/{numbytes} - Streams byte range data
  # ═══════════════════════════════════════════════════════════

  @positive @range
  Scenario: [DD-018] GET /range/100 - Returns 200 with octet-stream content-type
    Given path '/range/100'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/octet-stream'

  @positive @range
  Scenario: [DD-019] GET /range/1024 - Returns 200 for larger range
    Given path '/range/1024'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/octet-stream'

  @positive @range
  Scenario: [DD-020] GET /range/{n} with Range header - Returns 206 Partial Content
    Given path '/range/1000'
    And header Range = 'bytes=0-99'
    When method GET
    Then status 206
    And match responseHeaders['Content-Range'] != null

  # ═══════════════════════════════════════════════════════════
  # GET /stream/{n} - Streams n JSON objects
  # ═══════════════════════════════════════════════════════════

  @positive @stream
  Scenario: [DD-021] GET /stream/3 - Returns 200 with streamed JSON lines
    Given path '/stream/3'
    When method GET
    Then status 200

  @positive @stream
  Scenario: [DD-022] GET /stream/1 - Returns 200 for single streamed object
    Given path '/stream/1'
    When method GET
    Then status 200
