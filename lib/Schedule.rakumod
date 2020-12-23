use Course-List;
use Classroom-List;

unit class Schedule;

has @!schedule;

submethod new( $courses-file where .IO.e,
               $classes-file where .IO.e) {

    my $courses := Course-List.new($courses-file);
    my $classes := Classroom-List.new($classes-file);
    my @schedule = ($classes Z $courses).map({ $_.map({ .name }) });
    self.bless(:@schedule);
}

submethod BUILD( :@!schedule ) {}

method schedule() { @!schedule }

method gist {
    @!schedule.map( { .join( "\t⇒\t" ) } ).join("\t");
}

