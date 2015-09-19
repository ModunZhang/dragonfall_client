########################################################
# PS3 PPU Makefile generated for GNU Make by ProDG VSI #
########################################################

.SILENT:

unexport MAKEFLAGS
unexport MFLAGS

OUTDIR = ../../lib/msvc2005/PS3_Debug
INTDIR = PS3_Debug

LIBS=\

WLIBS=\

AS=ppu-lv2-gcc
AS_FLAGS=\
	-DSN_TARGET_PS3\
	-D_DEBUG\
	-D__GCC__\
	-D_PS3\
	-DNO_GETENV\
	-D_CRT_SECURE_NO_DEPRECATE\
	-D_HAS_EXCEPTIONS=0\
	-I../../include\
	-iquote.\
	-c\

CC=ppu-lv2-gcc
CC_FLAGS=\
	-DSN_TARGET_PS3\
	-D_DEBUG\
	-D__GCC__\
	-D_PS3\
	-DNO_GETENV\
	-D_CRT_SECURE_NO_DEPRECATE\
	-D_HAS_EXCEPTIONS=0\
	-I../../include\
	-iquote.\
	-c\
	-fpch-deps\
	-MMD -MV\

CXX=ppu-lv2-gcc
CXX_FLAGS=\
	-DSN_TARGET_PS3\
	-D_DEBUG\
	-D__GCC__\
	-D_PS3\
	-DNO_GETENV\
	-D_CRT_SECURE_NO_DEPRECATE\
	-D_HAS_EXCEPTIONS=0\
	-I../../include\
	-iquote.\
	-c\
	-fpch-deps\
	-MMD -MV\

AR=vsisnarl

OBJS=\
	"PS3_Debug/adler32.obj"\
	"PS3_Debug/compress.obj"\
	"PS3_Debug/crc32.obj"\
	"PS3_Debug/deflate.obj"\
	"PS3_Debug/gzio.obj"\
	"PS3_Debug/infback.obj"\
	"PS3_Debug/inffast.obj"\
	"PS3_Debug/inflate.obj"\
	"PS3_Debug/inftrees.obj"\
	"PS3_Debug/trees.obj"\
	"PS3_Debug/uncompr.obj"\
	"PS3_Debug/zutil.obj"\

CST_OBJS=\

CST_OUTS=\

CUSTOM: $(CST_OUTS) $(CST_OBJS)

COMPILE: $(OBJS)

"PS3_Debug/adler32.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/adler32.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/adler32.c" -o $@

"PS3_Debug/compress.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/compress.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/compress.c" -o $@

"PS3_Debug/crc32.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/crc32.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/crc32.c" -o $@

"PS3_Debug/deflate.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/deflate.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/deflate.c" -o $@

"PS3_Debug/gzio.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/gzio.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/gzio.c" -o $@

"PS3_Debug/infback.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/infback.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/infback.c" -o $@

"PS3_Debug/inffast.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/inffast.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/inffast.c" -o $@

"PS3_Debug/inflate.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/inflate.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/inflate.c" -o $@

"PS3_Debug/inftrees.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/inftrees.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/inftrees.c" -o $@

"PS3_Debug/trees.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/trees.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/trees.c" -o $@

"PS3_Debug/uncompr.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/uncompr.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/uncompr.c" -o $@

"PS3_Debug/zutil.obj":
	@echo ProDG Compiling "e:/GLF/libs/zlib/src/zutil.c"
	$(CC) $(CC_FLAGS) "e:/GLF/libs/zlib/src/zutil.c" -o $@

LIB: "../../lib/msvc2005/PS3_Debug/zlib_d.lib"

"../../lib/msvc2005/PS3_Debug/zlib_d.lib" : $(CST_OBJS) $(OBJS)
	@echo ProDG Creating Library $@
	$(AR) -M <"$(INTDIR)/zlib_lib.txt"

