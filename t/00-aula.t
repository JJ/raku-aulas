use Test;

use Auler::Aula;

my Str $ID = "Aula1";
my Int $capacidad = 33;
my $localización = "Planta baja, aula 0";
my Tipo-Aula $tipo = Lab;

my $este-aula = Auler::Aula.new( :$ID, :$capacidad, :$localización, :$tipo );
isa-ok( $este-aula, "Auler::Aula", "Tipo correcto");
done-testing;
