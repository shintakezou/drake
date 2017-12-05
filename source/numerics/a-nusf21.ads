pragma License (Unrestricted); -- BSD 3-Clause
--  translated unit from SFMT (SFMT-params216091.h)
with Ada.Numerics.SFMT;
package Ada.Numerics.SFMT_216091 is
   new SFMT (
      MEXP => 216091,
      POS1 => 627,
      SL1 => 11,
      SL2 => 3,
      SR1 => 10,
      SR2 => 1,
      MSK1 => 16#bff7bff7#,
      MSK2 => 16#bfffffff#,
      MSK3 => 16#bffffa7f#,
      MSK4 => 16#ffddfbfb#,
      PARITY1 => 16#f8000001#,
      PARITY2 => 16#89e80709#,
      PARITY3 => 16#3bd2b64b#,
      PARITY4 => 16#0c64b1e4#);
--  The largest periods.
pragma Preelaborate (Ada.Numerics.SFMT_216091);
