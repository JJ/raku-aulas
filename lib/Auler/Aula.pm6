enum Tipo-Aula <Lab Clase Sala>;

unit role Auler::Aula;

has Str $!ID is required;
has $!localización is required;
has Int $!capacidad is required;
has Tipo-Aula $!tipo is required;

submethod BUILD( :$!ID, :$!capacidad, :$!localización, :$!tipo) {};
