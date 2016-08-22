package Git::Database::Role::ObjectReader;

use Git::Database::Object::Blob;
use Git::Database::Object::Tree;
use Git::Database::Object::Commit;
use Git::Database::Object::Tag;

use Moo::Role;

requires
  'get_object_meta',
  'get_object_attributes',
  'all_digests',
  ;

sub has_object {
    my ( $self, $digest ) = @_;
    my ( $sha1, $kind, $size ) = $self->get_object_meta($digest);
    return $kind eq 'missing' ? '' : $kind;
}

my %kind2class = (
    blob   => 'Git::Database::Object::Blob',
    tree   => 'Git::Database::Object::Tree',
    commit => 'Git::Database::Object::Commit',
    tag    => 'Git::Database::Object::Tag',
);

sub get_object {
    my ( $self, $digest ) = @_;
    my $attr = $self->get_object_attributes($digest);
    return $attr
      && $kind2class{ $attr->{kind} }->new( %$attr, backend => $self );
}

1;

__END__

=pod

=head1 NAME

Git::Database::Role::ObjectReader - Abstract role for a Git database backend

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 has_object

    # assuming 4b825dc642cb6eb9a060e54bf8d69288fbee4904 (the empty tree)
    # is in the database and 123456 is not

    $kind = $backend->has_object('4b825dc642cb6eb9a060e54bf8d69288fbee4904');  # true ('tree')
    $kind = $backend->has_object('4b825d');    # also true ('tree')
    $kind = $backend->has_object('123456');    # false ('')

Given a digest value (possibly abbreviated), C<has_object> returns a
boolean indicating if the corresponding object is in the database.

As a convenience, if the object exists in the Git database, the true
value that is returned is its "kind".

=head2 get_object

    # a Git::Database::Object::Tree representing the empty tree
    $tree = $r->get_object('4b825dc642cb6eb9a060e54bf8d69288fbee4904');
    $tree = $r->get_object('4b825d');    # idem

    # undef
    $tree = $r->get_object('123456');

Given a digest value (possibly abbreviated), C<get_object>
returns the full object extracted from the Git database (one of
L<Git::Database::Object::Blob>, L<Git::Database::Object::Tree>,
L<Git::Database::Object::Commit>, or L<Git::Database::Object::Tag>).

Returns C<undef> if the object is not in the Git database.

=head1 REQUIRED METHODS

=head2 get_object_meta

    # ( '4b825dc642cb6eb9a060e54bf8d69288fbee4904', 'tree', 0 );
    ( $digest, $kind, $size ) = $backend->get_object_meta('4b825d');

    # ( '123456', 'missing', undef )
    ( $digest, $kind, $size ) = $backend->get_object_meta('123456');

Given a digest value (possibly abbreviated), return a list containing
the complete digest, the object type and its size (if the requested
object is in the database).

Otherwise it returns the requested C<$digest>, the string C<missing>
and the C<undef> value.

=head2 get_object_attributes

    # {
    #     kind    => 'tree',
    #     size    => 0,
    #     content => '',
    #     digest  => '4b825dc642cb6eb9a060e54bf8d69288fbee4904',
    # }
    my $attr = $backend->get_object_attributes('4b825d');

    # undef
    my $attr = $backend->get_object_attributes('123456');

Given a digest value (possibly abbreviated), return a hash reference with
all the attributes needed to create a new object (if the requested object
is in the database). This method is typically used by L</get_object>
to create the actual object instance.

Otherwise return the C<undef> value.

=head2 all_digests

    # all the digests contained in the Git database
    my @sha1 = $backend->all_digests();

    # filter by kind
    my @trees = $backend->all_digests('tree');

Return all the digests contained in the Git object database.
If a L<kind|Git::Database::Role::Object/kind> argument is provided,
only return the digests for that specific object kind.

=head1 COPYRIGHT

Copyright 2016 Philippe Bruhat (BooK), all rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
