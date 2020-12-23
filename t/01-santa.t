use Test;

use Cap;
use Course;
use Classroom;
use Course-List;
use Classroom-List;
use Schedule;

my Str $ID = "Aula1";
my Int $capacidad = 33;

for ( Course, Classroom ) -> \C {
    my $c = C.new($ID, $capacidad);
    isa-ok($c, C, "Inits OK");
    is( $c.capacity, $capacidad, "Assignment of capacity OK");
    is( $c.name, $ID, "Assignment of name OK");
}

my $courses := Course-List.new( "docs/courses.csv");
# .name.say for $courses;
is( $courses.list.first.capacity, 130, "Sorted stuff" );

my $classes := Classroom-List.new( "docs/classes.csv");
is( $classes.list.first.capacity, 150, "Sorted stuff" );

say ($classes Z $courses )
        .map( {  $_.map( { .name } ).join( "\t→\t") }  )
        .join( "\n" );

for $courses, $classes -> \iterable {
    my @list = iterable.list;
    for iterable -> $i {
        is( $i, @list.shift, "Running over list" )
    }
}


my $schedule = Schedule.new("docs/courses.csv", "docs/classes.csv");
is( $schedule.schedule[0].elems, 2, "Stores an array");
like( $schedule.gist, /Nik/, "Produces output");

done-testing;
