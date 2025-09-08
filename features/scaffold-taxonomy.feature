Feature: Scaffold a custom taxonomy

  Scenario: Scaffold a taxonomy that uses Doctrine pluralization
    Given a FP install

    When I run `fp scaffold taxonomy fungus --raw`
    Then STDOUT should contain:
      """
      __( 'Popular Fungi'
      """

  Scenario: Extended scaffolded taxonomy includes term_updated_messages
    Given a FP install

    When I run `fp scaffold taxonomy fungus`
    Then STDOUT should contain:
      """
      add_filter( 'term_updated_messages', 'fungus_updated_messages' );
      """
    And STDOUT should contain:
      """
      $messages['fungus'] = array(
      """
    And STDOUT should contain:
      """
      1 => __( 'Fungus added.', 'YOUR-TEXTDOMAIN' ),
      """
    And STDOUT should contain:
      """
      6 => __( 'Fungi deleted.', 'YOUR-TEXTDOMAIN' ),
      """
