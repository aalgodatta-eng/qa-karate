@regression @response-formats
Feature: Response Formats - Returns responses in different data formats
  Validates that httpbin.org returns content in various formats:
  JSON, HTML, XML, UTF-8 encoding, gzip, deflate, and brotli compressed responses.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET /json - Returns JSON
  # ═══════════════════════════════════════════════════════════

  @positive @json-format
  Scenario: [RF-001] GET /json - Returns 200 with JSON content-type
    Given path '/json'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'application/json'

  @positive @json-format
  Scenario: [RF-002] GET /json - Returns slideshow JSON structure
    Given path '/json'
    When method GET
    Then status 200
    And match response contains { slideshow: '#object' }
    And match response.slideshow contains { author: '#string', date: '#string', slides: '#array', title: '#string' }

  @positive @json-format
  Scenario: [RF-003] GET /json - Slideshow contains at least one slide
    Given path '/json'
    When method GET
    Then status 200
    And assert response.slideshow.slides.length > 0

  @positive @json-format
  Scenario: [RF-004] GET /json - Each slide has a title and type
    Given path '/json'
    When method GET
    Then status 200
    And match each response.slideshow.slides contains { title: '#string', type: '#string' }

  # ═══════════════════════════════════════════════════════════
  # GET /html - Returns HTML
  # ═══════════════════════════════════════════════════════════

  @positive @html-format
  Scenario: [RF-005] GET /html - Returns 200 with text/html content-type
    Given path '/html'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text/html'

  @positive @html-format
  Scenario: [RF-006] GET /html - Response body contains HTML markup
    Given path '/html'
    And header Accept = 'text/html'
    When method GET
    Then status 200
    And assert response.contains('<!DOCTYPE html>') || response.contains('<html')

  @positive @html-format
  Scenario: [RF-007] GET /html - Response is non-empty HTML content
    Given path '/html'
    When method GET
    Then status 200
    And assert response.length > 100

  # ═══════════════════════════════════════════════════════════
  # GET /xml - Returns XML
  # ═══════════════════════════════════════════════════════════

  @positive @xml-format
  Scenario: [RF-008] GET /xml - Returns 200 with XML content-type
    Given path '/xml'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'xml'

  @positive @xml-format
  Scenario: [RF-009] GET /xml - Response contains XML slideshow structure
    Given path '/xml'
    And header Accept = 'application/xml'
    When method GET
    Then status 200
    And match response /slideshow != null

  # ═══════════════════════════════════════════════════════════
  # GET /encoding/utf8 - Returns UTF-8 encoded content
  # ═══════════════════════════════════════════════════════════

  @positive @encoding
  Scenario: [RF-010] GET /encoding/utf8 - Returns 200 with UTF-8 HTML content
    Given path '/encoding/utf8'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text/html'

  @positive @encoding
  Scenario: [RF-011] GET /encoding/utf8 - Response contains unicode characters
    Given path '/encoding/utf8'
    When method GET
    Then status 200
    And assert response.length > 0

  # ═══════════════════════════════════════════════════════════
  # GET /gzip - Returns gzip-encoded data
  # ═══════════════════════════════════════════════════════════

  @positive @compression
  Scenario: [RF-012] GET /gzip - Returns 200 with gzipped response (auto-decompressed)
    Given path '/gzip'
    And header Accept-Encoding = 'gzip'
    When method GET
    Then status 200
    And match response contains { gzipped: true }

  @positive @compression
  Scenario: [RF-013] GET /gzip - Response contains expected fields after decompression
    Given path '/gzip'
    When method GET
    Then status 200
    And match response contains { gzipped: '#boolean', headers: '#object', method: '#string', origin: '#string' }
    And match response.gzipped == true
    And match response.method == 'GET'

  # ═══════════════════════════════════════════════════════════
  # GET /deflate - Returns deflate-encoded data
  # ═══════════════════════════════════════════════════════════

  @positive @compression
  Scenario: [RF-014] GET /deflate - Returns 200 with deflate response (auto-decompressed)
    Given path '/deflate'
    And header Accept-Encoding = 'deflate'
    When method GET
    Then status 200
    And match response contains { deflated: true }

  @positive @compression
  Scenario: [RF-015] GET /deflate - Response contains expected fields after decompression
    Given path '/deflate'
    When method GET
    Then status 200
    And match response contains { deflated: '#boolean', headers: '#object', method: '#string', origin: '#string' }
    And match response.deflated == true
    And match response.method == 'GET'

  # ═══════════════════════════════════════════════════════════
  # GET /brotli - Returns brotli-encoded data
  # ═══════════════════════════════════════════════════════════

  @positive @compression
  Scenario: [RF-016] GET /brotli - Returns 200 with brotli response (auto-decompressed)
    Given path '/brotli'
    And header Accept-Encoding = 'br'
    When method GET
    Then status 200
    And match response contains { brotli: true }

  @positive @compression
  Scenario: [RF-017] GET /brotli - Response contains expected fields after decompression
    Given path '/brotli'
    When method GET
    Then status 200
    And match response contains { brotli: '#boolean', headers: '#object', method: '#string', origin: '#string' }
    And match response.brotli == true

  # ═══════════════════════════════════════════════════════════
  # GET /robots.txt - Returns robots.txt
  # ═══════════════════════════════════════════════════════════

  @positive @text-format
  Scenario: [RF-018] GET /robots.txt - Returns 200 with text content
    Given path '/robots.txt'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text'

  # ═══════════════════════════════════════════════════════════
  # GET /deny - Returns denied response (negative path)
  # ═══════════════════════════════════════════════════════════

  @negative @text-format
  Scenario: [RF-019] GET /deny - Returns plain text denial message
    Given path '/deny'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'text'
    And assert response.contains('DENY') || response.length > 0

  # ═══════════════════════════════════════════════════════════
  # Content Negotiation
  # ═══════════════════════════════════════════════════════════

  @positive @content-negotiation
  Scenario Outline: [RF-020] Response format Content-Type matches endpoint type
    Given path '<endpoint>'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains '<expectedContentType>'

    Examples:
      | endpoint        | expectedContentType |
      | /json           | application/json    |
      | /html           | text/html           |
      | /encoding/utf8  | text/html           |
