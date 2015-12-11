package Data::Validation::Exception;

use namespace::autoclean;

use Unexpected::Functions qw( has_exception );
use Moo;

extends q(Unexpected);
with    q(Unexpected::TraitFor::ExceptionClasses);

my $class = __PACKAGE__;

has_exception $class;

has_exception 'InvalidParameter' => parents => [ $class ];

has_exception 'Allowed' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not in the list of allowed values';

has_exception 'BetweenValues' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not in range';

has_exception 'EqualTo' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not equal to the required value';

has_exception 'FieldComparison' => parents => [ 'InvalidParameter' ],
   error   => 'Field [_1] does not [_2] field [_3]';

has_exception 'Hexadecimal' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not a hexadecimal number';

has_exception 'Mandatory' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] is mandatory';

has_exception 'MatchingRegex' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] does not match the required regex';

has_exception 'MatchingType' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] does not of the required type [_3]';

has_exception 'Printable' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value is not a printable character';

has_exception 'SimpleText' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not simple text';

has_exception 'ValidHostname' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not a hostname';

has_exception 'ValidIdentifier' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not a valid identifier';

has_exception 'ValidInteger' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not valid integer';

has_exception 'ValidLength' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not a valid length';

has_exception 'ValidNumber' => parents => [ 'InvalidParameter' ],
   error   => 'Parameter [_1] value [_2] is not valid number';

has_exception 'KnownType' => parents => [ $class ],
   error   => 'Type constraint [_1] is unknown';

has_exception 'ValidationErrors' => parents => [ $class ],
   error   => 'There is at least one data validation error';

has '+class' => default => $class;

1;

__END__

=pod

=encoding utf-8

=head1 Name

Data::Validation::Exception - Defines the exceptions throw by the distribution

=head1 Synopsis

   use Data::Validation::Exception;

=head1 Description

Defines the exceptions throw by the distribution

=head1 Configuration and Environment

Defines the following exceptions;

=over 3

=item C<InvalidParameter>

=item C<BetweenValues>

=item C<EqualTo>

=item C<FieldComparison>

=item C<Hexadecimal>

=item C<KnownType>

=item C<Mandatory>

=item C<MatchingRegex>

=item C<MatchingType>

=item C<Printable>

=item C<SimpleText>

=item C<ValidHostname>

=item C<ValidIdentifier>

=item C<ValidInteger>

=item C<ValidLength>

=item C<ValidNumber>

=item C<ValidationErrors>

=back

=head1 Subroutines/Methods

None

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Unexpected>

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

Copyright (c) 2015 Peter Flanigan. All rights reserved

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
