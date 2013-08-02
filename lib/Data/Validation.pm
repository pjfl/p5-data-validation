# @(#)$Ident: Validation.pm 2013-08-02 20:14 pjf ;

package Data::Validation;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.12.%d', q$Rev: 4 $ =~ /\d+/gmx );

use 5.01;
use Data::Validation::Constraints;
use Data::Validation::Filters;
use English           qw( -no_match_vars );
use List::Util        qw( first );
use Moo;
use Try::Tiny;
use Unexpected::Types qw( HashRef );

has 'exception'   => is => 'ro', isa => sub {
   $_[ 0 ] and $_[ 0 ]->can( 'throw' ) or die 'Exception class cannot throw' },
   required       => 1;

has 'constraints' => is => 'ro', isa => HashRef, default => sub { {} };

has 'fields'      => is => 'ro', isa => HashRef, default => sub { {} };

has 'filters'     => is => 'ro', isa => HashRef, default => sub { {} };

has '_operators'  => is => 'ro', isa => HashRef,
   default        => sub { { q(eq) => sub { $_[ 0 ] eq $_[ 1 ] },
                             q(==) => sub { $_[ 0 ] == $_[ 1 ] },
                             q(ne) => sub { $_[ 0 ] ne $_[ 1 ] },
                             q(!=) => sub { $_[ 0 ] != $_[ 1 ] },
                             q(>)  => sub { $_[ 0 ] >  $_[ 1 ] },
                             q(>=) => sub { $_[ 0 ] >= $_[ 1 ] },
                             q(<)  => sub { $_[ 0 ] <  $_[ 1 ] },
                             q(<=) => sub { $_[ 0 ] <= $_[ 1 ] }, } };

sub check_form {
   # Validate all the fields on a form by repeated calling check_field
   my ($self, $prefix, $form) = @_; my @errors = (); $prefix ||= q();

   ($form and ref $form eq 'HASH')
      or $self->exception->throw( 'Form has no values' );

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

   @errors and $self->exception->throw( error => 'Validation errors',
                                        args  => \@errors );
   return $form;
}

sub check_field { # Validate form field values
   my ($self, $id, $value) = @_; my $field;

   unless ($id and $field = $self->fields->{ $id }
           and ($field->{filters} or $field->{validate})) {
      $self->exception->throw( error => 'Field [_1] undefined',
                               args  => [ $id, $value ] );
   }

   $field->{filters}
      and $value = $self->_filter( $field->{filters}, $id, $value );


   for my $method (__get_methods( $field->{validate} )) {
      $method eq q(compare) or $self->_validate( $method, $id, $value );
   }

   return $value;
}

# Private methods
sub _compare_fields {
   my ($self, $prefix, $form, $lhs_name) = @_; my $rhs_name;

   my $id         = $prefix.$lhs_name;
   my $constraint = $self->constraints->{ $id } || {};

   unless ($rhs_name = $constraint->{other_field}) {
      my $error = 'Constraint [_1] has no comparison field';

      $self->exception->throw( error => $error, args => [ $id ] );
   }

   my $lhs  = $form->{ $lhs_name } || q();
   my $rhs  = $form->{ $rhs_name } || q();
   my $op   = $constraint->{operator} || 'eq';
   my $bool = exists $self->_operators->{ $op }
            ? $self->_operators->{ $op }->( $lhs, $rhs ) : 0;

   unless ($bool) {
      my $error = $constraint->{error_compare}
               || 'Field [_1] does not [_2] field [_3]';

      $lhs_name = $self->fields->{ $prefix.$lhs_name }->{label} || $lhs_name;
      $rhs_name = $self->fields->{ $prefix.$rhs_name }->{label} || $rhs_name;

      $self->exception->throw( error => $error,
                               args  => [ $lhs_name, $op, $rhs_name ] );
   }

   return;
}

sub _filter {
   my ($self, $filters, $id, $value) = @_;

   my $config = $self->filters->{ $id } || {};

   for my $method (__get_methods( $filters )) {
      my %config  = ( method    => $method,
                      exception => $self->exception, %{ $config }, );
      my $dvf_obj = try   { Data::Validation::Filters->new( %config ) }
                    catch { $self->exception->throw( $_ ) };

      $value = $dvf_obj->filter( $value );
   }

   return $value;
}

sub _validate {
   my ($self, $method, $id, $value) = @_;

   my $config     = $self->constraints->{ $id } || {};
   my $error      = $config->{ "error_${method}" } || q();
   my %config     = ( method    => $method,
                      exception => $self->exception, %{ $config }, );
   my $constraint = try   { Data::Validation::Constraints->new( %config ) }
                    catch { $self->exception->throw( $_ ) };

   unless ($constraint->validate( $value )) {
      my $name = $self->fields->{ $id }->{label}
              || $self->fields->{ $id }->{fhelp} # Deprecated
              || $id;

      $error or ($error = $method) =~ s{ \A is }{e}imx;
      $self->exception->throw( error => $error, args => [ $name, $value ] );
   }

   return;
}

# Private subroutines
sub __get_methods {
   return split q( ), $_[ 0 ] || q();
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

Describes version v0.12.$Rev: 4 $ of L<Data::Validation>

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
         exception   => $config->{exception_class} || q(Exception::Class),
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

=item exception

Class capable of throwing an exception. Should provide an I<args> attribute

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
I<exception> class to C<throw> an error

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

