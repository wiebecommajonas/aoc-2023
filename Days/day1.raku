my $input-file = "Inputs/day1.txt";

my @input = $input-file.IO.slurp.lines;

my $part-one := @input.map(-> $el { ($el ~~ /\d/).Int * 10 + ($el.flip ~~ /\d/).Int }).sum;

say "Part 1: $part-one";

my regex digit { \d | 'zero' | 'one' | 'two' | 'three' | 'four' | 'five' | 'six' | 'seven' | 'eight' | 'nine' }

my %mapper = 0=>0, 1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9,
             'zero'=>0, 'one'=>1, 'two'=>2, 'three'=>3, 'four'=>4, 'five'=>5, 'six'=>6, 'seven'=>7, 'eight'=>8, 'nine'=>9;

my $part-two := @input.map(-> $el { my @matches=$el.match(&digit, :exhaustive); %mapper{@matches[0]} * 10 + %mapper{@matches[{$_-1}]} }).sum;

say "Part 2: $part-two";
