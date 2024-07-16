my $input-file = "Inputs/day7.txt";

my @input = $input-file.IO.lines.map({.split(" ")}).map(-> ($a, $b) {($a.comb.list, $b.Int)});

sub is-five-of-a-kind(List:D (List:D $cards, Int:D \_) --> Bool:D) {
    $cards.reduce(&infix:<eq>)
}

sub is-four-of-a-kind(List:D (List:D $cards, Int:D \_) --> Bool:D) {
    so $cards.map(-> $card {$cards.grep({$card eq $_}).elems}).any == 4
}

sub is-full-house(List:D (List:D $cards, Int:D \_) --> Bool:D) {
    so $cards.map(-> $card {
        my $rest = $cards.grep({!($card eq $_)});
        $rest.elems == 2 && $rest.reduce(&infix:<eq>)
    }).any == True
}

sub is-three-of-a-kind(List:D (List:D $cards, Int:D \_) --> Bool:D) {
    so $cards.map(-> $card {$cards.grep({$card eq $_}).elems}).any == 3
}

sub is-two-pair(List:D (List:D $cards, Int:D \_) --> Bool:D) {
    so $cards.map(-> $card {($card, $cards.grep({$card eq $_}).elems)}).grep({$_[1] == 2}).map({.[0]}).unique.elems == 2
}

sub is-one-pair(List:D (List:D $cards, Int:D \_) --> Bool:D) {
    so $cards.map(-> $card {($card, $cards.grep({$card eq $_}).elems)}).grep({$_[1] == 2}).map({.[0]}).unique.elems == 1
}

sub is-high-card(List:D (List:D $cards, Int:D \_) --> Bool:D) {
    $cards.elems == $cards.unique.elems
}

sub value(List:D $bet --> Int:D) {
    given $bet {
        when &is-five-of-a-kind  { 6 }
        when &is-four-of-a-kind  { 5 }
        when &is-full-house      { 4 }
        when &is-three-of-a-kind { 3 }
        when &is-two-pair        { 2 }
        when &is-one-pair        { 1 }
        when &is-high-card       { 0 }
    }
}

sub card-value(Str:D $card --> Int:D) {
    try {
        CATCH {
            given $card {
                when "A" { return 14 }
                when "K" { return 13 }
                when "Q" { return 12 }
                when "J" { return 11 }
                when "T" { return 10 }
            }
        }
        return $card.Int
    }
}

sub card-value-two(Str:D $card --> Int:D) {
    try {
        CATCH {
            given $card {
                when "A" { return 14 }
                when "K" { return 13 }
                when "Q" { return 12 }
                when "J" { return  1 }
                when "T" { return 10 }
            }
        }
        return $card.Int
    }
}

sub value-two(List:D $bet --> Int:D) {
    my $jokers = $bet[0].grep({$_ eq "J"}).elems;
    given $bet {
        when &is-five-of-a-kind  { 6 }
        when &is-four-of-a-kind  { 5 + (1 if $jokers != 0) }
        when &is-full-house      { 4 + (2 if $jokers != 0) }
        when &is-three-of-a-kind { 3 + (2 if $jokers != 0) }
        when &is-two-pair        { 2 + (2 if $jokers >= 1) + (1 if $jokers == 2) }
        when &is-one-pair        { 1 + (2 if $jokers != 0) }
        when &is-high-card       { 0 + (1 if $jokers != 0) }
    }
}

my $sorted = @input.sort({.&value, .[0].map(&card-value)[0], .[0].map(&card-value)[1], .[0].map(&card-value)[2], .[0].map(&card-value)[3], .[0].map(&card-value)[4]});
my $part-one = ($sorted.map({.[1]}) Z* 1..*).sum;
say "Part 1: $part-one";

my $sorted-two = @input.sort({.&value-two, .[0].map(&card-value-two)[0], .[0].map(&card-value-two)[1], .[0].map(&card-value-two)[2], .[0].map(&card-value-two)[3], .[0].map(&card-value-two)[4]});
my $part-two = ($sorted-two.map({.[1]}) Z* 1..*).sum;
say "Part 2: $part-two";

