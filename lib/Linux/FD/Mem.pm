package Linux::FD::Mem;

use strict;
use warnings;

use XSLoader;

XSLoader::load(__PACKAGE__, __PACKAGE__->VERSION);

1;

# ABSTRACT: memory file descriptors

=head1 SYNOPSIS

 use Linux::FD::Mem
 
 my $fh = Linux::FD::Mem->new();

=method new($name, @flags)

This creates an anonymous file and returns a file descriptor that refers to it. The file behaves like a regular file, and so can be modified, truncated, memory-mapped, and so on. However, unlike a regular file, it lives in RAM and has a volatile backing storage. Once all references to the file are dropped, it is automatically released. Anonymous memory is used for all backing pages of the file. Therefore, files created by this module have the same semantics as other anonymous memory allocations such as those allocated using L<File::Map|File::Map>'s C<map_anonymous>.

The name supplied in C<$name> is used as a filename and will be displayed as the target of the corresponding symbolic link in the directory /proc/self/fd/. The displayed name is always prefixed with memfd: and serves only for debugging purposes. Names do not affect the behavior of the file descriptor, and as such multiple files can have the same name without any side effects.

C<@flags> is an optional list of flags. It allows one of the following two values:

=over 4

=item * C<"allow-sealing">

This is used to allow sealing the filehandle.

=item * C<"huge-table">

to allow huge table support. If C<"huge-table"> is given one can also pass either C<"huge-2mb"> or C<"huge-1gb"> to explicitly set the page size.

=back

=cut
