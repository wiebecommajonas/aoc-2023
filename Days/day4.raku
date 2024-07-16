my $input-file = "Inputs/day4.txt";

my @lines = $input-file.IO.slurp.lines;

my grammar Card {
    rule TOP { "Card" <ws>**1..3 <num> ":" ( <ws>**1..2 <num> )**10..10 <ws> "|" ( <ws>**1..2 <num> )**25..25 }
    regex num { \d**1..3 }
}

sub points(Card $card --> Int:D) {
    my $len = ($card[0]>>.Int (&) $card[1]>>.Int).elems;
    if $len == 0 {
        0
    } else {
        2**($len-1)
    }
}

my $part-one = @lines.map({Card.parse($_).&points}).sum;
say "Part 1: $part-one";

sub matches(Card $card --> Int:D) {
    ($card[0]>>.Int (&) $card[1]>>.Int).elems
}

multi sub cards(List $cards where *.elems == 0, Bag $acc, Int:D :$max! --> Int:D) {
    [+] $acc.values
}
multi sub cards(List $cards, Bag $acc, Int:D :$max! --> Int:D) {
    my $card-num = $cards.head.key;
    my $matches = $cards.head.value;
    my $num = %$acc{$card-num};
    cards($cards.tail(*-1).list, $acc (+) (($card-num+1)..min($card-num+$matches, $max)).map({$_ => $num }).Bag, :max($max))
}

my @list = @lines.map({Card.parse($_)}).map({$_{'num'}.Int => $_.&matches}).list;
my $max = @list>>.key.max;
my $part-two = cards(@list, (1..$max).Bag, :max($max));

say "Part 2: $part-two";

