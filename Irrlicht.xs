#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <Irrlicht/irrlicht.h>
#include <time.h>

struct timespec my_time_spec;

/* our framerate monitor memory */
#define FRAMES_MAX 4096
unsigned int frames[FRAMES_MAX] = { 0 };
/* two pointers into the ringbuffer frames[] */
unsigned int frames_start = 0;
unsigned int frames_end = 0;
unsigned int last = 0;

double max_fps = 0;
double min_fps = 20000000;

unsigned int max_frame_time = 0;
unsigned int min_frame_time = 20000;

/* wake_time: the time we waited to long in this frame, and thus must be awake
   (e.g. not sleep) the next frame to correct for this */
unsigned int wake_time = 0;

using namespace irr;

using namespace core;
using namespace scene;
using namespace video;
using namespace gui;
//using namespace io;

IrrlichtDevice* device;
IVideoDriver* driver;
ISceneManager* smgr;
IGUIEnvironment* guienv;
ITimer* timer;

int _irrlicht_init_engine (
 unsigned int w, unsigned int h, unsigned int d, int fs)
  {
  device =
     createDevice(
        EDT_OPENGL,			// renderer
        dimension2d<s32>(w, h),		// size
        d,				// bit depth
        fs,				// fullscreen?
        false,				// stencilbuffer
        0);				// event receiver
  if (NULL == device) { return 0; }     // error

  driver = device->getVideoDriver();
  smgr = device->getSceneManager();
  guienv = device->getGUIEnvironment();
  timer = device->getTimer();

  if (NULL == driver || NULL == smgr || NULL == guienv)
    {
    return 0;                           // error
    }

  // add a static string
  guienv->addStaticText(L"Hello Perl! This is the Irrlicht Software engine!",
         rect<int>(10,10,200,30), true);

  // add a camera
  smgr->addCameraSceneNode(0, vector3df(0,10,-40), vector3df(0,0,0));

  return 1;
  }

/*
Games::Irrlicht XS code (C) by Tels <http://bloodgate.com/perl/> 
*/

MODULE = Games::Irrlicht		PACKAGE = Games::Irrlicht

PROTOTYPES: DISABLE
#############################################################################
        
int
_init_engine(SV* classname, unsigned int w, unsigned int h, unsigned int d, unsigned int fs)
    CODE:
        RETVAL = _irrlicht_init_engine(w,h,d,fs);
    OUTPUT:
        RETVAL

void
_done_engine(SV* classname)
    CODE:
        device->drop();

#############################################################################

SV*
_run_engine(SV* classname)
    PREINIT:
        int rc;
    CODE:
        rc = device->run();             /* true when we still run */
  /* Anything can be drawn between a beginScene() and an endScene() call.
    The beginScene clears the screen with a color and also the depth buffer
    if wanted. Then we let the Scene Manager and the GUI Environment draw
    their content. With the endScene() call everything is presented on the
    screen.
  */
        driver->beginScene(true, true, SColor(0,100,100,100));
          smgr->drawAll();
          guienv->drawAll();
        driver->endScene();
        RETVAL = newSViv( rc );                 /* return result */
    OUTPUT:
        RETVAL

#############################################################################

SV*
_get_ticks(SV* classname)
    PREINIT:
	int rc;
    CODE:
	rc = timer->getTime();
	RETVAL = newSVuv( rc );
    OUTPUT:	
	RETVAL

##############################################################################
# _delay() - if the time between last and this frame was too short, delay the
#            app a bit. Also returns current time corrected by base_ticks.

SV*
_delay(min_time,base_ticks)
        unsigned int    min_time
        unsigned int    base_ticks
  CODE:
    /*
     min_time  - ms to spent between frames minimum
     wake_time - ms we were late in last frame, so we slee this time shorter
     last      - time in ticks of last frame
    */
    /* caluclate how long we should sleep */
    unsigned int now, time, frame_cnt, diff;
    int to_sleep;
    double framerate;

    //if (last == 0)
    //  {
    //  last = timer->getTime() - base_ticks;
    //  }
    now = timer->getTime() - base_ticks;

    if (min_time > 0)
      {
      to_sleep = min_time - wake_time - (now - last) - 1;

      # sometimes Delay() does not seem to work, so retry until it we sleeped
      # long enough
      while (to_sleep > 2)
        {
//	printf ("to_sleep: %i\n", to_sleep);
	my_time_spec.tv_sec = 0;
	my_time_spec.tv_nsec = to_sleep * 1000;
	nanosleep( &my_time_spec, NULL);	// struct timespec *rem);
        now = timer->getTime() - base_ticks;
//	printf ("now: %i\n", now);
        to_sleep = min_time - (now - last);
        }
      wake_time = 0;

      if (now - last > min_time)
        {
        wake_time = now - last - min_time;
        }
      }
//	printf ("now: %i\n", now);
    diff = now - last;
    ST(0) = newSViv(now);
    ST(1) = newSViv(diff);
    last = now;
    /* ******************************************************************** */
    /* monitor the framerate */

    /* add current value to ringbuffer */
    frames[frames_end] = now; frames_end++;
    if (frames_end >= FRAMES_MAX)
      {
      frames_end = 0;
      }
    /* buffer full? if so, remove oldest entry */
    if (frames_end == frames_start)
      {
      frames_start++;
      if (frames_start >= FRAMES_MAX)
        {
        frames_start = 0;
        }
      }
    /* keep only values in the buffer, that are at most 1000 ms old */
    while (now - frames[frames_start] > 1000)
      {
      /* remove value from start */
      frames_start++;
      if (frames_start >= FRAMES_MAX)
        {
        frames_start = 0;
        }
      if (frames_start == frames_end)
        {
        /* buffer empty */
        break;
        }
      }
    framerate = 0;
    if (frames_start != frames_end)
      {
      /* got some frames, so calc. current frame rate */
      time = now - frames[frames_start] + 1;
      /* printf ("time %i start %i (%i) end %i (%i) ",
        time,frames_start,frames[frames_start],frames_end,now); */
      if (frames_start < frames_end)
        {
        frame_cnt = frames_end - frames_start + 1;
        }
      else
        {
        frame_cnt = 1024 - (frames_start - frames_end - 1);
        }
      /* does it make sense to calc. fps? */
      if (frame_cnt > 20)
        {
        framerate = (double)(10000 * frame_cnt / time) / 10;
        if (min_fps > framerate) { min_fps = framerate; }
        if (max_fps < framerate) { max_fps = framerate; }
        if (diff > max_frame_time) { max_frame_time = diff; }
        if (diff < min_frame_time && diff > 0) { min_frame_time = diff; }
        }
      /* printf (" frames %i time %i fps %f\n",frame_cnt,time,framerate);
      printf (" min %f max %f\n",min_fps,max_fps); */
      }

    ST(2) = newSVnv(framerate);
    XSRETURN(3);

SV*
min_fps(SV* classname)
    CODE:
      RETVAL = newSVnv(min_fps);
    OUTPUT:
      RETVAL

SV*
max_fps(SV* classname)
    CODE:
      RETVAL = newSVnv(max_fps);
    OUTPUT:
      RETVAL

SV*
max_frame_time(SV* classname)
    CODE:
      RETVAL = newSViv(max_frame_time);
    OUTPUT:
      RETVAL

SV*
min_frame_time(SV* classname)
    CODE:
      RETVAL = newSViv(min_frame_time);
    OUTPUT:
      RETVAL

