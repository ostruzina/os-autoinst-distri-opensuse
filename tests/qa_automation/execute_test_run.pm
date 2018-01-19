# SUSE's openQA tests
#
# Copyright © 2017 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
# Summary:  to execute testsuites in openQA from QA:Head by running its build up test run script
# Maintainer: Yong Sun  <yosun@suse.com>

use strict;
use File::Basename;
use IO::File;
use Data::Dumper;
use utils;
use testapi;
use ctcs2_to_junit;
use upload_system_log;
use base "opensusebasetest";

sub run {
    my $timeout   = get_var("MAX_JOB_TIME", 7200);
    my $test      = get_var("QA_TESTSUITE") . get_var("QA_VERSION");
    my $runfile   = "/usr/share/qa/tools/test_$test-run";
    my $run_exist = script_run("ls $runfile | wc -l");
    unless ($run_exist eq "1") {
        $runfile = "/usr/lib/ctcs2/tools/test_$test-run";
    }
    my $run_log = "/tmp/$test-run.log";

    #execute test run
    script_run("/usr/share/qa/tools/test_$test-run |tee $run_log", $timeout);

    save_screenshot;

    #output result to serial0 and upload test log
    if (get_var("QA_TESTSUITE")) {
        my $test_log = script_output("ls /var/log/qa/ctcs2/");
        my $tarball  = "/tmp/$test_log.tar.bz2";
        assert_script_run("tar cjf $tarball -C /var/log/qa/ctcs2 $test_log");
        upload_logs($tarball, timeout => 600);

        #convert to junit log
        my $script_output = script_output("cat $run_log");
        my $tc_result     = analyzeResult($script_output);
        my $xml_result    = generateXML($tc_result);
        script_output "echo \'$xml_result\' > /tmp/output.xml", 7200;
        parse_junit_log("/tmp/output.xml");
    }

    #upload system log
    upload_system_logs();

    #assert test result
    assert_script_run("grep 'Test run completed successfully' $run_log");
}

1;
