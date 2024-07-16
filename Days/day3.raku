my $input-file = "Inputs/day3.txt";

my $input = $input-file.IO.slurp.Str;
my $line-width = $input.lines[0].chars + 1; # Plus newline
my $lines = $input.lines.elems;

my @matched-numbers = $input.comb(/\d+/, :match);

my $first = @matched-numbers[0];

sub neighbors(Int:D $start, Int:D $end, Int:D :$max-y!, Int:D :$max-x! --> List) {
    my @result = ();
    if $start div $max-x != $end div $max-x {
        say "ERROR: start and end not on the same line";
        say "start: $start";
        say "end: $end";
    }
    if $start mod $max-x > 0 {
        @result.push($start - 1);
    }
    if $end mod $max-x != $max-x - 1 {
        @result.push($end + 1);
    }
    my $line = $start div $max-x;
    if $line > 0 {
        my $prev-line-start = max(0, $max-x * ($line - 1));
        my $prev-line-end = $prev-line-start + $max-x - 1;
        @result.push(|(max($start-$max-x-1, $prev-line-start)..min($end-$max-x+1, $prev-line-end)));
    }
    if $line < $max-y - 1 {
        my $next-line-start = max(0, $max-x * ($line + 1));
        my $next-line-end = $next-line-start + $max-x - 1;
        @result.push(|(max($start+$max-x-1, $next-line-start)..min($end+$max-x+1, $next-line-end)));
    }
    @result
}

my regex Symbol {<:P + :S - [\.]>}
my $part-one = @matched-numbers.grep({neighbors($_.from, $_.to-1, :max-x($line-width), :max-y($input.lines.elems)).map({$input.substr($_, 1).match(&Symbol).so}).any.so}).map({.Int}).sum;
say "Part 1: $part-one";

my regex Gear { \* }
my @pairs = @matched-numbers.map({
    my $match = $_;
    neighbors($match.from, $match.to-1, :max-x($line-width), :max-y($input.lines.elems)).map({
        my $gear-index = $_;
        with $input.substr($gear-index, 1).match(&Gear) {
            $gear-index => $match.Int
        } else { Nil }
    })
    .grep({.defined})
    .unique
}).flat;

my @gears = @pairs.map({$_.key => $_.value.list}).Bag.grep({$_.value == 2}).map({.key}).unique;
my $part-two = @gears.map({my $pair = $_; [*] @pairs.grep({$_.key == $pair}).map({.value})}).sum;
say "Part 2. $part-two";


