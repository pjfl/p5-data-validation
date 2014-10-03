package Data::Validation;

use 5.010001;
use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.16.%d', q$Rev: 3 $ =~ /\d+/gmx );

use Moo;
use Data::Validation::Constants;
use Data::Validation::Constraints;
use Data::Validation::Filters;
use English                 qw( -no_match_vars );
use List::Util              qw( first );
use Try::Tiny;
use Unexpected::Types       qw( HashRef NonZeroPositiveInt );
use Unexpected::Functions   qw( FieldComparison ValidationErrors );

has 'constraints' => is => 'ro', isa => HashRef, default => sub { {} };

has 'level'       => is => 'ro', isa => NonZeroPositiveInt, default => 1;

has 'fields'      => is => 'ro', isa => HashRef, default => sub { {} };

has 'filters'     => is => 'ro', isa => HashRef, default => sub { {} };

has '_operators'  => is => 'ro', isa => HashRef, default => sub {
   { 'eq' => sub { $_[ 0 ] eq $_[ 1 ] },
     '==' => sub { $_[ 0 ] == $_[ 1 ] },
     'ne' => sub { $_[ 0 ] ne $_[ 1 ] },
     '!=' => sub { $_[ 0 ] != $_[ 1 ] },
     '>'  => sub { $_[ 0 ] >  $_[ 1 ] },
     '>=' => sub { $_[ 0 ] >= $_[ 1 ] },
     '<'  => sub { $_[ 0 ] <  $_[ 1 ] },
     '<=' => sub { $_[ 0 ] <= $_[ 1 ] }, } };

# Public methods
sub check_form { # Validate all fields on a form by repeated calling check_field
   my ($self, $prefix, $form) = @_; my @errors = (); $prefix ||= NUL;

   ($form and ref $form eq HASH) or $self->_throw( 'Form bad hash' );

   for my $name (sort keys %{ $form }) {
      my $id = $prefix.$name; my $field = $self->fields->{ $id };

      ($field and ($field->{filters} or $field->{validate})) or next;

      try   {
         $form->{ $name } = $self->check_field( $id, $form->{ $name } );
         __should_compare( $field )
            and $self->_compare_fields( $prefix, $form, $name );
      }
      catch { push @errors, $_ };
   }

   @errors and $self->_throw
      ( class => ValidationErrors, args => \@errors, level => 2 );

   return $form;
}

sub check_field { # Validate form field values
   my ($self, $id, $value) = @_; my $field;

   unless ($id and $field = $self->fields->{ $id }
           and ($field->{filters} or $field->{validate})) {
      $self->_throw( error => 'Field [_1] undefined', args => [ $id, $value ] );
   }

   $field->{filters}
      and $value = $self->_filter( $field->{filters}, $id, $value );

   for my $method (__get_methods( $field->{validate} )) {
      $method eq 'compare' or $self->_validate( $method, $id, $value );
   }

   return $value;
}

# Private methods
sub _compare_fields {
   my ($self, $prefix, $form, $lhs_name) = @_;

   my $id         = $prefix.$lhs_name;
   my $constraint = $self->constraints->{ $id } || {};
   my $rhs_name   = $constraint->{other_field}
      or $self->_throw( error => 'Constraint [_1] has no comparison field',
                        args  => [ $id ] );
   my $op         = $constraint->{operator} || 'eq';
   my $lhs        = $form->{ $lhs_name } || NUL;
   my $rhs        = $form->{ $rhs_name } || NUL;
   my $bool       = exists $self->_operators->{ $op }
                  ? $self->_operators->{ $op }->( $lhs, $rhs ) : 0;

   unless ($bool) {
      $lhs_name = $self->fields->{ $prefix.$lhs_name }->{label} || $lhs_name;
      $rhs_name = $self->fields->{ $prefix.$rhs_name }->{label} || $rhs_name;

      $self->_throw( class => FieldComparison,
                     args  => [ $lhs_name, $op, $rhs_name ] );
   }

   return;
}

sub _filter {
   my ($self, $filters, $id, $value) = @_;

   for my $method (__get_methods( $filters )) {
      my %attr    = ( %{ $self->filters->{ $id } || {} }, method => $method, );
      my $dvf_obj = Data::Validation::Filters->new( %attr );

      $value = $dvf_obj->filter( $value );
   }

   return $value;
}

