#!/usr/bin/env perl6

use Schedule;

sub MAIN( $courses-file where .IO.e = "docs/courses.csv",
          $classes-file where .IO.e = "docs/classes.csv") {
    say Schedule.new( $courses-file, $classes-file)
}
