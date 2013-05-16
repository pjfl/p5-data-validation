# Name

Data::Validation - Filter and check data values

# Version

Describes version v0.11.$Rev: 1 $ [Data::Validation](https://metacpan.org/module/Data::Validation)

# Synopsis

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

# Description

This module implements filters and common constraints in builtin
methods and uses a factory pattern to implement an extensible list of
external filters and constraints

Data values are filtered first before testing against the constraints. The
filtered data values are returned if they conform to the constraints,
otherwise an exception is thrown

# Configuration and Environment

The following are passed to the constructor

- exception

    Class capable of throwing an exception. Should provide an _args_ attribute

- constraints

    Hash containing constraint attributes. Keys are the `$id` values passed
    to ["check\_field"](#check\_field). See [Data::Validation::Constraints](https://metacpan.org/module/Data::Validation::Constraints)

- fields

    Hash containing field definitions. Keys are the `$id` values passed
    to ["check\_field"](#check\_field). Each field definition can contain a space
    separated list of filters to apply and a space separated list of
    constraints. Each constraint method must return true for the value to
    be accepted

- filters

    Hash containing filter attributes. Keys are the `$id` values passed
    to ["check\_field"](#check\_field). See [Data::Validation::Filters](https://metacpan.org/module/Data::Validation::Filters)

- operators

    Hash containing operator code refs. The keys of the hash ref are comparison
    operators and their values are the anonymous code refs that compare
    the operands and return a boolean. Used by the _compare_ form validation
    method

# Subroutines/Methods

## check\_form

    $form = $dv->check_form( $prefix, $form );

Calls ["check\_field"](#check\_field) for each of the keys in the `$form` hash. In
the calls to ["check\_field"](#check\_field) the `$form` keys have the `$prefix`
prepended to them to create the key to the `$fields` hash

If one of the fields constraint names is _compare_, then the fields
value is compared with the value for another field. The constraint
attribute _other\_field_ determines which field to compare and the
_operator_ constraint attribute gives the comparison operator which
defaults to `eq`

All fields are checked. Multiple error objects are stored, if they occur,
in the `args` attribute of the returned error object

## check\_field

    $value = $dv->check_field( $id, $value );

Checks one value for conformance. The `$id` is used as a key to the
_fields_ hash whose _validate_ attribute contains the list of space
separated constraint names. The value is tested against each
constraint in turn. All tests must pass or the subroutine will use the
_exception_ class to `throw` an error

# Diagnostics

None

# Dependencies

- [Moose](https://metacpan.org/module/Moose)
- [Data::Validation::Constraints](https://metacpan.org/module/Data::Validation::Constraints)
- [Data::Validation::Filters](https://metacpan.org/module/Data::Validation::Filters)
- [List::Util](https://metacpan.org/module/List::Util)
- [Try::Tiny](https://metacpan.org/module/Try::Tiny)

# Incompatibilities

OpenDNS. I have received reports that hosts configured to use OpenDNS fail the
`isValidHostname` test. Apparently OpenDNS causes the core Perl function
`gethostbyname` to return it's argument rather than undefined as per the
documentation

# Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2013 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/module/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
