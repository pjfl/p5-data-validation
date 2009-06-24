# @(#)$Id$

package Data::Validation;

use strict;
use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

use Data::Validation::Constraints;
use Data::Validation::Filters;
use English qw(-no_match_vars);
use Moose;

has 'exception'   => ( is => q(ro), isa => q(Exception), required => 1 );
has 'constraints' => ( is => q(ro), isa => q(HashRef), default => sub { {} } );
has 'fields'      => ( is => q(ro), isa => q(HashRef), default => sub { {} } );
has 'filters'     => ( is => q(ro), isa => q(HashRef), default => sub { {} } );
has 'operators'   => ( is => q(ro), isa => q(HashRef), default => sub {
   return { q(eq) => sub { return $_[0] eq $_[1] },
            q(==) => sub { return $_[0] == $_[1] },
            q(ne) => sub { return $_[0] ne $_[1] },
            q(!=) => sub { return $_[0] != $_[1] },
            q(>)  => sub { return $_[0] >  $_[1] },
            q(>=) => sub { return $_[0] >= $_[1] },
            q(<)  => sub { return $_[0] <  $_[1] },
            q(<=) => sub { return $_[0] <= $_[1] }, } }, );

sub check_form {
   # Validate all the fields on a form by repeated calling check_field
   my ($self, $prefix, $form) = @_; $prefix ||= q(); my $methods;

   unless ($form && ref $form eq q(HASH)) {
      $self->exception->throw( 'Form has no values' );
   }

   for my $name (keys %{ $form }) {
      my $id = $prefix.$name; my $field = $self->fields->{ $id };

      next unless ($field and $methods = $field->{validate});

      $form->{ $name } = $self->check_field( $id, $form->{ $name } );

      if (-1 < index $methods, q(compare)) {
         $self->_compare_fields( $prefix, $form, $name );
      }
   }

   return $form;
}

sub check_field {
   # Validate form field values
   my ($self, $id, $value) = @_; my $field;

   unless ($id and $field = $self->fields->{ $id }
           and ($field->{filters} or $field->{validate})) {
      $self->exception->throw( error => 'No definition for field [_1]',
                               args  => [ $id, $value ] );
   }

   if ($field->{filters}) {
      $value = $self->_filter( $field->{filters}, $id, $value );
   }

   for my $method (split q( ), $field->{validate}) {
      $self->_validate( $method, $id, $value );
   }

   return $value;
}

# Private methods

sub _compare_fields {
   my ($self, $prefix, $form, $name1) = @_; my $name2;

   my $id         = $prefix.$name1;
   my $constraint = $self->constraints->{ $id } || {};

   unless ($name2 = $constraint->{other_field}) {
      my $error = 'Constraint [_1] has no comparison field';

      $self->exception->throw( error => $error, args => [ $id ] );
   }

   my $lhs  = $form->{ $name1 } || q();
   my $rhs  = $form->{ $name2 } || q();
   my $op   = $constraint->{operator} || q(eq);
   my $bool = exists $self->operators->{ $op }
            ? $self->operators->{ $op }->( $lhs, $rhs ) : 0;

   unless ($bool) {
      my $error = 'Field [_1] [_2] field [_3]';

      $self->exception->throw( error => $error,
                               args  => [ $name1, $op, $name2 ] );
   }

   return;
}

sub _filter {
   my ($self, $filters, $id, $value) = @_;

   for my $method (split q( ), $filters) {
      my %config = ( method    => $method,
                     exception => $self->exception,
                     %{ $self->filters->{ $id } || {} }, );
      my $filter_ref = eval { Data::Validation::Filters->new( %config ) };

      $self->exception->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

      $value = $filter_ref->filter( $value );
   }

   return $value;
}

sub _validate {
   my ($self, $method, $id, $value) = @_;

   return if ($method eq q(compare));

   my %config = ( method    => $method,
                  exception => $self->exception,
                  %{ $self->constraints->{ $id } || {} }, );
   my $constraint_ref = eval { Data::Validation::Constraints->new( %config ) };

   $self->exception->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

   unless ($constraint_ref->validate( $value )) {
      (my $error = $method) =~ s{ \A is }{e}imx;

      $self->exception->throw( error => $error, args => [ $id, $value ] );
   }

   return;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__

=pod

=head1 Name

Data::Validation - Filter and check data values

=head1 Version

0.3.$Rev$

=head1 Synopsis

   use Data::Validation;

   sub check_field {
      my ($self, $stash, $id, $value) = @_;
      my $config = { exception   => q(Exception::Class),
                     constraints => $stash->{constraints} || {},
                     fields      => $stash->{fields}      || {},
                     filters     => $stash->{filters}     || {} };
      my $dv = eval { Data::Validation->new( %{ $config } ) };

      $self->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

      return $dv->check_field( $id, $value );
   }

   sub check_form  {
      my ($self, $stash, $form) = @_;
      my $config = { exception   => q(Exception::Class),
                     constraints => $stash->{constraints} || {},
                     fields      => $stash->{fields}      || {},
                     filters     => $stash->{filters}     || {} };
      my $dv = eval { Data::Validation->new( %{ $config } ) };

      $self->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

      return $dv->check_form( $stash->{form_prefix}, $form );
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

=item L<Moose>

=item L<Data::Validation::Constraints>

=item L<Data::Validation::Filters>

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

