#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <sys/mman.h>
#include <sys/syscall.h>
#include <linux/memfd.h>

#define die_sys(format) Perl_croak(aTHX_ format, strerror(errno))

static SV* S_io_fdopen(pTHX_ int fd, const char* classname, char type) {
	PerlIO* pio = PerlIO_fdopen(fd, "r");
	GV* gv = newGVgen(classname ? classname : "Linux::FD::Mem");
	SV* ret = newRV_noinc((SV*)gv);
	IO* io = GvIOn(gv);
	IoTYPE(io) = type;
	IoIFP(io) = pio;
	IoOFP(io) = pio;
	if (classname) {
		HV* stash = gv_stashpv(classname, FALSE);
		sv_bless(ret, stash);
	}
	return ret;
}
#define io_fdopen(fd, classname, type) S_io_fdopen(aTHX_ fd, classname, type)

typedef struct { const char* key; size_t length; int value; } map[];

static const map mem_flags = {
	{ STR_WITH_LEN("allow-sealing"), MFD_ALLOW_SEALING },
#ifdef MFD_HUGETLB
	{ STR_WITH_LEN("huge-table"), MFD_HUGETLB },
	{ STR_WITH_LEN("huge-2mb"), MFD_HUGE_2MB },
	{ STR_WITH_LEN("huge-1gb"), MFD_HUGE_1GB },
#endif
};

static UV S_get_mem_flag(pTHX_ SV* flag_name) {
	int i;
	for (i = 0; i < sizeof mem_flags / sizeof *mem_flags; ++i)
		if (strEQ(SvPV_nolen(flag_name), mem_flags[i].key))
			return mem_flags[i].value;
	Perl_croak(aTHX_ "No such flag '%s' known", SvPV_nolen(flag_name));
}
#define get_mem_flag(name) S_get_mem_flag(aTHX_ name)

MODULE = Linux::FD::Mem				PACKAGE = Linux::FD::Mem

SV*
new(classname, name, ...)
	const char* classname;
	const char* name;
	PREINIT:
	int memfd;
	int i, flags = MFD_CLOEXEC;
	CODE:
	for (i = 2; i < items; i++)
		flags |= get_mem_flag(ST(i));
	memfd = syscall(__NR_memfd_create, name, flags);
	if (memfd < 0)
		die_sys("Couldn't open memfd: %s");
	RETVAL = io_fdopen(memfd, classname, '+');
	OUTPUT:
		RETVAL

