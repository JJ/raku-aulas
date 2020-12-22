use Test;

use Cap;
use Course;
use Classroom;

my Str $ID = "Aula1";
my Int $capacidad = 33;

for ( Course, Classroom ) -> \C {
    my $c = C.new($ID, $capacidad);
    isa-ok($c, C, "Inits OK");
    is( $c.capacity, $capacidad, "Assignment of capacity OK");
    is( $c.name, $ID, "Assignment of name OK");
}
done-testing;
