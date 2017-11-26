pragma License (Unrestricted); -- BSD 3-Clause
--  translated unit from SFMT (SFMT-params19937.h)
with Ada.Numerics.SFMT;
package Ada.Numerics.SFMT_19937 is
   new SFMT (
      MEXP => 19937,
      POS1 => 122,
      SL1 => 18,
      SL2 => 1,
      SR1 => 11,
      SR2 => 1,
      MSK1 => 16#dfffffef#,
      MSK2 => 16#ddfecb7f#,
      MSK3 => 16#bffaffff#,
      MSK4 => 16#bffffff6#,
      PARITY1 => 16#00000001#,
      PARITY2 => 16#00000000#,
      PARITY3 => 16#00000000#,
      PARITY4 => 16#13c9e684#);
--  For normal use.
pragma Preelaborate (Ada.Numerics.SFMT_19937);
