use Auler::Aula-Curso;

unit class Auler::Asignaciones;

has Auler::Aula-Curso @!asignaciones;
has Int $!año-inicio is required;
has Int $!año-final is required = $!año-inicio+1;
