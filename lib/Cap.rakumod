unit role Cap;

has Str $!name is required;
has Int $!capacity is required;

submethod BUILD( :$!name, :$!capacity ) {};

method name() { $!name }
method capacity() { $!capacity }