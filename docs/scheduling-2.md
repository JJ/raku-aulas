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

### Containers and containees

> El cielo esta entablicuadrillado, ¿quién lo desentablicuadrillará?
> El que lo entablicuadrille, buen entablicuadrillador será.
> -- Spanish tongue twiter, loosely translated as "The sky is
> tablesquarebricked, who will de-trablesquarebrick it? The
> tablesquarebrickalyer that tablesquaresbricks it, good
> tablesquarebrickalyer will be.

![This is almost tablesquaredwhatever](https://live.staticflickr.com/5607/31741755686_7e7fd2b883_k_d.jpg)

It's worth the while to check
out
[this old Advent article, by Zoffix Znet](https://perl6advent.wordpress.com/2017/12/02/perl-6-sigils-variables-and-containers/),
on what's binding and what's assignment in the Raku world. Binding is
essentially calling an object by another name. If you bind an object
to a variable, that variable will behave exactly the same as the
object. And the other way round.

```raku
my $courses := Course-List.new( "docs/courses.csv");
```

We are simply calling the right hand side of this binding by another
name, which is shorter and more convenient. We can call any method,
and also we can put this "in a zipping context" by calling for on it:

```raku
.name.say for $courses;
```

Will return

```text
Woodworking 101
Toymaking 101
ToyOps 310
Wrapping 210
Ha-ha-haing 401
Reindeer speed driving 130
```

As you can see, the "zipping context" is exactly the same as the
(not-yet-documented)
[iterable context](https://github.com/Raku/doc/issues/1225), which
is also invoked (or *coerces* objects into, whatever you prefer) when
used with `for`. `for $courses` will actually call
`$courses.iterator`, returning the iterator of the list it contains.

This is not actually a digression, this is totally on topic. I will
have to digress, however, to explain what *would* have happened in the
case we would have used normal assignment, as in

```raku
my $boxed-courses = Course-List.new( "docs/courses.csv");
```

Assignment is a nice and peculiar thing in Raku. As [the above
mentioned article says](https://perl6advent.wordpress.com/2017/12/02/perl-6-sigils-variables-and-containers/),
it *boxes* an object into a container. You can't easily box any kind
of thing into a Scalar container,
so, [Procusto style](https://es.wikipedia.org/wiki/Procusto) it needs
to fit it into the container in a certain way. But any way you think
about it, the fact is that, unlike before, `$boxes-courses` is *not* a
`Course-List` object; it's a `Scalar` object that has *scalarized*, or
*itemized*, a `Course-List` object. What would you need to de-scalarize
it? Simply calling
the [de-cont operator](https://docs.raku.org/routine/%3C%3E) on it, `$boxed-courses<>`,
which unwraps the container and gives you what's inside.


## Scheduler classes

![Filling the class in all the wrong places](https://live.staticflickr.com/92/244008954_ceff0265c7_k_d.jpg)

> OK, back to our regular schedule...r.

Again, don't let's just try to do things as we see fit. We need to
create an issue to fix

- As a programmer, I need a class that creates schedules given a
  couple of files with courses and classes.


Santa is happy to prove such a thing:

```raku
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
```

Not only it schedules courses, you can simply use it by `say`ing
it. It's also tested, so you know that it's going to work no matter
what. With that, we can close the user story.

But, can we?

## Wrapping up with a script


Santa was really satisfied with this new application. He only needed
to write this small main script:

```raku
use Schedule;

sub MAIN( $courses-file where .IO.e = "docs/courses.csv",
          $classes-file where .IO.e = "docs/classes.csv") {
    say Schedule.new( $courses-file, $classes-file)
}
```

Which was straight and to the point: here are the files, here's the
schedule. But, besides, it was tested, prepared for the unextpected,
and could actually be expanded to take into account unexpected events
(what happens if you can't fit elves into a particular class? What if
you need to take into account other constraints, like not filling
biggest first, but filling smuggest first? You can just change the
algorithm, without even changing this main script. Which you don't
really need:

```shell
raku -Ilib -MSchedule -e "say Schedule.new( | @*ARGS )" docs/courses.csv docs/classes.csv
```

using the command line switches for the library search path (`-I`) and
loading a module ( `-M`) you can just write a statement that will take
the arguments and *flatten* them to make them into the method's
signature.

Doing this, Santa sat down in his favorite armchair to enjoy a cup of
cask-aged eggnogg and watch every Santa-themed movie that was being
streamed until next NPCC started.

