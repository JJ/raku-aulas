unit role Cap-List[::T] does Iterable;

has T @!list;

submethod new( $file where .IO.e ) {
    $file.IO.lines
            ==> map( *.split( /","\s+/) )
            ==> map( { T.new( @_[0], +@_[1] ) } )
            ==> sort( { -$_.capacity } )
            ==> my @list;
    self.bless( :@list );
}

submethod BUILD( :@!list ) {}

method list() { @!list }

method iterator() {@!list.iterator}

