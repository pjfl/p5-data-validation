package Data::Validation::Constraints;

use namespace::autoclean;
use charnames qw( :full );

use Moo;
use Data::Validation::Constants;
use Regexp::Common    qw( number );
use Scalar::Util      qw( blessed looks_like_number );
use Unexpected::Types qw( Any Bool Int );

with q(Data::Validation::Utils);

has 'max_length' => is => 'ro', isa => Int;

has 'max_value'  => is => 'ro', isa => Int;

has 'min_length' => is => 'ro', isa => Int;

has 'min_value'  => is => 'ro', isa => Int;

has 'required'   => is => 'ro', isa => Bool;

has 'value'      => is => 'ro', isa => Any;

sub validate {
   my ($self, $val) = @_; my $method = $self->method; my $class;

   return 0 if (not $val and $self->required);

   return 1 if (not $val and not $self->required and $method ne 'isMandatory');

   return $self->$method( $val ) if ($self->can( $method ));

   return $self->_load_class( 'isValid', $method )->_validate( $val );
}

# Builtin factory validation methods
sub isBetweenValues {
   my ($self, $val) = @_;

   defined $self->min_value and $val < $self->min_value and return 0;
   defined $self->max_value and $val > $self->max_value and return 0;
   return 1;
}

sub isEqualTo {
   my ($self, $val) = @_;

   $self->isValidNumber( $val ) and $self->isValidNumber( $self->value )
      and return $val == $self->value ? 1 : 0;

   return $val eq $self->value ? 1 : 0;
}

sub isHexadecimal {
   my ($self, $val) = @_; $self->pattern( '\A '.$RE{num}{hex}.' \z' );

   return $self->isMatchingRegex( $val );
}

sub isMandatory {
   return defined $_[ 1 ] && length $_[ 1 ] ? 1 : 0;
}

sub isMatchingRegex {
   my ($self, $val) = @_; my $pat = $self->pattern;

   return $val =~ m{ $pat }msx ? 1 : 0;
}

sub isPrintable {
   $_[ 0 ]->pattern( '\A \p{IsPrint}+ \z' );
   return $_[ 0 ]->isMatchingRegex( $_[ 1 ] );
}

sub isSimpleText {
   $_[ 0 ]->pattern( '\A [a-zA-Z0-9_ \-\.]+ \z' );
   return $_[ 0 ]->isMatchingRegex( $_[ 1 ] );
}

sub isValidHostname {
   return (gethostbyname $_[ 1 ])[ 0 ] ? 1 : 0;
}

sub isValidIdentifier {
   $_[ 0 ]->pattern( '\A [a-zA-Z_] \w* \z' );
   return $_[ 0 ]->isMatchingRegex( $_[ 1 ] );
}

sub isValidInteger {
   my ($self, $val) = @_;

   $self->pattern( '\A '.$RE{num}{int}{-sep=>'[_]?'}.' \z' );
   $self->isMatchingRegex( $val ) or return 0;
   int $val == $val or return 0;
   return 1;
}

sub isValidLength {
   my ($self, $val) = @_;

   defined $self->min_length and length $val < $self->min_length and return 0;
   defined $self->max_length and length $val > $self->max_length and return 0;
   return 1;
}

sub isValidNumber {
   defined $_[ 1 ] or return 0;
   looks_like_number( $_[ 1 ] ) and return 1;
   return 0;
}

1;

__END__

=pod

=head1 Name

Data::Validation::Constraints - Test data values for conformance with constraints

=head1 Synopsis

   use Data::Validation::Constraints;

   %config = ( method => $method, %{ $self->constraints->{ $id } || {} } );

   $constraint_ref = Data::Validation::Constraints->new( %config );

   $constraint_ref->validate( $value );

=head1 Description

Tests a single data value for conformance with a constraint

=head1 Configuration and Environment

Uses the L<Moo::Role> L<Data::Validation::Utils>. Defines the
following attributes:

=over 3

=item error

A string containing the error message that is thrown if the validation
fails

=item max_length

Used by L</isValidLength>. The I<length> of the supplied value must be
numerically less than this

=item max_value

Used by L</isBetweenValues>.

=item min_length

Used by L</isValidLength>.

=item min_value

Used by L</isBetweenValues>.

=item required

If true then null values are not allowed regardless of what other
validation would be done

=item value

Used by the L</isEqualTo> method as the other value in the comparison

=back

=head1 Subroutines/Methods

=head2 validate

Called by L<Data::Validation>::check_field this method implements
tests for a null input value so that individual validation methods
don't have to. It calls either a built in validation method or
L</_validate> which should have been overridden in a factory
subclass. An exception is thrown if the data value is not acceptable

=head2 _validate

Should have been overridden in an external constraint subclass

=head2 isBetweenValues

Test to see if the supplied value is numerically greater than
C<< $self->min_value >> and less than C<< $self->max_value >>

=head2 isEqualTo

Test to see if the supplied value is equal to C<< $self->value >>. Calls
C<isValidNumber> on both values to determine the type of comparison
to perform

=head2 isHexadecimal

Tests to see if the value matches the regular expression for a hexadecimal
number

=head2 isMandatory

Null values are not allowed

=head2 isMatchingRegex

Does the supplied value match C<< $self->pattern >>?

=head2 isPrintable

Is the supplied value entirely composed of printable characters?

=head2 isSimpleText

Simple text is defined as matching the pattern '\A [a-zA-Z0-9_ \-\.]+ \z'

=head2 isValidHostname

Calls C<gethostbyname> on the supplied value

=head2 isValidIdentifier

Identifiers must match the pattern '\A [a-zA-Z_] \w* \z'

=head2 isValidInteger

Tests to see if the supplied value is an integer

=head2 isValidLength

Tests to see if the length of the supplied value is greater than
C<< $self->min_length >> and less than C<< $self->max_length >>

=head2 isValidNumber

Return true if the supplied value C<looks_like_number>

=head1 External Constraints

Each of these constraint subclasses implements the required C<_validate>
method

=head2 Date

If the C<str2time> method in the L<CatalystX::Usul::Class::Time>
module can parse the supplied value then it is deemed to be a valid
date

=head2 Email

If the C<address> method in the L<Email::Valid> module can parse the
supplied value then it is deemed to be a valid email address

=head2 Password

Currently implements a minimum password length of six characters and
that the password contain at least one non alphabetic character

=head2 Path

Screen out these characters: ; & * { } and space

=head2 Postcode

Tests to see if the supplied value matches one of the approved
patterns for a valid postcode

=head2 URL

Call the C<request> method in L<LWP::UserAgent> to test if a URL is accessible

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<charnames>

=item L<Moo>

=item L<Regexp::Common>

=item L<Unexpected::Types>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There is no POD coverage test because the subclasses docs are in here instead

The L<Data::Validation::Constraints::Date> module requires the module
L<CatalystX::Usul::Time> and this is not listed as prerequisite as it
would create a circular dependency

Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 License and Copyright

Copyright (c) 2013 Peter Flanigan. All rights reserved

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
