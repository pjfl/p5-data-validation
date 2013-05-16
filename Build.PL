# @(#)$Ident: Build.PL 2013-05-16 21:20 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev: 1 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(Data::Validation),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'                 => 5.01,
      'namespace::autoclean' => 0.13,
      'Email::Valid'         => 0.184,
      'LWP::UserAgent'       => 2.036,
      'Moose'                => 2.0802,
      'Regexp::Common'       => 2010010201,
      'Try::Tiny'            => 0.09, },
   recommends                => {
      'App::cpanminus'       => 1.6005,
      'Class::Usul'          => q(0.21.0), },
   configure_requires        => {
      'version'              => 0.88,
      'Module::Build'        => 0.4004, },
   build_requires            => {
      'version'              => 0.88,
      'Class::Null'          => 1.09,
      'Exception::Class'     => 1.23,
      'Module::Build'        => 0.4004,
      'Test::Pod'            => 1.26, },
} )->create_build_script; # Goal!

# Local Variables:
# eval: (load-project-state "data-validation")
# mode: perl
# tab-title: Validation
# tab-width: 3
# End:
