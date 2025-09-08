Feature: Scaffold plugin unit tests

  Scenario: Scaffold plugin tests
    Given a FP install
    When I run `fp plugin path`
    Then save STDOUT as {PLUGIN_DIR}

    When I run `fp scaffold plugin hello-world --skip-tests`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/hello-world/.editorconfig file should exist
    And the {PLUGIN_DIR}/hello-world/hello-world.php file should exist
    And the {PLUGIN_DIR}/hello-world/readme.txt file should exist
    And the {PLUGIN_DIR}/hello-world/tests directory should not exist

    When I run `fp scaffold plugin-tests hello-world`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/hello-world/tests directory should contain:
      """
      bootstrap.php
      test-sample.php
      """
    And the {PLUGIN_DIR}/hello-world/tests/bootstrap.php file should contain:
      """
      require dirname( dirname( __FILE__ ) ) . '/hello-world.php';
      """
    And the {PLUGIN_DIR}/hello-world/tests/bootstrap.php file should contain:
      """
      * @package Hello_World
      """
    And the {PLUGIN_DIR}/hello-world/tests/test-sample.php file should contain:
      """
      * @package Hello_World
      """
    And the {PLUGIN_DIR}/hello-world/bin directory should contain:
      """
      install-fp-tests.sh
      """
    And the {PLUGIN_DIR}/hello-world/phpunit.xml.dist file should contain:
      """
      <exclude>./tests/test-sample.php</exclude>
      """
    And the {PLUGIN_DIR}/hello-world/.phpcs.xml.dist file should exist
    And the {PLUGIN_DIR}/hello-world/circle.yml file should not exist
    And the {PLUGIN_DIR}/hello-world/bitbucket-pipelines.yml file should not exist
    And the {PLUGIN_DIR}/hello-world/.gitlab-ci.yml file should not exist
    And the {PLUGIN_DIR}/hello-world/.circleci/config.yml file should contain:
      """
      jobs:
        php56-build:
          <<: *php_job
          docker:
            - image: circleci/php:5.6
            - image: *mysql_image
      """
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

    When I run `fp eval "if ( is_executable( '{PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh' ) ) { echo 'executable'; } else { exit( 1 ); }"`
    Then STDOUT should be:
      """
      executable
      """

  Scenario: Scaffold plugin tests with Circle as the provider, part one
    Given a FP install
    And I run `fp scaffold plugin hello-world --ci=circle`

    When I run `fp plugin path hello-world --dir`
    Then save STDOUT as {PLUGIN_DIR}
    And the {PLUGIN_DIR}/circle.yml file should not exist
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
      version: 2
      """
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
      php56-build
      """
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
      php70-build
      """
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
      php71-build
      """
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
      php72-build
      """
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
      php73-build
      """
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
      php74-build
      """

  Scenario: Scaffold plugin tests with Circle as the provider, part two
    Given a FP install
    And I run `fp scaffold plugin hello-world --skip-tests`

    When I run `fp plugin path hello-world --dir`
    Then save STDOUT as {PLUGIN_DIR}

    When I run `fp scaffold plugin-tests hello-world --ci=circle`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/circle.yml file should not exist
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
      version: 2
      """
    And the {PLUGIN_DIR}/.circleci/config.yml file should contain:
      """
                  rm -rf $FP_TESTS_DIR $FP_CORE_DIR
                  bash bin/install-fp-tests.sh finpress_test root '' 127.0.0.1 4.5 $SKIP_DB_CREATE
                  phpunit
                  FP_MULTISITE=1 phpunit
                  SKIP_DB_CREATE=true
                  rm -rf $FP_TESTS_DIR $FP_CORE_DIR
                  bash bin/install-fp-tests.sh finpress_test root '' 127.0.0.1 latest $SKIP_DB_CREATE
                  phpunit
                  FP_MULTISITE=1 phpunit
                  SKIP_DB_CREATE=true
                  rm -rf $FP_TESTS_DIR $FP_CORE_DIR
                  bash bin/install-fp-tests.sh finpress_test root '' 127.0.0.1 trunk $SKIP_DB_CREATE
                  phpunit
                  FP_MULTISITE=1 phpunit
                  SKIP_DB_CREATE=true
      """

  Scenario: Scaffold plugin tests with Gitlab as the provider
    Given a FP install
    And I run `fp scaffold plugin hello-world --skip-tests`

    When I run `fp plugin path hello-world --dir`
    Then save STDOUT as {PLUGIN_DIR}

    When I run `fp scaffold plugin-tests hello-world --ci=gitlab`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/.gitlab-ci.yml file should contain:
      """
      MYSQL_DATABASE
      """

  Scenario: Scaffold plugin tests with Bitbucket Pipelines as the provider
    Given a FP install
    And I run `fp scaffold plugin hello-world --skip-tests`

    When I run `fp plugin path hello-world --dir`
    Then save STDOUT as {PLUGIN_DIR}

    When I run `fp scaffold plugin-tests hello-world --ci=bitbucket`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/bitbucket-pipelines.yml file should contain:
      """
      pipelines:
        default:
      """
    And the {PLUGIN_DIR}/bitbucket-pipelines.yml file should contain:
      """
          - step:
              image: php:7.4
              name: "PHP 7.4"
              script:
                # Install Dependencies
                - apt-get update && apt-get install -y subversion git zip libzip-dev --no-install-recommends
      """
    And the {PLUGIN_DIR}/bitbucket-pipelines.yml file should contain:
      """
          - step:
              image: php:8.0
              name: "PHP 8.0"
              script:
                # Install Dependencies
                - apt-get update && apt-get install -y subversion git zip libzip-dev --no-install-recommends
      """
    And the {PLUGIN_DIR}/bitbucket-pipelines.yml file should contain:
      """
          - step:
              image: php:8.2
              name: "PHP 8.2"
              script:
                # Install Dependencies
                - apt-get update && apt-get install -y subversion git zip libzip-dev --no-install-recommends
      """
    And the {PLUGIN_DIR}/bitbucket-pipelines.yml file should contain:
      """
      definitions:
        services:
          database:
            image: mysql:latest
            environment:
              MYSQL_DATABASE: 'finpress_tests'
              MYSQL_ROOT_PASSWORD: 'root'
      """

  Scenario: Scaffold plugin tests with invalid slug
    Given a FP install
    Then the {RUN_DIR}/fp-content/plugins/hello.php file should exist

    When I try `fp scaffold plugin-tests hello`
    Then STDERR should be:
      """
      Error: Invalid plugin slug specified. No such target directory '{RUN_DIR}/fp-content/plugins/hello'.
      """
    And the return code should be 1

    When I try `fp scaffold plugin-tests .`
    Then STDERR should be:
      """
      Error: Invalid plugin slug specified. The slug cannot be '.' or '..'.
      """
    And the return code should be 1

    When I try `fp scaffold plugin-tests ../`
    Then STDERR should be:
      """
      Error: Invalid plugin slug specified. The target directory '{RUN_DIR}/fp-content/plugins/../' is not in '{RUN_DIR}/fp-content/plugins'.
      """
    And the return code should be 1

  Scenario: Scaffold plugin tests with invalid directory
    Given a FP install
    And I run `fp scaffold plugin hello-world --skip-tests`

    When I run `fp plugin path hello-world --dir`
    Then save STDOUT as {PLUGIN_DIR}

    When I try `fp scaffold plugin-tests hello-world --dir=non-existent-dir`
    Then STDERR should be:
      """
      Error: Invalid plugin directory specified. No such directory 'non-existent-dir'.
      """
    And the return code should be 1

    When I run `rm -rf {PLUGIN_DIR} && touch {PLUGIN_DIR}`
    Then the return code should be 0
    When I try `fp scaffold plugin-tests hello-world`
    Then STDERR should be:
      """
      Error: Invalid plugin slug specified. No such target directory '{PLUGIN_DIR}'.
      """
    And the return code should be 1

  Scenario: Scaffold plugin tests with a symbolic link
    Given a FP install
    And I run `fp scaffold plugin hello-world --skip-tests`

    When I run `fp plugin path hello-world --dir`
    Then save STDOUT as {PLUGIN_DIR}

    When I run `mv {PLUGIN_DIR} {RUN_DIR} && ln -s {RUN_DIR}/hello-world {PLUGIN_DIR}`
    Then the return code should be 0

    When I run `fp scaffold plugin-tests hello-world`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/tests directory should contain:
      """
      bootstrap.php
      """

  Scenario: Scaffold plugin tests with custom main file
    Given a FP install
    And a fp-content/plugins/foo/bar.php file:
      """
      <?php
      /**
       * Plugin Name:     Foo
       * Plugin URI:      https://example.com
       * Description:     Foo desctiption
       * Author:          John Doe
       * Author URI:      https://example.com
       * Text Domain:     foo
       * Domain Path:     /languages
       * Version:         0.1.0
       *
       * @package  Foo
       */
      """

    When I run `fp scaffold plugin-tests foo`
    Then the fp-content/plugins/foo/tests/bootstrap.php file should contain:
      """
      require dirname( dirname( __FILE__ ) ) . '/bar.php';
      """

  Scenario: Accept bitbucket as valid CI in plugin scaffold
    Given a FP install
    When I run `fp plugin path`
    Then save STDOUT as {PLUGIN_DIR}

    When I run `fp scaffold plugin hello-world --ci=bitbucket`
    Then STDOUT should not be empty
    And the {PLUGIN_DIR}/hello-world/.editorconfig file should exist
    And the {PLUGIN_DIR}/hello-world/hello-world.php file should exist
    And the {PLUGIN_DIR}/hello-world/readme.txt file should exist
    And the {PLUGIN_DIR}/hello-world/bitbucket-pipelines.yml file should exist
    And the {PLUGIN_DIR}/hello-world/tests directory should exist
