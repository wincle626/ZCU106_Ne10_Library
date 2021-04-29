/*
 *  Copyright 2013-14 ARM Limited
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * Neither the name of ARM Limited nor the
 *      names of its contributors may be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY ARM LIMITED AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL ARM LIMITED BE LIABLE FOR ANY
 *  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * NE10 Library : dsp/NE10_fft_int32.neon.s
 */

        .text
        .syntax   unified

        /* Registers define*/
        /*ARM Registers*/
        p_fout          .req   r0
        p_factors       .req   r1
        p_twiddles      .req   r2
        p_fin           .req   r3
        p_fout0         .req   r4
        p_fout1         .req   r5
        p_fout2         .req   r6
        p_fout3         .req   r7
        stage_count     .req   r8
        fstride         .req   r9
        mstride         .req   r10
        count           .req   r1
        count_f         .req   r1
        count_m         .req   r12
        p_tw1           .req   r3
        p_tw2           .req   r11
        p_tw3           .req   r14
        radix           .req   r5
        tmp0            .req   r12

        /*NEON variale Declaration for the first stage*/
        d_in0           .dn   d0
        d_in1           .dn   d1
        q_in01          .qn   q0
        d_in2           .dn   d2
        d_in3           .dn   d3
        q_in23          .qn   q1
        d_out0          .dn   d4
        d_out1          .dn   d5
        d_out2          .dn   d6
        d_out3          .dn   d7

        d_in0_r01       .dn   d0
        d_in0_i01       .dn   d2
        d_in1_r01       .dn   d4
        d_in1_i01       .dn   d6
        d_in0_r23       .dn   d1
        d_in0_i23       .dn   d3
        d_in1_r23       .dn   d5
        d_in1_i23       .dn   d7
        q_in0_r0123     .qn   q0
        q_in0_i0123     .qn   q1
        q_in1_r0123     .qn   q2
        q_in1_i0123     .qn   q3
        d_out0_r01      .dn   d16
        d_out0_i01      .dn   d18
        d_out1_r01      .dn   d20
        d_out1_i01      .dn   d22
        d_out0_r23      .dn   d17
        d_out0_i23      .dn   d19
        d_out1_r23      .dn   d21
        d_out1_i23      .dn   d23
        q_out0_r0123    .qn   q8
        q_out0_i0123    .qn   q9
        q_out1_r0123    .qn   q10
        q_out1_i0123    .qn   q11

        d_in0_0         .dn   d0
        d_in1_0         .dn   d1
        d_in2_0         .dn   d2
        d_in3_0         .dn   d3
        d_in0_1         .dn   d4
        d_in1_1         .dn   d5
        d_in2_1         .dn   d6
        d_in3_1         .dn   d7
        q_in0_01        .qn   q0
        q_in1_01        .qn   q2
        q_in2_01        .qn   q1
        q_in3_01        .qn   q3
        d_out0_0        .dn   d16
        d_out1_0        .dn   d17
        d_out2_0        .dn   d18
        d_out3_0        .dn   d19
        d_out0_1        .dn   d20
        d_out1_1        .dn   d21
        d_out2_1        .dn   d22
        d_out3_1        .dn   d23
        q_out0_01       .qn   q8
        q_out1_01       .qn   q10
        q_out2_01       .qn   q9
        q_out3_01       .qn   q11
        d_s0            .dn   d24
        q_s0_01         .qn   q12
        d_s1            .dn   d26
        q_s1_01         .qn   q13
        d_s2            .dn   d28
        q_s2_01         .qn   q14

        /*NEON variale Declaration for mstride ge2 loop */
        q_fin0_r        .qn   q4
        q_fin0_i        .qn   q5
        q_fin1_r        .qn   q0
        q_fin1_i        .qn   q1
        d_fin1_rl       .dn   d0
        d_fin1_rh       .dn   d1
        d_fin1_il       .dn   d2
        d_fin1_ih       .dn   d3
        q_tw1_r         .qn   q2
        q_tw1_i         .qn   q3
        d_tw1_rl        .dn   d4
        d_tw1_rh        .dn   d5
        d_tw1_il        .dn   d6
        d_tw1_ih        .dn   d7
        q_fin2_r        .qn   q8
        q_fin2_i        .qn   q9
        d_fin2_rl       .dn   d16
        d_fin2_rh       .dn   d17
        d_fin2_il       .dn   d18
        d_fin2_ih       .dn   d19
        q_tw2_r         .qn   q10
        q_tw2_i         .qn   q11
        d_tw2_rl        .dn   d20
        d_tw2_rh        .dn   d21
        d_tw2_il        .dn   d22
        d_tw2_ih        .dn   d23
        q_fin3_r        .qn   q0
        q_fin3_i        .qn   q1
        d_fin3_rl       .dn   d0
        d_fin3_rh       .dn   d1
        d_fin3_il       .dn   d2
        d_fin3_ih       .dn   d3
        q_tw3_r         .qn   q2
        q_tw3_i         .qn   q3
        d_tw3_rl        .dn   d4
        d_tw3_rh        .dn   d5
        d_tw3_il        .dn   d6
        d_tw3_ih        .dn   d7
        q_s0_r          .qn   q12
        q_s0_i          .qn   q13
        d_s0_rl         .dn   d24
        d_s0_rh         .dn   d25
        d_s0_il         .dn   d26
        d_s0_ih         .dn   d27
        q_s1_r          .qn   q14
        q_s1_i          .qn   q15
        d_s1_rl         .dn   d28
        d_s1_rh         .dn   d29
        d_s1_il         .dn   d30
        d_s1_ih         .dn   d31
        q_s2_r          .qn   q8
        q_s2_i          .qn   q9
        q_s2_rh         .qn   q10
        q_s2_ih         .qn   q11
        d_s2_rl         .dn   d16
        d_s2_rh         .dn   d17
        d_s2_il         .dn   d18
        d_s2_ih         .dn   d19
        q_s5_r          .qn   q0
        q_s5_i          .qn   q1
        q_s4_r          .qn   q2
        q_s4_i          .qn   q3
        q_s3_r          .qn   q14
        q_s3_i          .qn   q15
        q_fout0_r       .qn   q10
        q_fout0_i       .qn   q11
        q_fout2_r       .qn   q12
        q_fout2_i       .qn   q13
        q_fout1_r       .qn   q8
        q_fout1_i       .qn   q9
        q_fout3_r       .qn   q14
        q_fout3_i       .qn   q15

        /*NEON variale Declaration for mstride 2 loop */
        d_fin0_r        .dn   d0
        d_fin0_i        .dn   d1
        q_fin0          .qn   q0
        d_fin1_r        .dn   d2
        d_fin1_i        .dn   d3
        q_fin1          .qn   q1
        d_tw1_r         .dn   d4
        d_tw1_i         .dn   d5
        d_fin2_r        .dn   d6
        d_fin2_i        .dn   d7
        q_fin2          .qn   q3
        d_tw2_r         .dn   d16
        d_tw2_i         .dn   d17
        d_fin3_r        .dn   d18
        d_fin3_i        .dn   d19
        q_fin3          .qn   q9
        d_tw3_r         .dn   d0
        d_tw3_i         .dn   d1
        d_s0_r          .dn   d22
        d_s0_i          .dn   d23
        d_s1_r          .dn   d24
        d_s1_i          .dn   d25
        d_s2_r          .dn   d26
        d_s2_i          .dn   d27
        d_s5_r          .dn   d28
        d_s5_i          .dn   d29
        d_s4_r          .dn   d30
        d_s4_i          .dn   d31
        d_s3_r          .dn   d16
        d_s3_i          .dn   d17
        d_fout0_r       .dn   d0
        d_fout0_i       .dn   d1
        d_fout2_r       .dn   d2
        d_fout2_i       .dn   d3
        d_fout1_r       .dn   d4
        d_fout1_i       .dn   d5
        d_fout3_r       .dn   d6
        d_fout3_i       .dn   d7

        d_tmp0          .dn   d30
        d_tmp1          .dn   d31
        q_tmp           .qn   q15
        d_tmp2_0        .dn   d28
        d_tmp2_1        .dn   d29
        q_tmp2          .qn   q14
        d_tmp3_0        .dn   d20
        d_tmp3_1        .dn   d21
        q_tmp3          .qn   q10

        /*NEON variale Declaration for mstride 2 loop */
        d_tw1_r01       .dn   d16
        d_tw2_r01       .dn   d17
        d_tw1_i01       .dn   d18
        d_tw2_i01       .dn   d19
        d_tw3_r01       .dn   d20
        d_tw3_i01       .dn   d21
        q_fin0_r0123    .qn   q0
        q_fin0_i0123    .qn   q1
        q_fin01_r01     .qn   q0
        q_fin01_i01     .qn   q1
        q_fin23_r01     .qn   q2
        q_fin23_i01     .qn   q3
        q_fin01_r23     .qn   q11
        q_fin01_i23     .qn   q12
        q_fin23_r23     .qn   q13
        q_fin23_i23     .qn   q14
        d_fin0_r01      .dn   d0
        d_fin1_r01      .dn   d1
        d_fin0_i01      .dn   d2
        d_fin1_i01      .dn   d3
        d_fin2_r01      .dn   d4
        d_fin3_r01      .dn   d5
        d_fin2_i01      .dn   d6
        d_fin3_i01      .dn   d7
        d_fin0_r23      .dn   d22
        d_fin1_r23      .dn   d23
        d_fin0_i23      .dn   d24
        d_fin1_i23      .dn   d25
        d_fin2_r23      .dn   d26
        d_fin3_r23      .dn   d27
        d_fin2_i23      .dn   d28
        d_fin3_i23      .dn   d29
        q_s0_r0123      .qn   q13
        q_s0_i0123      .qn   q14
        d_s0_r01        .dn   d26
        d_s0_r23        .dn   d27
        d_s0_i01        .dn   d28
        d_s0_i23        .dn   d29
        q_s1_r0123      .qn   q2
        q_s1_i0123      .qn   q3
        d_s1_r01        .dn   d4
        d_s1_r23        .dn   d5
        d_s1_i01        .dn   d6
        d_s1_i23        .dn   d7
        q_s2_r0123      .qn   q15
        q_s2_i0123      .qn   q10
        d_s2_r01        .dn   d30
        d_s2_r23        .dn   d31
        d_s2_i01        .dn   d20
        d_s2_i23        .dn   d21
        q_s5_r0123      .qn   q11
        q_s5_i0123      .qn   q12
        q_s4_r0123      .qn   q4
        q_s4_i0123      .qn   q5
        q_s3_r0123      .qn   q6
        q_s3_i0123      .qn   q7
        q_fout0_r0123   .qn   q0
        q_fout0_i0123   .qn   q1
        q_fout2_r0123   .qn   q2
        q_fout2_i0123   .qn   q3
        q_fout1_r0123   .qn   q13
        q_fout1_i0123   .qn   q14
        q_fout3_r0123   .qn   q6
        q_fout3_i0123   .qn   q7
        d_fout0_r01     .dn   d0
        d_fout1_r01     .dn   d1
        d_fout0_i01     .dn   d2
        d_fout1_i01     .dn   d3
        d_fout2_r01     .dn   d4
        d_fout3_r01     .dn   d5
        d_fout2_i01     .dn   d6
        d_fout3_i01     .dn   d7
        d_fout0_r23     .dn   d26
        d_fout1_r23     .dn   d27
        d_fout0_i23     .dn   d28
        d_fout1_i23     .dn   d29
        d_fout2_r23     .dn   d12
        d_fout3_r23     .dn   d13
        d_fout2_i23     .dn   d14
        d_fout3_i23     .dn   d15

        .macro RADIX2_BUTTERFLY2_P4 scaled
        vld4.32         {d_in0_r01, d_in0_i01, d_in1_r01, d_in1_i01}, [p_fin]!
        vld4.32         {d_in0_r23, d_in0_i23, d_in1_r23, d_in1_i23}, [p_fin]!

        .if \scaled
        vshr.s32        q_in0_r0123, q_in0_r0123, #1
        vshr.s32        q_in0_i0123, q_in0_i0123, #1
        vshr.s32        q_in1_r0123, q_in1_r0123, #1
        vshr.s32        q_in1_i0123, q_in1_i0123, #1
        .endif

        vqsub.s32       q_out1_r0123, q_in0_r0123, q_in1_r0123
        vqsub.s32       q_out1_i0123, q_in0_i0123, q_in1_i0123
        vqadd.s32       q_out0_r0123, q_in0_r0123, q_in1_r0123
        vqadd.s32       q_out0_i0123, q_in0_i0123, q_in1_i0123
        vst4.32         {d_out0_r01, d_out0_i01, d_out1_r01, d_out1_i01}, [p_fout0]!
        vst4.32         {d_out0_r23, d_out0_i23, d_out1_r23, d_out1_i23}, [p_fout0]!
        .endm

        .macro RADIX4_BUTTERFLY4_P4 scaled
        vld1.32         {d_in0_0, d_in1_0, d_in2_0, d_in3_0}, [p_fin]!
        vld1.32         {d_in0_1, d_in1_1, d_in2_1, d_in3_1}, [p_fin]!
        vswp            d_in1_0, d_in0_1
        vswp            d_in3_0, d_in2_1
        .if \scaled
        vshr.s32        q_in0_01, q_in0_01, #2
        vshr.s32        q_in1_01, q_in1_01, #2
        vshr.s32        q_in2_01, q_in2_01, #2
        vshr.s32        q_in3_01, q_in3_01, #2
        .endif

        vqsub.s32       q_s2_01, q_in0_01, q_in2_01
        vqadd.s32       q_out0_01, q_in0_01, q_in2_01
        vqadd.s32       q_s0_01, q_in1_01, q_in3_01
        vqsub.s32       q_s1_01, q_in1_01, q_in3_01
        vqsub.s32       q_out2_01, q_out0_01, q_s0_01
        vrev64.32       q_s1_01, q_s1_01
        vqadd.s32       q_out0_01, q_out0_01, q_s0_01
        vqadd.s32       q_out1_01, q_s2_01, q_s1_01
        vqsub.s32       q_out3_01, q_s2_01, q_s1_01
        vrev64.32       q_tmp, q_out1_01
        vrev64.32       q_tmp2, q_out3_01
        vtrn.32         q_out3_01, q_tmp
        vtrn.32         q_out1_01, q_tmp2
        vswp            d_out1_0, d_out0_1
        vswp            d_out3_0, d_out2_1
        vst1.32         {d_out0_0, d_out1_0, d_out2_0, d_out3_0}, [p_fout0]!
        vst1.32         {d_out0_1, d_out1_1, d_out2_1, d_out3_1}, [p_fout0]!
        .endm

        .macro RADIX4_BUTTERFLY4_INVERSE_P4 scaled
        vld1.32         {d_in0_0, d_in1_0, d_in2_0, d_in3_0}, [p_fin]!
        vld1.32         {d_in0_1, d_in1_1, d_in2_1, d_in3_1}, [p_fin]!
        vswp            d_in1_0, d_in0_1
        vswp            d_in3_0, d_in2_1
        .if \scaled
        vshr.s32        q_in0_01, q_in0_01, #2
        vshr.s32        q_in1_01, q_in1_01, #2
        vshr.s32        q_in2_01, q_in2_01, #2
        vshr.s32        q_in3_01, q_in3_01, #2
        .endif

        vqsub.s32       q_s2_01, q_in0_01, q_in2_01
        vqadd.s32       q_out0_01, q_in0_01, q_in2_01
        vqadd.s32       q_s0_01, q_in1_01, q_in3_01
        vqsub.s32       q_s1_01, q_in1_01, q_in3_01
        vqsub.s32       q_out2_01, q_out0_01, q_s0_01
        vrev64.32       q_s1_01, q_s1_01
        vqadd.s32       q_out0_01, q_out0_01, q_s0_01
        vqsub.s32       q_out1_01, q_s2_01, q_s1_01
        vqadd.s32       q_out3_01, q_s2_01, q_s1_01
        vrev64.32       q_tmp, q_out1_01
        vrev64.32       q_tmp2, q_out3_01
        vtrn.32         q_out3_01, q_tmp
        vtrn.32         q_out1_01, q_tmp2
        vswp            d_out1_0, d_out0_1
        vswp            d_out3_0, d_out2_1
        vst1.32         {d_out0_0, d_out1_0, d_out2_0, d_out3_0}, [p_fout0]!
        vst1.32         {d_out0_1, d_out1_1, d_out2_1, d_out3_1}, [p_fout0]!
        .endm

        .macro RADIX4_BUTTERFLY_P4 scaled
        vld2.32         {q_fin1_r, q_fin1_i}, [p_fout1]
        vld2.32         {q_tw1_r, q_tw1_i}, [p_tw1]!
        vld2.32         {q_fin2_r, q_fin2_i}, [p_fout2]
        vld2.32         {q_tw2_r, q_tw2_i}, [p_tw2]!

        .if \scaled
        vshr.s32        q_fin1_r, q_fin1_r, #2
        vshr.s32        q_fin1_i, q_fin1_i, #2
        vshr.s32        q_fin2_r, q_fin2_r, #2
        vshr.s32        q_fin2_i, q_fin2_i, #2
        .endif
        vmull.s32        q_s0_r, d_fin1_rl, d_tw1_rl
        vmull.s32        q_tmp, d_fin1_rh, d_tw1_rh
        vmull.s32        q_s0_i, d_fin1_rl, d_tw1_il
        vmull.s32        q_tmp2, d_fin1_rh, d_tw1_ih

        vmull.s32        q4, d_fin2_rl, d_tw2_rl
        vmull.s32        q5, d_fin2_rh, d_tw2_rh
        vmull.s32        q6, d_fin2_rl, d_tw2_il
        vmull.s32        q7, d_fin2_rh, d_tw2_ih

        vmlsl.s32        q_s0_r, d_fin1_il, d_tw1_il
        vmlsl.s32        q_tmp, d_fin1_ih, d_tw1_ih
        vmlal.s32        q_s0_i, d_fin1_il, d_tw1_rl
        vmlal.s32        q_tmp2, d_fin1_ih, d_tw1_rh

        vmlsl.s32        q4, d_fin2_il, d_tw2_il
        vmlsl.s32        q5, d_fin2_ih, d_tw2_ih
        vmlal.s32        q6, d_fin2_il, d_tw2_rl
        vmlal.s32        q7, d_fin2_ih, d_tw2_rh

        vld2.32         {q_fin3_r, q_fin3_i}, [p_fout3]
        vld2.32         {q_tw3_r, q_tw3_i}, [p_tw3]!
        vrshrn.i64       d_s0_rl, q_s0_r, #31
        vrshrn.i64       d_s0_rh, q_tmp, #31
        vrshrn.i64       d_s0_il, q_s0_i, #31
        vrshrn.i64       d_s0_ih, q_tmp2, #31
        .if \scaled
        vshr.s32        q_fin3_r, q_fin3_r, #2
        vshr.s32        q_fin3_i, q_fin3_i, #2
        .endif

        vmull.s32        q_s2_r, d_fin3_rl, d_tw3_rl
        vmull.s32        q_s2_rh, d_fin3_rh, d_tw3_rh
        vmull.s32        q_s2_i, d_fin3_rl, d_tw3_il
        vmull.s32        q_s2_ih, d_fin3_rh, d_tw3_ih

        vrshrn.i64       d_s1_rl, q4, #31
        vrshrn.i64       d_s1_rh, q5, #31
        vrshrn.i64       d_s1_il, q6, #31
        vrshrn.i64       d_s1_ih, q7, #31

        vmlsl.s32        q_s2_r, d_fin3_il, d_tw3_il
        vmlsl.s32        q_s2_rh, d_fin3_ih, d_tw3_ih
        vmlal.s32        q_s2_i, d_fin3_il, d_tw3_rl
        vmlal.s32        q_s2_ih, d_fin3_ih, d_tw3_rh

        vld2.32         {q_fin0_r, q_fin0_i}, [p_fout0]
        vrshrn.i64       d_s2_rl, q_s2_r, #31
        vrshrn.i64       d_s2_rh, q_s2_rh, #31
        vrshrn.i64       d_s2_il, q_s2_i, #31
        vrshrn.i64       d_s2_ih, q_s2_ih, #31
        .if \scaled
        vshr.s32        q_fin0_r, q_fin0_r, #2
        vshr.s32        q_fin0_i, q_fin0_i, #2
        .endif

        vsub.s32       q_s5_r, q_fin0_r, q_s1_r
        vsub.s32       q_s5_i, q_fin0_i, q_s1_i
        vadd.s32       q_fout0_r, q_fin0_r, q_s1_r
        vadd.s32       q_fout0_i, q_fin0_i, q_s1_i

        vadd.s32       q_s3_r, q_s0_r, q_s2_r
        vadd.s32       q_s3_i, q_s0_i, q_s2_i
        vsub.s32       q_s4_r, q_s0_r, q_s2_r
        vsub.s32       q_s4_i, q_s0_i, q_s2_i

        vsub.s32       q_fout2_r, q_fout0_r, q_s3_r
        vsub.s32       q_fout2_i, q_fout0_i, q_s3_i
        vadd.s32       q_fout0_r, q_fout0_r, q_s3_r
        vadd.s32       q_fout0_i, q_fout0_i, q_s3_i
        vst2.32         {q_fout2_r, q_fout2_i}, [p_fout2]!

        vadd.s32       q_fout1_r, q_s5_r, q_s4_i
        vsub.s32       q_fout1_i, q_s5_i, q_s4_r
        vsub.s32       q_fout3_r, q_s5_r, q_s4_i
        vadd.s32       q_fout3_i, q_s5_i, q_s4_r
        vst2.32         {q_fout0_r, q_fout0_i}, [p_fout0]!
        vst2.32         {q_fout1_r, q_fout1_i}, [p_fout1]!
        vst2.32         {q_fout3_r, q_fout3_i}, [p_fout3]!
        .endm

        .macro RADIX4_BUTTERFLY_INVERSE_P4 scaled
        vld2.32         {q_fin1_r, q_fin1_i}, [p_fout1]
        vld2.32         {q_tw1_r, q_tw1_i}, [p_tw1]!
        vld2.32         {q_fin2_r, q_fin2_i}, [p_fout2]
        vld2.32         {q_tw2_r, q_tw2_i}, [p_tw2]!

        .if \scaled
        vshr.s32        q_fin1_r, q_fin1_r, #2
        vshr.s32        q_fin1_i, q_fin1_i, #2
        vshr.s32        q_fin2_r, q_fin2_r, #2
        vshr.s32        q_fin2_i, q_fin2_i, #2
        .endif
        vmull.s32        q_s0_r, d_fin1_rl, d_tw1_rl
        vmull.s32        q_tmp, d_fin1_rh, d_tw1_rh
        vmull.s32        q_s0_i, d_fin1_il, d_tw1_rl
        vmull.s32        q_tmp2, d_fin1_ih, d_tw1_rh

        vmull.s32        q4, d_fin2_rl, d_tw2_rl
        vmull.s32        q5, d_fin2_rh, d_tw2_rh
        vmull.s32        q6, d_fin2_il, d_tw2_rl
        vmull.s32        q7, d_fin2_ih, d_tw2_rh

        vmlal.s32        q_s0_r, d_fin1_il, d_tw1_il
        vmlal.s32        q_tmp, d_fin1_ih, d_tw1_ih
        vmlsl.s32        q_s0_i, d_fin1_rl, d_tw1_il
        vmlsl.s32        q_tmp2, d_fin1_rh, d_tw1_ih

        vmlal.s32        q4, d_fin2_il, d_tw2_il
        vmlal.s32        q5, d_fin2_ih, d_tw2_ih
        vmlsl.s32        q6, d_fin2_rl, d_tw2_il
        vmlsl.s32        q7, d_fin2_rh, d_tw2_ih

        vld2.32         {q_fin3_r, q_fin3_i}, [p_fout3]
        vld2.32         {q_tw3_r, q_tw3_i}, [p_tw3]!
        vrshrn.i64       d_s0_rl, q_s0_r, #31
        vrshrn.i64       d_s0_rh, q_tmp, #31
        vrshrn.i64       d_s0_il, q_s0_i, #31
        vrshrn.i64       d_s0_ih, q_tmp2, #31
        .if \scaled
        vshr.s32        q_fin3_r, q_fin3_r, #2
        vshr.s32        q_fin3_i, q_fin3_i, #2
        .endif

        vmull.s32        q_s2_r, d_fin3_rl, d_tw3_rl
        vmull.s32        q_s2_rh, d_fin3_rh, d_tw3_rh
        vmull.s32        q_s2_i, d_fin3_il, d_tw3_rl
        vmull.s32        q_s2_ih, d_fin3_ih, d_tw3_rh

        vrshrn.i64       d_s1_rl, q4, #31
        vrshrn.i64       d_s1_rh, q5, #31
        vrshrn.i64       d_s1_il, q6, #31
        vrshrn.i64       d_s1_ih, q7, #31

        vmlal.s32        q_s2_r, d_fin3_il, d_tw3_il
        vmlal.s32        q_s2_rh, d_fin3_ih, d_tw3_ih
        vmlsl.s32        q_s2_i, d_fin3_rl, d_tw3_il
        vmlsl.s32        q_s2_ih, d_fin3_rh, d_tw3_ih

        vld2.32         {q_fin0_r, q_fin0_i}, [p_fout0]
        vrshrn.i64       d_s2_rl, q_s2_r, #31
        vrshrn.i64       d_s2_rh, q_s2_rh, #31
        vrshrn.i64       d_s2_il, q_s2_i, #31
        vrshrn.i64       d_s2_ih, q_s2_ih, #31
        .if \scaled
        vshr.s32        q_fin0_r, q_fin0_r, #2
        vshr.s32        q_fin0_i, q_fin0_i, #2
        .endif

        vsub.s32       q_s5_r, q_fin0_r, q_s1_r
        vsub.s32       q_s5_i, q_fin0_i, q_s1_i
        vadd.s32       q_fout0_r, q_fin0_r, q_s1_r
        vadd.s32       q_fout0_i, q_fin0_i, q_s1_i

        vadd.s32       q_s3_r, q_s0_r, q_s2_r
        vadd.s32       q_s3_i, q_s0_i, q_s2_i
        vsub.s32       q_s4_r, q_s0_r, q_s2_r
        vsub.s32       q_s4_i, q_s0_i, q_s2_i

        vsub.s32       q_fout2_r, q_fout0_r, q_s3_r
        vsub.s32       q_fout2_i, q_fout0_i, q_s3_i
        vadd.s32       q_fout0_r, q_fout0_r, q_s3_r
        vadd.s32       q_fout0_i, q_fout0_i, q_s3_i
        vst2.32         {q_fout2_r, q_fout2_i}, [p_fout2]!

        vsub.s32       q_fout1_r, q_s5_r, q_s4_i
        vadd.s32       q_fout1_i, q_s5_i, q_s4_r
        vadd.s32       q_fout3_r, q_s5_r, q_s4_i
        vsub.s32       q_fout3_i, q_s5_i, q_s4_r
        vst2.32         {q_fout0_r, q_fout0_i}, [p_fout0]!
        vst2.32         {q_fout1_r, q_fout1_i}, [p_fout1]!
        vst2.32         {q_fout3_r, q_fout3_i}, [p_fout3]!
        .endm

        .macro RADIX24_BUTTERFLY_P4 scaled
        vld2.32         {d_tw3_r01, d_tw3_i01}, [p_tw1]
        vld2.32         {d_fin0_r01, d_fin1_r01, d_fin0_i01, d_fin1_i01}, [p_fout0]!
        vld2.32         {d_fin2_r01, d_fin3_r01, d_fin2_i01, d_fin3_i01}, [p_fout0], tmp0
        vld2.32         {d_fin0_r23, d_fin1_r23, d_fin0_i23, d_fin1_i23}, [p_fout1]!
        vld2.32         {d_fin2_r23, d_fin3_r23, d_fin2_i23, d_fin3_i23}, [p_fout1], tmp0
        .if \scaled
        vshr.s32        q_fin01_r01, q_fin01_r01, #2
        vshr.s32        q_fin01_i01, q_fin01_i01, #2
        vshr.s32        q_fin23_r01, q_fin23_r01, #2
        vshr.s32        q_fin23_i01, q_fin23_i01, #2
        vshr.s32        q_fin01_r23, q_fin01_r23, #2
        vshr.s32        q_fin01_i23, q_fin01_i23, #2
        vshr.s32        q_fin23_r23, q_fin23_r23, #2
        vshr.s32        q_fin23_i23, q_fin23_i23, #2
        .endif

        vmull.s32       q4, d_fin3_r01, d_tw3_r01
        vmull.s32       q6, d_fin3_r01, d_tw3_i01
        vmull.s32       q5, d_fin3_r23, d_tw3_r01
        vmull.s32       q7, d_fin3_r23, d_tw3_i01
        vmlsl.s32       q4, d_fin3_i01, d_tw3_i01
        vmlal.s32       q6, d_fin3_i01, d_tw3_r01
        vmlsl.s32       q5, d_fin3_i23, d_tw3_i01
        vmlal.s32       q7, d_fin3_i23, d_tw3_r01
        vrshrn.i64      d_s2_r01, q4, #31
        vrshrn.i64      d_s2_i01, q6, #31
        vrshrn.i64      d_s2_r23, q5, #31
        vrshrn.i64      d_s2_i23, q7, #31

        vmull.s32       q4, d_fin2_r01, d_tw2_r01
        vmull.s32       q5, d_fin2_r23, d_tw2_r01
        vmull.s32       q6, d_fin2_r01, d_tw2_i01
        vmull.s32       q7, d_fin2_r23, d_tw2_i01
        vmlsl.s32       q4, d_fin2_i01, d_tw2_i01
        vmlsl.s32       q5, d_fin2_i23, d_tw2_i01
        vmlal.s32       q6, d_fin2_i01, d_tw2_r01
        vmlal.s32       q7, d_fin2_i23, d_tw2_r01
        vrshrn.i64      d_s1_r01, q4, #31
        vrshrn.i64      d_s1_r23, q5, #31
        vrshrn.i64      d_s1_i01, q6, #31
        vrshrn.i64      d_s1_i23, q7, #31

        vmull.s32       q4, d_fin1_r01, d_tw1_r01
        vmull.s32       q5, d_fin1_r23, d_tw1_r01
        vmull.s32       q6, d_fin1_r01, d_tw1_i01
        vmull.s32       q7, d_fin1_r23, d_tw1_i01
        vmlsl.s32       q4, d_fin1_i01, d_tw1_i01
        vmlsl.s32       q5, d_fin1_i23, d_tw1_i01
        vmlal.s32       q6, d_fin1_i01, d_tw1_r01
        vmlal.s32       q7, d_fin1_i23, d_tw1_r01

        vmov            d_fin1_r01, d_fin0_r23
        vmov            d_fin1_i01, d_fin0_i23

        vrshrn.i64      d_s0_r01, q4, #31
        vrshrn.i64      d_s0_r23, q5, #31
        vrshrn.i64      d_s0_i01, q6, #31
        vrshrn.i64      d_s0_i23, q7, #31

        vsub.s32        q_s5_r0123, q_fin0_r0123, q_s1_r0123
        vsub.s32        q_s5_i0123, q_fin0_i0123, q_s1_i0123
        vadd.s32        q_fout0_r0123, q_fin0_r0123, q_s1_r0123
        vadd.s32        q_fout0_i0123, q_fin0_i0123, q_s1_i0123

        vadd.s32        q_s3_r0123, q_s0_r0123, q_s2_r0123
        vadd.s32        q_s3_i0123, q_s0_i0123, q_s2_i0123
        vsub.s32        q_s4_r0123, q_s0_r0123, q_s2_r0123
        vsub.s32        q_s4_i0123, q_s0_i0123, q_s2_i0123
        vsub.s32        q_fout2_r0123, q_fout0_r0123, q_s3_r0123
        vsub.s32        q_fout2_i0123, q_fout0_i0123, q_s3_i0123
        vadd.s32        q_fout0_r0123, q_fout0_r0123, q_s3_r0123
        vadd.s32        q_fout0_i0123, q_fout0_i0123, q_s3_i0123

        vadd.s32        q_fout1_r0123, q_s5_r0123, q_s4_i0123
        vsub.s32        q_fout1_i0123, q_s5_i0123, q_s4_r0123
        vsub.s32        q_fout3_r0123, q_s5_r0123, q_s4_i0123
        vadd.s32        q_fout3_i0123, q_s5_i0123, q_s4_r0123

        vswp            d_fout1_r01, d_fout0_r23
        vswp            d_fout1_i01, d_fout0_i23
        vswp            d_fout3_r01, d_fout2_r23
        vswp            d_fout3_i01, d_fout2_i23

        vst2.32         {d_fout0_r01, d_fout1_r01, d_fout0_i01, d_fout1_i01}, [p_fout2]!
        vst2.32         {d_fout0_r23, d_fout1_r23, d_fout0_i23, d_fout1_i23}, [p_fout3]!
        vst2.32         {d_fout2_r01, d_fout3_r01, d_fout2_i01, d_fout3_i01}, [p_fout2], tmp0
        vst2.32         {d_fout2_r23, d_fout3_r23, d_fout2_i23, d_fout3_i23}, [p_fout3], tmp0
        .endm

        .macro RADIX24_BUTTERFLY_INVERSE_P4 scaled
        vld2.32         {d_tw3_r01, d_tw3_i01}, [p_tw1]
        vld2.32         {d_fin0_r01, d_fin1_r01, d_fin0_i01, d_fin1_i01}, [p_fout0]!
        vld2.32         {d_fin2_r01, d_fin3_r01, d_fin2_i01, d_fin3_i01}, [p_fout0], tmp0
        vld2.32         {d_fin0_r23, d_fin1_r23, d_fin0_i23, d_fin1_i23}, [p_fout1]!
        vld2.32         {d_fin2_r23, d_fin3_r23, d_fin2_i23, d_fin3_i23}, [p_fout1], tmp0
        .if \scaled
        vshr.s32        q_fin01_r01, q_fin01_r01, #2
        vshr.s32        q_fin01_i01, q_fin01_i01, #2
        vshr.s32        q_fin23_r01, q_fin23_r01, #2
        vshr.s32        q_fin23_i01, q_fin23_i01, #2
        vshr.s32        q_fin01_r23, q_fin01_r23, #2
        vshr.s32        q_fin01_i23, q_fin01_i23, #2
        vshr.s32        q_fin23_r23, q_fin23_r23, #2
        vshr.s32        q_fin23_i23, q_fin23_i23, #2
        .endif

        vmull.s32       q4, d_fin3_r01, d_tw3_r01
        vmull.s32       q6, d_fin3_i01, d_tw3_r01
        vmull.s32       q5, d_fin3_r23, d_tw3_r01
        vmull.s32       q7, d_fin3_i23, d_tw3_r01
        vmlal.s32       q4, d_fin3_i01, d_tw3_i01
        vmlsl.s32       q6, d_fin3_r01, d_tw3_i01
        vmlal.s32       q5, d_fin3_i23, d_tw3_i01
        vmlsl.s32       q7, d_fin3_r23, d_tw3_i01
        vrshrn.i64      d_s2_r01, q4, #31
        vrshrn.i64      d_s2_i01, q6, #31
        vrshrn.i64      d_s2_r23, q5, #31
        vrshrn.i64      d_s2_i23, q7, #31

        vmull.s32       q4, d_fin2_r01, d_tw2_r01
        vmull.s32       q5, d_fin2_r23, d_tw2_r01
        vmull.s32       q6, d_fin2_i01, d_tw2_r01
        vmull.s32       q7, d_fin2_i23, d_tw2_r01
        vmlal.s32       q4, d_fin2_i01, d_tw2_i01
        vmlal.s32       q5, d_fin2_i23, d_tw2_i01
        vmlsl.s32       q6, d_fin2_r01, d_tw2_i01
        vmlsl.s32       q7, d_fin2_r23, d_tw2_i01
        vrshrn.i64      d_s1_r01, q4, #31
        vrshrn.i64      d_s1_r23, q5, #31
        vrshrn.i64      d_s1_i01, q6, #31
        vrshrn.i64      d_s1_i23, q7, #31

        vmull.s32       q4, d_fin1_r01, d_tw1_r01
        vmull.s32       q5, d_fin1_r23, d_tw1_r01
        vmull.s32       q6, d_fin1_i01, d_tw1_r01
        vmull.s32       q7, d_fin1_i23, d_tw1_r01
        vmlal.s32       q4, d_fin1_i01, d_tw1_i01
        vmlal.s32       q5, d_fin1_i23, d_tw1_i01
        vmlsl.s32       q6, d_fin1_r01, d_tw1_i01
        vmlsl.s32       q7, d_fin1_r23, d_tw1_i01

        vmov            d_fin1_r01, d_fin0_r23
        vmov            d_fin1_i01, d_fin0_i23

        vrshrn.i64      d_s0_r01, q4, #31
        vrshrn.i64      d_s0_r23, q5, #31
        vrshrn.i64      d_s0_i01, q6, #31
        vrshrn.i64      d_s0_i23, q7, #31

        vsub.s32        q_s5_r0123, q_fin0_r0123, q_s1_r0123
        vsub.s32        q_s5_i0123, q_fin0_i0123, q_s1_i0123
        vadd.s32        q_fout0_r0123, q_fin0_r0123, q_s1_r0123
        vadd.s32        q_fout0_i0123, q_fin0_i0123, q_s1_i0123

        vadd.s32        q_s3_r0123, q_s0_r0123, q_s2_r0123
        vadd.s32        q_s3_i0123, q_s0_i0123, q_s2_i0123
        vsub.s32        q_s4_r0123, q_s0_r0123, q_s2_r0123
        vsub.s32        q_s4_i0123, q_s0_i0123, q_s2_i0123
        vsub.s32        q_fout2_r0123, q_fout0_r0123, q_s3_r0123
        vsub.s32        q_fout2_i0123, q_fout0_i0123, q_s3_i0123
        vadd.s32        q_fout0_r0123, q_fout0_r0123, q_s3_r0123
        vadd.s32        q_fout0_i0123, q_fout0_i0123, q_s3_i0123

        vsub.s32        q_fout1_r0123, q_s5_r0123, q_s4_i0123
        vadd.s32        q_fout1_i0123, q_s5_i0123, q_s4_r0123
        vadd.s32        q_fout3_r0123, q_s5_r0123, q_s4_i0123
        vsub.s32        q_fout3_i0123, q_s5_i0123, q_s4_r0123

        vswp            d_fout1_r01, d_fout0_r23
        vswp            d_fout1_i01, d_fout0_i23
        vswp            d_fout3_r01, d_fout2_r23
        vswp            d_fout3_i01, d_fout2_i23

        vst2.32         {d_fout0_r01, d_fout1_r01, d_fout0_i01, d_fout1_i01}, [p_fout2]!
        vst2.32         {d_fout0_r23, d_fout1_r23, d_fout0_i23, d_fout1_i23}, [p_fout3]!
        vst2.32         {d_fout2_r01, d_fout3_r01, d_fout2_i01, d_fout3_i01}, [p_fout2], tmp0
        vst2.32         {d_fout2_r23, d_fout3_r23, d_fout2_i23, d_fout3_i23}, [p_fout3], tmp0
        .endm

        /**
         * @details
         * This function implements the 4 butterfly
         *
         * @param[in/out] *Fout        points to input/output pointers
         * @param[in]     *factors     factors pointer:
                                        * 0: stage number
                                        * 1: stride for the first stage
                                        * others: factor out powers of 4, powers of 2
         * @param[in]     *twiddles     twiddles coeffs of FFT
         */

        .align 4
        .global ne10_mixed_radix_butterfly_forward_int32_unscaled_neon
        .thumb
        .thumb_func

