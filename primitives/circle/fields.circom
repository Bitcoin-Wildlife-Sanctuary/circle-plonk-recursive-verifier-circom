pragma circom 2.0.0;

template m31_inv() {
    signal input in;
    signal output out;

    signal inv;
    inv <-- 1 / in;
    inv * in === 1;

    out <== inv;
}

template m31_select() {
    signal input x0;
    signal input x1;

    signal input bit;

    signal output out;

    signal t1 <== bit * (x1 - x0);
    out <== t1 + x0;
}

template m31_swap() {
    signal input x0;
    signal input x1;

    signal input bit;

    signal output out0;
    signal output out1;

    component select_x0 = m31_select();
    select_x0.x0 <== x0;
    select_x0.x1 <== x1;
    select_x0.bit <== bit;

    out0 <== select_x0.out;
    out1 <== x0 + x1 - out0;
}

template cm31_add() {
    signal input a[2];
    signal input b[2];
    signal output out[2];

    out[0] <== a[0] + b[0];
    out[1] <== a[1] + b[1];
}

template cm31_add_m31() {
    signal input a[2];
    signal input b;
    signal output out[2];

    out[0] <== a[0] + b;
    out[1] <== a[1];
}

template cm31_sub() {
    signal input a[2];
    signal input b[2];
    signal output out[2];

    out[0] <== a[0] - b[0];
    out[1] <== a[1] - b[1];
}

template cm31_mul() {
    signal input a[2];
    signal input b[2];
    signal output out[2];

    signal t1;
    t1 <== a[0] * b[0];

    signal t2;
    t2 <== a[1] * b[1];

    signal t3;
    t3 <== a[0] * b[1];

    signal t4;
    t4 <== a[1] * b[0];

    out[0] <== t1 - t2;
    out[1] <== t3 + t4;
}

template cm31_mul_m31() {
    signal input a[2];
    signal input b;

    signal output out[2];

    for(var i = 0; i < 2; i++) {
        out[i] <== a[i] * b;
    }
}

template cm31_inv() {
    signal input a[2];
    signal output out[2];

    signal t1;
    t1 <== a[0] * a[0];

    signal t2;
    t2 <== a[1] * a[1];

    signal t3;
    t3 <== t1 + t2;

    component inv = m31_inv();
    inv.in <== t3;

    out[0] <== a[0] * inv.out;
    out[1] <== -a[1] * inv.out;
}

template cm31_shift_by_i() {
    signal input a[2];
    signal output out[2];

    out[0] <== -a[1];
    out[1] <== a[0];
}

template cm31_select() {
    signal input x0[2];
    signal input x1[2];

    signal input bit;

    signal output out[2];

    component select_real = m31_select();
    select_real.x0 <== x0[0];
    select_real.x1 <== x1[0];
    select_real.bit <== bit;
    out[0] <== select_real.out;

    component select_imag = m31_select();
    select_imag.x0 <== x0[1];
    select_imag.x1 <== x1[1];
    select_imag.bit <== bit;
    out[1] <== select_imag.out;
}

template cm31_swap() {
    signal input x0[2];
    signal input x1[2];

    signal input bit;

    signal output out0[2];
    signal output out1[2];

    component swap_real = m31_swap();
    swap_real.x0 <== x0[0];
    swap_real.x1 <== x1[0];
    swap_real.bit <== bit;
    out0[0] <== swap_real.out0;
    out1[0] <== swap_real.out1;

    component swap_imag = m31_swap();
    swap_imag.x0 <== x0[1];
    swap_imag.x1 <== x1[1];
    swap_imag.bit <== bit;
    out0[1] <== swap_imag.out0;
    out1[1] <== swap_imag.out1;
}

template qm31_add() {
    signal input a[4];
    signal input b[4];
    signal output out[4];

    component cm1 = cm31_add();
    cm1.a[0] <== a[0];
    cm1.a[1] <== a[1];
    cm1.b[0] <== b[0];
    cm1.b[1] <== b[1];
    out[0] <== cm1.out[0];
    out[1] <== cm1.out[1];

    component cm2 = cm31_add();
    cm2.a[0] <== a[2];
    cm2.a[1] <== a[3];
    cm2.b[0] <== b[2];
    cm2.b[1] <== b[3];
    out[2] <== cm2.out[0];
    out[3] <== cm2.out[1];
}

