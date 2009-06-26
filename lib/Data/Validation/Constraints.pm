# @(#)$Id$

package Data::Validation::Constraints;

use strict;
use charnames qw(:full);
use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.4.%d', q$Rev$ =~ /\d+/gmx );

use Moose;
use Regexp::Common qw(number);
use Scalar::Util   qw(looks_like_number);

with q(Data::Validation::Utils);

has 'max_length' => ( is => q(rw), isa => q(Int) );
has 'max_value'  => ( is => q(rw), isa => q(Int) );
has 'min_length' => ( is => q(rw), isa => q(Int) );
has 'min_value'  => ( is => q(rw), isa => q(Int) );
has 'required'   => ( is => q(rw), isa => q(Bool) );
has 'value'      => ( is => q(rw), isa => q(Any) );

sub validate {
   my ($self, $val) = @_; my $method = $self->method; my $class;

   return 0 if (!$val && $self->required);

   return 1 if (!$val && !$self->required && $method ne q(isMandatory));

   return $self->$method( $val ) if ($self->can( $method ));

   return $self->_load_class( q(isValid), $method )->_validate( $val );
}

# Private methods

sub _validate {
   my $self = shift; my $exception = $self->exception;

   $exception->throw( error => 'Method [_1] not overridden in class [_2]',
                      args  => [ q(_validate), ref $self || $self ] );
   return;
}

# Builtin factory validation methods

sub isBetweenValues {
   my ($self, $val) = @_;

   return 0 if (defined $self->min_value && $val < $self->min_value);
   return 0 if (defined $self->max_value && $val > $self->max_value);
   return 1;
}

sub isEqualTo {
   my ($self, $val) = @_;

   if ($self->isValidNumber( $val ) && $self->isValidNumber( $self->value )) {
      return 1 if ($val == $self->value);
      return 0;
   }

   return 1 if ($val eq $self->value);
   return 0;
}

sub isHexadecimal {
   my ($self, $val) = @_;

   $self->pattern( '\A '.$RE{num}{hex}.' \z' );
   return $self->isMatchingRegex( $val );
}

sub isMandatory {
   shift; return ((shift) ? 1 : 0);
}

sub isMatchingRegex {
   my ($self, $val) = @_; my $pat = $self->pattern;

   return $val =~ m{ $pat }msx ? 1 : 0;
}

sub isPrintable {
   my ($self, $val) = @_;

   $self->pattern( '\A \p{IsPrint}+ \z' );
   return $self->isMatchingRegex( $val );
}

sub isSimpleText {
   my ($self, $val) = @_;

   $self->pattern( '\A [a-zA-Z0-9_ \-\.]+ \z' );
   return $self->isMatchingRegex( $val );
}

sub isValidHostname {
   my ($self, $val) = @_; return (gethostbyname $val)[0] ? 1 : 0;
}

sub isValidIdentifier {
   my ($self, $val) = @_;

   $self->pattern( '\A [a-zA-Z_] \w* \z' );
   return $self->isMatchingRegex( $val );
}

sub isValidInteger {
   my ($self, $val) = @_;

   $self->pattern( '\A '.$RE{num}{int}{-sep=>'[_]?'}.' \z' );

   return 0 unless ($self->isMatchingRegex( $val ));
   return 0 unless (int $val == $val);
   return 1;
}

sub isValidLength {
   my ($self, $val) = @_;

   return 0 if (defined $self->min_length && length $val < $self->min_length);
   return 0 if (defined $self->max_length && length $val > $self->max_length);
   return 1;
}

sub isValidNumber {
   my ($self, $val) = @_;

   return 0 unless (defined $val);
   return 1 if     (looks_like_number( $val ));
   return 0;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__

=pod

=head1 Name

Data::Validation::Constraints - Test data values for conformance with constraints

=head1 Version

0.4.$Revision$

=head1 Synopsis

   use Data::Validation::Constraints;

   %config = ( method => $method,
               exception => q(Exception::Class),
               %{ $self->constraints->{ $id } || {} } );

   $constraint_ref = Data::Validation::Constraints->new( %config );

   $constraint_ref->validate( $value );

=head1 Description

Tests a single data value for conformance with a constraint

=head1 Configuration and Environment

Uses the L<Data::Validation::Utils> L<Moose::Role>. Defines the
following attributes:

=over 3

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

=item L<Data::Validation::Utils>

=item L<Moose>

=item L<Regexp::Common>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There is no POD coverage test because the subclasses docs are in here instead

The L<Data::Validation::Constraints::Date> module requires the as yet
unpublished module L<CatalystX::Usul::Class::Time> and this is not
listed as prerequisite as it would create a circular dependency

Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2008 Peter Flanigan. All rights reserved

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