ne10_mixed_radix_butterfly_forward_int32_unscaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             radix, [p_factors]                         /* get factors[2*stage_count]--- the first radix */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */

        /* judge the first radix is 2 or 4?  */
        cmp             radix, #2
        mov             p_fin, p_fout
        mov             p_fout0, p_fout
        mov             count, fstride
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_forward_first_stage_radix4

        /* the first stage for radix2 */
.L_ne10_unscaled_mixed_radix_butterfly_forward_first_stage_radix2:
        /* fstride gt 1 */
        RADIX2_BUTTERFLY2_P4 0

        subs            count, count, #4
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_forward_first_stage_radix2

        /* the second stage for radix2/4*/
        /* loop of the second stages  */
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
        mov             p_tw1, p_twiddles
        mov             p_fout0, p_fout
        add             p_fout1, p_fout, mstride, lsl #5
        mov             p_fout2, p_fout
        mov             p_fout3, p_fout1
        mov             tmp0, #96
        vld2.32         {d_tw1_r01, d_tw2_r01, d_tw1_i01, d_tw2_i01}, [p_tw1]!

.L_ne10_unscaled_radix24_butterfly_forward_second_stage_fstride:
        RADIX24_BUTTERFLY_P4 0

        subs            count_f, count_f, #2
        bgt             .L_ne10_unscaled_radix24_butterfly_forward_second_stage_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        /* end of the second stage for radix2/4*/
        sub             stage_count, stage_count, #2
        b               .L_ne10_unscaled_mixed_radix_butterfly_forward_other_stages

        /* the first stage  */
