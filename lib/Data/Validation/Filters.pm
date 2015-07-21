package Data::Validation::Filters;

use namespace::autoclean;

use Data::Validation::Constants qw( EXCEPTION_CLASS HASH TRUE );
use Data::Validation::Utils     qw( load_class );
use Unexpected::Types           qw( Str );
use Moo;

has 'method'  => is => 'ro', isa => Str, required => TRUE;

has 'pattern' => is => 'ro', isa => Str;

has 'replace' => is => 'ro', isa => Str;

sub new_from_method {
   my $class = shift; my $attr = ref $_[ 0 ] eq HASH ? $_[ 0 ] : { @_ };

   $class->can( $attr->{method} ) and return $class->new( $attr );

   return (load_class $class, 'filter', $attr->{method})->new( $attr );
}

sub filter {
   my ($self, $v) = @_; my $method = $self->method; return $self->$method( $v );
}

around 'filter' => sub {
   my ($orig, $self, $v) = @_; return defined $v ? $orig->( $self, $v ) : undef;
};

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

1;

__END__

=pod

=encoding utf8

=head1 Name

Data::Validation::Filters - Filter data values

=head1 Synopsis

   use Data::Validation::Filters;

   %config = ( method => $method, %{ $self->filters->{ $id } || {} } );

   $filter_ref = Data::Validation::Filters->new( %config );

   $value = $filter_ref->filter_value( $value );

=head1 Description

Applies a single filter to a data value and returns it's possibly changed
value

=head1 Configuration and Environment

Uses the L<Moo::Role> L<Data::Validation::Utils>. Defines the
following attributes:

=over 3

=item C<replace>

The replacement value used in regular expression search and replace
operations

=back

=head1 Subroutines/Methods

=head2 filter_value

Calls either a builtin method or an external one to filter the data value

=head2 filter

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

=item L<Moo>

=item L<Unexpected>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Validation.  Patches are welcome

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
