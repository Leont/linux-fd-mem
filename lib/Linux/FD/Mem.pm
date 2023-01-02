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

=method seal(@flags)

This is used to add a seal to the filehandle. Allowed values are:

=over 4

=item * C<"seal">

If this is set, no further seals can be added to the filehandle.

=item * C<"shrink">

If this is set the file in question cannot be reduced in size.

=item * C<"grow">

If this is set the size of the file in question cannot be increased.

=item * C<"write">

If this is set you cannot modify the contents of the file. Note that shrinking or growing the size of the file is still possible and allowed, thus this seal is normally used in combination with one of the other seals.

Adding this seal will fail if any writable, shared mapping exists.

=item * C<"future-write">

This seal is similar to C<"write"> but will allow modification via previously existing writable memory maps. It will not allow new such maps to be created.

Using this seal one process can create a memory buffer that it can continue to modify while sharing that buffer on a read-only basis with other processes. This requires Linux 5.1.

=back

=method get_seals()

This returns all the seals on the filehandle.

=cut
