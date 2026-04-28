/*
 * SPEED-CLIP-COSY
 * Cleaned Varian/VnmrJ pulse sequence for SPEED-encoded
 * phase-sensitive 1D CLIP-COSY experiments.
 */

#include <standard.h>
#include <chempack.h>

static int ph1[4]  = {0,0,0,0},   /* SPEED selective pulse phase */
           ph2[4]  = {0,0,2,2},   /* first hard 90 in first z-filter */
           ph3[4]  = {0,0,0,0},   /* first z-filter chirp */
           ph4[4]  = {0,2,0,2},   /* hard 90 before CLIP mixing */
           ph5[4]  = {1,1,1,1},   /* first hard 180 in CLIP mixing */
           ph6[4]  = {1,1,1,1},   /* central hard 90 in CLIP mixing */
           ph7[4]  = {3,3,3,3},   /* second hard 180 in CLIP mixing */
           ph8[4]  = {0,0,2,2},   /* hard 90 before second z-filter */
           ph9[4]  = {0,0,0,0},   /* second z-filter chirp */
           ph10[4] = {0,2,0,2},   /* final hard 90 */
           ph11[4] = {0,0,2,2};   /* receiver */

pulsesequence()
{
    double tpwr     = getval("tpwr"),
           pw       = getval("pw"),
           pw_sel   = getval("pw_sel"),
           pwr_sel  = getval("pwr_sel"),
           hsgt     = getval("hsgt"),
           hsglvl   = getval("hsglvl"),
           gt1      = getval("gt1"),
           gzlvl1   = getval("gzlvl1"),
           gt2      = getval("gt2"),
           gzlvl2   = getval("gzlvl2"),
           gt3      = getval("gt3"),
           gzlvlzq1 = getval("gzlvlzq1"),
           gzlvlzq2 = getval("gzlvlzq2"),
           gzlvlzq3 = getval("gzlvlzq3"),
           zqfpwr1  = getval("zqfpwr1"),
           zqfpwr2  = getval("zqfpwr2"),
           chirp1   = getval("chirp1"),
           chirp2   = getval("chirp2"),
           mixT     = getval("mixT"),
           gstab    = getval("gstab");

    char sspul[MAXSTR],
         satmode[MAXSTR],
         shp_sel[MAXSTR];

    getstr("sspul", sspul);
    getstr("satmode", satmode);
    getstr("shp_sel", shp_sel);

    settable(t1,  4, ph1);
    settable(t2,  4, ph2);
    settable(t3,  4, ph3);
    settable(t4,  4, ph4);
    settable(t5,  4, ph5);
    settable(t6,  4, ph6);
    settable(t7,  4, ph7);
    settable(t8,  4, ph8);
    settable(t9,  4, ph9);
    settable(t10, 4, ph10);
    settable(t11, 4, ph11);

    getelem(t1,  ct, v1);
    getelem(t2,  ct, v2);
    getelem(t3,  ct, v3);
    getelem(t4,  ct, v4);
    getelem(t5,  ct, v5);
    getelem(t6,  ct, v6);
    getelem(t7,  ct, v7);
    getelem(t8,  ct, v8);
    getelem(t9,  ct, v9);
    getelem(t10, ct, v10);
    getelem(t11, ct, oph);

    status(A);
    obsoffset(tof);
    obspower(tpwr);
    txphase(zero);

    if (sspul[0] == 'y')
    {
        zgradpulse(hsglvl, hsgt);
        delay(gstab);
        rgpulse(pw, zero, rof1, rof1);
        zgradpulse(hsglvl, hsgt);
        delay(gstab);
    }

    if (satmode[0] == 'y')
    {
        if ((d1 - satdly) > 0.02)
            delay(d1 - satdly);
        else
            delay(0.02);
        satpulse(satdly, zero, rof1, rof1);
    }
    else
    {
        delay(d1);
    }

    status(B);

    /* SPEED selective excitation module */
    obspower(tpwr);
    rgpulse(pw, zero, rof1, rof2);
    delay(50.0e-6);

    obspower(pwr_sel);
    zgradpulse(gzlvl2, gt2);
    shaped_pulse(shp_sel, pw_sel, v1, rof1, rof1);
    zgradpulse(gzlvl2, gt2);
    delay(50.0e-6);

    /* First z-filter */
    obspower(tpwr);
    rgpulse(pw, v2, rof1, rof1);
    obspower(zqfpwr1);
    delay(50.0e-6);
    zgradpulse(gzlvl1, gt1);
    rgradient('z', gzlvlzq1);
    shaped_pulse("wurst10000-30", chirp1, v3, rof1, rof2);
    rgradient('z', 0.0);
    zgradpulse(gzlvl1, gt1);
    delay(50.0e-6);

    obspower(tpwr);
    rgpulse(pw, v4, rof1, rof1);

    /* CLIP-COSY perfect-echo mixing block */
    delay(mixT/4.0);
    rgpulse(2.0*pw, v5, rof1, rof1);
    delay(mixT/4.0);
    rgpulse(pw, v6, rof1, rof1);
    delay(mixT/4.0);
    rgpulse(2.0*pw, v7, rof1, rof1);
    delay(mixT/4.0);

    /* Second z-filter */
    rgpulse(pw, v8, rof1, rof1);
    obspower(zqfpwr2);
    delay(50.0e-6);
    zgradpulse(gzlvl1, gt1);
    rgradient('z', gzlvlzq2);
    shaped_pulse("wurst10000-50", chirp2, v9, rof1, rof2);
    rgradient('z', 0.0);
    zgradpulse(gzlvl1, gt1);
    delay(50.0e-6);

    obspower(tpwr);
    zgradpulse(gzlvlzq3, gt3);
    delay(50.0e-6);
    rgpulse(pw, v10, rof1, rof2);

    status(C);
    startacq(getval("alfa"));
    sample(getval("at"));
    recoff();
    endacq();
}
