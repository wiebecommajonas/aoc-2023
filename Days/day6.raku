my $input-file = "Inputs/day6.txt";

my $input = $input-file.IO.slurp;

grammar Input {
    rule TOP { 'Time:' (<.ws> <num>)* 'Distance:' (<.ws> <num>)* }
    token num { \d+ }
}

my $parsed = Input.parse($input);
my $times = ($parsed[0] Z $parsed[1])>>.Int;

sub all-results(Int:D $time --> Seq) {
    (0..$time).map({$_ * ($time - $_)})
}

my $part-one = [*] $times.map(-> ($a, $b) {all-results($a).grep(*>$b).elems});
say "Part 1: $part-one";

my ($time, $dist) = $input.lines.map({.comb(/\d/).join.Int});
my $start = ceiling(($time / 2) - sqrt(($time/2)**2 - $dist));
my $end = floor(($time / 2) + sqrt(($time/2)**2 - $dist));
my $part-two = $end - $start + 1;
say "Part 2: $part-two";

