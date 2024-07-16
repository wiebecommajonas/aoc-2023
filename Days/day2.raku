my $input-file = "Inputs/day2.txt";

grammar Game {
    rule TOP { 'Game' <.ws> <num> ':' <.ws> <rounds> }
    rule rounds { (<packs> ';' <.ws>)* <packs> }
    rule packs { (<pack> ',' <.ws>)* <pack> }
    rule pack { <num> <.ws> <color> }
    regex num { \d+ }
    rule color { <red> | <green> | <blue> }
    token red { 'red' }
    token blue { 'blue' }
    token green { 'green' }
}

my @games = $input-file.IO.lines.map({Game.parse($_)});

# Part 1: MAX 12 red cubes, 13 green cubes, and 14 blue cubes

# flatten game
sub flatten(Game $game) {
    my @rounds = $game{'rounds'}[0];
    my %last = packs => $game{'rounds'}{'packs'};
    @rounds.push(%last);

    @rounds.map({
        my @packs = $_{'packs'}[0];
        my %last = pack => $_{'packs'}{'pack'};
        @packs.push(%last);
    })
    .flat
}

sub matches(Game $game, Int:D $red-max, Int:D $blue-max, Int:D $green-max --> Bool:D) {
    for flatten($game) -> $pack {
        given $pack{'pack'}{'color'} {
            when 'blue' {
                if $pack{'pack'}{'num'} > $blue-max {
                    return False
                }
            }
            when 'green' {
                if $pack{'pack'}{'num'} > $green-max {
                    return False
                }
            }
            when 'red' {
                if $pack{'pack'}{'num'} > $red-max {
                    return False
                }
            }
        }
    }
    True
}

my $part-one = @games.map({
        if matches($_, 12, 14, 13) { $_{'num'} }
        else { 0 }
    }).sum;

say "Part 1: $part-one";

sub min-set-of-cubes(Game $game --> Hash) {
    my %map = red => 0, blue => 0, green => 0;
    for flatten($game) -> $pack {
        my $color = $pack{'pack'}{'color'};
        if $pack{'pack'}{'num'} > %map{$color} {
            %map{$color} = $pack{'pack'}{'num'}.Int;
        }
    }  
    %map
}

sub power-of-set(Hash $set --> Int) {
    $set.values.reduce(&infix:<*>)
}

my $part-two = @games.map({power-of-set(min-set-of-cubes($_))}).sum;

say "Part 2: $part-two";
