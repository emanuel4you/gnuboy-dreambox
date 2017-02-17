
prefix = /usr
exec_prefix = /usr
bindir = /usr/bin

CC = arm-oe-linux-gnueabi-gcc  -march=armv7ve -mfpu=neon-vfpv4  -mfloat-abi=hard -mcpu=cortex-a15 --sysroot=/home/emanuel/OE2.5/opendreambox/build/dm900/tmp-glibc/sysroots/dm900
LD = $(CC)
AS = $(CC)
INSTALL = /usr/bin/install -c

CFLAGS =  -ansi -pedantic -Wall -Wno-implicit -Wno-long-long -O3 -fstrength-reduce -fthread-jumps  -fcse-follow-jumps -fcse-skip-blocks -frerun-cse-after-loop  -fexpensive-optimizations -fforce-addr -fomit-frame-pointer
# NOTE if get; undefined reference to 'vid_screenshot'
# screen shot support is not in the port/backend.
# Add -DGNUBOY_NO_SCREENSHOT define below.
# SDL port includes screen shot support already.
#CFLAGS += -DGNUBOY_NO_SCREENSHOT

# gcc 4.x configure tends to default to '-ansi -pedantic'
# avoid warnings related to strdup()
CFLAGS += -D_XOPEN_SOURCE=500

LDFLAGS = $(CFLAGS)  -s
ASFLAGS = $(CFLAGS)

TARGETS =  fbgnuboy sdlgnuboy

ASM_OBJS = 

SYS_DEFS = -DHAVE_CONFIG_H -DIS_LITTLE_ENDIAN  -DIS_LINUX
SYS_OBJS = sys/nix/nix.o $(ASM_OBJS)
SYS_INCS =  -I./sys/nix

## Requirements for (optional) .zip support
## Disable with GNUBOY_NO_MINIZIP defined
USE_MINIZIP = True
ifdef USE_MINIZIP
	SYS_OBJS += unzip/unzip.o unzip/ioapi.o
	LDFLAGS = -lz
else
	CFLAGS += -DGNUBOY_NO_MINIZIP
endif

FB_OBJS = sys/linux/fbdev.o sys/linux/kb.o sys/pc/keymap.o sys/linux/joy.o sys/oss/oss.o
FB_LIBS = 

SVGA_OBJS = sys/svga/svgalib.o sys/pc/keymap.o sys/linux/joy.o sys/oss/oss.o
SVGA_LIBS = -L/usr/local/lib -lvga

SDL_OBJS = sys/sdl/sdl.o sys/sdl/keymap.o sys/sdl/SFont.o
SDL_LIBS = -lSDL -lpthread
SDL_CFLAGS = -D_GNU_SOURCE=1 -D_REENTRANT -I/home/emanuel/OE2.5/opendreambox/build/dm900/tmp-glibc/sysroots/dm900/usr/include/SDL

X11_OBJS = sys/x11/xlib.o sys/x11/keymap.o sys/linux/joy.o sys/oss/oss.o
X11_LIBS =  -lX11 -lXext

all: $(TARGETS)

include Rules

fbgnuboy: $(OBJS) $(SYS_OBJS) $(FB_OBJS)
	$(LD) $(LDFLAGS) $(OBJS) $(SYS_OBJS) $(FB_OBJS) -o $@ $(FB_LIBS)

sgnuboy: $(OBJS) $(SYS_OBJS) $(SVGA_OBJS)
	$(LD) $(LDFLAGS) $(OBJS) $(SYS_OBJS) $(SVGA_OBJS) -o $@ $(SVGA_LIBS)

sdlgnuboy: $(OBJS) $(SYS_OBJS) $(SDL_OBJS)
	$(LD) $(LDFLAGS) $(OBJS) $(SYS_OBJS) $(SDL_OBJS) -o $@ $(SDL_LIBS)

sys/sdl/sdl.o: sys/sdl/sdl.c
	$(MYCC) $(SDL_CFLAGS) -c $< -o $@

sys/sdl/keymap.o: sys/sdl/keymap.c
	$(MYCC) $(SDL_CFLAGS) -c $< -o $@

sys/sdl/SFont.o: sys/sdl/SFont.c
	$(MYCC) $(SDL_CFLAGS) -c $< -o $@

xgnuboy: $(OBJS) $(SYS_OBJS) $(X11_OBJS)
	$(LD) $(LDFLAGS) $(OBJS) $(SYS_OBJS) $(X11_OBJS) -o $@ $(X11_LIBS)

install: all
	$(INSTALL) -d $(bindir)
	$(INSTALL) -m 755 $(TARGETS) $(bindir)

clean:
	rm -f *gnuboy gmon.out *.o unzip/*.o sys/*.o sys/*/*.o asm/*/*.o

distclean: clean
	rm -f config.* sys/nix/config.h Makefile