.L_ne10_unscaled_mixed_radix_butterfly_forward_first_stage_radix4:
        /* fstride gt 1 */
        RADIX4_BUTTERFLY4_P4 0

        subs            count, count, #2
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_forward_first_stage_radix4
        sub             stage_count, stage_count, #1


        /* the other stages for radix2  */
        /* loop of the other stages  */
.L_ne10_unscaled_mixed_radix_butterfly_forward_other_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_unscaled_mixed_radix_butterfly_forward_other_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_unscaled_mixed_radix_butterfly_forward_other_stages_mstride:
        RADIX4_BUTTERFLY_P4 0

        subs            count_m, count_m, #4
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_forward_other_stages_mstride
        /* end of mstride_ge2 loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_forward_other_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_forward_other_stages

.L_ne10_unscaled_mixed_radix_butterfly_forward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}


        /**
         * @details
         * This function implements the 4 butterfly
         *
         * @param[in/out] *Fout        points to input/output pointers
         * @param[in]     *factors     factors pointer:
                                        * 0: stage number
                                        * 1: stride for the first stage
                                        * others: factor out powers of 4, powers of 2
         * @param[in]     *twiddles     twiddles coeffs of FFT
         */

        .align 4
        .global ne10_mixed_radix_butterfly_backward_int32_unscaled_neon
        .thumb
        .thumb_func

