my $input-file = "Inputs/day8.txt";

my @input = $input-file.IO.slurp.lines;

grammar NodeG {
    rule TOP { <name=.name> '=' '(' <l=.name> ',' <r=.name> ')' }
    regex name { <[A..Z]>**3 }
}

class Node {
    has Node $.parent is rw;
    has Node $.left is rw;
    has Node $.right is rw;
    has $.value;

    multi method new($value --> Node:D) {
        return self.bless(:$value);
    }

    method is-leaf(--> Bool:D) {
        return !$!right.DEFINITE && !$!left.DEFINITE
    }

    multi method count(--> Int:D) { return self.count(()) }
    multi method count(@visited --> Int:D) {
        my @new-visited = ($!value, |@visited);
        if !self.is-leaf {
            my $count = 1;
            if !($!left.value (elem) @new-visited)  {
                say "left";
                $count += $!left.count(@new-visited);
            }
            if !($!right.value (elem) @new-visited) {
                say "right";
                $count += $!right.count(@new-visited);
            }
            return $count
        } else {
            return 0
        }
    }

    multi method find-node($value --> Node) { return self.find-node($value, ()) }
    multi method find-node($value, @visited --> Node) {
        my @new-visited = ($!value, |@visited);
        if $!value eqv $value and !self.is-leaf {
            return self
        }
        if $!left.DEFINITE && !($!left.value (elem) @new-visited) {
            return $!left.find-node($value, @new-visited)
        }
        if $!right.DEFINITE && !($!right.value (elem) @new-visited) {
            return $!right.find-node($value, @new-visited)
        }
        return Node
    }
}

my @rl = @input[0].comb;
my @nodes = @input[2..*].map({NodeG.parse($_)}).map({Node.new(left => Node.new($_.<l>.Str), right => Node.new($_.<r>.Str), value => $_.<name>.Str)});

say @nodes.elems;

my $start = @nodes.pop;
my $graph = fill-graph($start, @nodes);
say $graph;
say $graph.left;
say $graph.right;

exit;

sub next(Str:D $from where /<[A..Z]>**3/, Str:D $inst where /<[RL]>/, @nodes --> Str:D) {
    for @nodes -> $node {
        if $node.<name> eq $from {
            given $inst {
                when "R" { return $node.<r>.Str }
                when "L" { return $node.<l>.Str }
            }
        }
    }
}

sub steps-to-zzz(@nodes, @rl --> Int:D) {
    my $steps = 0;
    my $insts = @rl.elems;
    my $node = 'AAA';
    loop {
        my $inst = @rl[$steps mod $insts];
        $node = next($node, $inst, @nodes);
        $steps++;
        if $node eq "ZZZ" { return $steps }
    }
}

# my $part-one = steps-to-zzz(@nodes, @rl);
# say "Part 1: $part-one";

multi sub step(@start-nodes, @nodes, @rl --> Int:D) { step(@start-nodes, @nodes, @rl, 0) }
multi sub step(@start-nodes, @nodes, @rl, Int:D $acc --> Int:D) {
    if so @start-nodes.map({.<name>.Str}).all ~~ /Z$/ { return $acc }

    step(@start-nodes.map({
        my $next-node = next($_.<name>.Str, @rl[$acc mod @rl.elems], @nodes);
        @nodes.first({$_.<name> eq $next-node})
    }), @nodes, @rl, $acc + 1)
}

# way too slow
# my $part-two = step(@nodes.grep({$_.<name>.Str ~~ /A$/}), @nodes, @rl);
# say "Part 2: $part-two";

