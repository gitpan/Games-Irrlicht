use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
	'NAME'		=> 'Games::Irrlicht',
	'VERSION_FROM'	=> 'lib/Games/Irrlicht.pm',
	'PREREQ_PM'	=> {
			 Config::Simple => '4.55',
			},
	($] >= 5.005 ?
		(ABSTRACT_FROM  => 'lib/Games/Irrlicht.pm',
                AUTHOR         => 'Tels <http://bloodgate.com/>') : ()),
	'CC'		=> 'g++',
	'LD'		=> 'g++',
	'LIBS'		=> [ '-L/usr/X11R6/lib -L/usr/local/lib/Irrlicht -lX11 -lXext -lXxf86vm -lIrrlicht -lGL -ljpeg -lz' ],
	'LDFLAGS'	=> '-static -L/usr/X11R6/lib -L/usr/local/lib/Irrlicht -lXxf86vm -lIrrlicht -lGL -lGLU -ljpeg -lz -lX11 -lXext',
#	'LDFLAGS'	=>   '-L/usr/X11R6/lib -L/usr/local/lib/Irrlicht -Ljpeglib -Lzlib',

	'OPTIMIZE'	=> '-O2',
	'DEFINE'	=> '', # e.g., '-DHAVE_SOMETHING'
	'INC'		=> '',
#	'XSOPT'		=> '-C++', 
#	'OBJECT'	=> '', 
);
