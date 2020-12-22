use Test;

use Cap;
use Course;
use Classroom;
use Course-List;
use Classroom-List;

my Str $ID = "Aula1";
my Int $capacidad = 33;

for ( Course, Classroom ) -> \C {
    my $c = C.new($ID, $capacidad);
    isa-ok($c, C, "Inits OK");
    is( $c.capacity, $capacidad, "Assignment of capacity OK");
    is( $c.name, $ID, "Assignment of name OK");
}

my $courses = Course-List.new( "docs/courses.csv");
is( $courses.list.first.capacity, 130, "Sorted stuff" );

my $classes = Classroom-List.new( "docs/classes.csv");
is( $classes.list.first.capacity, 150, "Sorted stuff" );

done-testing;
