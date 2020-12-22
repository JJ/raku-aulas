unit role Cap;

has Str $!name is required;
has Int $!capacity is required;

submethod new( Str $name, Int $capacity ) {
    self.bless( :$name, :$capacity )
}

submethod BUILD( :$!name, :$!capacity ) {};

method name() { $!name }
method capacity() { $!capacity }