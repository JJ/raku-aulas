unit class Classroom;

has Str $!name is required;
has Int $!capacity is required;

submethod BUILD( :$!name, :$!capacity ) {};