ne10_mixed_radix_butterfly_backward_int32_unscaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             radix, [p_factors]                         /* get factors[2*stage_count]--- the first radix */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */

        /* judge the first radix is 2 or 4?  */
        cmp             radix, #2
        mov             p_fin, p_fout
        mov             p_fout0, p_fout
        mov             count, fstride
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_backward_first_stage_radix4

        /* the first stage for radix2 */
.L_ne10_unscaled_mixed_radix_butterfly_backward_first_stage_radix2:
        /* fstride gt 1 */
        RADIX2_BUTTERFLY2_P4 0

        subs            count, count, #4
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_backward_first_stage_radix2

        /* the second stage for radix2/4*/
        /* loop of the second stages  */
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
        mov             p_tw1, p_twiddles
        mov             p_fout0, p_fout
        add             p_fout1, p_fout, mstride, lsl #5
        mov             p_fout2, p_fout
        mov             p_fout3, p_fout1
        mov             tmp0, #96
        vld2.32         {d_tw1_r01, d_tw2_r01, d_tw1_i01, d_tw2_i01}, [p_tw1]!

.L_ne10_unscaled_radix24_butterfly_backward_second_stage_fstride:
        RADIX24_BUTTERFLY_INVERSE_P4 0

        subs            count_f, count_f, #2
        bgt             .L_ne10_unscaled_radix24_butterfly_backward_second_stage_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        /* end of the second stage for radix2/4*/
        sub             stage_count, stage_count, #2
        b               .L_ne10_unscaled_mixed_radix_butterfly_backward_other_stages

        /* the first stage  */
