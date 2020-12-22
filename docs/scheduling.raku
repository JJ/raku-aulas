#!/usr/bin/env raku

sub read-and-sort( $file where .IO.e ) {
    $file.IO.lines
      ==> map( *.split( /","\s+/) )
      ==> sort( { -$_[1].Int } )
      ==> map( { Pair.new( |@_ ) } )
}

say (read-and-sort( "classes.csv") Z read-and-sort( "courses.csv"))
    .map( {  $_.map( { .key } ).join( "\t→\t") }  )
    .join( "\n" )
