unit role Cap-List[::T];

has T @!list;

submethod new( $file where .IO.e ) {
    $file.IO.lines
            ==> map( *.split( /","\s+/) )
            ==> sort( { -$_[1].Int } )
            ==> map( { Pair.new( |@_ ) } )
            ==> my @list;
    self.bless( :@list );
}
submethod BUILD( :@!list ) {}