.L_ne10_unscaled_mixed_radix_butterfly_backward_first_stage_radix4:
        /* fstride gt 1 */
        RADIX4_BUTTERFLY4_INVERSE_P4 0

        subs            count, count, #2
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_backward_first_stage_radix4
        sub             stage_count, stage_count, #1

        /* the other stages  */
        /* loop of the other stages  */
.L_ne10_unscaled_mixed_radix_butterfly_backward_other_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_unscaled_mixed_radix_butterfly_backward_other_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_unscaled_mixed_radix_butterfly_backward_other_stages_mstride:
        RADIX4_BUTTERFLY_INVERSE_P4 0

        subs            count_m, count_m, #4
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_backward_other_stages_mstride
        /* end of mstride_ge2 loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_backward_other_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_unscaled_mixed_radix_butterfly_backward_other_stages


.L_ne10_unscaled_mixed_radix_butterfly_backward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}


        .align 4
        .global ne10_mixed_radix_butterfly_forward_int32_scaled_neon
        .thumb
        .thumb_func

ne10_mixed_radix_butterfly_forward_int32_scaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             radix, [p_factors]                         /* get factors[2*stage_count]--- the first radix */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */

        /* judge the first radix is 2 or 4?  */
        cmp             radix, #2
        mov             p_fin, p_fout
        mov             p_fout0, p_fout
        mov             count, fstride
        bgt             .L_ne10_scaled_mixed_radix_butterfly_forward_first_stage_radix4

        /* the first stage  */
