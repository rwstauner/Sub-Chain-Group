use strict;
use warnings;
use Test::More 0.96;

eval 'require Test::Synopsis'
  or plan skip_all => 'Test::Synopsis required for this test';

use Sub::Chain::Group ();
my $pm = $INC{'Sub/Chain/Group.pm'};
my ($synopsis, $line, @option) = Test::Synopsis::extract_synopsis($pm);
$synopsis = join ";\n",
  'sub trim { local $_ = shift; s/^\s+//; s/\s+$//; $_ }',
  @option,
  $synopsis;

my @tests = split /\n/, <<'TESTS';
is( $trimmed, '123 Street Rd.', 'filtered field' );
is_deeply( $fruit, {apple => 'GREEN', orange => 'YTRID'}, 'filtered group with multiple chains' );
TESTS

plan tests => scalar @tests;

eval join("\n", $synopsis, @tests);
die $@ if $@;
