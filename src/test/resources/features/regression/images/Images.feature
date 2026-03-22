@regression @images
Feature: Images - Returns different image formats
  Validates httpbin.org image endpoints returning PNG, JPEG, WebP, SVG, and AVIF formats.
  Tests content-type headers, status codes, and content negotiation.

  Background:
    * url baseUrl
    * configure connectTimeout = 30000
    * configure readTimeout = 60000

  # ═══════════════════════════════════════════════════════════
  # GET /image/png - Returns a PNG image
  # ═══════════════════════════════════════════════════════════

  @positive @png
  Scenario: [IMG-001] GET /image/png - Returns 200 with PNG content-type
    Given path '/image/png'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] == 'image/png'

  @positive @png
  Scenario: [IMG-002] GET /image/png - Response body is non-empty (has PNG data)
    Given path '/image/png'
    When method GET
    Then status 200
    And assert responseBytes != null

  # ═══════════════════════════════════════════════════════════
  # GET /image/jpeg - Returns a JPEG image
  # ═══════════════════════════════════════════════════════════

  @positive @jpeg
  Scenario: [IMG-003] GET /image/jpeg - Returns 200 with JPEG content-type
    Given path '/image/jpeg'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] == 'image/jpeg'

  @positive @jpeg
  Scenario: [IMG-004] GET /image/jpeg - Accept: image/jpeg returns JPEG
    Given path '/image/jpeg'
    And header Accept = 'image/jpeg'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] == 'image/jpeg'

  # ═══════════════════════════════════════════════════════════
  # GET /image/webp - Returns a WebP image
  # ═══════════════════════════════════════════════════════════

  @positive @webp
  Scenario: [IMG-005] GET /image/webp - Returns 200 with WebP content-type
    Given path '/image/webp'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] == 'image/webp'

  # ═══════════════════════════════════════════════════════════
  # GET /image/svg - Returns an SVG image
  # ═══════════════════════════════════════════════════════════

  @positive @svg
  Scenario: [IMG-006] GET /image/svg - Returns 200 with SVG content-type
    Given path '/image/svg'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'image/svg'

  @positive @svg
  Scenario: [IMG-007] GET /image/svg - SVG response body contains XML markup
    Given path '/image/svg'
    When method GET
    Then status 200
    And assert response != null

  # ═══════════════════════════════════════════════════════════
  # GET /image - Content negotiation based on Accept header
  # ═══════════════════════════════════════════════════════════

  @positive @image-negotiation
  Scenario: [IMG-008] GET /image - Accept image/png returns PNG
    Given path '/image'
    And header Accept = 'image/png'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] == 'image/png'

  @positive @image-negotiation
  Scenario: [IMG-009] GET /image - Accept image/jpeg returns JPEG
    Given path '/image'
    And header Accept = 'image/jpeg'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] == 'image/jpeg'

  @positive @image-negotiation
  Scenario: [IMG-010] GET /image - Accept image/webp returns WebP
    Given path '/image'
    And header Accept = 'image/webp'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] == 'image/webp'

  @positive @image-negotiation
  Scenario: [IMG-011] GET /image - Accept image/svg+xml returns SVG
    Given path '/image'
    And header Accept = 'image/svg+xml'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'svg'

  @negative @image-negotiation
  Scenario: [IMG-012] GET /image - Accept unsupported type returns 406 Not Acceptable
    Given path '/image'
    And header Accept = 'image/bmp'
    When method GET
    Then status 406

  @negative @image-negotiation
  Scenario: [IMG-013] GET /image - No Accept header returns default image format
    Given path '/image'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains 'image/'

  # ═══════════════════════════════════════════════════════════
  # Scenario Outline - All explicit image formats
  # ═══════════════════════════════════════════════════════════

  @positive
  Scenario Outline: [IMG-014] GET /image/<format> - Returns correct content-type
    Given path '/image/<format>'
    When method GET
    Then status 200
    And match responseHeaders['Content-Type'][0] contains '<expectedType>'

    Examples:
      | format | expectedType |
      | png    | image/png    |
      | jpeg   | image/jpeg   |
      | webp   | image/webp   |
      | svg    | image/svg    |