template qm31_add_cm31() {
    signal input a[4];
    signal input b[2];
    signal output out[4];

    component cm1 = cm31_add();
    cm1.a[0] <== a[0];
    cm1.a[1] <== a[1];
    cm1.b[0] <== b[0];
    cm1.b[1] <== b[1];
    out[0] <== cm1.out[0];
    out[1] <== cm1.out[1];

    out[2] <== a[2];
    out[3] <== a[3];
}

template qm31_sub() {
    signal input a[4];
    signal input b[4];
    signal output out[4];

    component cm1 = cm31_sub();
    cm1.a[0] <== a[0];
    cm1.a[1] <== a[1];
    cm1.b[0] <== b[0];
    cm1.b[1] <== b[1];
    out[0] <== cm1.out[0];
    out[1] <== cm1.out[1];

    component cm2 = cm31_sub();
    cm2.a[0] <== a[2];
    cm2.a[1] <== a[3];
    cm2.b[0] <== b[2];
    cm2.b[1] <== b[3];
    out[2] <== cm2.out[0];
    out[3] <== cm2.out[1];
}

template qm31_mul() {
    signal input a[4];
    signal input b[4];
    signal output out[4];

    signal a0b0[2];
    component cm1 = cm31_mul();
    cm1.a[0] <== a[0];
    cm1.a[1] <== a[1];
    cm1.b[0] <== b[0];
    cm1.b[1] <== b[1];
    a0b0[0] <== cm1.out[0];
    a0b0[1] <== cm1.out[1];

    signal a1b1[2];
    component cm2 = cm31_mul();
    cm2.a[0] <== a[2];
    cm2.a[1] <== a[3];
    cm2.b[0] <== b[2];
    cm2.b[1] <== b[3];
    a1b1[0] <== cm2.out[0];
    a1b1[1] <== cm2.out[1];

    component sum_a = cm31_add();
    sum_a.a[0] <== a[0];
    sum_a.a[1] <== a[1];
    sum_a.b[0] <== a[2];
    sum_a.b[1] <== a[3];

    component sum_b = cm31_add();
    sum_b.a[0] <== b[0];
    sum_b.a[1] <== b[1];
    sum_b.b[0] <== b[2];
    sum_b.b[1] <== b[3];

    signal asbs[2];
    component cm3 = cm31_mul();
    cm3.a[0] <== sum_a.out[0];
    cm3.a[1] <== sum_a.out[1];
    cm3.b[0] <== sum_b.out[0];
    cm3.b[1] <== sum_b.out[1];
    asbs[0] <== cm3.out[0];
    asbs[1] <== cm3.out[1];

    signal a1b1_shifted[2];
    component cm4 = cm31_shift_by_i();
    cm4.a[0] <== a1b1[0];
    cm4.a[1] <== a1b1[1];
    a1b1_shifted[0] <== cm4.out[0];
    a1b1_shifted[1] <== cm4.out[1];

    out[0] <== a0b0[0] + a1b1[0] * 2 + a1b1_shifted[0];
    out[1] <== a0b0[1] + a1b1[1] * 2 + a1b1_shifted[1];
    out[2] <== asbs[0] - a0b0[0] - a1b1[0];
    out[3] <== asbs[1] - a0b0[1] - a1b1[1];
}

template qm31_mul_m31() {
    signal input a[4];
    signal input b;

    signal output out[4];

    for(var i = 0; i < 4; i++) {
        out[i] <== a[i] * b;
    }
}

template qm31_mul_cm31() {
    signal input a[4];
    signal input b[2];

    signal output out[4];

    component s1 = cm31_mul();
    s1.a[0] <== a[0];
    s1.a[1] <== a[1];
    s1.b <== b;
    out[0] <== s1.out[0];
    out[1] <== s1.out[1];

    component s2 = cm31_mul();
    s2.a[0] <== a[2];
    s2.a[1] <== a[3];
    s2.b <== b;
    out[2] <== s2.out[0];
    out[3] <== s2.out[1];
}