sub _throw {
   my $self = shift; EXCEPTION_CLASS->throw( @_ );
}

sub _validate {
   my ($self, $method, $id, $value) = @_;

   my %attr = ( %{ $self->constraints->{ $id } || {} }, method => $method, );
   my $constraint = Data::Validation::Constraints->new( %attr );

   unless ($constraint->validate( $value )) {
     (my $class = $method) =~ s{ \A is }{}mx;
      my $name  = $self->fields->{ $id }->{label}
               || $self->fields->{ $id }->{fhelp} # Deprecated
               || $id;

      $self->_throw( class => $class,
                     args  => [ $name, $value ], level => $self->level );
   }

   return;
}

# Private functions
sub __get_methods {
   return split SPC, $_[ 0 ] || NUL;
}

sub __should_compare {
   return first { $_ eq 'compare' } __get_methods( $_[ 0 ]->{validate} );
}

1;

__END__

=pod

=head1 Name

Data::Validation - Filter and validate data values

=head1 Version

Describes version v0.16.$Rev: 3 $ of L<Data::Validation>

=head1 Synopsis

   use Data::Validation;

   sub check_field {
      my ($self, $config, $id, $value) = @_;

      my $dv_obj = $self->_build_validation_obj( $config );

      return $dv_obj->check_field( $id, $value );
   }

   sub check_form  {
      my ($self, $config, $form) = @_;

      my $dv_obj = $self->_build_validation_obj( $config );
      my $prefix = $config->{form_name}.q(.);

      return $dv_obj->check_form( $prefix, $form );
   }

   sub _build_validation_obj {
      my ($self, $config) = @_;

      return Data::Validation->new( {
         constraints => $config->{constraints}     || {},
         fields      => $config->{fields}          || {},
         filters     => $config->{filters}         || {} } );
   }

=head1 Description

This module implements filters and common constraints in builtin
methods and uses a factory pattern to implement an extensible list of
external filters and constraints

Data values are filtered first before testing against the constraints. The
filtered data values are returned if they conform to the constraints,
otherwise an exception is thrown

=head1 Configuration and Environment

The following are passed to the constructor

=over 3

=item constraints

Hash containing constraint attributes. Keys are the C<$id> values passed
to L</check_field>. See L<Data::Validation::Constraints>

=item fields

Hash containing field definitions. Keys are the C<$id> values passed
to L</check_field>. Each field definition can contain a space
separated list of filters to apply and a space separated list of
constraints. Each constraint method must return true for the value to
be accepted

=item filters

Hash containing filter attributes. Keys are the C<$id> values passed
to L</check_field>. See L<Data::Validation::Filters>

=item level

Positive integer defaults to 1. Used to select the stack frame from which
to throw the C<check_field> exception

=item operators

Hash containing operator code refs. The keys of the hash ref are comparison
operators and their values are the anonymous code refs that compare
the operands and return a boolean. Used by the I<compare> form validation
method

=back

=head1 Subroutines/Methods

=head2 check_form

   $form = $dv->check_form( $prefix, $form );

Calls L</check_field> for each of the keys in the C<$form> hash. In
the calls to L</check_field> the C<$form> keys have the C<$prefix>
prepended to them to create the key to the C<$fields> hash

If one of the fields constraint names is I<compare>, then the fields
value is compared with the value for another field. The constraint
attribute I<other_field> determines which field to compare and the
I<operator> constraint attribute gives the comparison operator which
defaults to C<eq>

All fields are checked. Multiple error objects are stored, if they occur,
in the C<args> attribute of the returned error object

=head2 check_field

   $value = $dv->check_field( $id, $value );

Checks one value for conformance. The C<$id> is used as a key to the
I<fields> hash whose I<validate> attribute contains the list of space
separated constraint names. The value is tested against each
constraint in turn. All tests must pass or the subroutine will use the
C<EXCEPTION_CLASS> class to C<throw> an error

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Moo>

=item L<Try::Tiny>

=item L<Unexpected::Types>

=back

=head1 Incompatibilities

OpenDNS. I have received reports that hosts configured to use OpenDNS fail the
C<isValidHostname> test. Apparently OpenDNS causes the core Perl function
C<gethostbyname> to return it's argument rather than undefined as per the
documentation

=head1 Bugs and Limitations

There are no known bugs in this module.
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

