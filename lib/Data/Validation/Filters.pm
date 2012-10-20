# @(#)$Id$

package Data::Validation::Filters;

use strict;
use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.9.%d', q$Rev$ =~ /\d+/gmx );

use Moose;

with q(Data::Validation::Utils);

has 'replace' => is => 'rw', isa => 'Str';

sub filter {
   my ($self, $val) = @_; defined $val or return; my $method = $self->method;

   $self->can( $method ) and return $self->$method( $val );

   return $self->_load_class( q(filter), $method )->_filter( $val );
}

# Private methods

sub _filter {
   my $self = shift; my $exception = $self->exception;

   $exception->throw( error => 'Method [_1] not overridden in class [_2]',
                      args  => [ q(_filter), ref $self || $self ] );
   return;
}

# Builtin factory filter methods

sub filterEscapeHTML {
   my ($self, $val) = @_;

   $val =~ s{ &(?!(amp|lt|gt|quot);) }{&amp;}gmx;
   $val =~ s{ < }{&lt;}gmx;
   $val =~ s{ > }{&gt;}gmx;
   $val =~ s{ \" }{&quot;}gmx;
   return $val;
}

sub filterLowerCase {
   my ($self, $val) = @_; return lc $val;
}

sub filterNonNumeric {
   my ($self, $val) = @_; $val =~ s{ \D+ }{}gmx; return $val;
}

sub filterReplaceRegex {
   my ($self, $val) = @_;

   my $pattern = $self->pattern or return $val;
   my $replace = defined $self->replace ? $self->replace : q();

   $val =~ s{ $pattern }{$replace}gmx;
   return $val;
}

sub filterTrimBoth {
   my ($self, $val) = @_;

   $val =~ s{ \A \s+ }{}mx; $val =~ s{ \s+ \z }{}mx;
   return $val;
}

sub filterUpperCase {
   my ($self, $val) = @_; return uc $val;
}

sub filterWhiteSpace {
   my ($self, $val) = @_; $val =~ s{ \s+ }{}gmx; return $val;
}

sub filterZeroLength {
   return defined $_[ 1 ] && length $_[ 1 ] ? $_[ 1 ] : undef;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__

=pod

=head1 Name

Data::Validation::Filters - Filter data values

=head1 Version

0.9.$Revision$

=head1 Synopsis

   use Data::Validation::Filters;

   %config = ( method => $method,
               exception => q(Exception::Class),
               %{ $self->filters->{ $id } || {} } );

   $filter_ref = Data::Validation::Filters->new( %config );

   $value = $filter_ref->filter( $value );

=head1 Description

Applies a single filter to a data value and returns it's possibly changed
value

=head1 Configuration and Environment

Uses the L<Data::Validation::Utils> L<Moose::Role>. Defines the
following attributes:

=over 3

=item replace

The replacement value used in regular expression search and replace
operations

=back

=head1 Subroutines/Methods

=head2 filter

Calls either a builtin method or an external one to filter the data value

=head2 _filter

Should have been overridden in an external filter subclass

=head2 filterEscapeHTML

Replaces &<>" with their &xxx; equivalents

=head2 filterLowerCase

Lower cases the data value

=head2 filterNonNumeric

Removes all non numeric characters

=head2 filterReplaceRegex

Matches the regular expression pattern and substitutes the replace string

=head2 filterTrimBoth

Remove all leading and trailing whitespace

=head2 filterUpperCase

Upper cases the data value

=head2 filterWhiteSpace

Removes all whitespace

=head2 filterZeroLength

Returns undef if value is zero length

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Data::Validation::Utils>

=item L<Moose>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2012 Peter Flanigan. All rights reserved

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
