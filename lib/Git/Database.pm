package Git::Database;

use Sub::Quote;
use Module::Runtime qw( use_module );

use Moo;
use namespace::clean;

has backend => (
    is       => 'ro',
    required => 1,
    default  => sub { use_module('Git::Database::Backend::None')->new; },
    isa      => sub {
        die "$_[0] DOES not Git::Database::Role::Backend"
          if !eval { $_[0]->does('Git::Database::Role::Backend') };
    },
    handles => [
        'hash_object',        # Git::Database::Role::Backend
        'get_object_meta',    # Git::Database::Role::ObjectReader
        'get_object_attributes',
        'get_object',
        'get_hashes',
        'has_object',
        'put_object',         # Git::Database::Role::ObjectWriter
        'resolve_ref',        # Git::Database::Role::RefReader
        'get_refs',
        'put_ref',            # Git::Database::Role::RefWriter
        'delete_ref'
    ],
);

1;

__END__

=pod

=head1 NAME

Git::Database - Provide access to the Git object database

=head1 SYNOPSIS

=head1 DESCRIPTION

Git::Database provides access from Perl to the object database stored
in a Git repository. It can use any supported Git wrapper to access
the Git object database maintained by Git.

=head1 ATTRIBUTES

=head2 backend

A object doing the L<Git::Database::Role::Backend> role, used to access
the data in the Git repository.

If none is provided, defaults to using the very limited
L<Git::Database::Backend::None>.

=head1 METHODS

All the backend methods are delegated to the L</backend> attribute.

The backend methods are split between several roles, and not all backends
do all the roles. Therefore not all backend objects support all these
methods.

=head2 From L<Git::Database::Role::Backend>

This is the minimum required role to be a backend. Hence this method is
always available.

=over 4

=item L<hash_object|Git::Database::Role::Backend/hash_object>

=back

=head2 From L<Git::Database::Role::ObjectReader>

=over 4

=item L<get_object_meta|Git::Database::Role::ObjectReader/get_object_meta>

=item L<get_object_attributes|Git::Database::Role::ObjectReader/get_object_attributes>

=item L<get_object|Git::Database::Role::ObjectReader/get_object>

=item L<get_hashes|Git::Database::Role::ObjectReader/get_hashes>

=back

=head2 From L<Git::Database::Role::ObjectWriter>

=over 4

=item L<put_object|Git::Database::Role::ObjectWriter/put_object>

=back

=head2 From L<Git::Database::Role::RefReader>

=over 4

=item L<resolve_ref|Git::Database::Role::RefReader/resolve_ref>

=item L<get_refs|Git::Database::Role::RefReader/get_refs>

=back

=head2 From L<Git::Database::Role::RefWriter>

=over 4

=item L<put_ref|Git::Database::Role::RefWriter/put_ref>

=item L<delete_ref|Git::Database::Role::RefWriter/delete_ref>

=back

=head1 SEE ALSO

L<Git::Database::Object::Blob>,
L<Git::Database::Object::Tree>,
L<Git::Database::Object::Commit>,
L<Git::Database::Object::Tag>,
L<Git::Database::Role::Backend>,
L<Git::Database::Role::ObjectReader>.
L<Git::Database::Role::ObjectWriter>.
L<Git::Database::Role::RefReader>.
L<Git::Database::Role::RefWriter>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Git::Database

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Git-Database>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Git-Database>

=item * Search CPAN

L<http://search.cpan.org/dist/Git-Database>

=item * MetaCPAN

L<http://metacpan.org/release/Git-Database>

=back

=head1 COPYRIGHT

Copyright 2013-2016 Philippe Bruhat (BooK), all rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
