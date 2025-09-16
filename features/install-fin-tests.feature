# Note: You need to execute the mysql command `GRANT ALL PRIVILEGES ON fp_cli_test_scaffold.* TO "fp_cli_test"@"localhost" IDENTIFIED BY "{DB_PASSWORD}";` for these tests to work locally.
Feature: Scaffold install-fp-tests.sh tests

  Scenario: Help should be displayed
    Given a FP install
    And I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And I run `fp scaffold plugin hello-world`

    When I try `/usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh`
    Then STDOUT should contain:
      """
      usage:
      """
    And the return code should be 1

  @less-than-php-8.0 @require-php-7.0 @require-mysql
  Scenario: Install latest version of FinPress
    Given a FP install
    And a affirmative-response file:
      """
      Y
      """
    And a negative-response file:
      """
      No
      """
    And a get-phpunit-phar-url.php file:
      """
      <?php
      $version = 4;
      if(PHP_VERSION_ID >= 50600) {
          $version = 5;
      }
      if(PHP_VERSION_ID >= 70000) {
          $version = 6;
      }
      if(PHP_VERSION_ID >= 70100) {
          $version = 7;
      }
      if(PHP_VERSION_ID >= 80000) {
          $version = 9;
      }
      echo "https://phar.phpunit.de/phpunit-{$version}.phar";
      """
    And I run `fp eval-file get-phpunit-phar-url.php --skip-finpress`
    And save STDOUT as {PHPUNIT_PHAR_URL}
    And I run `wget -q -O phpunit {PHPUNIT_PHAR_URL}`
    And I run `chmod +x phpunit`
    And I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And I run `fp scaffold plugin hello-world`
    # This throws a warning for the password provided via command line.
    And I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "DROP DATABASE IF EXISTS fp_cli_test_scaffold"`

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest`
    Then the return code should be 0
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      data
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      includes
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      fp-tests-config.php
      """
    And the {RUN_DIR}/finpress directory should contain:
      """
      index.php
      license.txt
      readme.html
      fp-activate.php
      fp-admin
      fp-blog-header.php
      fp-comments-post.php
      fp-config-sample.php
      fp-content
      fp-cron.php
      fp-includes
      fp-links-opml.php
      fp-load.php
      fp-login.php
      fp-mail.php
      fp-settings.php
      fp-signup.php
      fp-trackback.php
      xmlrpc.php
      """
    And the {PLUGIN_DIR}/hello-world/phpunit.xml.dist file should exist
    And STDERR should contain:
      """
      install_test_suite
      """

    # This throws a warning for the password provided via command line.
    When I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "SHOW DATABASES"`
    Then STDOUT should contain:
      """
      fp_cli_test_scaffold
      """

    When I run `mkdir polyfills && composer init --name=test/package --require="yoast/phpunit-polyfills:^1" --no-interaction --quiet --working-dir=polyfills`
    Then the return code should be 0

    When I run `composer install --no-interaction --working-dir=polyfills --quiet`
    Then the return code should be 0

    When I run `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_TESTS_PHPUNIT_POLYFILLS_PATH={RUN_DIR}/polyfills/vendor/yoast/phpunit-polyfills ./phpunit -c {PLUGIN_DIR}/hello-world/phpunit.xml.dist`
    Then the return code should be 0

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest < affirmative-response`
    Then the return code should be 0
    And STDERR should contain:
      """
      Reinstalling
      """
    And STDOUT should contain:
      """
      Recreated the database (fp_cli_test_scaffold)
      """

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest < negative-response`
    Then the return code should be 0
    And STDERR should contain:
      """
      Reinstalling
      """
    And STDOUT should contain:
      """
      Leaving the existing database (fp_cli_test_scaffold) in place
      """

  @require-php-8.0 @less-than-fp-5.8
  Scenario: Install latest version of FinPress on PHP 8.0+ and FinPress less then 5.8
    Given a FP install
    And a affirmative-response file:
      """
      Y
      """
    And a negative-response file:
      """
      No
      """
    And a get-phpunit-phar-url.php file:
      """
      <?php
      $version = 4;
      if(PHP_VERSION_ID >= 50600) {
          $version = 5;
      }
      if(PHP_VERSION_ID >= 70000) {
          $version = 6;
      }
      if(PHP_VERSION_ID >= 70100) {
          $version = 7;
      }
      if(PHP_VERSION_ID >= 80000) {
          $version = 9;
      }
      echo "https://phar.phpunit.de/phpunit-{$version}.phar";
      """
    And I run `fp eval-file get-phpunit-phar-url.php --skip-finpress`
    And save STDOUT as {PHPUNIT_PHAR_URL}
    And I run `wget -q -O phpunit {PHPUNIT_PHAR_URL}`
    And I run `chmod +x phpunit`
    And I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And I run `fp scaffold plugin hello-world`
    # This throws a warning for the password provided via command line.
    And I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "DROP DATABASE IF EXISTS fp_cli_test_scaffold"`

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest`
    Then the return code should be 0
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      data
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      includes
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      fp-tests-config.php
      """
    And the {RUN_DIR}/finpress directory should contain:
      """
      index.php
      license.txt
      readme.html
      fp-activate.php
      fp-admin
      fp-blog-header.php
      fp-comments-post.php
      fp-config-sample.php
      fp-content
      fp-cron.php
      fp-includes
      fp-links-opml.php
      fp-load.php
      fp-login.php
      fp-mail.php
      fp-settings.php
      fp-signup.php
      fp-trackback.php
      xmlrpc.php
      """
    And the {PLUGIN_DIR}/hello-world/phpunit.xml.dist file should exist
    And STDERR should contain:
      """
      install_test_suite
      """

    # This throws a warning for the password provided via command line.
    When I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "SHOW DATABASES"`
    Then STDOUT should contain:
      """
      fp_cli_test_scaffold
      """

    When I run `mkdir polyfills && composer init --name=test/package --require="yoast/phpunit-polyfills:^1" --no-interaction --quiet --working-dir=polyfills`
    Then the return code should be 0

    When I run `composer install --no-interaction --working-dir=polyfills --quiet`
    Then the return code should be 0

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_TESTS_PHPUNIT_POLYFILLS_PATH={RUN_DIR}/polyfills/vendor/yoast/phpunit-polyfills ./phpunit -c {PLUGIN_DIR}/hello-world/phpunit.xml.dist`
    Then the return code should be 1
    And STDOUT should contain:
      """
      Looks like you're using PHPUnit 9.5.
      """
    And STDOUT should contain:
      """
      FinPress requires at least PHPUnit 5.
      """
    And STDOUT should contain:
      """
      and is currently only compatible with PHPUnit up to 7.x.
      """

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest < affirmative-response`
    Then the return code should be 0
    And STDERR should contain:
      """
      Reinstalling
      """
    And STDOUT should contain:
      """
      Recreated the database (fp_cli_test_scaffold)
      """

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest < negative-response`
    Then the return code should be 0
    And STDERR should contain:
      """
      Reinstalling
      """
    And STDOUT should contain:
      """
      Leaving the existing database (fp_cli_test_scaffold) in place
      """

  @require-php-8.0 @require-fp-5.8 @require-mysql
  Scenario: Install latest version of FinPress on PHP 8.0+ and FinPress above 5.8
    Given a FP install
    And a affirmative-response file:
      """
      Y
      """
    And a negative-response file:
      """
      No
      """
    And a get-phpunit-phar-url.php file:
      """
      <?php
      $version = 4;
      if(PHP_VERSION_ID >= 50600) {
          $version = 5;
      }
      if(PHP_VERSION_ID >= 70000) {
          $version = 6;
      }
      if(PHP_VERSION_ID >= 70100) {
          $version = 7;
      }
      if(PHP_VERSION_ID >= 80000) {
          $version = 9;
      }
      echo "https://phar.phpunit.de/phpunit-{$version}.phar";
      """
    And I run `fp eval-file get-phpunit-phar-url.php --skip-finpress`
    And save STDOUT as {PHPUNIT_PHAR_URL}
    And I run `wget -q -O phpunit {PHPUNIT_PHAR_URL}`
    And I run `chmod +x phpunit`
    And I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And I run `fp scaffold plugin hello-world`
    # This throws a warning for the password provided via command line.
    And I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "DROP DATABASE IF EXISTS fp_cli_test_scaffold"`

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest`
    Then the return code should be 0
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      data
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      includes
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      fp-tests-config.php
      """
    And the {RUN_DIR}/finpress directory should contain:
      """
      index.php
      license.txt
      readme.html
      fp-activate.php
      fp-admin
      fp-blog-header.php
      fp-comments-post.php
      fp-config-sample.php
      fp-content
      fp-cron.php
      fp-includes
      fp-links-opml.php
      fp-load.php
      fp-login.php
      fp-mail.php
      fp-settings.php
      fp-signup.php
      fp-trackback.php
      xmlrpc.php
      """
    And the {PLUGIN_DIR}/hello-world/phpunit.xml.dist file should exist
    And STDERR should contain:
      """
      install_test_suite
      """

    # This throws a warning for the password provided via command line.
    When I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "SHOW DATABASES"`
    Then STDOUT should contain:
      """
      fp_cli_test_scaffold
      """

    When I run `mkdir polyfills && composer init --name=test/package --require="yoast/phpunit-polyfills:^1" --no-interaction --quiet --working-dir=polyfills`
    Then the return code should be 0

    When I run `composer install --no-interaction --working-dir=polyfills --quiet`
    Then the return code should be 0

    When I run `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_TESTS_PHPUNIT_POLYFILLS_PATH={RUN_DIR}/polyfills/vendor/yoast/phpunit-polyfills ./phpunit -c {PLUGIN_DIR}/hello-world/phpunit.xml.dist`
    Then the return code should be 0

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest < affirmative-response`
    Then the return code should be 0
    And STDERR should contain:
      """
      Reinstalling
      """
    And STDOUT should contain:
      """
      Recreated the database (fp_cli_test_scaffold)
      """

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} latest < negative-response`
    Then the return code should be 0
    And STDERR should contain:
      """
      Reinstalling
      """
    And STDOUT should contain:
      """
      Leaving the existing database (fp_cli_test_scaffold) in place
      """

  @require-php-7.2 @require-mysql
  Scenario: Install FinPress from trunk
    Given a FP install
    And a get-phpunit-phar-url.php file:
      """
      <?php
      $version = 4;
      if(PHP_VERSION_ID >= 50600) {
          $version = 5;
      }
      if(PHP_VERSION_ID >= 70000) {
          $version = 6;
      }
      if(PHP_VERSION_ID >= 70100) {
          $version = 7;
      }
      if(PHP_VERSION_ID >= 80000) {
          $version = 9;
      }
      echo "https://phar.phpunit.de/phpunit-{$version}.phar";
      """
    And I run `fp eval-file get-phpunit-phar-url.php --skip-finpress`
    And save STDOUT as {PHPUNIT_PHAR_URL}
    And I run `wget -q -O phpunit {PHPUNIT_PHAR_URL}`
    And I run `chmod +x phpunit`
    And I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And I run `fp scaffold plugin hello-world`
    # This throws a warning for the password provided via command line.
    And I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "DROP DATABASE IF EXISTS fp_cli_test_scaffold"`

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} trunk`
    Then the return code should be 0
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      data
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      includes
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      fp-tests-config.php
      """
    And the {RUN_DIR}/finpress directory should contain:
      """
      index.php
      """

    # FP 5.0+: js

    And the {RUN_DIR}/finpress directory should contain:
      """
      license.txt
      readme.html
      """

    # FP 5.0+: styles

    And the {RUN_DIR}/finpress directory should contain:
      """
      fp-activate.php
      fp-admin
      fp-blog-header.php
      fp-comments-post.php
      fp-config-sample.php
      fp-content
      fp-cron.php
      fp-includes
      fp-links-opml.php
      fp-load.php
      fp-login.php
      fp-mail.php
      fp-settings.php
      fp-signup.php
      fp-trackback.php
      xmlrpc.php
      """
    And the contents of the {RUN_DIR}/finpress/fp-includes/version.php file should match /\-(alpha|beta[0-9]+|RC[0-9]+)\-/
    And the {PLUGIN_DIR}/hello-world/phpunit.xml.dist file should exist
    And STDERR should contain:
      """
      install_test_suite
      """

    # This throws a warning for the password provided via command line.
    When I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "SHOW DATABASES"`
    Then STDOUT should contain:
      """
      fp_cli_test_scaffold
      """

    When I run `composer init --no-interaction --quiet --name=fp-cli/test-scenario --require="yoast/phpunit-polyfills=^1.0.1" --working-dir={RUN_DIR}/finpress-tests-lib`
    Then the return code should be 0

    When I run `composer install --no-interaction --quiet --working-dir={RUN_DIR}/finpress-tests-lib`
    Then the return code should be 0

    When I run `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_TESTS_PHPUNIT_POLYFILLS_PATH={RUN_DIR}/finpress-tests-lib/vendor/yoast/phpunit-polyfills ./phpunit -c {PLUGIN_DIR}/hello-world/phpunit.xml.dist`
    Then the return code should be 0

  @require-mysql
  Scenario: Install FinPress 3.7 and phpunit will not run
    Given a FP install
    And I run `fp plugin path`
    And save STDOUT as {PLUGIN_DIR}
    And I run `fp scaffold plugin hello-world`
    # This throws a warning for the password provided via command line.
    And I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "DROP DATABASE IF EXISTS fp_cli_test_scaffold"`

    When I try `FP_TESTS_DIR={RUN_DIR}/finpress-tests-lib FP_CORE_DIR={RUN_DIR}/finpress /usr/bin/env bash {PLUGIN_DIR}/hello-world/bin/install-fp-tests.sh fp_cli_test_scaffold {DB_USER} {DB_PASSWORD} {DB_HOST} 3.7`
    Then the return code should be 0
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      data
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      includes
      """
    And the {RUN_DIR}/finpress-tests-lib directory should contain:
      """
      fp-tests-config.php
      """
    And the {RUN_DIR}/finpress directory should contain:
      """
      index.php
      license.txt
      readme.html
      fp-activate.php
      fp-admin
      fp-blog-header.php
      fp-comments-post.php
      fp-config-sample.php
      fp-content
      fp-cron.php
      fp-includes
      fp-links-opml.php
      fp-load.php
      fp-login.php
      fp-mail.php
      fp-settings.php
      fp-signup.php
      fp-trackback.php
      xmlrpc.php
      """
    And the {RUN_DIR}/finpress/fp-includes/version.php file should contain:
      """
      3.7
      """
    And STDERR should contain:
      """
      install_test_suite
      """

    # This throws a warning for the password provided via command line.
    When I try `mysql -u{DB_USER} -p{DB_PASSWORD} -h{MYSQL_HOST} -P{MYSQL_PORT} --protocol=tcp -e "SHOW DATABASES"`
    And STDOUT should contain:
      """
      fp_cli_test_scaffold
      """
