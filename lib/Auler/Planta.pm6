unit role Auler::Planta[ UInt $min-plantas, UInt $max-plantas ];

has Int $mi-planta is required where * >= -$min-plantas and * <= $max-plantas;