template qm31_inv() {
    signal input a[4];
    signal output out[4];

    signal b2[2];
    signal ib2[2];

    component cm_b2 = cm31_mul();
    cm_b2.a[0] <== a[2];
    cm_b2.a[1] <== a[3];
    cm_b2.b[0] <== a[2];
    cm_b2.b[1] <== a[3];
    b2[0] <== cm_b2.out[0];
    b2[1] <== cm_b2.out[1];
    ib2[0] <== -b2[1];
    ib2[1] <== b2[0];

    signal a2[2];
    component cm_a2 = cm31_mul();
    cm_a2.a[0] <== a[0];
    cm_a2.a[1] <== a[1];
    cm_a2.b[0] <== a[0];
    cm_a2.b[1] <== a[1];
    a2[0] <== cm_a2.out[0];
    a2[1] <== cm_a2.out[1];

    signal denom[2];
    denom[0] <== a2[0] - b2[0] - b2[0] - ib2[0];
    denom[1] <== a2[1] - b2[1] - b2[1] - ib2[1];

    component denom_inverse = cm31_inv();
    denom_inverse.a[0] <== denom[0];
    denom_inverse.a[1] <== denom[1];

    component a_out = cm31_mul();
    a_out.a[0] <== a[0];
    a_out.a[1] <== a[1];
    a_out.b[0] <== denom_inverse.out[0];
    a_out.b[1] <== denom_inverse.out[1];
    out[0] <== a_out.out[0];
    out[1] <== a_out.out[1];

    component b_out = cm31_mul();
    b_out.a[0] <== -a[2];
    b_out.a[1] <== -a[3];
    b_out.b[0] <== denom_inverse.out[0];
    b_out.b[1] <== denom_inverse.out[1];
    out[2] <== b_out.out[0];
    out[3] <== b_out.out[1];
}

template qm31_neg() {
    signal input a[4];
    signal output out[4];

    out[0] <== -a[0];
    out[1] <== -a[1];
    out[2] <== -a[2];
    out[3] <== -a[3];
}

template qm31_select() {
    signal input x0[4];
    signal input x1[4];

    signal input bit;

    signal output out[4];

    component select_first = cm31_select();
    select_first.x0[0] <== x0[0];
    select_first.x0[1] <== x0[1];
    select_first.x1[0] <== x1[0];
    select_first.x1[1] <== x1[1];
    select_first.bit <== bit;
    out[0] <== select_first.out[0];
    out[1] <== select_first.out[1];

    component select_second = cm31_select();
    select_second.x0[0] <== x0[2];
    select_second.x0[1] <== x0[3];
    select_second.x1[0] <== x1[2];
    select_second.x1[1] <== x1[3];
    select_second.bit <== bit;
    out[2] <== select_second.out[0];
    out[3] <== select_second.out[1];
}

template qm31_swap() {
    signal input x0[4];
    signal input x1[4];

    signal input bit;

    signal output out0[4];
    signal output out1[4];

    component swap_first = cm31_swap();
    swap_first.x0[0] <== x0[0];
    swap_first.x0[1] <== x0[1];
    swap_first.x1[0] <== x1[0];
    swap_first.x1[1] <== x1[1];
    swap_first.bit <== bit;
    out0[0] <== swap_first.out0[0];
    out0[1] <== swap_first.out0[1];
    out1[0] <== swap_first.out1[0];
    out1[1] <== swap_first.out1[1];

    component swap_second = cm31_swap();
    swap_second.x0[0] <== x0[2];
    swap_second.x0[1] <== x0[3];
    swap_second.x1[0] <== x1[2];
    swap_second.x1[1] <== x1[3];
    swap_second.bit <== bit;
    out0[2] <== swap_second.out0[0];
    out0[3] <== swap_second.out0[1];
    out1[2] <== swap_second.out1[0];
    out1[3] <== swap_second.out1[1];
}

template qm31_cond_neg() {
    signal input a[4];
    signal input bit;

    signal bit_neg <== 1 - 2 * bit;

    signal output out[4];
    for(var i = 0; i < 4; i++) {
        out[i] <== a[i] * bit_neg;
    }
}