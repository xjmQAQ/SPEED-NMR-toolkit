/*
 * SPEED-NOESY
 * Cleaned Varian/VnmrJ pulse sequence for SPEED-encoded
 * phase-sensitive 1D NOESY experiments.
 */

#include <standard.h>
#include <chempack.h>

static int ph_presat[4] = {0,0,2,2},   /* presaturation phase */
           ph_noe1[4]   = {2,0,2,0},   /* first 90 after SPEED module */
           ph_zq[4]     = {0,0,0,0},   /* z-filter chirp */
           ph_noe2[4]   = {0,0,2,2},   /* final 90 */
           ph_rec[4]    = {0,2,2,0};   /* receiver */

pulsesequence()
{
    double mixN      = getval("mixN"),
           mixNcorr,
           pw_sel    = getval("pw_sel"),
           pwr_sel   = getval("pwr_sel"),
           gzlvl2    = getval("gzlvl2"),
           gt2       = getval("gt2"),
           gstab     = getval("gstab"),
           gzlvl1    = getval("gzlvl1"),
           gt1       = getval("gt1"),
           zqfpw1    = getval("zqfpw1"),
           zqfpwr1   = getval("zqfpwr1"),
           gzlvlzq1  = getval("gzlvlzq1");

    char satmode[MAXSTR],
         wet[MAXSTR],
         sspul[MAXSTR],
         shp_sel[MAXSTR],
         zqfpat1[MAXSTR];

    getstr("satmode", satmode);
    getstr("wet", wet);
    getstr("sspul", sspul);
    getstr("shp_sel", shp_sel);
    getstr("zqfpat1", zqfpat1);

    settable(t1, 4, ph_presat);
    settable(t2, 4, ph_noe1);
    settable(t3, 4, ph_zq);
    settable(t4, 4, ph_noe2);
    settable(t5, 4, ph_rec);

    getelem(t1, ct, v6);
    getelem(t2, ct, v2);
    getelem(t3, ct, v3);
    getelem(t4, ct, v4);
    getelem(t5, ct, oph);

    mixNcorr = 0.0;
    if (satmode[1] == 'y')
        mixNcorr += satdly;
    if (getflag("Gzqfilt"))
        mixNcorr += zqfpw1 + 2.0*gstab + gt1;
    if (wet[1] == 'y')
        mixNcorr += 4.0*(getval("pwwet") + getval("gtw") + getval("gswet"));

    if (mixNcorr > mixN)
        mixN = mixNcorr;

    status(A);
    obsoffset(tof);
    obspower(tpwr);
    txphase(zero);

    if (sspul[0] == 'y')
        steadystate();

    if (satmode[0] == 'y')
    {
        if ((d1 - satdly) > 0.02)
            delay(d1 - satdly);
        else
            delay(0.02);
        satpulse(satdly, v6, rof1, rof1);
    }
    else
    {
        delay(d1);
    }

    if (wet[0] == 'y')
        wet4(zero, one);

    status(B);

    /* SPEED selective excitation module */
    obspower(tpwr);
    rgpulse(pw, zero, rof1, 2.0e-6);
    delay(50.0e-6);

    obspower(pwr_sel);
    zgradpulse(gzlvl2, gt2);
    delay(gstab);
    shaped_pulse(shp_sel, pw_sel, zero, rof1, rof1);
    zgradpulse(gzlvl2, gt2);
    delay(gstab);

    /* Phase-sensitive NOESY transfer module */
    obspower(tpwr);
    rgpulse(pw, v2, rof1, rof1);

    if (satmode[1] == 'y')
        satpulse((mixN - mixNcorr), v6, rof1, rof1);
    else
        delay(mixN - mixNcorr);

    if (wet[1] == 'y')
        wet4(zero, one);

    if (getflag("Gzqfilt"))
    {
        obspower(zqfpwr1);
        rgradient('z', gzlvlzq1);
        shaped_pulse(zqfpat1, zqfpw1, v3, rof1, rof2);
        rgradient('z', 0.0);
        delay(gstab);
        zgradpulse(gzlvl1, gt1);
        delay(gstab);
    }

    obspower(tpwr);
    rgpulse(pw, v4, rof1, rof2);

    status(C);
    startacq(getval("alfa"));
    sample(getval("at"));
    recoff();
    endacq();
}
