#------------------------------------------------------------------------------------------------------------------------
#-- POWERLINK check IP-Core Revision script
#--
#--       Copyright (C) 2011 B&R
#--
#--    Redistribution and use in source and binary forms, with or without
#--    modification, are permitted provided that the following conditions
#--    are met:
#--
#--    1. Redistributions of source code must retain the above copyright
#--       notice, this list of conditions and the following disclaimer.
#--
#--    2. Redistributions in binary form must reproduce the above copyright
#--       notice, this list of conditions and the following disclaimer in the
#--       documentation and/or other materials provided with the distribution.
#--
#--    3. Neither the name of B&R nor the names of its
#--       contributors may be used to endorse or promote products derived
#--       from this software without prior written permission. For written
#--       permission, please contact office@br-automation.com
#--
#--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#--    POSSIBILITY OF SUCH DAMAGE.
#--
#------------------------------------------------------------------------------------------------------------------------
#-- Version History
#------------------------------------------------------------------------------------------------------------------------
#-- 2012-08-09    V0.01    mairt    initial version
#------------------------------------------------------------------------------------------------------------------------

use Getopt::Long;    # for getopt

$IP_REV_DEFINE_AXI = "XPAR_AXI_POWERLINK_0_PLK_CORE_REV";
$IP_REV_DEFINE_PLB = "XPAR_PLB_POWERLINK_0_PLK_CORE_REV";

################################
# F U N C T I O N S
################################

#Define USAGE of script
sub usage
{
    print "usage:\n
        check_ip_rev.pl [--help] --format 'PATH/xparameters.h' --iprev 'revision'\n
        --help   = print this help page\n

        --xparameters = Path to xparameters.h\n

        --iprev  = IP-Core revsision to compare with\n";
}

################################
# M A I N
################################

# check arguments
#-- prints usage if no command line parameters are passed or there is an unknown
#   parameter or help option is passed
if ( @ARGV < 1 or
     !GetOptions('help|?' => \$help, 'xparameters=s' => \$xparameters, 'iprev=s' => \$iprev, )
     or defined $help )
{
    usage();
    exit -1;
}

if ($xparameters eq "")
{
    print "ERROR: No --xparameters parameter provided!\n";
    usage();
    exit -1;
} elsif ($iprev eq "")
{
    print "ERROR: No --iprev parameter provided!\n";
    usage();
    exit;
}

$comment_found = 0;

# open xparameters.h
open (XPARAM, '<', $xparameters) || die "Cannot open xparameters.h file $xparameters: $!";

while (<XPARAM>)
{
    if (($_ =~ /^\#define\ $IP_REV_DEFINE_AXI/) || ($_ =~ /^\#define\ $IP_REV_DEFINE_PLB/))
    {
        $comment_found = 1;

        $xparam_ip_rev = $_;

        @xparam_ip_rev = split (/ /, $xparam_ip_rev);

        $xparam_ip_rev = @xparam_ip_rev[2];

        chomp($xparam_ip_rev);

        # compare the two revisions
        if($xparam_ip_rev ne "$iprev")
        {
            print STDERR "ERROR: POWERLINK IP-core version not compliant to PCP software!
Expected: $iprev
Current:  $xparam_ip_rev
Update your POWERLINK IP-Core search path in XPS or the POWERLINK IP-core source files!\n";
            $return = -1;
        } else {
            $return = 0;
        }
    }
}

if ($comment_found == 0)
{
    print STDERR "ERROR: IP Revision define was not found in xparameters.h!\n";
    $return = -1;
}

# close open files
close (XPARAM) || die "Cannot close file $xparameters: $!";

# terminate
exit $return;