.L_ne10_scaled_mixed_radix_butterfly_forward_first_stage_radix2:
        /* fstride gt 1 */
        RADIX2_BUTTERFLY2_P4 1

        subs            count, count, #4
        bgt             .L_ne10_scaled_mixed_radix_butterfly_forward_first_stage_radix2

        /* the second stage for radix2/4*/
        /* loop of the second stages  */
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
        mov             p_tw1, p_twiddles
        mov             p_fout0, p_fout
        add             p_fout1, p_fout, mstride, lsl #5
        mov             p_fout2, p_fout
        mov             p_fout3, p_fout1
        mov             tmp0, #96
        vld2.32         {d_tw1_r01, d_tw2_r01, d_tw1_i01, d_tw2_i01}, [p_tw1]!

.L_ne10_scaled_radix24_butterfly_forward_second_stage_fstride:
        RADIX24_BUTTERFLY_P4 1

        subs            count_f, count_f, #2
        bgt             .L_ne10_scaled_radix24_butterfly_forward_second_stage_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        /* end of the second stage for radix2/4*/
        sub             stage_count, stage_count, #2
        b               .L_ne10_scaled_mixed_radix_butterfly_forward_other_stages

        /* the first stage  */
.L_ne10_scaled_mixed_radix_butterfly_forward_first_stage_radix4:
        /* fstride gt 1 */
        RADIX4_BUTTERFLY4_P4 1

        subs            count, count, #2
        bgt             .L_ne10_scaled_mixed_radix_butterfly_forward_first_stage_radix4
        sub             stage_count, stage_count, #1


        /* the other stages  */
        /* loop of the other stages  */
.L_ne10_scaled_mixed_radix_butterfly_forward_other_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_scaled_mixed_radix_butterfly_forward_other_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_scaled_mixed_radix_butterfly_forward_other_stages_mstride:
        RADIX4_BUTTERFLY_P4 1

        subs            count_m, count_m, #4
        bgt             .L_ne10_scaled_mixed_radix_butterfly_forward_other_stages_mstride
        /* end of mstride_ge2 loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_scaled_mixed_radix_butterfly_forward_other_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_scaled_mixed_radix_butterfly_forward_other_stages

.L_ne10_scaled_mixed_radix_butterfly_forward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}


        /**
         * @details
         * This function implements the 4 butterfly
         *
         * @param[in/out] *Fout        points to input/output pointers
         * @param[in]     *factors     factors pointer:
                                        * 0: stage number
                                        * 1: stride for the first stage
                                        * others: factor out powers of 4, powers of 2
         * @param[in]     *twiddles     twiddles coeffs of FFT
         */

        .align 4
        .global ne10_mixed_radix_butterfly_backward_int32_scaled_neon
        .thumb
        .thumb_func

ne10_mixed_radix_butterfly_backward_int32_scaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             radix, [p_factors]                         /* get factors[2*stage_count]--- the first radix */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */

        /* judge the first radix is 2 or 4?  */
        cmp             radix, #2
        mov             p_fin, p_fout
        mov             p_fout0, p_fout
        mov             count, fstride
        bgt             .L_ne10_scaled_mixed_radix_butterfly_backward_first_stage_radix4

        /* the first stage  */
.L_ne10_scaled_mixed_radix_butterfly_backward_first_stage_radix2:
        /* fstride gt 1 */
        RADIX2_BUTTERFLY2_P4 1

        subs            count, count, #4
        bgt             .L_ne10_scaled_mixed_radix_butterfly_backward_first_stage_radix2

        /* the second stage for radix2/4*/
        /* loop of the second stages  */
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
        mov             p_tw1, p_twiddles
        mov             p_fout0, p_fout
        add             p_fout1, p_fout, mstride, lsl #5
        mov             p_fout2, p_fout
        mov             p_fout3, p_fout1
        mov             tmp0, #96
        vld2.32         {d_tw1_r01, d_tw2_r01, d_tw1_i01, d_tw2_i01}, [p_tw1]!

.L_ne10_scaled_radix24_butterfly_backward_second_stage_fstride:
        RADIX24_BUTTERFLY_INVERSE_P4 1

        subs            count_f, count_f, #2
        bgt             .L_ne10_scaled_radix24_butterfly_backward_second_stage_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        /* end of the second stage for radix2/4*/
        sub             stage_count, stage_count, #2
        b               .L_ne10_scaled_mixed_radix_butterfly_backward_other_stages

.L_ne10_scaled_mixed_radix_butterfly_backward_first_stage_radix4:
        /* fstride gt 1 */
        RADIX4_BUTTERFLY4_INVERSE_P4 1

        subs            count, count, #2
        bgt             .L_ne10_scaled_mixed_radix_butterfly_backward_first_stage_radix4
        sub             stage_count, stage_count, #1

        /* the other stages  */
        /* loop of the other stages  */
.L_ne10_scaled_mixed_radix_butterfly_backward_other_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_scaled_mixed_radix_butterfly_backward_other_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_scaled_mixed_radix_butterfly_backward_other_stages_mstride:
        RADIX4_BUTTERFLY_INVERSE_P4 1

        subs            count_m, count_m, #4
        bgt             .L_ne10_scaled_mixed_radix_butterfly_backward_other_stages_mstride
        /* end of mstride_ge2 loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_scaled_mixed_radix_butterfly_backward_other_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_scaled_mixed_radix_butterfly_backward_other_stages


.L_ne10_scaled_mixed_radix_butterfly_backward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}



        .align 4
        .global ne10_radix4_butterfly_forward_int32_unscaled_neon
        .thumb
        .thumb_func

ne10_radix4_butterfly_forward_int32_unscaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */
        sub             stage_count, stage_count, #1

        /* loop of the stages  */
.L_ne10_unscaled_radix4_butterfly_forward_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_unscaled_radix4_butterfly_forward_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_unscaled_radix4_butterfly_forward_stages_mstride:

        RADIX4_BUTTERFLY_P4 0

        subs            count_m, count_m, #4
        bgt             .L_ne10_unscaled_radix4_butterfly_forward_stages_mstride

        /* end of mstride_loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_unscaled_radix4_butterfly_forward_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_unscaled_radix4_butterfly_forward_stages

.L_ne10_unscaled_radix4_butterfly_forward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}

        .align 4
        .global ne10_radix4_butterfly_backward_int32_unscaled_neon
        .thumb
        .thumb_func

ne10_radix4_butterfly_backward_int32_unscaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */
        sub             stage_count, stage_count, #1

        /* loop of the stages  */
.L_ne10_unscaled_radix4_butterfly_backward_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_unscaled_radix4_butterfly_backward_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_unscaled_radix4_butterfly_backward_stages_mstride:
        RADIX4_BUTTERFLY_INVERSE_P4 0
        subs            count_m, count_m, #4
        bgt             .L_ne10_unscaled_radix4_butterfly_backward_stages_mstride

        /* end of mstride_loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_unscaled_radix4_butterfly_backward_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_unscaled_radix4_butterfly_backward_stages


.L_ne10_unscaled_radix4_inverse_butterfly_backward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}

        .align 4
        .global ne10_radix2_butterfly_forward_int32_unscaled_neon
        .thumb
        .thumb_func

ne10_radix2_butterfly_forward_int32_unscaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */
        sub             stage_count, stage_count, #2


        /* loop of the second stages  */
.L_ne10_unscaled_radix2_butterfly_forwards_second_stage:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
        mov             p_tw1, p_twiddles
        mov             p_fout0, p_fout
        add             p_fout1, p_fout, mstride, lsl #5
        mov             p_fout2, p_fout
        mov             p_fout3, p_fout1
        mov             tmp0, #96
        vld2.32         {d_tw1_r01, d_tw2_r01, d_tw1_i01, d_tw2_i01}, [p_tw1]!

.L_ne10_unscaled_radix2_butterfly_forwards_second_stage_fstride:
        RADIX24_BUTTERFLY_P4 0

        subs            count_f, count_f, #2
        bgt             .L_ne10_unscaled_radix2_butterfly_forwards_second_stage_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2


        /* loop of the other stages  */
