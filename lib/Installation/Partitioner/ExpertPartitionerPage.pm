# SUSE's openQA tests
#
# Copyright © 2019 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

# Summary: The class introduces all accessing methods for Expert Partitioner
# Page, that are common for all the versions of the page (e.g. for both
# Libstorage and Libstorage-NG).
# Maintainer: Oleksandr Orlov <oorlov@suse.de>

package Installation::Partitioner::ExpertPartitionerPage;
use strict;
use warnings;
use testapi;
use parent 'Installation::WizardPage';

use constant {
    EXPERT_PARTITIONER_PAGE    => 'expert-partitioner',
    SELECTED_HARD_DISK         => 'partitioning_raid-disk_%s-selected',
    SELECTED_RAID              => 'partitioning_raid-raid-selected',
    SELECTED_VOLUME_MANAGEMENT => 'volume_management_feature',
    SELECTED_HARD_DISKS        => 'partitioning_raid-hard_disks-selected'
};

sub new {
    my ($class, $args) = @_;
    my $self = bless {
        add_raid_shortcut      => $args->{add_raid_shortcut},
        add_partition_shortcut => $args->{add_partition_shortcut}
    }, $class;
}

sub _select_system_view_section {
    send_key('alt-s');
}

sub select_item_in_system_view_table {
    my ($self, $item) = @_;
    assert_screen(EXPERT_PARTITIONER_PAGE);
    _select_system_view_section();
 # TODO: Replace if-else by renaming needle tags using single naming pattern (like for hard disks selection). The conditions were added as a temporary solution.
    if ($item eq 'raid') {
        send_key_until_needlematch(SELECTED_RAID, 'down');
    }
    elsif ($item eq 'volume-management') {
        send_key_until_needlematch(SELECTED_VOLUME_MANAGEMENT, 'down');
    }
    elsif ($item eq 'hard-disks') {
        send_key_until_needlematch(SELECTED_HARD_DISKS, 'down');
    }
    else {
        send_key_until_needlematch((sprintf SELECTED_HARD_DISK, $item), "down");
    }
}

sub expand_item_in_system_view_table {
    my ($self, $item) = @_;
    assert_screen(EXPERT_PARTITIONER_PAGE);
    send_key('right');
}

sub select_partitions_tab {
    assert_screen(EXPERT_PARTITIONER_PAGE);
    send_key('alt-p');
}

sub press_add_raid_button {
    my ($self) = @_;
    assert_screen(EXPERT_PARTITIONER_PAGE);
    send_key($self->{add_raid_shortcut});
}

sub press_add_partition_button {
    my ($self) = @_;
    assert_screen(EXPERT_PARTITIONER_PAGE);
    send_key($self->{add_partition_shortcut});
}

sub press_accept_button {
    wait_still_screen;
    assert_screen(EXPERT_PARTITIONER_PAGE);
    send_key('alt-a');
}

1;
