package Data::Validation::Exception;

use namespace::sweep;

use Moo;
use Unexpected::Functions qw( has_exception );

extends q(Unexpected);
with    q(Unexpected::TraitFor::ExceptionClasses);

my $class = __PACKAGE__;

has_exception $class;

has_exception 'Constraint' => parents => [ $class ],
   error   => 'String [_1] contains possible taint';

has_exception 'BetweenValues' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not in range';

has_exception 'EqualTo' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not equal to the required value';

has_exception 'FieldComparison' => parents => [ 'Constraint' ],
   error   => 'Field [_1] does not [_2] field [_3]';

has_exception 'Hexadecimal' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a hexadecimal number';

has_exception 'Mandatory' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] is mandatory';

has_exception 'MatchingRegex' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] does not match the required regex';

has_exception 'Printable' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value is not a printable character';

has_exception 'SimpleText' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not simple text';

has_exception 'ValidHostname' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a hostname';

has_exception 'ValidIdentifier' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid identifier';

has_exception 'ValidInteger' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not valid integer';

has_exception 'ValidLength' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not a valid length';

has_exception 'ValidNumber' => parents => [ 'Constraint' ],
   error   => 'Parameter [_1] value [_2] is not valid number';

has_exception 'ValidationErrors' => parents => [ $class ],
   error   => 'There is at least one data validation error';

has '+class' => default => $class;

1;

__END__

=pod

=encoding utf8

=head1 Name

Data::Validation::Exception - One-line description of the modules purpose

=head1 Synopsis

   use Data::Validation::Exception;
   # Brief but working code examples

=head1 Description

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=back

=head1 Subroutines/Methods

=head1 Diagnostics

=head1 Dependencies

=over 3

=item L<Class::Usul>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Validation.
Patches are welcome

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 License and Copyright

Copyright (c) 2014 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
# vim: expandtab shiftwidth=3:
