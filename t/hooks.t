# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;
use Test::More;

my $mod = 'Sub::Chain::Group';
eval "require $mod";

sub run_tests {
  my ($chain, $in, $exp) = @_;
  my @in_k = sort keys %$in;
  my @out_k = (@in_k, 'debug');

  is_deeply($chain->call($in), $exp, 'hash transformed');
  is_deeply($chain->call(\@in_k, [@$in{@in_k}]), [@$exp{@out_k}], 'array transformed');
}

sub up { uc $_[0] };
sub x10 { $_[0] * 10 }

sub desc {
  my $d = shift;
  if( ref $d eq 'HASH' ){
    $d->{desc} = $d->{sprinkles}
      ? "$d->{desc} with $d->{sprinkles} sprinkles"
      : "$d->{shape} with $d->{desc}";
  }
  elsif( ref $d eq 'ARRAY' ){
    $d->[0] = $d->[2]
      ? "$d->[0] with $d->[2] sprinkles"
      : "$d->[1] with $d->[0]";
  }
  $d;
}

sub debug {
  my $d = shift;
  if( ref $d eq 'HASH' ){
    $d->{debug} = substr($d->{shape}, 0, 1) . "/" . $d->{sprinkles};
  }
  elsif( ref $d eq 'ARRAY' ){
    push @$d, substr($d->[1], 0, 1) . "/" . $d->[2];
  }
  $d;
}

my $chain = new_ok($mod);
$chain->append(\&up,    fields => 'shape');
$chain->append(\&x10,   fields => ['sprinkles']);
$chain->append(\&desc,  hook => 'before');
$chain->append(\&debug, hook => ['after']);

run_tests(
  $chain,
  {
    shape => 'round',
    sprinkles => 45,
    desc => 'blue frosting',
  },
  {
    shape => 'ROUND',
    sprinkles => 450,
    desc => 'blue frosting with 45 sprinkles',
    debug => 'R/450',
  },
);

run_tests(
  $chain,
  {
    shape => 'round',
    sprinkles => 0,
    desc => 'blue frosting',
  },
  {
    shape => 'ROUND',
    sprinkles => 0,
    desc => 'round with blue frosting',
    debug => 'R/0',
  },
);

done_testing;