.L_ne10_unscaled_radix2_butterfly_forwards_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_unscaled_radix2_butterfly_forwards_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_unscaled_radix2_butterfly_forwards_stages_mstride:
        RADIX4_BUTTERFLY_P4 0

        subs            count_m, count_m, #4
        bgt             .L_ne10_unscaled_radix2_butterfly_forwards_stages_mstride

        /* end of mstride_loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_unscaled_radix2_butterfly_forwards_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_unscaled_radix2_butterfly_forwards_stages

.L_ne10_unscaled_radix2_butterfly_forwards_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}

        .align 4
        .global ne10_radix2_butterfly_backward_int32_unscaled_neon
        .thumb
        .thumb_func

ne10_radix2_butterfly_backward_int32_unscaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */
        sub             stage_count, stage_count, #2


        /* loop of the second stages  */
.L_ne10_unscaled_radix2_butterfly_backward_second_stage:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
        mov             p_tw1, p_twiddles
        mov             p_fout0, p_fout
        add             p_fout1, p_fout, mstride, lsl #5
        mov             p_fout2, p_fout
        mov             p_fout3, p_fout1
        mov             tmp0, #96
        vld2.32         {d_tw1_r01, d_tw2_r01, d_tw1_i01, d_tw2_i01}, [p_tw1]!

.L_ne10_unscaled_radix2_butterfly_backward_second_stage_fstride:
        RADIX24_BUTTERFLY_INVERSE_P4 0

        subs            count_f, count_f, #2
        bgt             .L_ne10_unscaled_radix2_butterfly_backward_second_stage_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2


        /* loop of the other stages  */
.L_ne10_unscaled_radix2_butterfly_backward_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_unscaled_radix2_butterfly_backward_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_unscaled_radix2_butterfly_backward_stages_mstride:
        RADIX4_BUTTERFLY_INVERSE_P4 0

        subs            count_m, count_m, #4
        bgt             .L_ne10_unscaled_radix2_butterfly_backward_stages_mstride

        /* end of mstride_loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_unscaled_radix2_butterfly_backward_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_unscaled_radix2_butterfly_backward_stages


.L_ne10_unscaled_radix2_butterfly_backward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}

        .align 4
        .global ne10_radix4_butterfly_forward_int32_scaled_neon
        .thumb
        .thumb_func

ne10_radix4_butterfly_forward_int32_scaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */
        sub             stage_count, stage_count, #1

        /* loop of the stages  */
.L_ne10_scaled_radix4_butterfly_forward_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_scaled_radix4_butterfly_forward_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_scaled_radix4_butterfly_forward_stages_mstride:

        RADIX4_BUTTERFLY_P4 1

        subs            count_m, count_m, #4
        bgt             .L_ne10_scaled_radix4_butterfly_forward_stages_mstride

        /* end of mstride_loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_scaled_radix4_butterfly_forward_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_scaled_radix4_butterfly_forward_stages

.L_ne10_scaled_radix4_butterfly_forward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}

        .align 4
        .global ne10_radix4_butterfly_backward_int32_scaled_neon
        .thumb
        .thumb_func

ne10_radix4_butterfly_backward_int32_scaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */
        sub             stage_count, stage_count, #1

        /* loop of the stages  */
.L_ne10_scaled_radix4_butterfly_backward_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_scaled_radix4_butterfly_backward_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_scaled_radix4_butterfly_backward_stages_mstride:
        RADIX4_BUTTERFLY_INVERSE_P4 1

        subs            count_m, count_m, #4
        bgt             .L_ne10_scaled_radix4_butterfly_backward_stages_mstride

        /* end of mstride_loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_scaled_radix4_butterfly_backward_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_scaled_radix4_butterfly_backward_stages


.L_ne10_scaled_radix4_inverse_butterfly_backward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}

        .align 4
        .global ne10_radix2_butterfly_forward_int32_scaled_neon
        .thumb
        .thumb_func

ne10_radix2_butterfly_forward_int32_scaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */
        sub             stage_count, stage_count, #2


        /* loop of the second stages  */
.L_ne10_scaled_radix2_butterfly_forwards_second_stage:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
        mov             p_tw1, p_twiddles
        mov             p_fout0, p_fout
        add             p_fout1, p_fout, mstride, lsl #5
        mov             p_fout2, p_fout
        mov             p_fout3, p_fout1
        mov             tmp0, #96
        vld2.32         {d_tw1_r01, d_tw2_r01, d_tw1_i01, d_tw2_i01}, [p_tw1]!

.L_ne10_scaled_radix2_butterfly_forwards_second_stage_fstride:
        RADIX24_BUTTERFLY_P4 1

        subs            count_f, count_f, #2
        bgt             .L_ne10_scaled_radix2_butterfly_forwards_second_stage_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2


        /* loop of the other stages  */
