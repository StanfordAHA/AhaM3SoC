/////////////////////////////////////////////////////////////////////////////////////////////
/// TSMC Library/IP Product
/// Filename: tphn16ffcllgv18e.v
/// Technology: CLN16FCLL001
/// Product Type: Standard I/O
/// Product Name: tphn16ffcllgv18e
/// Version: 090a
////////////////////////////////////////////////////////////////////////////////////////////
////
///  STATEMENT OF USE
///
///  This information contains confidential and proprietary information of TSMC.
///  No part of this information may be reproduced, transmitted, transcribed,
///  stored in a retrieval system, or translated into any human or computer
///  language, in any form or by any means, electronic, mechanical, magnetic,
///  optical, chemical, manual, or otherwise, without the prior written permission
///  of TSMC.  This information was prepared for informational purpose and is for
///  use by TSMC's customers only.  TSMC reserves the right to make changes in the
///  information at any time and without notice.
///
////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps

`celldefine
module PCBRTE_H (IRTE, RTE);
  input  IRTE;
  output RTE;

  buf  (RTE, IRTE);

specify
  (IRTE => RTE)=(0, 0);
endspecify

endmodule
`endcelldefine

`celldefine
module PCBRTE_V (IRTE, RTE);
  input  IRTE;
  output RTE;

  buf  (RTE, IRTE);

specify
  (IRTE => RTE)=(0, 0);
endspecify

endmodule
`endcelldefine

`celldefine
module PCLAMP_H (VDDESD, VSSESD);
  inout VDDESD, VSSESD;
endmodule
`endcelldefine

`celldefine
module PCLAMP_V (VDDESD, VSSESD);
  inout VDDESD, VSSESD;
endmodule
`endcelldefine

`celldefine
module PCLAMPC_H (VDDESD, VSSESD);
  inout VDDESD, VSSESD;
endmodule
`endcelldefine

`celldefine
module PCLAMPC_V (VDDESD, VSSESD);
  inout VDDESD, VSSESD;
endmodule
`endcelldefine

`celldefine
module PDB2ANA_H (AIO, RTE);
  input RTE;
  inout AIO;
endmodule
`endcelldefine

`celldefine
module PDB2ANA_V (AIO, RTE);
  input RTE;
  inout AIO;
endmodule
`endcelldefine

`celldefine
module PDB3A_H (AIO);
   inout AIO;
endmodule
`endcelldefine

`celldefine
module PDB3A_V (AIO);
   inout AIO;
endmodule
`endcelldefine

`celldefine
module PDB3AC_H (AIO);
   inout AIO;
endmodule
`endcelldefine

`celldefine
module PDB3AC_V (AIO);
   inout AIO;
endmodule
`endcelldefine

`celldefine
module PDDWUWSWCDG_H (C, DS0, DS1, DS2, DS3, I, IE, OEN, PAD, PE, PS, ST, RTE);
input  DS0, DS1, DS2, DS3, I, IE, OEN, PE, PS, ST, RTE;
output C;
inout  PAD;

parameter PullTime = 10000;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(Idelay, I, 1'b0);
pmos   (IRTE, I, RTECTRL);
primitive_retention Iretention (IRTE1, RTECTRL, Idelay);
nmos   (IRTE, IRTE1, RTECTRL);

pmos   #1(OENdelay, OEN, 1'b0);
pmos   (OENRTE, OEN, RTECTRL);
primitive_retention OENretention (OENRTE1, RTECTRL, OENdelay);
nmos   (OENRTE, OENRTE1, RTECTRL);

pmos   #1(DS0delay, DS0, 1'b0);
pmos   (DS0RTE, DS0, RTECTRL);
primitive_retention DS0retention (DS0RTE1, RTECTRL, DS0delay);
nmos   (DS0RTE, DS0RTE1, RTECTRL);

pmos   #1(DS1delay, DS1, 1'b0);
pmos   (DS1RTE, DS1, RTECTRL);
primitive_retention DS1retention (DS1RTE1, RTECTRL, DS1delay);
nmos   (DS1RTE, DS1RTE1, RTECTRL);

pmos   #1(DS2delay, DS2, 1'b0);
pmos   (DS2RTE, DS2, RTECTRL);
primitive_retention DS2retention (DS2RTE1, RTECTRL, DS2delay);
nmos   (DS2RTE, DS2RTE1, RTECTRL);

pmos   #1(DS3delay, DS3, 1'b0);
pmos   (DS3RTE, DS3, RTECTRL);
primitive_retention DS3retention (DS3RTE1, RTECTRL, DS3delay);
nmos   (DS3RTE, DS3RTE1, RTECTRL);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PEdelay, PE, 1'b0);
pmos   (PERTE, PE, RTECTRL);
primitive_retention PEretention (PERTE1, RTECTRL, PEdelay);
nmos   (PERTE, PERTE1, RTECTRL);

pmos   #1(PSdelay, PS, 1'b0);
pmos   (PSRTE, PS, RTECTRL);
primitive_retention PSretention (PSRTE1, RTECTRL, PSdelay);
nmos   (PSRTE, PSRTE1, RTECTRL);

bufif0 (PAD_q, IRTE, OENRTE);
pmos   (PG_PAD_1, PAD_q, 1'b0);

not    (PSRTEB, PSRTE);
and    (PD, PERTE, PSRTEB);
and    (PU, PERTE, PSRTE);
buf    #(PullTime,0) (pu_pad, PU);
buf    #(PullTime,0) (pd_pad, PD);

rnmos  (PAD_pu, 1'b1, pu_pad);
rnmos  (PAD_pd, 1'b0, pd_pad);
rpmos  (PG_PAD_1, PAD_pu, 1'b0);
rpmos  (PG_PAD_1, PAD_pd, 1'b0);

pmos   (PG_PAD_2, PG_PAD_1, 1'b0);

bufif1 (PG_PAD_2, DS0RTE, 1'b0);
bufif1 (PG_PAD_2, DS1RTE, 1'b0);
bufif1 (PG_PAD_2, DS2RTE, 1'b0);
bufif1 (PG_PAD_2, DS3RTE, 1'b0);

pmos   (PAD, PG_PAD_2, 1'b0);
bufif1 (SIG_IE, PAD, 1'b1);

buf    (pd_c, PD);
buf    (pu_c, PU);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

always @(PE or PS) begin
  if (PE === 1'b1 && PS === 1'bx) begin
    $display("%t ++Forbidden Pull Pattern++ : %m", $realtime);
  end
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
  end
end
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(I) begin
  if (I === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS3) ++ : %m", $realtime);
  end
end
always @(PE) begin
  if (PE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PS) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify
endmodule
`endcelldefine

`celldefine
module PDDWUWSWCDG_V (C, DS0, DS1, DS2, DS3, I, IE, OEN, PAD, PE, PS, ST, RTE);
input  DS0, DS1, DS2, DS3, I, IE, OEN, PE, PS, ST, RTE;
output C;
inout  PAD;

parameter PullTime = 10000;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(Idelay, I, 1'b0);
pmos   (IRTE, I, RTECTRL);
primitive_retention Iretention (IRTE1, RTECTRL, Idelay);
nmos   (IRTE, IRTE1, RTECTRL);

pmos   #1(OENdelay, OEN, 1'b0);
pmos   (OENRTE, OEN, RTECTRL);
primitive_retention OENretention (OENRTE1, RTECTRL, OENdelay);
nmos   (OENRTE, OENRTE1, RTECTRL);

pmos   #1(DS0delay, DS0, 1'b0);
pmos   (DS0RTE, DS0, RTECTRL);
primitive_retention DS0retention (DS0RTE1, RTECTRL, DS0delay);
nmos   (DS0RTE, DS0RTE1, RTECTRL);

pmos   #1(DS1delay, DS1, 1'b0);
pmos   (DS1RTE, DS1, RTECTRL);
primitive_retention DS1retention (DS1RTE1, RTECTRL, DS1delay);
nmos   (DS1RTE, DS1RTE1, RTECTRL);

pmos   #1(DS2delay, DS2, 1'b0);
pmos   (DS2RTE, DS2, RTECTRL);
primitive_retention DS2retention (DS2RTE1, RTECTRL, DS2delay);
nmos   (DS2RTE, DS2RTE1, RTECTRL);

pmos   #1(DS3delay, DS3, 1'b0);
pmos   (DS3RTE, DS3, RTECTRL);
primitive_retention DS3retention (DS3RTE1, RTECTRL, DS3delay);
nmos   (DS3RTE, DS3RTE1, RTECTRL);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PEdelay, PE, 1'b0);
pmos   (PERTE, PE, RTECTRL);
primitive_retention PEretention (PERTE1, RTECTRL, PEdelay);
nmos   (PERTE, PERTE1, RTECTRL);

pmos   #1(PSdelay, PS, 1'b0);
pmos   (PSRTE, PS, RTECTRL);
primitive_retention PSretention (PSRTE1, RTECTRL, PSdelay);
nmos   (PSRTE, PSRTE1, RTECTRL);

bufif0 (PAD_q, IRTE, OENRTE);
pmos   (PG_PAD_1, PAD_q, 1'b0);

not    (PSRTEB, PSRTE);
and    (PD, PERTE, PSRTEB);
and    (PU, PERTE, PSRTE);
buf    #(PullTime,0) (pu_pad, PU);
buf    #(PullTime,0) (pd_pad, PD);

rnmos  (PAD_pu, 1'b1, pu_pad);
rnmos  (PAD_pd, 1'b0, pd_pad);
rpmos  (PG_PAD_1, PAD_pu, 1'b0);
rpmos  (PG_PAD_1, PAD_pd, 1'b0);

pmos   (PG_PAD_2, PG_PAD_1, 1'b0);

bufif1 (PG_PAD_2, DS0RTE, 1'b0);
bufif1 (PG_PAD_2, DS1RTE, 1'b0);
bufif1 (PG_PAD_2, DS2RTE, 1'b0);
bufif1 (PG_PAD_2, DS3RTE, 1'b0);

pmos   (PAD, PG_PAD_2, 1'b0);
bufif1 (SIG_IE, PAD, 1'b1);

buf    (pd_c, PD);
buf    (pu_c, PU);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

always @(PE or PS) begin
  if (PE === 1'b1 && PS === 1'bx) begin
    $display("%t ++Forbidden Pull Pattern++ : %m", $realtime);
  end
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
  end
end
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(I) begin
  if (I === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS3) ++ : %m", $realtime);
  end
end
always @(PE) begin
  if (PE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PS) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify
endmodule
`endcelldefine

`celldefine
module PDDWUWSWCDGS_H (C, DS0, DS1, DS2, DS3, I, IE, OEN, PAD, PU, PD, ST, RTE);
input  DS0, DS1, DS2, DS3, I, IE, OEN, PU, PD, ST, RTE;
output C;
inout  PAD;

parameter PullTime = 10000, PullTime_spu = 750;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(Idelay, I, 1'b0);
pmos   (IRTE, I, RTECTRL);
primitive_retention Iretention (IRTE1, RTECTRL, Idelay);
nmos   (IRTE, IRTE1, RTECTRL);

pmos   #1(OENdelay, OEN, 1'b0);
pmos   (OENRTE, OEN, RTECTRL);
primitive_retention OENretention (OENRTE1, RTECTRL, OENdelay);
nmos   (OENRTE, OENRTE1, RTECTRL);

pmos   #1(DS0delay, DS0, 1'b0);
pmos   (DS0RTE, DS0, RTECTRL);
primitive_retention DS0retention (DS0RTE1, RTECTRL, DS0delay);
nmos   (DS0RTE, DS0RTE1, RTECTRL);

pmos   #1(DS1delay, DS1, 1'b0);
pmos   (DS1RTE, DS1, RTECTRL);
primitive_retention DS1retention (DS1RTE1, RTECTRL, DS1delay);
nmos   (DS1RTE, DS1RTE1, RTECTRL);

pmos   #1(DS2delay, DS2, 1'b0);
pmos   (DS2RTE, DS2, RTECTRL);
primitive_retention DS2retention (DS2RTE1, RTECTRL, DS2delay);
nmos   (DS2RTE, DS2RTE1, RTECTRL);

pmos   #1(DS3delay, DS3, 1'b0);
pmos   (DS3RTE, DS3, RTECTRL);
primitive_retention DS3retention (DS3RTE1, RTECTRL, DS3delay);
nmos   (DS3RTE, DS3RTE1, RTECTRL);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PUdelay, PU, 1'b0);
pmos   (PURTE, PU, RTECTRL);
primitive_retention PUretention (PURTE1, RTECTRL, PUdelay);
nmos   (PURTE, PURTE1, RTECTRL);

pmos   #1(PDdelay, PD, 1'b0);
pmos   (PDRTE, PD, RTECTRL);
primitive_retention PDretention (PDRTE1, RTECTRL, PDdelay);
nmos   (PDRTE, PDRTE1, RTECTRL);

bufif0 (PAD_q, IRTE, OENRTE);
pmos   (PG_PAD_1, PAD_q, 1'b0);

and    (SPU_pre, PURTE, PDRTE);
not    (DS2B, DS2RTE);
not    (DS3B, DS3RTE);
not    (OE, OENRTE);
and    (no_pull_pre, DS2B, DS3B, OE);
pmos   (no_pull, no_pull_pre, RTE);
nmos   (no_pull, 1'b1, RTE);
pmos   (SPU, SPU_pre, no_pull);
nmos   (SPU, 1'b0, no_pull);

nmos   #(PullTime_spu,0) (PUP, PURTE, SPU);
pmos   #(PullTime,0) (PUP, PURTE, SPU);
nmos   (pu_pad, PUP, PURTE);
pmos   (pu_pad, PURTE, PURTE);
pmos   #(PullTime,0) (pd_pad, PDRTE, PURTE);
nmos   (pd_pad, 1'b0, PURTE);
rnmos  (PAD_pu, 1'b1, pu_pad);
rnmos  (PAD_pd, 1'b0, pd_pad);
rpmos  (PG_PAD_1, PAD_pu, 1'b0);
rpmos  (PG_PAD_1, PAD_pd, 1'b0);

buf    (pu_c, PURTE);
nmos   (pd_c, 1'b0, SPU);
pmos   (pd_c, PDRTE, SPU);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

pmos   (PG_PAD_2, PG_PAD_1, 1'b0);

bufif1 (PG_PAD_2, DS0RTE, 1'b0);
bufif1 (PG_PAD_2, DS1RTE, 1'b0);

pmos   (PAD, PG_PAD_2, 1'b0);
bufif1 (SIG_IE, PAD, 1'b1);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

always @(PU or PD or I or OEN or DS3 or DS2) begin
  if (PU === 1'b1 && PD === 1'b1 && OEN === 1'b0 && I === 1'b0 && DS3 === 1'b0 && DS2 === 1'b0) begin
    $display("%t ++Forbidden EM Pattern++ : %m", $realtime);
    $stop(1);
  end
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
  end
end
always @(PU) begin
  if (PU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PU) ++ : %m", $realtime);
  end
end
always @(PD) begin
  if (PD === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PD) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PU) begin
  if (PU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PU) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PD) begin
  if (PD === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PD) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(I) begin
  if (I === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS3) ++ : %m", $realtime);
  end
end
always @(PU) begin
  if (PU === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PU) ++ : %m", $realtime);
  end
end
always @(PD) begin
  if (PD === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PD) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify
endmodule
`endcelldefine

`celldefine
module PDDWUWSWCDGS_V (C, DS0, DS1, DS2, DS3, I, IE, OEN, PAD, PU, PD, ST, RTE);
input  DS0, DS1, DS2, DS3, I, IE, OEN, PU, PD, ST, RTE;
output C;
inout  PAD;

parameter PullTime = 10000, PullTime_spu = 750;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(Idelay, I, 1'b0);
pmos   (IRTE, I, RTECTRL);
primitive_retention Iretention (IRTE1, RTECTRL, Idelay);
nmos   (IRTE, IRTE1, RTECTRL);

pmos   #1(OENdelay, OEN, 1'b0);
pmos   (OENRTE, OEN, RTECTRL);
primitive_retention OENretention (OENRTE1, RTECTRL, OENdelay);
nmos   (OENRTE, OENRTE1, RTECTRL);

pmos   #1(DS0delay, DS0, 1'b0);
pmos   (DS0RTE, DS0, RTECTRL);
primitive_retention DS0retention (DS0RTE1, RTECTRL, DS0delay);
nmos   (DS0RTE, DS0RTE1, RTECTRL);

pmos   #1(DS1delay, DS1, 1'b0);
pmos   (DS1RTE, DS1, RTECTRL);
primitive_retention DS1retention (DS1RTE1, RTECTRL, DS1delay);
nmos   (DS1RTE, DS1RTE1, RTECTRL);

pmos   #1(DS2delay, DS2, 1'b0);
pmos   (DS2RTE, DS2, RTECTRL);
primitive_retention DS2retention (DS2RTE1, RTECTRL, DS2delay);
nmos   (DS2RTE, DS2RTE1, RTECTRL);

pmos   #1(DS3delay, DS3, 1'b0);
pmos   (DS3RTE, DS3, RTECTRL);
primitive_retention DS3retention (DS3RTE1, RTECTRL, DS3delay);
nmos   (DS3RTE, DS3RTE1, RTECTRL);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PUdelay, PU, 1'b0);
pmos   (PURTE, PU, RTECTRL);
primitive_retention PUretention (PURTE1, RTECTRL, PUdelay);
nmos   (PURTE, PURTE1, RTECTRL);

pmos   #1(PDdelay, PD, 1'b0);
pmos   (PDRTE, PD, RTECTRL);
primitive_retention PDretention (PDRTE1, RTECTRL, PDdelay);
nmos   (PDRTE, PDRTE1, RTECTRL);

bufif0 (PAD_q, IRTE, OENRTE);
pmos   (PG_PAD_1, PAD_q, 1'b0);

and    (SPU_pre, PURTE, PDRTE);
not    (DS2B, DS2RTE);
not    (DS3B, DS3RTE);
not    (OE, OENRTE);
and    (no_pull_pre, DS2B, DS3B, OE);
pmos   (no_pull, no_pull_pre, RTE);
nmos   (no_pull, 1'b1, RTE);
pmos   (SPU, SPU_pre, no_pull);
nmos   (SPU, 1'b0, no_pull);

nmos   #(PullTime_spu,0) (PUP, PURTE, SPU);
pmos   #(PullTime,0) (PUP, PURTE, SPU);
nmos   (pu_pad, PUP, PURTE);
pmos   (pu_pad, PURTE, PURTE);
pmos   #(PullTime,0) (pd_pad, PDRTE, PURTE);
nmos   (pd_pad, 1'b0, PURTE);
rnmos  (PAD_pu, 1'b1, pu_pad);
rnmos  (PAD_pd, 1'b0, pd_pad);
rpmos  (PG_PAD_1, PAD_pu, 1'b0);
rpmos  (PG_PAD_1, PAD_pd, 1'b0);

buf    (pu_c, PURTE);
nmos   (pd_c, 1'b0, SPU);
pmos   (pd_c, PDRTE, SPU);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

pmos   (PG_PAD_2, PG_PAD_1, 1'b0);

bufif1 (PG_PAD_2, DS0RTE, 1'b0);
bufif1 (PG_PAD_2, DS1RTE, 1'b0);

pmos   (PAD, PG_PAD_2, 1'b0);
bufif1 (SIG_IE, PAD, 1'b1);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

always @(PU or PD or I or OEN or DS3 or DS2) begin
  if (PU === 1'b1 && PD === 1'b1 && OEN === 1'b0 && I === 1'b0 && DS3 === 1'b0 && DS2 === 1'b0) begin
    $display("%t ++Forbidden EM Pattern++ : %m", $realtime);
    $stop(1);
  end
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
  end
end
always @(PU) begin
  if (PU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PU) ++ : %m", $realtime);
  end
end
always @(PD) begin
  if (PD === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PD) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PU) begin
  if (PU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PU) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PD) begin
  if (PD === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PD) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(I) begin
  if (I === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS3) ++ : %m", $realtime);
  end
end
always @(PU) begin
  if (PU === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PU) ++ : %m", $realtime);
  end
end
always @(PD) begin
  if (PD === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PD) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify
endmodule
`endcelldefine

`celldefine
module PDIDWUWSWCDG_H (C, IE, PAD, PE, PS, ST, RTE);
input  IE, PE, PS, ST, RTE, PAD;
output C;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PEdelay, PE, 1'b0);
pmos   (PERTE, PE, RTECTRL);
primitive_retention PEretention (PERTE1, RTECTRL, PEdelay);
nmos   (PERTE, PERTE1, RTECTRL);

pmos   #1(PSdelay, PS, 1'b0);
pmos   (PSRTE, PS, RTECTRL);
primitive_retention PSretention (PSRTE1, RTECTRL, PSdelay);
nmos   (PSRTE, PSRTE1, RTECTRL);

nmos   (SIG_IE, PAD, 1'b1);

not    (PSRTEB, PSRTE);
and    (PD, PERTE, PSRTEB);
and    (PU, PERTE, PSRTE);

buf    (pd_c, PD);
buf    (pu_c, PU);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

always @(PE or PS) begin
  if (PE === 1'b1 && PS === 1'bx) begin
    $display("%t ++Forbidden Pull Pattern++ : %m", $realtime);
  end
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(PE) begin
  if (PE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PS) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify

endmodule
`endcelldefine

`celldefine
module PDIDWUWSWCDG_V (C, IE, PAD, PE, PS, ST, RTE);
input  IE, PE, PS, ST, RTE, PAD;
output C;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PEdelay, PE, 1'b0);
pmos   (PERTE, PE, RTECTRL);
primitive_retention PEretention (PERTE1, RTECTRL, PEdelay);
nmos   (PERTE, PERTE1, RTECTRL);

pmos   #1(PSdelay, PS, 1'b0);
pmos   (PSRTE, PS, RTECTRL);
primitive_retention PSretention (PSRTE1, RTECTRL, PSdelay);
nmos   (PSRTE, PSRTE1, RTECTRL);

nmos   (SIG_IE, PAD, 1'b1);

not    (PSRTEB, PSRTE);
and    (PD, PERTE, PSRTEB);
and    (PU, PERTE, PSRTE);

buf    (pd_c, PD);
buf    (pu_c, PU);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

always @(PE or PS) begin
  if (PE === 1'b1 && PS === 1'bx) begin
    $display("%t ++Forbidden Pull Pattern++ : %m", $realtime);
  end
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(PE) begin
  if (PE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PS) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify

endmodule
`endcelldefine

`celldefine
module PRCUT_H ();
endmodule
`endcelldefine

`celldefine
module PRCUT_V ();
endmodule
`endcelldefine

`celldefine
module PRWDWUWHWSWDGZ_H (C, DS0, DS1, DS2, DS3, I, IE, OEN, PAD, PE, PS, SPU, ST, SL, RTE);
input  DS0, DS1, DS2, DS3, I, IE, OEN, PE, PS, SPU, ST, SL, RTE;
output C;
inout  PAD;

parameter PullTime = 10000, PullTime_spu = 400;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(Idelay, I, 1'b0);
pmos   (IRTE, I, RTECTRL);
primitive_retention Iretention (IRTE1, RTECTRL, Idelay);
nmos   (IRTE, IRTE1, RTECTRL);

pmos   #1(OENdelay, OEN, 1'b0);
pmos   (OENRTE, OEN, RTECTRL);
primitive_retention OENretention (OENRTE1, RTECTRL, OENdelay);
nmos   (OENRTE, OENRTE1, RTECTRL);

pmos   #1(DS0delay, DS0, 1'b0);
pmos   (DS0RTE, DS0, RTECTRL);
primitive_retention DS0retention (DS0RTE1, RTECTRL, DS0delay);
nmos   (DS0RTE, DS0RTE1, RTECTRL);

pmos   #1(DS1delay, DS1, 1'b0);
pmos   (DS1RTE, DS1, RTECTRL);
primitive_retention DS1retention (DS1RTE1, RTECTRL, DS1delay);
nmos   (DS1RTE, DS1RTE1, RTECTRL);

pmos   #1(DS2delay, DS2, 1'b0);
pmos   (DS2RTE, DS2, RTECTRL);
primitive_retention DS2retention (DS2RTE1, RTECTRL, DS2delay);
nmos   (DS2RTE, DS2RTE1, RTECTRL);

pmos   #1(DS3delay, DS3, 1'b0);
pmos   (DS3RTE, DS3, RTECTRL);
primitive_retention DS3retention (DS3RTE1, RTECTRL, DS3delay);
nmos   (DS3RTE, DS3RTE1, RTECTRL);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(SLdelay, SL, 1'b0);
pmos   (SLRTE, SL, RTECTRL);
primitive_retention SLretention (SLRTE1, RTECTRL, SLdelay);
nmos   (SLRTE, SLRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PEdelay, PE, 1'b0);
pmos   (PERTE, PE, RTECTRL);
primitive_retention PEretention (PERTE1, RTECTRL, PEdelay);
nmos   (PERTE, PERTE1, RTECTRL);

pmos   #1(PSdelay, PS, 1'b0);
pmos   (PSRTE, PS, RTECTRL);
primitive_retention PSretention (PSRTE1, RTECTRL, PSdelay);
nmos   (PSRTE, PSRTE1, RTECTRL);

pmos   #1(SPUdelay, SPU, 1'b0);
pmos   (SPURTE, SPU, RTECTRL);
primitive_retention SPUretention (SPURTE1, RTECTRL, SPUdelay);
nmos   (SPURTE, SPURTE1, RTECTRL);

bufif0 (PAD_q, IRTE, OENRTE);
pmos   (PG_PAD_1, PAD_q, 1'b0);

not    (PSRTEB, PSRTE);
and    (PD, PERTE, PSRTEB);
and    (PU, PERTE, PSRTE);

nmos   #(PullTime_spu, 0) (PUP, PU, SPURTE);
pmos   #(PullTime, 0) (PUP, PU, SPURTE);
nmos   (pu_pad, PUP, PU);
pmos   (pu_pad, PU, PU);
buf    #(PullTime,0) (pd_pad, PD);

rnmos  (PAD_pu, 1'b1, pu_pad);
rnmos  (PAD_pd, 1'b0, pd_pad);
rpmos  (PG_PAD_1, PAD_pu, 1'b0);
rpmos  (PG_PAD_1, PAD_pd, 1'b0);

pmos   (PG_PAD_2, PG_PAD_1, 1'b0);

bufif1 (PG_PAD_2, DS0RTE, 1'b0);
bufif1 (PG_PAD_2, DS1RTE, 1'b0);
bufif1 (PG_PAD_2, DS2RTE, 1'b0);
bufif1 (PG_PAD_2, DS3RTE, 1'b0);
bufif1 (PG_PAD_2, SLRTE, 1'b0);

pmos   (PAD, PG_PAD_2, 1'b0);
bufif1 (SIG_IE, PAD, 1'b1);

buf    (pd_c, PD);
buf    (pu_c, PU);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

always @(PE or PS) begin
  if (PE === 1'b1 && PS === 1'bx) begin
    $display("%t ++Forbidden Pull Pattern : PS++ : %m", $realtime);
  end
end

always @(PE or PS or SPU) begin
  if (PE === 1'b1 && PS === 1'b1 && SPU === 1'bx) begin
    $display("%t ++Forbidden Pull Pattern : SPU++ : %m", $realtime);
  end
end

always @(PE or PS or SPU or I or OEN or DS3 or DS2) begin
  if (PE === 1'b1 && PS === 1'b1 && SPU === 1'b1 && OEN === 1'b0 && I === 1'b0 && DS3 === 1'b0 && DS2 === 1'b0) begin
    $display("%t ++Forbidden EM Pattern++ : %m", $realtime);
    $stop(1);
  end
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
  end
end
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
  end
end
always @(SPU) begin
  if (SPU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SPU) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(SL) begin
  if (SL === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SL) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(SPU) begin
  if (SPU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SPU) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(SL) begin
  if (SL === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SL) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(I) begin
  if (I === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS3) ++ : %m", $realtime);
  end
end
always @(PE) begin
  if (PE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PS) ++ : %m", $realtime);
  end
end
always @(SPU) begin
  if (SPU === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (SPU) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(SL) begin
  if (SL === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (SL) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify
endmodule
`endcelldefine

`celldefine
module PRWDWUWHWSWDGZ_V (C, DS0, DS1, DS2, DS3, I, IE, OEN, PAD, PE, PS, SPU, ST, SL, RTE);
input  DS0, DS1, DS2, DS3, I, IE, OEN, PE, PS, SPU, ST, SL, RTE;
output C;
inout  PAD;

parameter PullTime = 10000, PullTime_spu = 400;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(Idelay, I, 1'b0);
pmos   (IRTE, I, RTECTRL);
primitive_retention Iretention (IRTE1, RTECTRL, Idelay);
nmos   (IRTE, IRTE1, RTECTRL);

pmos   #1(OENdelay, OEN, 1'b0);
pmos   (OENRTE, OEN, RTECTRL);
primitive_retention OENretention (OENRTE1, RTECTRL, OENdelay);
nmos   (OENRTE, OENRTE1, RTECTRL);

pmos   #1(DS0delay, DS0, 1'b0);
pmos   (DS0RTE, DS0, RTECTRL);
primitive_retention DS0retention (DS0RTE1, RTECTRL, DS0delay);
nmos   (DS0RTE, DS0RTE1, RTECTRL);

pmos   #1(DS1delay, DS1, 1'b0);
pmos   (DS1RTE, DS1, RTECTRL);
primitive_retention DS1retention (DS1RTE1, RTECTRL, DS1delay);
nmos   (DS1RTE, DS1RTE1, RTECTRL);

pmos   #1(DS2delay, DS2, 1'b0);
pmos   (DS2RTE, DS2, RTECTRL);
primitive_retention DS2retention (DS2RTE1, RTECTRL, DS2delay);
nmos   (DS2RTE, DS2RTE1, RTECTRL);

pmos   #1(DS3delay, DS3, 1'b0);
pmos   (DS3RTE, DS3, RTECTRL);
primitive_retention DS3retention (DS3RTE1, RTECTRL, DS3delay);
nmos   (DS3RTE, DS3RTE1, RTECTRL);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(SLdelay, SL, 1'b0);
pmos   (SLRTE, SL, RTECTRL);
primitive_retention SLretention (SLRTE1, RTECTRL, SLdelay);
nmos   (SLRTE, SLRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PEdelay, PE, 1'b0);
pmos   (PERTE, PE, RTECTRL);
primitive_retention PEretention (PERTE1, RTECTRL, PEdelay);
nmos   (PERTE, PERTE1, RTECTRL);

pmos   #1(PSdelay, PS, 1'b0);
pmos   (PSRTE, PS, RTECTRL);
primitive_retention PSretention (PSRTE1, RTECTRL, PSdelay);
nmos   (PSRTE, PSRTE1, RTECTRL);

pmos   #1(SPUdelay, SPU, 1'b0);
pmos   (SPURTE, SPU, RTECTRL);
primitive_retention SPUretention (SPURTE1, RTECTRL, SPUdelay);
nmos   (SPURTE, SPURTE1, RTECTRL);

bufif0 (PAD_q, IRTE, OENRTE);
pmos   (PG_PAD_1, PAD_q, 1'b0);

not    (PSRTEB, PSRTE);
and    (PD, PERTE, PSRTEB);
and    (PU, PERTE, PSRTE);

nmos   #(PullTime_spu, 0) (PUP, PU, SPURTE);
pmos   #(PullTime, 0) (PUP, PU, SPURTE);
nmos   (pu_pad, PUP, PU);
pmos   (pu_pad, PU, PU);
buf    #(PullTime,0) (pd_pad, PD);

rnmos  (PAD_pu, 1'b1, pu_pad);
rnmos  (PAD_pd, 1'b0, pd_pad);
rpmos  (PG_PAD_1, PAD_pu, 1'b0);
rpmos  (PG_PAD_1, PAD_pd, 1'b0);

pmos   (PG_PAD_2, PG_PAD_1, 1'b0);

bufif1 (PG_PAD_2, DS0RTE, 1'b0);
bufif1 (PG_PAD_2, DS1RTE, 1'b0);
bufif1 (PG_PAD_2, DS2RTE, 1'b0);
bufif1 (PG_PAD_2, DS3RTE, 1'b0);
bufif1 (PG_PAD_2, SLRTE, 1'b0);

pmos   (PAD, PG_PAD_2, 1'b0);
bufif1 (SIG_IE, PAD, 1'b1);

buf    (pd_c, PD);
buf    (pu_c, PU);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

always @(PE or PS) begin
  if (PE === 1'b1 && PS === 1'bx) begin
    $display("%t ++Forbidden Pull Pattern : PS++ : %m", $realtime);
  end
end

always @(PE or PS or SPU) begin
  if (PE === 1'b1 && PS === 1'b1 && SPU === 1'bx) begin
    $display("%t ++Forbidden Pull Pattern : SPU++ : %m", $realtime);
  end
end

always @(PE or PS or SPU or I or OEN or DS3 or DS2) begin
  if (PE === 1'b1 && PS === 1'b1 && SPU === 1'b1 && OEN === 1'b0 && I === 1'b0 && DS3 === 1'b0 && DS2 === 1'b0) begin
    $display("%t ++Forbidden EM Pattern++ : %m", $realtime);
    $stop(1);
  end
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
  end
end
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
  end
end
always @(SPU) begin
  if (SPU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SPU) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(SL) begin
  if (SL === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SL) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS3) begin
  if (DS3 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS3) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PE) begin
  if (PE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PS) begin
  if (PS === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PS) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(SPU) begin
  if (SPU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SPU) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(SL) begin
  if (SL === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SL) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(I) begin
  if (I === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS2) ++ : %m", $realtime);
  end
end
always @(DS3) begin
  if (DS3 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS3) ++ : %m", $realtime);
  end
end
always @(PE) begin
  if (PE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PE) ++ : %m", $realtime);
  end
end
always @(PS) begin
  if (PS === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PS) ++ : %m", $realtime);
  end
end
always @(SPU) begin
  if (SPU === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (SPU) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(SL) begin
  if (SL === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (SL) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && DS3 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify
endmodule
`endcelldefine

`celldefine
module PRWDWUWSWCDGH_H (C, DS0, DS1, DS2, I, IE, OEN, PAD, PU, PD, ST, SL, RTE);

input  DS0, DS1, DS2, I, IE, OEN, PU, PD, ST, SL, RTE;
output C;
inout  PAD;

parameter PullTime = 10000;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(Idelay, I, 1'b0);
pmos   (IRTE, I, RTECTRL);
primitive_retention Iretention (IRTE1, RTECTRL, Idelay);
nmos   (IRTE, IRTE1, RTECTRL);

pmos   #1(OENdelay, OEN, 1'b0);
pmos   (OENRTE, OEN, RTECTRL);
primitive_retention OENretention (OENRTE1, RTECTRL, OENdelay);
nmos   (OENRTE, OENRTE1, RTECTRL);

pmos   #1(DS0delay, DS0, 1'b0);
pmos   (DS0RTE, DS0, RTECTRL);
primitive_retention DS0retention (DS0RTE1, RTECTRL, DS0delay);
nmos   (DS0RTE, DS0RTE1, RTECTRL);

pmos   #1(DS1delay, DS1, 1'b0);
pmos   (DS1RTE, DS1, RTECTRL);
primitive_retention DS1retention (DS1RTE1, RTECTRL, DS1delay);
nmos   (DS1RTE, DS1RTE1, RTECTRL);

pmos   #1(DS2delay, DS2, 1'b0);
pmos   (DS2RTE, DS2, RTECTRL);
primitive_retention DS2retention (DS2RTE1, RTECTRL, DS2delay);
nmos   (DS2RTE, DS2RTE1, RTECTRL);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(SLdelay, SL, 1'b0);
pmos   (SLRTE, SL, RTECTRL);
primitive_retention SLretention (SLRTE1, RTECTRL, SLdelay);
nmos   (SLRTE, SLRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PUdelay, PU, 1'b0);
pmos   (PURTE, PU, RTECTRL);
primitive_retention PUretention (PURTE1, RTECTRL, PUdelay);
nmos   (PURTE, PURTE1, RTECTRL);

pmos   #1(PDdelay, PD, 1'b0);
pmos   (PDRTE, PD, RTECTRL);
primitive_retention PDretention (PDRTE1, RTECTRL, PDdelay);
nmos   (PDRTE, PDRTE1, RTECTRL);

bufif0 (PAD_q, IRTE, OENRTE);
pmos   (PG_PAD_1, PAD_q, 1'b0);

pmos   #(PullTime,0) (pu_pad, PURTE, PDRTE);
nmos   (pu_pad, 1'b0, PDRTE);
pmos   #(PullTime,0) (pd_pad, PDRTE, PURTE);
nmos   (pd_pad, 1'b0, PURTE);
rnmos  (PAD_pu, 1'b1, pu_pad);
rnmos  (PAD_pd, 1'b0, pd_pad);
rpmos  (PG_PAD_1, PAD_pu, 1'b0);
rpmos  (PG_PAD_1, PAD_pd, 1'b0);

pmos   (pu_c, PURTE, PDRTE);
nmos   (pu_c, 1'b0, PDRTE);
pmos   (pd_c, PDRTE, PURTE);
nmos   (pd_c, 1'b0, PURTE);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

and    (BH, PURTE, PDRTE);
not    (inv_lastPAD, lastPAD);
and    (BH_uen, BH, lastPAD);
and    (BH_den, BH, inv_lastPAD);
rnmos  (PAD_bu, 1'b1, BH_uen);
rnmos  (PAD_bd, 1'b0, BH_den);
rpmos  (PG_PAD_1, PAD_bu, 1'b0);
rpmos  (PG_PAD_1, PAD_bd, 1'b0);

pmos   (PG_PAD_2, PG_PAD_1, 1'b0);

bufif1 (PG_PAD_2, DS0RTE, 1'b0);
bufif1 (PG_PAD_2, DS1RTE, 1'b0);
bufif1 (PG_PAD_2, DS2RTE, 1'b0);
bufif1 (PG_PAD_2, SLRTE, 1'b0);

pmos   (PAD, PG_PAD_2, 1'b0);
pmos   #1(lastPAD, PAD, 1'b0);
bufif1 (SIG_IE, PAD, 1'b1);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
  end
end
always @(SL) begin
  if (SL === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SL) ++ : %m", $realtime);
  end
end
always @(PU) begin
  if (PU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PU) ++ : %m", $realtime);
  end
end
always @(PD) begin
  if (PD === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PD) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(SL) begin
  if (SL === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SL) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PU) begin
  if (PU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PU) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PD) begin
  if (PD === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PD) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(I) begin
  if (I === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS2) ++ : %m", $realtime);
  end
end
always @(SL) begin
  if (SL === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (SL) ++ : %m", $realtime);
  end
end
always @(PU) begin
  if (PU === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PU) ++ : %m", $realtime);
  end
end
always @(PD) begin
  if (PD === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PD) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify
endmodule
`endcelldefine

`celldefine
module PRWDWUWSWCDGH_V (C, DS0, DS1, DS2, I, IE, OEN, PAD, PU, PD, ST, SL, RTE);

input  DS0, DS1, DS2, I, IE, OEN, PU, PD, ST, SL, RTE;
output C;
inout  PAD;

parameter PullTime = 10000;

pmos   (RTECTRL, RTE, 1'b0);

pmos   #1(Idelay, I, 1'b0);
pmos   (IRTE, I, RTECTRL);
primitive_retention Iretention (IRTE1, RTECTRL, Idelay);
nmos   (IRTE, IRTE1, RTECTRL);

pmos   #1(OENdelay, OEN, 1'b0);
pmos   (OENRTE, OEN, RTECTRL);
primitive_retention OENretention (OENRTE1, RTECTRL, OENdelay);
nmos   (OENRTE, OENRTE1, RTECTRL);

pmos   #1(DS0delay, DS0, 1'b0);
pmos   (DS0RTE, DS0, RTECTRL);
primitive_retention DS0retention (DS0RTE1, RTECTRL, DS0delay);
nmos   (DS0RTE, DS0RTE1, RTECTRL);

pmos   #1(DS1delay, DS1, 1'b0);
pmos   (DS1RTE, DS1, RTECTRL);
primitive_retention DS1retention (DS1RTE1, RTECTRL, DS1delay);
nmos   (DS1RTE, DS1RTE1, RTECTRL);

pmos   #1(DS2delay, DS2, 1'b0);
pmos   (DS2RTE, DS2, RTECTRL);
primitive_retention DS2retention (DS2RTE1, RTECTRL, DS2delay);
nmos   (DS2RTE, DS2RTE1, RTECTRL);

pmos   #1(STdelay, ST, 1'b0);
pmos   (STRTE, ST, RTECTRL);
primitive_retention STretention (STRTE1, RTECTRL, STdelay);
nmos   (STRTE, STRTE1, RTECTRL);

pmos   #1(SLdelay, SL, 1'b0);
pmos   (SLRTE, SL, RTECTRL);
primitive_retention SLretention (SLRTE1, RTECTRL, SLdelay);
nmos   (SLRTE, SLRTE1, RTECTRL);

pmos   #1(IEdelay, IE, 1'b0);
pmos   (IERTE, IE, RTECTRL);
primitive_retention IEretention (IERTE1, RTECTRL, IEdelay);
nmos   (IERTE, IERTE1, RTECTRL);

pmos   #1(PUdelay, PU, 1'b0);
pmos   (PURTE, PU, RTECTRL);
primitive_retention PUretention (PURTE1, RTECTRL, PUdelay);
nmos   (PURTE, PURTE1, RTECTRL);

pmos   #1(PDdelay, PD, 1'b0);
pmos   (PDRTE, PD, RTECTRL);
primitive_retention PDretention (PDRTE1, RTECTRL, PDdelay);
nmos   (PDRTE, PDRTE1, RTECTRL);

bufif0 (PAD_q, IRTE, OENRTE);
pmos   (PG_PAD_1, PAD_q, 1'b0);

pmos   #(PullTime,0) (pu_pad, PURTE, PDRTE);
nmos   (pu_pad, 1'b0, PDRTE);
pmos   #(PullTime,0) (pd_pad, PDRTE, PURTE);
nmos   (pd_pad, 1'b0, PURTE);
rnmos  (PAD_pu, 1'b1, pu_pad);
rnmos  (PAD_pd, 1'b0, pd_pad);
rpmos  (PG_PAD_1, PAD_pu, 1'b0);
rpmos  (PG_PAD_1, PAD_pd, 1'b0);

pmos   (pu_c, PURTE, PDRTE);
nmos   (pu_c, 1'b0, PDRTE);
pmos   (pd_c, PDRTE, PURTE);
nmos   (pd_c, 1'b0, PURTE);
rnmos  (C_pu, 1'b1, pu_c);
rnmos  (C_pd, 1'b0, pd_c);
rpmos  (SIG_IE, C_pu, 1'b0);
rpmos  (SIG_IE, C_pd, 1'b0);

and    (BH, PURTE, PDRTE);
not    (inv_lastPAD, lastPAD);
and    (BH_uen, BH, lastPAD);
and    (BH_den, BH, inv_lastPAD);
rnmos  (PAD_bu, 1'b1, BH_uen);
rnmos  (PAD_bd, 1'b0, BH_den);
rpmos  (PG_PAD_1, PAD_bu, 1'b0);
rpmos  (PG_PAD_1, PAD_bd, 1'b0);

pmos   (PG_PAD_2, PG_PAD_1, 1'b0);

bufif1 (PG_PAD_2, DS0RTE, 1'b0);
bufif1 (PG_PAD_2, DS1RTE, 1'b0);
bufif1 (PG_PAD_2, DS2RTE, 1'b0);
bufif1 (PG_PAD_2, SLRTE, 1'b0);

pmos   (PAD, PG_PAD_2, 1'b0);
pmos   #1(lastPAD, PAD, 1'b0);
bufif1 (SIG_IE, PAD, 1'b1);

and    (PG_C_1, SIG_IE, IERTE);

pmos   (PG_C_2, PG_C_1, 1'b0);

bufif1 (PG_C_2, STRTE, 1'b0);

pmos   (C, PG_C_2, 1'b0);

always @(PAD) begin
  if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") && $countdrivers(PAD))
    $display("%t ++BUS CONFLICT++ : %m", $realtime);
end

`ifdef NON_STOP_IF_INPUT_PIN_Z
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
  end
end
always @(SL) begin
  if (SL === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SL) ++ : %m", $realtime);
  end
end
always @(PU) begin
  if (PU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PU) ++ : %m", $realtime);
  end
end
always @(PD) begin
  if (PD === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PD) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
  end
end
`else
always @(I) begin
  if (I === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (I) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(OEN) begin
  if (OEN === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (OEN) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS0) begin
  if (DS0 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS0) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS1) begin
  if (DS1 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS1) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(DS2) begin
  if (DS2 === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (DS2) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(SL) begin
  if (SL === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (SL) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PU) begin
  if (PU === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PU) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(PD) begin
  if (PD === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (PD) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(IE) begin
  if (IE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (IE) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(ST) begin
  if (ST === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (ST) ++ : %m", $realtime);
    $stop(1);
  end
end
always @(RTE) begin
  if (RTE === 1'bz) begin
    $display("%t ++ ERROR: Floating pin (RTE) ++ : %m", $realtime);
    $stop(1);
  end
end
`endif

always @(I) begin
  if (I === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (I) ++ : %m", $realtime);
  end
end
always @(OEN) begin
  if (OEN === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (OEN) ++ : %m", $realtime);
  end
end
always @(DS0) begin
  if (DS0 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS0) ++ : %m", $realtime);
  end
end
always @(DS1) begin
  if (DS1 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS1) ++ : %m", $realtime);
  end
end
always @(DS2) begin
  if (DS2 === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (DS2) ++ : %m", $realtime);
  end
end
always @(SL) begin
  if (SL === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (SL) ++ : %m", $realtime);
  end
end
always @(PU) begin
  if (PU === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PU) ++ : %m", $realtime);
  end
end
always @(PD) begin
  if (PD === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (PD) ++ : %m", $realtime);
  end
end
always @(IE) begin
  if (IE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (IE) ++ : %m", $realtime);
  end
end
always @(ST) begin
  if (ST === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (ST) ++ : %m", $realtime);
  end
end
always @(RTE) begin
  if (RTE === 1'bx) begin
    $display("%t ++ Warning: Unknown pin (RTE) ++ : %m", $realtime);
  end
end

specify
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b0) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b1) (I   => PAD)=(0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b0) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b0 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b0 && DS2 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b0 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (DS0 == 1'b1 && DS1 == 1'b1 && DS2 == 1'b1 && SL == 1'b1) (OEN => PAD)=(0, 0, 0, 0, 0, 0);
    if (ST == 1'b0) (PAD => C)=(0, 0);
    if (ST == 1'b1) (PAD => C)=(0, 0);
    if (ST == 1'b0) (IE => C)=(0, 0);
    if (ST == 1'b1) (IE => C)=(0, 0);
endspecify
endmodule
`endcelldefine

`celldefine
module PVDD1CDGM_H (RTE, VDD, VSS);
  input RTE;
  inout VDD, VSS;
endmodule
`endcelldefine

`celldefine
module PVDD1CDGM_V (RTE, VDD, VSS);
  input RTE;
  inout VDD, VSS;
endmodule
`endcelldefine

`celldefine
module PVDD2CDGM_H (RTE, VDDPST, VSSPST);
  input RTE;
  inout VDDPST, VSSPST;
endmodule
`endcelldefine

`celldefine
module PVDD2CDGM_V (RTE, VDDPST, VSSPST);
  input RTE;
  inout VDDPST, VSSPST;
endmodule
`endcelldefine

`celldefine
module PVDD2POCM_H (RTE, VDDPST, VSSPST);
  input RTE;
  inout VDDPST, VSSPST;
endmodule
`endcelldefine

`celldefine
module PVDD2POCM_V (RTE, VDDPST, VSSPST);
  input RTE;
  inout VDDPST, VSSPST;
endmodule
`endcelldefine

`celldefine
module PVDD3ACM_H (AVDD, AVSS, TACVDD, TACVSS);
  inout AVDD, AVSS, TACVDD, TACVSS;
  tran (AVDD, TACVDD);
  tran (AVSS, TACVSS);
endmodule
`endcelldefine

`celldefine
module PVDD3ACM_V (AVDD, AVSS, TACVDD, TACVSS);
  inout AVDD, AVSS, TACVDD, TACVSS;
  tran (AVDD, TACVDD);
  tran (AVSS, TACVSS);
endmodule
`endcelldefine

`celldefine
module PVDD3AM_H (AVDD, AVSS, TAVDD, TAVSS);
  inout AVDD, AVSS, TAVDD, TAVSS;
  tran (AVDD, TAVDD);
  tran (AVSS, TAVSS);
endmodule
`endcelldefine

`celldefine
module PVDD3AM_V (AVDD, AVSS, TAVDD, TAVSS);
  inout AVDD, AVSS, TAVDD, TAVSS;
  tran (AVDD, TAVDD);
  tran (AVSS, TAVSS);
endmodule
`endcelldefine

primitive primitive_retention (q, RTECTRL, current_state);
  output q; reg q;
  input RTECTRL, current_state;
  table
  //RTECTRL current_state   q   q+
    (01)    0            :  ? : 0;
    (01)    1            :  ? : 1;
    1       (??)         :  ? : -;
    0       ?            :  ? : 0;
  endtable
endprimitive
