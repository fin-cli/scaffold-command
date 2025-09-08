Feature: FinPress code scaffolding

  @theme
  Scenario: Scaffold a child theme
    Given a FP install
    And I run `fp theme path`
    And save STDOUT as {THEME_DIR}

    When I run `fp scaffold child-theme zombieland --parent_theme=umbrella --theme_name=Zombieland --author=Tallahassee --author_uri=https://fp-cli.org --theme_uri=http://www.zombieland.com`
    Then the {THEME_DIR}/zombieland/style.css file should exist
    And the {THEME_DIR}/zombieland/functions.php file should exist
    And STDOUT should be:
      """
      Success: Created '{THEME_DIR}/zombieland'.
      """
    And the {THEME_DIR}/zombieland/.editorconfig file should exist

  Scenario: Scaffold a child theme with only --parent_theme parameter
    Given a FP install
    And I run `fp theme path`
    And save STDOUT as {THEME_DIR}

    When I run `fp scaffold child-theme hello-world --parent_theme=simple-life`
    Then STDOUT should not be empty
    And the {THEME_DIR}/hello-world/style.css file should exist
    And the {THEME_DIR}/hello-world/style.css file should contain:
      """
      Theme Name:     Hello-world
      """

  Scenario: Scaffold a child theme with non existing parent theme and also activate parameter
    Given a FP install

    When I try `fp scaffold child-theme hello-world --parent_theme=just-test --activate --quiet`
    Then STDERR should contain:
      """
      Error: The parent theme is missing. Please install the "just-test" parent theme.
      """
    And the return code should be 1

  Scenario: Scaffold a child theme with non existing parent theme and also network activate parameter
    Given a FP install

    When I try `fp scaffold child-theme hello-world --parent_theme=just-test --enable-network --quiet`
    Then STDERR should contain:
      """
      Error: This is not a multisite install
      """
    And the return code should be 1

  @require-fp-4.6
  Scenario: Scaffold a child theme and network enable it
    Given a FP multisite install

    When I run `fp scaffold child-theme zombieland --parent_theme=umbrella --theme_name=Zombieland --author=Tallahassee --author_uri=https://fp-cli.org --theme_uri=http://www.zombieland.com --enable-network`
    Then STDOUT should contain:
      """
      Success: Network enabled the 'Zombieland' theme.
      """

  Scenario: Scaffold a child theme with invalid slug
    Given a FP install
    When I try `fp scaffold child-theme . --parent_theme=simple-life`
    Then STDERR should contain:
      """
      Error: Invalid theme slug specified.
      """
    And the return code should be 1

    When I try `fp scaffold child-theme ../ --parent_theme=simple-life`
    Then STDERR should contain:
      """
      Error: Invalid theme slug specified.
      """
    And the return code should be 1

  @tax @cpt
  Scenario: Scaffold a Custom Taxonomy and Custom Post Type and write it to active theme
    Given a FP install
    And I run `fp eval 'echo STYLESHEETPATH;'`
    And save STDOUT as {STYLESHEETPATH}

    When I run `fp scaffold taxonomy zombie-speed --theme`
    Then the {STYLESHEETPATH}/taxonomies/zombie-speed.php file should exist

    When I run `fp scaffold post-type zombie --theme`
    Then the {STYLESHEETPATH}/post-types/zombie.php file should exist
    And STDOUT should be:
      """
      Success: Created '{STYLESHEETPATH}/post-types/zombie.php'.
      """

    When I run `fp scaffold post-type zombie`
    Then STDOUT should contain:
      """
      'rest_base'             => 'zombie'
      """
    And STDOUT should contain:
      """
      add_filter( 'post_updated_messages'
      """
    When I run `fp scaffold post-type zombie --raw`
    Then STDOUT should not contain:
      """
      add_filter( 'post_updated_messages'
      """

  # Test for all flags but --label, --theme, --plugin and --raw
  @tax
  Scenario: Scaffold a Custom Taxonomy and attach it to CPTs including one that is prefixed and has a text domain
    Given a FP install
    When I run `fp scaffold taxonomy zombie-speed --post_types="prefix-zombie,wraith" --textdomain=zombieland`
    Then STDOUT should contain:
      """
      __( 'Zombie speeds'
      """
    And STDOUT should contain:
      """
      array( 'prefix-zombie', 'wraith' )
      """
    And STDOUT should contain:
      """
      __( 'Zombie speeds', 'zombieland'
      """

  @tax
  Scenario: Scaffold a Custom Taxonomy with label "Speed"
    Given a FP install
    When I run `fp scaffold taxonomy zombie-speed --label="Speed"`
    Then STDOUT should contain:
      """
      __( 'Speeds'
      """
    And STDOUT should contain:
      """
      _x( 'Speed', 'taxonomy general name',
      """

  # Test for all flags but --label, --theme, --plugin and --raw
  @cpt
  Scenario: Scaffold a Custom Post Type
    Given a FP install
    When I run `fp scaffold post-type zombie --textdomain=zombieland`
    Then STDOUT should contain:
      """
      __( 'Zombies'
      """
    And STDOUT should contain:
      """
      __( 'Zombies', 'zombieland'
      """
    And STDOUT should contain:
      """
      'menu_icon'             => 'dashicons-admin-post',
      """

  Scenario: CPT slug is too long
    Given a FP install
    When I try `fp scaffold post-type slugiswaytoolonginfact`
    Then STDERR should be:
      """
      Error: Post type slugs cannot exceed 20 characters in length.
      """
    And the return code should be 1

  @cpt
  Scenario: Scaffold a Custom Post Type with label
    Given a FP install
    When I run `fp scaffold post-type zombie --label="Brain eater"`
    Then STDOUT should contain:
      """
      __( 'Brain eaters'
      """

  Scenario: Scaffold a Custom Post Type with dashicon
    Given a FP install
    When I run `fp scaffold post-type zombie --dashicon="art"`
    Then STDOUT should contain:
      """
      'menu_icon'             => 'dashicons-art',
      """

  Scenario: Scaffold a Custom Post Type with dashicon in the case of passing "dashicon-info"
    Given a FP install
    When I run `fp scaffold post-type zombie --dashicon="dashicon-info"`
    Then STDOUT should contain:
      """
      'menu_icon'             => 'dashicons-info',
      """

  Scenario: Scaffold a Custom Post Type with dashicon in the case of passing "dashicons-info"
    Given a FP install
    When I run `fp scaffold post-type zombie --dashicon="dashicons-info"`
    Then STDOUT should contain:
      """
      'menu_icon'             => 'dashicons-info',
      """

  Scenario: Scaffold a plugin
    Given a FP install
    And I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And I run `fp core version`
    And save STDOUT as {FP_VERSION}

    When I run `fp scaffold plugin hello-world --plugin_author="Hello World Author"`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/hello-world/.gitignore file should exist
    And the {PLUGIN_DIR}/hello-world/.editorconfig file should exist
    And the {PLUGIN_DIR}/hello-world/hello-world.php file should exist
    And the {PLUGIN_DIR}/hello-world/readme.txt file should exist
    And the {PLUGIN_DIR}/hello-world/composer.json file should exist
    And the {PLUGIN_DIR}/hello-world/.gitignore file should contain:
      """
      .DS_Store
      phpcs.xml
      phpunit.xml
      Thumbs.db
      fp-cli.local.yml
      node_modules/
      vendor/
      """
    And the {PLUGIN_DIR}/hello-world/.distignore file should contain:
      """
      .git
      .gitignore
      """
    And the {PLUGIN_DIR}/hello-world/.phpcs.xml.dist file should contain:
      """
      	<rule ref="PHPCompatibilityFP"/>
      """
    And the {PLUGIN_DIR}/hello-world/.phpcs.xml.dist file should contain:
      """
      	<config name="testVersion" value="7.2-"/>
      """
    And the {PLUGIN_DIR}/hello-world/hello-world.php file should contain:
      """
      * Plugin Name:     Hello World
      """
    And the {PLUGIN_DIR}/hello-world/hello-world.php file should contain:
      """
      * Version:         0.1.0
      """
    And the {PLUGIN_DIR}/hello-world/hello-world.php file should contain:
      """
      * @package         Hello_World
      """
    And the {PLUGIN_DIR}/hello-world/readme.txt file should contain:
      """
      Stable tag: 0.1.0
      """
    And the {PLUGIN_DIR}/hello-world/readme.txt file should contain:
      """
      Tested up to: {FP_VERSION}
      """

    When I run `cat {PLUGIN_DIR}/hello-world/composer.json`
    Then STDOUT should contain:
      """
      fp-cli/i18n-command
      """

  Scenario: Scaffold a plugin by prompting
    Given a FP install
    And a session file:
      """
      hello-world

      Hello World
      An awesome introductory plugin for FinPress
      FP-CLI
      https://fp-cli.org
      https://fp-cli.org
      n
      circle
      Y
      n
      n
      """

    When I run `fp scaffold plugin --prompt < session`
    Then STDOUT should not be empty
    And the fp-content/plugins/hello-world/hello-world.php file should exist
    And the fp-content/plugins/hello-world/readme.txt file should exist
    And the fp-content/plugins/hello-world/tests directory should exist

    When I run `fp plugin status hello-world`
    Then STDOUT should contain:
      """
      Status: Active
      """
    And STDOUT should contain:
      """
      Name: Hello World
      """
    And STDOUT should contain:
      """
      Description: An awesome introductory plugin for FinPress
      """

  Scenario: Scaffold a plugin and activate it
    Given a FP install
    When I run `fp scaffold plugin hello-world --activate`
    Then STDOUT should contain:
      """
      Plugin 'hello-world' activated.
      """

  @require-fp-4.6
  Scenario: Scaffold a plugin and network activate it
    Given a FP multisite install
    When I run `fp scaffold plugin hello-world --activate-network`
    Then STDOUT should contain:
      """
      Plugin 'hello-world' network activated.
      """

  Scenario: Scaffold a plugin with invalid slug
    Given a FP install
    When I try `fp scaffold plugin .`
    Then STDERR should contain:
      """
      Error: Invalid plugin slug specified.
      """
    And the return code should be 1

    When I try `fp scaffold plugin ../`
    Then STDERR should contain:
      """
      Error: Invalid plugin slug specified.
      """
    And the return code should be 1

  @require-php-5.6 @require-fp-4.6
  Scenario: Scaffold starter code for a theme
    Given a FP install
    And I run `fp theme path`
    And save STDOUT as {THEME_DIR}

    # Allow for warnings to be generated due to https://github.com/fp-cli/scaffold-command/issues/181
    When I try `fp scaffold _s starter-theme`
    Then STDOUT should contain:
      """
      Success: Created theme 'Starter-theme'.
      """
    And the {THEME_DIR}/starter-theme/style.css file should exist
    And the {THEME_DIR}/starter-theme/.editorconfig file should exist

  @require-php-5.6 @require-fp-4.6
  Scenario: Scaffold starter code for a theme with sass
    Given a FP install
    And I run `fp theme path`
    And save STDOUT as {THEME_DIR}

    # Allow for warnings to be generated due to https://github.com/fp-cli/scaffold-command/issues/181
    When I try `fp scaffold _s starter-theme --sassify`
    Then STDOUT should contain:
      """
      Success: Created theme 'Starter-theme'.
      """
    And the {THEME_DIR}/starter-theme/sass directory should exist

  @require-php-5.6 @require-fp-4.6
  Scenario: Scaffold starter code for a WooCommerce theme
    Given a FP install
    And I run `fp theme path`
    And save STDOUT as {THEME_DIR}

    # Allow for warnings to be generated due to https://github.com/fp-cli/scaffold-command/issues/181
    When I try `fp scaffold _s starter-theme --woocommerce`
    Then STDOUT should contain:
      """
      Success: Created theme 'Starter-theme'.
      """
    And the {THEME_DIR}/starter-theme/woocommerce.css file should exist
    And the {THEME_DIR}/starter-theme/inc/woocommerce.php file should exist

  @require-php-5.6 @require-fp-4.6 @require-mysql
  Scenario: Scaffold starter code for a theme and activate it
    Given a FP install
    # Allow for warnings to be generated due to https://github.com/fp-cli/scaffold-command/issues/181
    When I try `fp scaffold _s starter-theme --activate`
    Then STDOUT should contain:
      """
      Success: Switched to 'Starter-theme' theme.
      """

  Scenario: Scaffold starter code for a theme with invalid slug
    Given a FP install
    When I try `fp scaffold _s .`
    Then STDERR should contain:
      """
      Error: Invalid theme slug specified.
      """
    And the return code should be 1

    When I try `fp scaffold _s ../`
    Then STDERR should contain:
      """
      Error: Invalid theme slug specified.
      """
    And the return code should be 1

    When I try `fp scaffold _s 1themestartingwithnumber`
    Then STDERR should contain:
      """
      Error: Invalid theme slug specified. Theme slugs can only contain letters, numbers, underscores and hyphens, and can only start with a letter or underscore.
      """
    And the return code should be 1

  Scenario: Scaffold plugin and tests for non-standard plugin directory
    Given a FP install

    When I run `fp scaffold plugin custom-plugin --dir=fp-content/mu-plugins --skip-tests`
    Then STDOUT should not be empty
    And the fp-content/mu-plugins/custom-plugin/custom-plugin.php file should exist
    And the fp-content/mu-plugins/custom-plugin/tests directory should not exist

    When I try `fp scaffold plugin-tests --dir=fp-content/mu-plugins/incorrect-custom-plugin`
    Then STDERR should contain:
      """
      Error: Invalid plugin directory specified.
      """
    And the return code should be 1

    When I run `fp scaffold plugin-tests --dir=fp-content/mu-plugins/custom-plugin`
    Then STDOUT should contain:
      """
      Success: Created test files.
      """
    And the fp-content/mu-plugins/custom-plugin/tests directory should exist
    And the fp-content/mu-plugins/custom-plugin/tests/bootstrap.php file should exist
    And the fp-content/mu-plugins/custom-plugin/tests/bootstrap.php file should contain:
      """
      require dirname( dirname( __FILE__ ) ) . '/custom-plugin.php';
      """

  Scenario: Scaffold tests for a plugin with a different slug than plugin directory
    Given a FP install
    And a fp-content/mu-plugins/custom-plugin2/custom-plugin-slug.php file:
      """
      <?php
      /**
       * Plugin Name: Handbook
       * Description: Features for a handbook, complete with glossary and table of contents
       * Author: Nacin
       */
      """

    When I run `fp scaffold plugin-tests custom-plugin-slug --dir=fp-content/mu-plugins/custom-plugin2`
    Then STDOUT should contain:
      """
      Success: Created test files.
      """
    And the fp-content/mu-plugins/custom-plugin2/tests directory should exist
    And the fp-content/mu-plugins/custom-plugin2/tests/bootstrap.php file should exist
    And the fp-content/mu-plugins/custom-plugin2/tests/bootstrap.php file should contain:
      """
      require dirname( dirname( __FILE__ ) ) . '/custom-plugin-slug.php';
      """

  Scenario: Scaffold tests parses plugin readme.txt
    Given a FP install
    When I run `fp core version`
    Then save STDOUT as {FP_VERSION}
    When I run `fp plugin path`
    Then save STDOUT as {PLUGIN_DIR}

    When I run `fp scaffold plugin hello-world`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/hello-world/readme.txt file should exist
    And the {PLUGIN_DIR}/hello-world/.circleci/config.yml file should exist
    And the {PLUGIN_DIR}/hello-world/.circleci/config.yml file should contain:
      """
      workflows:
        version: 2
        main:
          jobs:
            - php56-build
            - php70-build
            - php71-build
            - php72-build
            - php73-build
            - php74-build
      """

  @require-php-5.6 @require-fp-4.6
  Scenario: Scaffold starter code for a theme and network enable it
    Given a FP multisite install
    # Allow for warnings to be generated due to https://github.com/fp-cli/scaffold-command/issues/181
    When I try `fp scaffold _s starter-theme --enable-network`
    Then STDOUT should contain:
      """
      Success: Network enabled the 'Starter-theme' theme.
      """

  @require-php-5.6 @require-fp-4.6 @require-mysql
  Scenario: Scaffold starter code for a theme, but can't unzip theme files
    Given a FP install
    And a misconfigured FP_CONTENT_DIR constant directory
    When I try `fp scaffold _s starter-theme`
    Then STDERR should contain:
      """
      Error: Could not decompress your theme files
      """
    And the return code should be 1

  Scenario: Overwrite existing files
    Given a FP install
    When I run `fp scaffold plugin test`
    And I try `fp scaffold plugin test --force`
    Then STDERR should contain:
      """
      already exists
      """
    And STDOUT should contain:
      """
      Replacing
      """
    And the return code should be 0

  Scenario: Scaffold tests for invalid plugin directory
    Given a FP install

    When I try `fp scaffold plugin-tests incorrect-custom-plugin`
    Then STDERR should contain:
      """
      Error: Invalid plugin slug specified.
      """
    And the return code should be 1