.L_ne10_scaled_radix2_butterfly_forwards_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_scaled_radix2_butterfly_forwards_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_scaled_radix2_butterfly_forwards_stages_mstride:
        RADIX4_BUTTERFLY_P4 1

        subs            count_m, count_m, #4
        bgt             .L_ne10_scaled_radix2_butterfly_forwards_stages_mstride

        /* end of mstride_loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_scaled_radix2_butterfly_forwards_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_scaled_radix2_butterfly_forwards_stages

.L_ne10_scaled_radix2_butterfly_forwards_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}

        .align 4
        .global ne10_radix2_butterfly_backward_int32_scaled_neon
        .thumb
        .thumb_func

ne10_radix2_butterfly_backward_int32_scaled_neon:

        push            {r4-r12,lr}
        vpush           {q4-q7}

        ldr             stage_count, [p_factors]   /* get factors[0]---stage_count */
        ldr             fstride, [p_factors, #4]   /* get factors[1]---fstride */
        add             p_factors, p_factors, stage_count, lsl #3 /* get the address of factors[2*stage_count] */
        ldr             mstride, [p_factors, #-4]                  /* get factors[2*stage_count-1]--- mstride */
        sub             stage_count, stage_count, #2


        /* loop of the second stages  */
.L_ne10_scaled_radix2_butterfly_backward_second_stage:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
        mov             p_tw1, p_twiddles
        mov             p_fout0, p_fout
        add             p_fout1, p_fout, mstride, lsl #5
        mov             p_fout2, p_fout
        mov             p_fout3, p_fout1
        mov             tmp0, #96
        vld2.32         {d_tw1_r01, d_tw2_r01, d_tw1_i01, d_tw2_i01}, [p_tw1]!

.L_ne10_scaled_radix2_butterfly_backward_second_stage_fstride:
        RADIX24_BUTTERFLY_INVERSE_P4 1

        subs            count_f, count_f, #2
        bgt             .L_ne10_scaled_radix2_butterfly_backward_second_stage_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2


        /* loop of the other stages  */
.L_ne10_scaled_radix2_butterfly_backward_stages:
        lsr             fstride, fstride, #2

        /* loop of fstride  */
        mov             count_f, fstride
.L_ne10_scaled_radix2_butterfly_backward_stages_fstride:
        sub             tmp0, fstride, count_f
        mul             tmp0, tmp0, mstride
        add             p_fout0, p_fout, tmp0, lsl #5
        add             p_fout2, p_fout0, mstride, lsl #4   /* get the address of F[mstride*2] */
        add             p_fout1, p_fout0, mstride, lsl #3   /* get the address of F[mstride] */
        add             p_fout3, p_fout2, mstride, lsl #3   /* get the address of F[mstride*3] */
        mov             p_tw1, p_twiddles
        add             p_tw2, p_tw1, mstride, lsl #3       /* get the address of tw2 */
        add             p_tw3, p_tw1, mstride, lsl #4       /* get the address of tw3 */

        /* loop of mstride  */
        mov             count_m, mstride

.L_ne10_scaled_radix2_butterfly_backward_stages_mstride:
        RADIX4_BUTTERFLY_INVERSE_P4 1

        subs            count_m, count_m, #4
        bgt             .L_ne10_scaled_radix2_butterfly_backward_stages_mstride

        /* end of mstride_loop */

        subs            count_f, count_f, #1
        bgt             .L_ne10_scaled_radix2_butterfly_backward_stages_fstride

        add             p_twiddles, p_twiddles, mstride, lsl #4
        add             p_twiddles, p_twiddles, mstride, lsl #3 /* get the address of twiddles += mstride*3 */
        lsl             mstride, mstride, #2

        subs            stage_count, stage_count, #1
        bgt             .L_ne10_scaled_radix2_butterfly_backward_stages


.L_ne10_scaled_radix2_butterfly_backward_end:
        /*Return From Function*/
        vpop            {q4-q7}
        pop             {r4-r12,pc}


        /* Registers undefine*/
        /*ARM Registers*/
        .unreq          p_fout
        .unreq          p_factors
        .unreq          p_twiddles
        .unreq          p_fin
        .unreq          p_fout0
        .unreq          p_fout1
        .unreq          p_fout2
        .unreq          p_fout3
        .unreq          stage_count
        .unreq          fstride
        .unreq          mstride
        .unreq          count
        .unreq          count_f
        .unreq          count_m
        .unreq          p_tw1
        .unreq          p_tw2
        .unreq          p_tw3
        .unreq          radix
        .unreq          tmp0

        /*NEON variale Declaration for the first stage*/
        .unreq          d_in0
        .unreq          d_in1
        .unreq          q_in01
        .unreq          d_in2
        .unreq          d_in3
        .unreq          q_in23
        .unreq          d_out0
        .unreq          d_out1
        .unreq          d_out2
        .unreq          d_out3

        .unreq          d_in0_r01
        .unreq          d_in0_i01
        .unreq          d_in1_r01
        .unreq          d_in1_i01
        .unreq          d_in0_r23
        .unreq          d_in0_i23
        .unreq          d_in1_r23
        .unreq          d_in1_i23
        .unreq          q_in0_r0123
        .unreq          q_in0_i0123
        .unreq          q_in1_r0123
        .unreq          q_in1_i0123
        .unreq          d_out0_r01
        .unreq          d_out0_i01
        .unreq          d_out1_r01
        .unreq          d_out1_i01
        .unreq          d_out0_r23
        .unreq          d_out0_i23
        .unreq          d_out1_r23
        .unreq          d_out1_i23
        .unreq          q_out0_r0123
        .unreq          q_out0_i0123
        .unreq          q_out1_r0123
        .unreq          q_out1_i0123

        .unreq          d_in0_0
        .unreq          d_in1_0
        .unreq          d_in2_0
        .unreq          d_in3_0
        .unreq          d_in0_1
        .unreq          d_in1_1
        .unreq          d_in2_1
        .unreq          d_in3_1
        .unreq          q_in0_01
        .unreq          q_in1_01
        .unreq          q_in2_01
        .unreq          q_in3_01
        .unreq          d_out0_0
        .unreq          d_out1_0
        .unreq          d_out2_0
        .unreq          d_out3_0
        .unreq          d_out0_1
        .unreq          d_out1_1
        .unreq          d_out2_1
        .unreq          d_out3_1
        .unreq          q_out0_01
        .unreq          q_out1_01
        .unreq          q_out2_01
        .unreq          q_out3_01
        .unreq          d_s0
        .unreq          q_s0_01
        .unreq          d_s1
        .unreq          q_s1_01
        .unreq          d_s2
        .unreq          q_s2_01

        /*NEON variale Declaration for mstride ge2 loop */
        .unreq          q_fin0_r
        .unreq          q_fin0_i
        .unreq          q_fin1_r
        .unreq          q_fin1_i
        .unreq          d_fin1_rl
        .unreq          d_fin1_rh
        .unreq          d_fin1_il
        .unreq          d_fin1_ih
        .unreq          q_tw1_r
        .unreq          q_tw1_i
        .unreq          d_tw1_rl
        .unreq          d_tw1_rh
        .unreq          d_tw1_il
        .unreq          d_tw1_ih
        .unreq          q_fin2_r
        .unreq          q_fin2_i
        .unreq          d_fin2_rl
        .unreq          d_fin2_rh
        .unreq          d_fin2_il
        .unreq          d_fin2_ih
        .unreq          q_tw2_r
        .unreq          q_tw2_i
        .unreq          d_tw2_rl
        .unreq          d_tw2_rh
        .unreq          d_tw2_il
        .unreq          d_tw2_ih
        .unreq          q_fin3_r
        .unreq          q_fin3_i
        .unreq          d_fin3_rl
        .unreq          d_fin3_rh
        .unreq          d_fin3_il
        .unreq          d_fin3_ih
        .unreq          q_tw3_r
        .unreq          q_tw3_i
        .unreq          d_tw3_rl
        .unreq          d_tw3_rh
        .unreq          d_tw3_il
        .unreq          d_tw3_ih
        .unreq          q_s0_r
        .unreq          q_s0_i
        .unreq          d_s0_rl
        .unreq          d_s0_rh
        .unreq          d_s0_il
        .unreq          d_s0_ih
        .unreq          q_s1_r
        .unreq          q_s1_i
        .unreq          d_s1_rl
        .unreq          d_s1_rh
        .unreq          d_s1_il
        .unreq          d_s1_ih
        .unreq          q_s2_r
        .unreq          q_s2_i
        .unreq          q_s2_rh
        .unreq          q_s2_ih
        .unreq          d_s2_rl
        .unreq          d_s2_rh
        .unreq          d_s2_il
        .unreq          d_s2_ih
        .unreq          q_s5_r
        .unreq          q_s5_i
        .unreq          q_s4_r
        .unreq          q_s4_i
        .unreq          q_s3_r
        .unreq          q_s3_i
        .unreq          q_fout0_r
        .unreq          q_fout0_i
        .unreq          q_fout2_r
        .unreq          q_fout2_i
        .unreq          q_fout1_r
        .unreq          q_fout1_i
        .unreq          q_fout3_r
        .unreq          q_fout3_i

        /*NEON variale Declaration for mstride 2 loop */
        .unreq          d_fin0_r
        .unreq          d_fin0_i
        .unreq          q_fin0
        .unreq          d_fin1_r
        .unreq          d_fin1_i
        .unreq          q_fin1
        .unreq          d_tw1_r
        .unreq          d_tw1_i
        .unreq          d_fin2_r
        .unreq          d_fin2_i
        .unreq          q_fin2
        .unreq          d_tw2_r
        .unreq          d_tw2_i
        .unreq          d_fin3_r
        .unreq          d_fin3_i
        .unreq          q_fin3
        .unreq          d_tw3_r
        .unreq          d_tw3_i
        .unreq          d_s0_r
        .unreq          d_s0_i
        .unreq          d_s1_r
        .unreq          d_s1_i
        .unreq          d_s2_r
        .unreq          d_s2_i
        .unreq          d_s5_r
        .unreq          d_s5_i
        .unreq          d_s4_r
        .unreq          d_s4_i
        .unreq          d_s3_r
        .unreq          d_s3_i
        .unreq          d_fout0_r
        .unreq          d_fout0_i
        .unreq          d_fout2_r
        .unreq          d_fout2_i
        .unreq          d_fout1_r
        .unreq          d_fout1_i
        .unreq          d_fout3_r
        .unreq          d_fout3_i

        .unreq          d_tmp0
        .unreq          d_tmp1
        .unreq          q_tmp
        .unreq          d_tmp2_0
        .unreq          d_tmp2_1
        .unreq          q_tmp2
        .unreq          d_tmp3_0
        .unreq          d_tmp3_1

        /*NEON variale Declaration for mstride 2 loop */
        .unreq          d_tw1_r01
        .unreq          d_tw2_r01
        .unreq          d_tw1_i01
        .unreq          d_tw2_i01
        .unreq          d_tw3_r01
        .unreq          d_tw3_i01
        .unreq          q_fin0_r0123
        .unreq          q_fin0_i0123
        .unreq          q_fin01_r01
        .unreq          q_fin01_i01
        .unreq          q_fin23_r01
        .unreq          q_fin23_i01
        .unreq          q_fin01_r23
        .unreq          q_fin01_i23
        .unreq          q_fin23_r23
        .unreq          q_fin23_i23
        .unreq          d_fin0_r01
        .unreq          d_fin1_r01
        .unreq          d_fin0_i01
        .unreq          d_fin1_i01
        .unreq          d_fin2_r01
        .unreq          d_fin3_r01
        .unreq          d_fin2_i01
        .unreq          d_fin3_i01
        .unreq          d_fin0_r23
        .unreq          d_fin1_r23
        .unreq          d_fin0_i23
        .unreq          d_fin1_i23
        .unreq          d_fin2_r23
        .unreq          d_fin3_r23
        .unreq          d_fin2_i23
        .unreq          d_fin3_i23
        .unreq          q_s0_r0123
        .unreq          q_s0_i0123
        .unreq          d_s0_r01
        .unreq          d_s0_r23
        .unreq          d_s0_i01
        .unreq          d_s0_i23
        .unreq          q_s1_r0123
        .unreq          q_s1_i0123
        .unreq          d_s1_r01
        .unreq          d_s1_r23
        .unreq          d_s1_i01
        .unreq          d_s1_i23
        .unreq          q_s2_r0123
        .unreq          q_s2_i0123
        .unreq          d_s2_r01
        .unreq          d_s2_r23
        .unreq          d_s2_i01
        .unreq          d_s2_i23
        .unreq          q_s5_r0123
        .unreq          q_s5_i0123
        .unreq          q_s4_r0123
        .unreq          q_s4_i0123
        .unreq          q_s3_r0123
        .unreq          q_s3_i0123
        .unreq          q_fout0_r0123
        .unreq          q_fout0_i0123
        .unreq          q_fout2_r0123
        .unreq          q_fout2_i0123
        .unreq          q_fout1_r0123
        .unreq          q_fout1_i0123
        .unreq          q_fout3_r0123
        .unreq          q_fout3_i0123
        .unreq          d_fout0_r01
        .unreq          d_fout1_r01
        .unreq          d_fout0_i01
        .unreq          d_fout1_i01
        .unreq          d_fout2_r01
        .unreq          d_fout3_r01
        .unreq          d_fout2_i01
        .unreq          d_fout3_i01
        .unreq          d_fout0_r23
        .unreq          d_fout1_r23
        .unreq          d_fout0_i23
        .unreq          d_fout1_i23
        .unreq          d_fout2_r23
        .unreq          d_fout3_r23
        .unreq          d_fout2_i23
        .unreq          d_fout3_i23

        /* end of the file */
        .end
