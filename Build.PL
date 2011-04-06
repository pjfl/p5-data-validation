# @(#)$Id$

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

Bob->new( {
   stop_tests => 1,
   license    => q(perl),
   module     => q(Data::Validation),
   home_page  => q(http://www.roxsoft.co.uk),
   requires   => {
      'perl'                         => 5.008,
      'charnames'                    => 1.05,
      'namespace::autoclean'         => 0.05,
      'version'                      => 0.74,
      'Class::MOP'                   => 0.53,
      'Email::Valid'                 => 0.179,
      'List::Util'                   => 1.19,
      'LWP::UserAgent'               => 2.036,
      'Moose'                        => 0.38,
      'Moose::Role'                  => 0.55,
      'Moose::Util::TypeConstraints' => 0.21,
      'Regexp::Common'               => 2.120,
      'Scalar::Util'                 => 1.19,
      'Try::Tiny'                    => 0.09, },
   recommends         => { 'CatalystX::Usul::Time' => q(0.3.0), },
   configure_requires => { 'Module::Build'    => 0.32,
                           'version'          => 0.74, },
   build_requires     => { 'Exception::Class' => 1.23,
                           'Class::Null'      => 1.09,
                           'Test::More'       => 0.74,
                           'Test::Pod'        => 1.26, },
} )->create_build_script; # Goal!

# Local Variables:
# mode: perl
# tab-width: 3
# End:
