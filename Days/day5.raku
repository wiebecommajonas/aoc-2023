my $input-file = "Inputs/day5.txt";

my $input = $input-file.IO.slurp;

grammar Almanac {
    rule TOP { <seeds> <map>* }
    rule seeds { "seeds:" ( <.ws> <num> )* }
    rule map { <from=.word> "-to-" <to=.word> "map:" <range>* }
    rule range { <dst-range-start=.num> <.ws> <src-range-start=.num> <.ws> <range-len=.num> }
    token word { \w+ }
    token num { \d+ }
    token rest { .* }
}

my $almanac = Almanac.parse($input);

sub apply-map(Int:D $value, Match $map --> Int:D) {
    for $map{'range'} -> $range {
        my $start = $range{'src-range-start'}.Int;
        my $len = $range{'range-len'}.Int;
        if $value >= $start && $value < $start + $len {
            return $range{'dst-range-start'}.Int + ($value - $start);
        }
    }
    return $value;
}

multi sub apply-maps(Int:D $value, List $maps where *.elems == 0 --> Int:D) {
    $value
}
multi sub apply-maps(Int:D $value, List $maps --> Int:D) {
    apply-maps(apply-map($value, $maps.head), $maps.tail(*-1).list)
}

my $part-one = $almanac{'seeds'}[0]>>.Int.map({apply-maps($_, $almanac{'map'})}).min;
say "Part 1: $part-one";

multi sub apply-map-to-range(List $range, Match $map --> List) { apply-map-to-range($range, $map, ()) }
multi sub apply-map-to-range(List (Int:D $start, Int:D $len) where *[1] == 0, Match $map, List $acc --> List) { $acc.list }
multi sub apply-map-to-range(List (Int:D $start, Int:D $len), Match $map, List $acc --> List) {
    for $map{'range'} -> $range {
        my $src-start = $range{'src-range-start'}.Int;
        my $range-len = $range{'range-len'}.Int;
        if $start >= $src-start && $start < $src-start + $range-len {
            my $new-end = min($src-start + $range-len, $start + $len);
            my $new-len = $new-end - $start;
            my $new-range = ($range{'dst-range-start'}.Int + ($start - $src-start), $new-len);
            my $remaining = ($start + $new-len, $len - $new-len);
            return apply-map-to-range($remaining, $map, ($new-range, |$acc));
        }
    }
    return ($($start, $len), |$acc);
}

multi sub apply-maps(List (Int:D $start, Int:D $len), List $maps --> List) { apply-maps((($start, $len),), $maps) }
multi sub apply-maps(List $ranges, List $maps where *.elems == 0 --> List) { $ranges.list }
multi sub apply-maps(List $ranges, List $maps --> List) { apply-maps($ranges.map({apply-map-to-range($_, $maps.head)}).flat.list, $maps.tail(*-1).list) }

my @ranges = $almanac{'seeds'}[0]>>.Int.map({($^a, $^b)});
my $part-two = @ranges.map({apply-maps($_, $almanac{'map'})}).flat.map(*[0]).min;
say "Part 2: $part-two";

