
# home grown "makefile" to compile the .so file properly, MakeMaker does not
# like me this week...

/home/usr/local/bin/perl /usr/local/lib/perl5/5.8.2/ExtUtils/xsubpp  -C++ -typemap /usr/local/lib/perl5/5.8.2/ExtUtils/typemap  Irrlicht.xs > Irrlicht.xsc && mv Irrlicht.xsc Irrlicht.c

g++ Irrlicht.c -shared -fno-strict-aliasing -o blib/arch/auto/Games/Irrlicht/Irrlicht.so -I/usr/local/include "-I/usr/local/lib/perl5/5.8.2/i686-linux/CORE" -L"/usr/X11R6/lib" -L"/usr/local/lib/Irrlicht" -lIrrlicht -lGL -lXxf86vm -lXext -lX11 -ljpeg -lz



