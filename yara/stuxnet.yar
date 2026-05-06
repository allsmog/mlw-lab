/*
 * Starter YARA rules for Stuxnet analysis.
 *
 * These are illustrative rules suitable for academic detection. Tighten
 * them with bytes you confirm against your own sample. Public IOCs are
 * derived from the Symantec dossier (Falliere/Murchu/Chien, 2011) and
 * ESET's "Stuxnet Under the Microscope" (Matrosov et al.).
 *
 * Test:   yara -r yara/stuxnet.yar samples/
 */

import "pe"
import "hash"

private rule IsPE {
    condition:
        uint16(0) == 0x5A4D and
        uint32(uint32(0x3C)) == 0x00004550
}

rule Stuxnet_Dropped_Filename_Strings
{
    meta:
        author      = "school project"
        description = "Filenames Stuxnet drops or hides on disk"
        reference   = "Symantec W32.Stuxnet Dossier, Appendix A"
    strings:
        $a = "~WTR4132.tmp" ascii wide nocase
        $b = "~WTR4141.tmp" ascii wide nocase
        $c = "mrxnet.sys"   ascii wide nocase
        $d = "mrxcls.sys"   ascii wide nocase
        $e = "oem7A.PNF"    ascii wide nocase
        $f = "mdmcpq3.PNF"  ascii wide nocase
        $g = "mdmeric3.PNF" ascii wide nocase
    condition:
        2 of them
}

rule Stuxnet_Step7_DLL_Hijack
{
    meta:
        description = "Indicators of the s7otbxdx.dll hijack"
        reference   = "Langner; Symantec dossier"
    strings:
        $orig    = "s7otbxsx.dll" ascii wide nocase     // renamed-original
        $hijack  = "s7otbxdx.dll" ascii wide nocase     // hijacker name
        $exp1    = "s7blk_read"   ascii
        $exp2    = "s7blk_write"  ascii
        $exp3    = "s7db_open"    ascii
    condition:
        $orig and $hijack and 2 of ($exp*)
}

rule Stuxnet_AV_Process_Allowlist
{
    meta:
        description = "AV process names Stuxnet checks for"
    strings:
        $a = "avp.exe"        ascii nocase
        $b = "mcshield.exe"   ascii nocase
        $c = "rtvscan.exe"    ascii nocase
        $d = "ccsvchst.exe"   ascii nocase
        $e = "tmpreview.exe"  ascii nocase
        $f = "egui.exe"       ascii nocase
    condition:
        4 of them
}

rule Stuxnet_LNK_Loader
{
    meta:
        description = "Heuristic for the Stuxnet LNK exploit (CVE-2010-2568)"
        reference   = "MSRC MS10-046"
    strings:
        // Shell IDList pattern that controls icon loading.
        $shellcode_marker = { 14 00 1F 50 E0 4F D0 20 EA 3A 69 10 A2 D8 08 00 2B 30 30 9D }
        $tmp_loader1      = "~WTR4132.tmp" ascii wide nocase
        $tmp_loader2      = "~WTR4141.tmp" ascii wide nocase
    condition:
        $shellcode_marker or any of ($tmp_loader*)
}

rule Stuxnet_Driver_Realtek_Cert
{
    meta:
        description = "PE signed by the (revoked) Realtek code-signing cert used by Stuxnet drivers"
        reference   = "Verisign revocation 2010-07-16"
    condition:
        IsPE and
        pe.number_of_signatures > 0 and
        for any sig in pe.signatures : (
            sig.subject contains "Realtek Semiconductor"
        )
}

rule Stuxnet_Driver_JMicron_Cert
{
    meta:
        description = "PE signed by the (revoked) JMicron cert used in later Stuxnet drivers"
    condition:
        IsPE and
        pe.number_of_signatures > 0 and
        for any sig in pe.signatures : (
            sig.subject contains "JMicron Technology"
        )
}

rule Stuxnet_Combined_Heuristic
{
    meta:
        description = "Triggers when several Stuxnet indicators co-occur"
    condition:
        IsPE and (
            (Stuxnet_Dropped_Filename_Strings and Stuxnet_AV_Process_Allowlist) or
            (Stuxnet_Step7_DLL_Hijack)        or
            (Stuxnet_Driver_Realtek_Cert)     or
            (Stuxnet_Driver_JMicron_Cert)
        )
}
