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

## Scheduler classes


