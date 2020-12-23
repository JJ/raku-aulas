# Christmas-oriented programming, part deux

In
the
[previous installment of this series of articles](https://raku-advent.blog/2020/12/22/day-23-christmas-oriented-design-and-implementation/),
we started with a straightforward script, and we wanted to arrive to a
sound object-oriented design using [Raku](https://raku.org).

Our (re)starting point was this user story:

> [US1] As a NPCC dean, given I have a list of classrooms (and their
  capacity) and a list of courses (and their enrolment), I want to
  assign classrooms to courses in the best way possible.

And we arrived to this script:

```raku
my $courses = Course-List.new( "docs/courses.csv");
my $classes = Classroom-List.new( "docs/classes.csv");
say ($classes.list Z $courses.list )
        .map( {  $_.map( { .name } ).join( "\t→\t") }  )
        .join( "\n" );
```

That does not really cut it, though. Every user story must be solved
with a set of tests. But, well, the user story was kinda vague to
start with: "in the best way possible" could be anything. So it could
be argued that the way we have done is, indeed, the best way, but we
can't really say without the test. So let's reformulate a bit the US:

> [US1]  As a NPCC dean, given I have a list of classrooms (and their
  capacity) and a list of courses (and their enrolment), I want to
  assign classrooms to courses so that no course is left without a
  classroom, and all courses fit in a classroom.

This is something we can hold on to. But of course, scripts can't be
tested (well,
they [can](https://github.com/JJ/perl6-test-script-output), but that's
another story). So let's give this script a bit of class.

## Ducking it out with lists

Actually, there's something that does not really cut it in the script
above. In the original script, you took a couple of lists and zipped
it together. Here you need to call the `.list` method to achieve the
same. But the object is still the same, right? Shouldn't it be
possible, and easy, to just zip together the two objects? Also, that
begs the client of the class to know the actual implementation. An
object should hide its internals as much as possible. Let's make
that an issue to solve

> As a programmer, I want the object holding the courses and
> classrooms to behave as would a list in a "zipping" context.

Santa rubbed his beard thinking about how to pull this
off. `Course-List` objects are, well, that precise kind of
objects. They *include* a list, but, how can they behave as a list?
Also, what's precisely a list "in a zipping context".

Long story short, he figured out that a "zipping context" actually
iterates over every member of the two lists, in turn, putting them
together. So we need to make the
objects
[`Iterable`](https://docs.raku.org/type/Iterable). Fortunately, that's
something you can definitely do in Raku. By mixing roles, you can make
objects behave in some other way, as long as you've got the machinery
to do so.


```raku
unit role Cap-List[::T] does Iterable;

has T @!list;

submethod new( $file where .IO.e ) {
    $file.IO.lines
            ==> map( *.split( /","\s+/) )
            ==> map( { T.new( @_[0], +@_[1] ) } )
            ==> sort( { -$_.capacity } )
            ==> my @list;
    self.bless( :@list );
}
submethod BUILD( :@!list ) {}

method list() { @!list }

method iterator() {@!list.iterator}
```

With respect to the original version, we've just mixed in the
`Iterable` role and implemented an `iterator` method, that returns the
iterator on the `@!list` attribute. That's not the only thing we need
for it to be in "a zipping context", however. Which begs a small
diggression on Raku containers and binding.



## Scheduler classes


