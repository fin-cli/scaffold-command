<?php

if ( ! class_exists( 'FP_CLI' ) ) {
	return;
}

$fpcli_scaffold_autoloader = __DIR__ . '/vendor/autoload.php';
if ( file_exists( $fpcli_scaffold_autoloader ) ) {
	require_once $fpcli_scaffold_autoloader;
}

FP_CLI::add_command( 'scaffold', 'Scaffold_Command' );
