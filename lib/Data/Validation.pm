package Data::Validation;

# @(#)$Id$

use Moose;
use Data::Validation::Utils;
use Data::Validation::Constraints;
use Data::Validation::Filters;
use English qw(-no_match_vars);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

has 'exception'   => ( is => q(ro), isa => q(Exception), required => 1 );
has 'constraints' => ( is => q(ro), isa => q(HashRef), default => sub { {} } );
has 'fields'      => ( is => q(ro), isa => q(HashRef), default => sub { {} } );
has 'filters'     => ( is => q(ro), isa => q(HashRef), default => sub { {} } );

sub check_form {
   # Validate all the fields on a form by repeated calling check_field
   my ($me, $prefix, $form) = @_; $prefix ||= q(); my $field;

   unless ($form && ref $form eq q(HASH)) {
      $me->exception->throw( q(eNoFormValues) );
   }

   for my $name (keys %{ $form }) {
      my $id = $prefix.$name;

      next unless ($field = $me->fields->{ $id } and $field->{validate});

      $form->{ $name } = $me->check_field( $id, $form->{ $name } );
   }

   return $form;
}

sub check_field {
   # Validate form field values
   my ($me, $id, $value) = @_;
   my (%config, $constraint_ref, $error, $field, $filter_ref, $method);

   unless ($id and $field = $me->fields->{ $id } and $field->{validate}) {
      $me->exception->throw( error => q(eNoFieldDefinition),
                             arg1  => $id, arg2 => $value );
   }

   if ($field->{filters}) {
      for $method (split q( ), $field->{filters}) {
         %config = ( method => $method,
                     exception => $me->exception,
                     %{ $me->filters->{ $id } || {} }, );
         $filter_ref = eval { Data::Validation::Filters->new( %config ) };

         $me->exception->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

         $value = $filter_ref->filter( $value );
      }
   }

   for $method (split q( ), $field->{validate}) {
      %config = ( method => $method,
                  exception => $me->exception,
                  %{ $me->constraints->{ $id } || {} }, );
      $constraint_ref = eval { Data::Validation::Constraints->new( %config ) };

      $me->exception->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

      unless ($constraint_ref->validate( $value )) {
         ($error = $method) =~ s{ \A is }{e}imx;
         $me->exception->throw( error => $error, arg1 => $id, arg2 => $value );
      }
   }

   return $value;
}

1;

__END__

=pod

=head1 Name

Data::Validation - Check data values for conformance with constraints

=head1 Version

0.2.$Rev$

=head1 Synopsis

   use Data::Validation;

   sub check_field {
      my ($me, $stash, $id, $value) = @_;
      my $config = { exception   => q(Exception::Class),
                     constraints => $stash->{constraints} || {},
                     fields      => $stash->{fields}      || {},
                     filters     => $stash->{filters}     || {} };
      my $dv = eval { Data::Validation->new( %{ $config } ) };

      $me->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

      return $dv->check_field( $id, $value );
   }

   sub check_form  {
      my ($me, $stash, $form) = @_;
      my $config = { exception   => q(Exception::Class),
                     constraints => $stash->{constraints} || {},
                     fields      => $stash->{fields}      || {},
                     filters     => $stash->{filters}     || {} };
      my $dv = eval { Data::Validation->new( %{ $config } ) };

      $me->throw( $EVAL_ERROR ) if ($EVAL_ERROR);

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

Class capable of throwing an exception

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
I<exception> class to I<throw> an error

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Moose>

=item L<Moose::Util::TypeConstraints>

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
