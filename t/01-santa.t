use Test;

use Cap;
use Course;
use Classroom;

my Str $ID = "Aula1";
my Int $capacidad = 33;

for ( Course, Classroom ) -> \C {
    isa-ok(C.new($ID, $capacidad), C, "Inits OK");
}
done-testing;
