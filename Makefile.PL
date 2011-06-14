use 5.010;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WebService::Libris',
    AUTHOR              => q{Moritz Lenz <moritz@faui2k3.org>},
    VERSION_FROM        => 'lib/WebService/Libris.pm',
    ABSTRACT_FROM       => 'lib/WebService/Libris.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        Mojolicious     => 0.040,
        'Test::More'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WebService-Libris-*' },
);
