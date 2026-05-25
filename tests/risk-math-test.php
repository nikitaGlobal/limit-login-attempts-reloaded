<?php
/**
 * Lean tests for RiskLevelMath (no WordPress bootstrap).
 *
 * Run: php tests/risk-math-test.php
 */

$root = dirname( __DIR__ );
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', $root . '/' );
}
require_once $root . '/core/utils/RiskLevelMath.php';

use LLAR\Core\Utils\RiskLevelMath;

$failed = 0;

function assert_true( $cond, $msg ) {
	global $failed;
	if ( ! $cond ) {
		echo "FAIL: {$msg}\n";
		$failed++;
	}
}

$levels = array(
	array( 'exact' => 0, 'title' => 'zero_title', 'color' => 'green' ),
	array( 'max_exclusive' => 100, 'count_title' => true, 'color' => 'yellow' ),
	array( 'default' => true, 'color' => 'red' ),
);

$level = RiskLevelMath::resolve_risk_level( 0, $levels );
assert_true( isset( $level['exact'] ) && 0 === (int) $level['exact'], 'exact zero level' );

$level = RiskLevelMath::resolve_risk_level( 50, $levels );
assert_true( isset( $level['max_exclusive'] ) && 100 === (int) $level['max_exclusive'], 'max_exclusive band' );

$level = RiskLevelMath::resolve_risk_level( 500, $levels );
assert_true( ! empty( $level['default'] ), 'default level for high count' );

$cutoff = strtotime( '-8 day' );
$stats  = array(
	$cutoff - 1000 => 1,
	time()         => 5,
);
$pruned = RiskLevelMath::prune_retries_stats_old_buckets( $stats );
assert_true( ! isset( $pruned[ $cutoff - 1000 ] ), 'prune old bucket' );
assert_true( isset( $pruned[ time() ] ) || count( $pruned ) >= 1, 'keep recent bucket' );

$colors = array( 'green' => '#97F6C8', 'red' => '#FF6633' );
$hex    = RiskLevelMath::resolve_chart_color( array( 'color' => 'red' ), $colors );
assert_true( '#FF6633' === $hex, 'resolve_chart_color' );

if ( $failed > 0 ) {
	echo "{$failed} assertion(s) failed.\n";
	exit( 1 );
}

echo "All RiskLevelMath tests passed.\n";
exit( 0 );
