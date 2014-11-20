# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::ExtTestNew;
use strict;
use base qw(Bugzilla::Extension);

# This code for this is in ./extensions/ExtTestNew/lib/Util.pm
use Bugzilla::Extension::ExtTestNew::Util;
use Data::Dumper;

our $VERSION = '0.01';

# See the documentation of Bugzilla::Hook ("perldoc Bugzilla::Hook" 
# in the bugzilla directory) for a list of all available hooks.
sub db_schema_abstract_schema {
    my ($self, $args) = @_;
    my $schema = $args->{'schema'};
    my $tab_1 = {
        FIELDS => [
            id                  => {TYPE => 'MEDIUMSERIAL', NOTNULL => 1,
                                    PRIMARYKEY => 1},
            value               => {TYPE => 'varchar(64)', NOTNULL => 1}
        ]
    };
    my $tab_2 = {
        FIELDS => [
            id                  => {TYPE => 'SMALLSERIAL', NOTNULL => 1,
                                    PRIMARYKEY => 1},
            value               => {TYPE => 'varchar(64)', NOTNULL => 1},
            tab_1_id            => {TYPE => 'INT3', NOTNULL => 1,
                                    REFERENCES => {TABLE  => 'tab_1',
                                                   COLUMN => 'id',
                                                   DELETE => 'CASCADE'}}
        ],
        INDEXES => [
            tab_1_id_idx => {TYPE => 'UNIQUE', FIELDS => ['tab_1_id']}
        ]
    };

    $schema->{'tab_1'} = $tab_1;
    $schema->{'tab_2'} = $tab_2;
}

sub install_update_db {
    my $dbh = Bugzilla->dbh();

    if ($dbh->bz_column_info('tab_1', 'id')->{TYPE} ne 'MEDIUMSERIAL') {
	print("Updating tab_1::id column type\n");
	$dbh->bz_drop_related_fks('tab_1', 'id');
	$dbh->bz_alter_column('tab_1', 'id', {TYPE => 'MEDIUMSERIAL',
					      NOTNULL => 1,
					      PRIMARYKEY => 1});
	$dbh->bz_alter_column('tab_2', 'tab_1_id', {TYPE => 'INT3', NOTNULL => 1,
						    REFERENCES => {TABLE  => 'tab_1',
								   COLUMN => 'id',
								   DELETE => 'CASCADE'}});
    }
}

sub install_before_final_checks {
    my ($self, $args) = @_;
    my $silent = $args->{'silent'};

    return if $silent;

    my $dbh = Bugzilla->dbh();
    my $table = 'tab_2';
    my $column = 'tab_1_id';
    my $info = $dbh->bz_column_info($table, $column);

    local $Data::Dumper::Purity = 1;
    local $Data::Dumper::Deepcopy = 1;
    local $Data::Dumper::Terse = 0;
    local $Data::Dumper::Sortkeys = 1;

    print "bz_column_info of $table::$column:\n" . Dumper($info) . "\n";

    my $rows = $dbh->selectall_arrayref("SHOW COLUMNS FROM $table WHERE Field = '$column'");

    print "show columns of $table::$column:\n" . Dumper($rows) . "\n";
}

__PACKAGE__->NAME;
