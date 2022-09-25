--
-- Copyright (c) 2016 University of Cambridge All rights reserved.
--
-- Author: Marco Forconesi
--
-- This software was developed with the support of 
-- Prof. Gustavo Sutter and Prof. Sergio Lopez-Buedo and
-- University of Cambridge Computer Laboratory NetFPGA team.
--
-- @NETFPGA_LICENSE_HEADER_START@
--
-- Licensed to NetFPGA C.I.C. (NetFPGA) under one or more
-- contributor license agreements.  See the NOTICE file distributed with this
-- work for additional information regarding copyright ownership.  NetFPGA
-- licenses this file to you under the NetFPGA Hardware-Software License,
-- Version 1.0 (the "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at:
--
--   http://www.netfpga-cic.org
--
-- Unless required by applicable law or agreed to in writing, Work distributed
-- under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
-- CONDITIONS OF ANY KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations under the License.
--
-- @NETFPGA_LICENSE_HEADER_END@

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

package xgmii_includes is

    -- XGMII characters
    constant S                    : std_logic_vector(7 downto 0)  := x"FB";
    constant T                    : std_logic_vector(7 downto 0)  := x"FD";
    constant E                    : std_logic_vector(7 downto 0)  := x"FE";
    constant I                    : std_logic_vector(7 downto 0)  := x"07";

    constant PREAMBLE_LANE0_D     : std_logic_vector(63 downto 0) := x"D5555555555555" & S;
    constant PREAMBLE_LANE0_C     : std_logic_vector(7 downto 0)  := x"01";

    constant PREAMBLE_LANE4_D     : std_logic_vector(63 downto 0) := x"555555" & S & I & I & I & I;
    constant PREAMBLE_LANE4_C     : std_logic_vector(7 downto 0)  := x"1F";

    constant PREAMBLE_LANE4_END_D : std_logic_vector(31 downto 0) := x"D5555555";
    constant PREAMBLE_LANE4_END_C : std_logic_vector(7 downto 0)  := x"00";

    constant QW_IDLE_D            : std_logic_vector(63 downto 0) := I & I & I & I & I & I & I & I;
    constant QW_IDLE_C            : std_logic_vector(7 downto 0)  := x"FF";

    constant XGMII_ERROR_L0_D     : std_logic_vector(7 downto 0)  := E;
    constant XGMII_ERROR_L0_C     : std_logic_vector(7 downto 0)  := x"01";

    constant XGMII_ERROR_L4_D     : std_logic_vector(7 downto 0)  := E;
    constant XGMII_ERROR_L4_C     : std_logic_vector(7 downto 0)  := x"10";

    constant CRC802_3_PRESET      : std_logic_vector(31 downto 0) := x"FFFFFFFF";

    function sof_lane0(
        xgmii_d : in std_logic_vector(63 downto 0);
        xgmii_c : in std_logic_vector(7 downto 0)
    ) return boolean;

    function sof_lane4(
        xgmii_d : in std_logic_vector(63 downto 0);
        xgmii_c : in std_logic_vector(7 downto 0)
    ) return boolean;

    function crc_rev(
        crc : in std_logic_vector(31 downto 0)
    ) return std_logic_vector;

    function byte_rev(
        b : in std_logic_vector(7 downto 0)
    ) return std_logic_vector;

    function is_tchar(
        byte : std_logic_vector(7 downto 0)
    ) return boolean;

    function crc8B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(63 downto 0)
    ) return std_logic_vector;

    function crc7B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(55 downto 0)
    ) return std_logic_vector;

    function crc6B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(47 downto 0)
    ) return std_logic_vector;

    function crc5B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(39 downto 0)
    ) return std_logic_vector;

    function crc4B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(31 downto 0)
    ) return std_logic_vector;

    function crc3B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(23 downto 0)
    ) return std_logic_vector;

    function crc2B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(15 downto 0)
    ) return std_logic_vector;

    function crc1B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(7 downto 0)
    ) return std_logic_vector;
end package;

package body xgmii_includes is
    --//////////////////////////////////////////////
    -- sof_lane0
    --//////////////////////////////////////////////
    function sof_lane0(
        xgmii_d : in std_logic_vector(63 downto 0);
        xgmii_c : in std_logic_vector(7 downto 0)
    ) return boolean is
    begin
        if xgmii_d(7 downto 0) = S and xgmii_c(0) = '1' then
            return true;
        else
            return false;
        end if;
    end function;

    --/////////////////////////////////////////////
    -- sof_lane4
    --/////////////////////////////////////////////
    function sof_lane4(
        xgmii_d : in std_logic_vector(63 downto 0);
        xgmii_c : in std_logic_vector(7 downto 0)
    ) return boolean is
    begin
        if xgmii_d(39 downto 32) = S and xgmii_c(4) = '1' then
            return true;
        else
            return false;
        end if;
    end function;

    --/////////////////////////////////////////////
    -- crc_rev
    --/////////////////////////////////////////////
    function crc_rev(
        crc : in std_logic_vector(31 downto 0)
    ) return std_logic_vector is
        variable o : std_logic_vector(31 downto 0);
    begin
        for idx in 0 to 31 loop
            o(idx) := crc(31 - idx);
        end loop;
        return o;
    end function;

    --//////////////////////////////////////////////
    -- byte_rev
    --//////////////////////////////////////////////
    function byte_rev(
        b : in std_logic_vector(7 downto 0)
    ) return std_logic_vector is
        variable o : std_logic_vector(7 downto 0);
    begin
        for idx in 0 to 8 loop
            o(idx) := b(7 - idx);
        end loop;
        return o;
    end function;

    --//////////////////////////////////////////////
    -- is_tchar
    --//////////////////////////////////////////////
    function is_tchar(
        byte : std_logic_vector(7 downto 0)
    ) return boolean is
    begin
        if byte = T then
            return true;
        else
            return false;
        end if;
    end function;

    --//////////////////////////////////////////////
    -- crc8B
    --//////////////////////////////////////////////
    function crc8B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(63 downto 0)
    ) return std_logic_vector is
        variable o : std_logic_vector(31 downto 0);
    begin
        o(0)  := d(15) xor c(12) xor d(63) xor d(47) xor d(39) xor d(5) xor d(32) xor c(28) xor d(16) xor c(21) xor c(13) xor c(0) xor d(33) xor c(29) xor c(22) xor d(10) xor d(57) xor d(34) xor d(0) xor d(26) xor c(31) xor d(18) xor c(23) xor c(15) xor d(51) xor c(2) xor d(8) xor d(35) xor d(19) xor c(16) xor d(9) xor d(2) xor d(13) xor d(53) xor d(37) xor d(3) xor d(29) xor c(26) xor c(18) xor d(54) xor c(5) xor d(38) xor d(31);
        o(1)  := c(27) xor c(19) xor c(12) xor d(63) xor c(6) xor d(47) xor d(39) xor d(5) xor c(28) xor d(16) xor c(21) xor d(56) xor d(25) xor c(30) xor d(17) xor d(10) xor c(14) xor d(57) xor d(50) xor c(1) xor d(7) xor d(0) xor d(26) xor c(31) xor c(15) xor d(51) xor c(2) xor d(35) xor d(1) xor d(19) xor d(12) xor c(24) xor d(52) xor c(3) xor d(36) xor d(28) xor d(13) xor c(17) xor d(3) xor d(30) xor d(29) xor c(26) xor d(14) xor c(18) xor d(62) xor d(54) xor c(5) xor d(46) xor d(4);
        o(2)  := c(27) xor c(19) xor c(20) xor c(12) xor d(63) xor d(55) xor c(6) xor d(47) xor d(39) xor d(5) xor d(32) xor d(24) xor c(21) xor d(56) xor c(7) xor c(0) xor d(33) xor d(6) xor d(25) xor d(10) xor d(57) xor d(50) xor d(49) xor d(26) xor d(11) xor c(23) xor d(8) xor d(27) xor d(19) xor d(12) xor c(3) xor d(28) xor c(25) xor d(61) xor d(45) xor c(4) xor d(37) xor c(26) xor d(62) xor d(54) xor c(5) xor d(46) xor d(4) xor d(31);
        o(3)  := d(23) xor c(27) xor c(20) xor d(55) xor c(6) xor d(32) xor d(5) xor d(24) xor c(28) xor c(21) xor c(13) xor d(56) xor c(7) xor d(48) xor c(0) xor d(25) xor d(10) xor c(22) xor c(8) xor d(49) xor c(1) xor d(7) xor d(26) xor d(18) xor d(11) xor d(27) xor c(24) xor d(60) xor d(44) xor d(9) xor d(36) xor d(61) xor d(53) xor c(4) xor d(45) xor d(3) xor d(30) xor c(26) xor d(62) xor d(54) xor c(5) xor d(46) xor d(38) xor d(4) xor d(31);
        o(4)  := d(23) xor d(15) xor c(27) xor c(12) xor d(63) xor d(55) xor c(6) xor d(39) xor d(5) xor d(32) xor d(24) xor d(16) xor c(13) xor c(7) xor d(48) xor d(33) xor d(6) xor d(25) xor d(17) xor c(14) xor d(57) xor c(8) xor c(1) xor d(34) xor d(0) xor c(31) xor d(18) xor c(15) xor d(51) xor c(9) xor d(43) xor d(19) xor c(16) xor d(60) xor d(59) xor d(52) xor d(44) xor c(25) xor d(13) xor d(61) xor d(45) xor d(30) xor d(22) xor c(26) xor c(18) xor d(38) xor d(4);
        o(5)  := d(23) xor c(27) xor c(19) xor c(12) xor d(63) xor d(39) xor d(24) xor c(21) xor d(56) xor c(7) xor c(29) xor d(17) xor c(22) xor d(10) xor c(14) xor d(57) xor c(8) xor d(50) xor d(42) xor d(34) xor d(0) xor d(26) xor c(31) xor c(23) xor d(58) xor c(9) xor d(43) xor d(8) xor d(35) xor d(19) xor d(12) xor d(60) xor d(59) xor d(44) xor d(9) xor d(2) xor d(21) xor d(13) xor c(17) xor c(10) xor d(53) xor d(22) xor d(14) xor c(18) xor d(62) xor c(5) xor d(4);
        o(6)  := d(23) xor c(20) xor c(19) xor d(55) xor c(6) xor d(16) xor c(28) xor c(13) xor d(56) xor d(41) xor d(33) xor d(25) xor c(30) xor c(22) xor d(57) xor c(8) xor d(49) xor d(42) xor d(7) xor d(34) xor d(18) xor c(23) xor d(11) xor c(15) xor d(58) xor c(9) xor d(43) xor d(8) xor d(1) xor d(20) xor c(24) xor d(12) xor d(59) xor d(52) xor d(9) xor d(21) xor d(13) xor c(10) xor d(61) xor d(3) xor d(22) xor c(18) xor c(11) xor d(62) xor d(38);
        o(7)  := c(19) xor c(20) xor d(63) xor d(55) xor d(47) xor d(39) xor d(40) xor d(5) xor d(24) xor c(28) xor d(16) xor c(13) xor d(56) xor c(7) xor d(48) xor d(41) xor c(0) xor d(6) xor d(17) xor c(22) xor c(14) xor d(42) xor d(7) xor d(34) xor d(26) xor d(18) xor d(11) xor c(15) xor d(58) xor c(9) xor c(2) xor d(35) xor d(20) xor d(12) xor c(24) xor d(60) xor d(9) xor d(21) xor c(25) xor d(13) xor c(10) xor d(61) xor d(53) xor d(3) xor d(29) xor d(22) xor c(26) xor c(18) xor c(11) xor c(5) xor d(38) xor d(31);
        o(8)  := d(23) xor c(27) xor c(19) xor c(20) xor d(63) xor d(55) xor c(6) xor d(40) xor d(32) xor c(28) xor c(13) xor d(41) xor c(0) xor d(6) xor d(25) xor d(17) xor c(22) xor c(14) xor c(8) xor c(1) xor d(0) xor d(26) xor c(31) xor d(18) xor d(11) xor d(51) xor c(2) xor d(35) xor d(20) xor d(12) xor d(60) xor d(59) xor d(52) xor c(3) xor d(9) xor d(28) xor d(21) xor c(25) xor d(13) xor c(10) xor d(53) xor d(3) xor d(30) xor d(29) xor c(18) xor c(11) xor d(62) xor c(5) xor d(46) xor d(4) xor d(31);
        o(9)  := c(20) xor c(19) xor c(12) xor c(6) xor d(40) xor d(39) xor d(5) xor d(24) xor d(16) xor c(28) xor c(21) xor c(7) xor c(0) xor d(25) xor c(29) xor d(17) xor d(10) xor c(14) xor d(50) xor c(1) xor d(34) xor c(23) xor d(11) xor c(15) xor d(58) xor c(9) xor d(51) xor c(2) xor d(8) xor d(27) xor d(20) xor d(19) xor d(12) xor d(59) xor d(52) xor c(3) xor d(2) xor d(28) xor d(61) xor c(4) xor d(45) xor d(3) xor d(29) xor d(30) xor d(22) xor c(26) xor c(11) xor d(62) xor d(54) xor d(31);
        o(10) := d(23) xor c(27) xor c(20) xor d(63) xor d(47) xor d(5) xor d(32) xor d(24) xor c(28) xor c(7) xor c(0) xor c(30) xor c(8) xor d(49) xor d(50) xor c(1) xor d(7) xor d(34) xor d(0) xor c(31) xor d(11) xor c(23) xor d(58) xor d(8) xor d(35) xor d(27) xor d(1) xor c(24) xor d(60) xor c(3) xor d(44) xor d(28) xor d(21) xor d(13) xor c(10) xor d(61) xor c(4) xor d(37) xor d(3) xor d(30) xor c(26) xor c(18) xor d(54) xor d(4) xor d(31);
        o(11) := d(23) xor d(15) xor c(27) xor c(19) xor c(12) xor d(63) xor d(47) xor d(39) xor d(5) xor d(32) xor d(16) xor c(13) xor d(48) xor d(6) xor c(22) xor c(8) xor d(49) xor c(1) xor d(7) xor d(18) xor c(23) xor c(15) xor d(51) xor c(9) xor d(43) xor d(8) xor d(35) xor d(27) xor d(20) xor d(19) xor d(12) xor c(24) xor c(16) xor d(60) xor d(59) xor d(9) xor d(36) xor c(25) xor d(13) xor c(4) xor d(37) xor d(30) xor d(22) xor c(26) xor c(18) xor c(11) xor d(62) xor d(54) xor d(46) xor d(38) xor d(4);
        o(12) := c(27) xor c(19) xor c(20) xor d(63) xor d(39) xor d(32) xor d(16) xor c(21) xor d(48) xor d(33) xor d(6) xor c(29) xor d(17) xor c(22) xor d(10) xor c(14) xor d(57) xor d(50) xor d(42) xor d(7) xor d(0) xor c(31) xor d(11) xor c(15) xor d(58) xor d(51) xor c(9) xor d(12) xor c(24) xor d(59) xor d(9) xor d(36) xor d(2) xor d(21) xor c(25) xor d(13) xor c(17) xor c(10) xor d(61) xor d(45) xor d(22) xor d(14) xor c(18) xor d(62) xor d(54) xor d(46) xor d(4);
        o(13) := d(15) xor c(20) xor c(19) xor d(47) xor d(32) xor d(5) xor d(16) xor c(28) xor c(21) xor d(56) xor d(41) xor c(0) xor d(6) xor c(30) xor d(10) xor c(22) xor d(57) xor d(50) xor d(49) xor c(23) xor d(11) xor c(15) xor d(58) xor d(8) xor d(35) xor d(1) xor d(20) xor d(12) xor c(16) xor d(60) xor d(44) xor d(9) xor d(21) xor c(25) xor d(13) xor c(10) xor d(61) xor d(53) xor d(45) xor d(3) xor c(26) xor c(18) xor c(11) xor d(62) xor d(38) xor d(31);
        o(14) := c(27) xor d(15) xor c(19) xor c(20) xor c(12) xor d(55) xor d(40) xor d(5) xor c(21) xor d(56) xor d(48) xor c(0) xor c(29) xor d(10) xor c(22) xor d(57) xor d(49) xor c(1) xor d(7) xor d(34) xor d(0) xor c(31) xor d(11) xor c(23) xor d(43) xor d(8) xor d(19) xor d(20) xor c(24) xor d(12) xor c(16) xor d(60) xor d(59) xor d(52) xor d(44) xor d(9) xor d(2) xor c(17) xor d(61) xor d(37) xor d(30) xor c(26) xor d(14) xor c(11) xor d(46) xor d(31) xor d(4);
        o(15) := c(27) xor c(20) xor c(12) xor d(55) xor d(47) xor d(39) xor c(28) xor c(21) xor c(13) xor d(56) xor d(48) xor d(6) xor d(33) xor c(30) xor c(22) xor d(10) xor d(42) xor c(1) xor d(7) xor d(18) xor c(23) xor d(11) xor d(58) xor d(51) xor c(2) xor d(43) xor d(8) xor d(1) xor d(19) xor c(24) xor d(60) xor d(59) xor d(36) xor d(9) xor c(25) xor d(13) xor c(17) xor d(45) xor d(30) xor d(3) xor d(29) xor d(14) xor c(18) xor d(54) xor d(4);
        o(16) := d(15) xor c(19) xor c(12) xor d(63) xor d(55) xor d(39) xor d(16) xor d(41) xor c(0) xor d(33) xor d(6) xor d(17) xor c(14) xor d(50) xor d(42) xor d(7) xor d(34) xor d(26) xor c(15) xor d(58) xor d(51) xor d(19) xor d(12) xor c(24) xor c(16) xor d(59) xor c(3) xor d(44) xor d(28) xor c(25) xor d(37) xor c(5) xor d(46) xor d(31);
        o(17) := d(15) xor c(20) xor c(6) xor d(40) xor d(32) xor d(5) xor d(16) xor c(13) xor d(41) xor d(6) xor d(33) xor d(25) xor d(57) xor d(50) xor d(49) xor c(1) xor d(18) xor d(11) xor c(15) xor d(58) xor d(43) xor d(27) xor c(16) xor d(36) xor c(25) xor c(17) xor c(4) xor d(45) xor d(30) xor d(14) xor c(26) xor d(62) xor d(54) xor d(38);
        o(18) := c(27) xor d(15) xor d(40) xor d(39) xor d(5) xor d(32) xor d(24) xor c(21) xor d(56) xor c(7) xor d(48) xor c(0) xor d(17) xor d(10) xor c(14) xor d(57) xor d(49) xor d(42) xor d(26) xor c(2) xor d(35) xor c(16) xor d(44) xor d(13) xor c(17) xor d(61) xor d(53) xor d(37) xor d(29) xor c(26) xor d(14) xor c(18) xor c(5) xor d(31) xor d(4);
        o(19) := d(23) xor c(27) xor c(19) xor d(55) xor c(6) xor d(47) xor d(39) xor c(28) xor d(16) xor d(56) xor d(48) xor d(41) xor c(0) xor d(25) xor c(22) xor c(8) xor c(1) xor d(34) xor c(15) xor d(43) xor d(12) xor d(60) xor d(52) xor c(3) xor d(36) xor d(9) xor d(28) xor d(13) xor c(17) xor d(30) xor d(3) xor d(14) xor c(18) xor d(38) xor d(4) xor d(31);
        o(20) := d(15) xor c(20) xor c(19) xor d(55) xor d(47) xor d(40) xor d(24) xor c(28) xor c(7) xor d(33) xor c(29) xor c(1) xor d(42) xor d(11) xor c(23) xor c(9) xor d(51) xor c(2) xor d(35) xor d(8) xor d(27) xor d(12) xor c(16) xor d(59) xor d(2) xor d(13) xor c(4) xor d(37) xor d(29) xor d(3) xor d(30) xor d(22) xor c(18) xor d(54) xor d(46) xor d(38);
        o(21) := d(23) xor c(19) xor c(20) xor d(39) xor d(32) xor c(21) xor d(41) xor c(30) xor c(29) xor d(10) xor c(8) xor d(50) xor d(34) xor d(7) xor d(26) xor d(11) xor d(58) xor c(2) xor d(1) xor c(24) xor d(12) xor c(3) xor d(36) xor d(28) xor d(2) xor d(21) xor c(17) xor c(10) xor d(53) xor d(45) xor d(37) xor d(29) xor d(14) xor d(54) xor d(46) xor c(5);
        o(22) := d(15) xor c(20) xor c(12) xor d(63) xor c(6) xor d(47) xor d(39) xor d(40) xor d(5) xor d(32) xor c(28) xor d(16) xor c(13) xor d(6) xor d(25) xor c(29) xor c(30) xor d(49) xor d(34) xor d(26) xor d(18) xor d(11) xor c(23) xor c(15) xor d(51) xor c(9) xor c(2) xor d(8) xor d(27) xor d(1) xor d(20) xor d(19) xor c(16) xor d(52) xor c(3) xor d(44) xor d(36) xor d(2) xor d(28) xor c(25) xor d(45) xor c(4) xor d(37) xor d(3) xor d(29) xor d(22) xor c(26) xor c(11) xor d(54) xor c(5);
        o(23) := c(27) xor d(63) xor c(6) xor d(47) xor d(32) xor d(24) xor c(28) xor d(16) xor c(7) xor d(48) xor d(25) xor c(30) xor d(17) xor c(22) xor c(14) xor d(57) xor d(50) xor d(7) xor d(34) xor c(23) xor c(15) xor c(2) xor d(43) xor d(8) xor d(27) xor d(1) xor c(24) xor c(3) xor d(44) xor d(9) xor d(36) xor d(28) xor d(21) xor d(13) xor c(17) xor c(10) xor c(4) xor d(37) xor d(3) xor d(29) xor d(14) xor c(18) xor d(62) xor d(54) xor d(46) xor d(4);
        o(24) := d(23) xor d(15) xor c(19) xor d(47) xor d(24) xor d(16) xor c(28) xor d(56) xor c(7) xor c(0) xor d(6) xor d(33) xor c(29) xor c(8) xor d(49) xor d(42) xor d(7) xor d(26) xor d(0) xor c(31) xor c(23) xor c(15) xor d(43) xor d(8) xor d(35) xor d(27) xor d(20) xor c(24) xor d(12) xor c(16) xor c(3) xor d(36) xor d(2) xor d(28) xor c(25) xor d(13) xor d(61) xor d(53) xor c(4) xor d(45) xor d(3) xor c(18) xor c(11) xor d(62) xor c(5) xor d(46) xor d(31);
        o(25) := d(23) xor d(15) xor c(19) xor c(20) xor c(12) xor d(55) xor c(6) xor d(5) xor d(32) xor d(48) xor d(41) xor d(6) xor d(25) xor c(30) xor c(29) xor c(8) xor c(1) xor d(42) xor d(7) xor d(34) xor d(26) xor d(11) xor c(9) xor d(35) xor d(1) xor d(27) xor d(19) xor c(24) xor d(12) xor c(16) xor d(60) xor d(52) xor d(44) xor d(2) xor c(25) xor c(17) xor d(61) xor c(4) xor d(45) xor d(30) xor d(22) xor c(26) xor d(14) xor d(46) xor c(5);
        o(26) := d(15) xor c(27) xor c(20) xor c(12) xor d(63) xor c(6) xor d(39) xor d(40) xor d(32) xor d(24) xor c(28) xor d(16) xor c(7) xor d(41) xor d(6) xor d(25) xor c(29) xor c(30) xor c(22) xor d(57) xor d(11) xor c(23) xor c(15) xor c(9) xor d(43) xor d(8) xor d(35) xor d(1) xor d(19) xor c(16) xor d(60) xor d(59) xor d(44) xor d(9) xor d(2) xor d(21) xor c(25) xor c(17) xor c(10) xor d(53) xor d(45) xor d(37) xor d(3) xor d(22) xor d(14) xor d(38) xor d(4);
        o(27) := d(23) xor d(15) xor d(40) xor d(39) xor d(5) xor d(24) xor c(28) xor c(21) xor c(13) xor d(56) xor c(7) xor c(0) xor c(29) xor c(30) xor d(10) xor c(8) xor d(42) xor d(7) xor d(34) xor d(0) xor c(31) xor d(18) xor c(23) xor d(58) xor d(43) xor d(8) xor d(1) xor d(20) xor c(24) xor c(16) xor d(59) xor d(52) xor d(44) xor d(36) xor d(2) xor d(21) xor d(13) xor c(17) xor c(10) xor d(37) xor d(3) xor d(14) xor c(26) xor c(18) xor c(11) xor d(62) xor d(38) xor d(31);
        o(28) := d(23) xor c(27) xor c(19) xor c(12) xor d(55) xor d(39) xor d(41) xor d(6) xor d(33) xor c(30) xor c(29) xor d(17) xor c(22) xor c(14) xor d(57) xor c(8) xor c(1) xor d(42) xor d(7) xor d(0) xor c(31) xor d(58) xor c(9) xor d(51) xor d(43) xor d(35) xor d(1) xor d(19) xor d(20) xor c(24) xor d(12) xor d(9) xor d(36) xor d(2) xor d(13) xor c(25) xor c(17) xor d(61) xor d(37) xor d(30) xor d(22) xor d(14) xor c(18) xor c(11) xor d(38) xor d(4);
        o(29) := c(19) xor c(20) xor c(12) xor d(40) xor d(5) xor d(32) xor c(28) xor d(16) xor c(13) xor d(56) xor d(41) xor d(6) xor c(30) xor d(57) xor d(50) xor d(42) xor d(34) xor d(0) xor d(18) xor c(31) xor c(23) xor d(11) xor c(15) xor c(9) xor c(2) xor d(8) xor d(35) xor d(1) xor d(19) xor d(12) xor d(60) xor d(36) xor d(21) xor c(25) xor d(13) xor c(10) xor d(37) xor d(3) xor d(29) xor d(22) xor c(26) xor c(18) xor d(54) xor d(38);
        o(30) := c(27) xor d(15) xor c(20) xor c(19) xor d(55) xor d(40) xor d(39) xor d(5) xor c(21) xor c(13) xor d(56) xor d(41) xor c(0) xor d(33) xor d(17) xor c(29) xor d(10) xor c(14) xor d(49) xor d(7) xor d(34) xor d(0) xor c(31) xor d(18) xor d(11) xor d(35) xor d(20) xor c(24) xor d(12) xor c(16) xor d(59) xor c(3) xor d(36) xor d(2) xor d(28) xor d(21) xor c(10) xor d(53) xor d(37) xor c(26) xor c(11) xor d(4) xor d(31);
        o(31) := c(27) xor c(20) xor c(12) xor d(55) xor d(40) xor d(39) xor d(32) xor d(16) xor c(28) xor c(21) xor d(48) xor d(6) xor d(33) xor c(30) xor d(17) xor d(10) xor c(22) xor c(14) xor c(1) xor d(34) xor d(11) xor c(15) xor d(58) xor d(35) xor d(1) xor d(27) xor d(19) xor d(20) xor d(52) xor d(9) xor d(36) xor c(25) xor c(17) xor c(4) xor d(3) xor d(30) xor d(14) xor c(11) xor d(54) xor d(38) xor d(4);
        return o;
    end function;

    --//////////////////////////////////////////////
    -- crc7B
    --//////////////////////////////////////////////
    function crc7B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(55 downto 0)
    ) return std_logic_vector is
        variable o : std_logic_vector(31 downto 0);
    begin
        o(0)  := d(23) xor c(20) xor d(55) xor c(6) xor d(39) xor d(5) xor d(24) xor c(21) xor c(13) xor c(7) xor c(0) xor d(25) xor c(30) xor c(29) xor d(10) xor d(49) xor c(8) xor c(1) xor d(7) xor d(0) xor d(26) xor c(31) xor d(18) xor d(11) xor c(23) xor d(43) xor c(2) xor d(8) xor d(1) xor d(27) xor c(24) xor d(2) xor d(21) xor c(10) xor c(4) xor d(45) xor d(30) xor d(29) xor c(26) xor d(46) xor c(5) xor d(31);
        o(1)  := c(27) xor c(20) xor d(55) xor d(39) xor d(5) xor c(13) xor d(48) xor c(0) xor d(6) xor c(29) xor d(17) xor c(22) xor c(14) xor d(49) xor d(42) xor d(18) xor d(11) xor c(23) xor c(9) xor d(43) xor d(8) xor d(27) xor d(20) xor c(3) xor d(44) xor d(9) xor d(2) xor d(28) xor d(21) xor c(25) xor c(10) xor c(4) xor d(22) xor c(26) xor c(11) xor d(54) xor d(46) xor d(38) xor d(31) xor d(4);
        o(2)  := d(23) xor c(27) xor c(20) xor c(12) xor d(55) xor c(6) xor d(47) xor d(39) xor d(24) xor c(28) xor d(16) xor c(13) xor c(7) xor d(48) xor c(0) xor d(41) xor d(25) xor c(29) xor d(17) xor c(14) xor d(49) xor c(8) xor d(42) xor d(0) xor c(31) xor d(18) xor d(11) xor c(15) xor c(2) xor d(19) xor d(20) xor d(2) xor d(53) xor d(37) xor d(3) xor d(29) xor c(11) xor d(54) xor d(46) xor d(38) xor d(31) xor d(4);
        o(3)  := d(23) xor d(15) xor c(12) xor d(47) xor d(40) xor d(24) xor c(28) xor d(16) xor c(21) xor c(13) xor d(48) xor c(7) xor d(41) xor c(29) xor c(30) xor d(17) xor d(10) xor c(14) xor c(8) xor c(1) xor d(18) xor c(15) xor c(9) xor d(1) xor d(19) xor c(16) xor d(52) xor c(3) xor d(36) xor d(2) xor d(28) xor d(53) xor d(45) xor d(37) xor d(30) xor d(3) xor d(22) xor d(54) xor d(46) xor d(38);
        o(4)  := d(15) xor c(20) xor d(55) xor c(6) xor d(47) xor d(40) xor d(5) xor d(24) xor d(16) xor c(21) xor c(7) xor c(0) xor d(25) xor d(17) xor d(10) xor c(22) xor c(14) xor d(49) xor c(1) xor d(7) xor d(26) xor d(11) xor c(23) xor c(15) xor c(9) xor d(51) xor d(43) xor d(8) xor d(35) xor c(24) xor c(16) xor d(52) xor d(44) xor d(9) xor d(36) xor c(17) xor d(53) xor d(37) xor d(30) xor d(22) xor c(26) xor d(14) xor c(5) xor d(31);
        o(5)  := c(27) xor d(15) xor c(20) xor d(55) xor d(5) xor d(16) xor c(13) xor d(48) xor c(0) xor d(6) xor c(30) xor c(29) xor c(22) xor d(49) xor d(50) xor d(42) xor d(34) xor d(0) xor d(26) xor c(31) xor d(18) xor d(11) xor c(15) xor d(51) xor d(35) xor d(1) xor d(27) xor c(16) xor d(52) xor d(9) xor d(36) xor d(2) xor d(13) xor c(25) xor c(17) xor c(4) xor d(45) xor c(26) xor d(14) xor c(18) xor d(54) xor c(5) xor d(31) xor d(4);
        o(6)  := d(15) xor c(27) xor c(19) xor c(6) xor d(47) xor d(5) xor c(28) xor c(21) xor d(48) xor d(41) xor d(33) xor d(25) xor c(30) xor d(17) xor d(10) xor c(14) xor d(50) xor d(49) xor c(1) xor d(34) xor d(0) xor d(26) xor c(31) xor c(23) xor d(51) xor d(8) xor d(35) xor d(1) xor d(12) xor c(16) xor d(44) xor d(13) xor c(17) xor d(53) xor d(30) xor d(3) xor c(26) xor d(14) xor c(18) xor d(54) xor c(5) xor d(4);
        o(7)  := d(23) xor c(27) xor c(19) xor d(55) xor d(47) xor d(40) xor d(39) xor d(5) xor d(32) xor c(28) xor d(16) xor c(21) xor c(13) xor d(48) xor c(0) xor d(33) xor c(30) xor d(10) xor c(22) xor c(8) xor d(50) xor c(1) xor d(34) xor d(26) xor d(18) xor c(23) xor c(15) xor d(8) xor d(1) xor d(27) xor d(12) xor d(52) xor d(9) xor d(21) xor d(13) xor c(17) xor c(10) xor d(53) xor c(4) xor d(45) xor d(3) xor d(30) xor c(26) xor d(14) xor c(18) xor c(5) xor d(31) xor d(4);
        o(8)  := d(23) xor c(27) xor d(15) xor c(19) xor d(55) xor d(47) xor d(5) xor d(32) xor d(24) xor c(28) xor c(21) xor c(13) xor c(7) xor d(33) xor c(30) xor d(17) xor d(10) xor c(22) xor c(14) xor c(8) xor d(18) xor c(9) xor d(51) xor d(43) xor d(1) xor d(27) xor d(20) xor d(12) xor c(16) xor d(52) xor d(44) xor d(9) xor d(21) xor d(13) xor c(10) xor c(4) xor d(45) xor d(3) xor d(22) xor c(26) xor c(18) xor c(11) xor d(54) xor d(38) xor d(4);
        o(9)  := d(23) xor c(27) xor c(19) xor c(20) xor c(12) xor d(32) xor c(28) xor d(16) xor c(0) xor c(29) xor d(17) xor c(22) xor c(14) xor c(8) xor d(50) xor d(42) xor d(0) xor d(26) xor c(31) xor c(23) xor d(11) xor c(15) xor c(9) xor d(51) xor d(43) xor d(8) xor d(20) xor d(19) xor d(12) xor d(44) xor d(9) xor d(2) xor d(21) xor c(17) xor c(10) xor d(53) xor d(37) xor d(3) xor d(22) xor d(14) xor c(11) xor d(54) xor c(5) xor d(46) xor d(4) xor d(31);
        o(10) := d(23) xor d(15) xor c(12) xor d(55) xor d(39) xor d(5) xor d(24) xor c(28) xor d(16) xor c(7) xor d(41) xor c(8) xor d(50) xor d(42) xor d(0) xor d(26) xor c(31) xor c(15) xor c(9) xor c(2) xor d(27) xor d(19) xor d(20) xor c(16) xor d(52) xor d(36) xor d(13) xor d(53) xor c(4) xor d(3) xor d(29) xor d(22) xor c(26) xor c(18) xor c(11) xor d(46) xor c(5);
        o(11) := c(27) xor d(15) xor c(19) xor c(20) xor c(12) xor d(55) xor d(40) xor d(39) xor d(5) xor d(24) xor c(21) xor c(7) xor c(0) xor d(41) xor c(30) xor d(10) xor c(1) xor d(7) xor d(0) xor c(31) xor d(11) xor c(23) xor c(9) xor d(51) xor d(43) xor c(2) xor d(8) xor d(35) xor d(1) xor d(27) xor d(19) xor c(24) xor d(12) xor c(16) xor d(52) xor c(3) xor d(28) xor c(17) xor c(4) xor d(30) xor d(29) xor d(22) xor c(26) xor d(14) xor d(54) xor d(46) xor d(38) xor d(31) xor d(4);
        o(12) := c(27) xor d(55) xor c(6) xor d(40) xor d(5) xor d(24) xor c(28) xor c(7) xor c(0) xor d(6) xor d(25) xor c(30) xor c(29) xor c(22) xor d(49) xor d(50) xor d(42) xor d(34) xor c(23) xor d(51) xor d(43) xor d(8) xor d(1) xor c(3) xor d(9) xor d(2) xor d(28) xor d(13) xor c(25) xor c(17) xor d(53) xor d(37) xor d(3) xor c(26) xor d(14) xor c(18) xor d(54) xor d(46) xor d(38) xor d(31) xor d(4);
        o(13) := d(23) xor c(27) xor c(19) xor d(39) xor d(5) xor d(24) xor c(28) xor d(48) xor c(7) xor d(41) xor d(33) xor c(29) xor c(30) xor c(8) xor d(50) xor d(49) xor d(42) xor c(1) xor d(7) xor d(0) xor c(31) xor c(23) xor d(8) xor d(1) xor d(27) xor d(12) xor c(24) xor d(52) xor d(36) xor d(2) xor d(13) xor d(53) xor c(4) xor d(45) xor d(37) xor d(30) xor d(3) xor c(26) xor c(18) xor d(54) xor d(4);
        o(14) := d(23) xor c(27) xor c(20) xor c(19) xor d(47) xor d(40) xor d(32) xor c(28) xor d(48) xor d(41) xor d(6) xor c(29) xor c(30) xor c(8) xor d(49) xor d(7) xor d(0) xor d(26) xor c(31) xor d(11) xor c(9) xor d(51) xor c(2) xor d(35) xor d(1) xor c(24) xor d(12) xor d(52) xor d(44) xor d(36) xor d(2) xor c(25) xor d(53) xor d(29) xor d(3) xor d(22) xor c(5) xor d(38) xor d(4);
        o(15) := c(20) xor c(6) xor d(47) xor d(40) xor d(39) xor d(5) xor c(28) xor c(21) xor d(48) xor c(0) xor d(6) xor d(25) xor c(30) xor c(29) xor d(10) xor d(50) xor d(34) xor d(0) xor c(31) xor d(11) xor c(9) xor d(51) xor d(43) xor d(35) xor d(1) xor d(52) xor c(3) xor d(28) xor d(2) xor d(21) xor c(25) xor c(10) xor d(37) xor d(3) xor d(22) xor c(26) xor d(46) xor d(31);
        o(16) := d(23) xor c(27) xor c(20) xor d(55) xor c(6) xor d(47) xor c(13) xor c(0) xor d(33) xor d(25) xor c(22) xor c(8) xor d(50) xor d(42) xor d(7) xor d(34) xor d(26) xor d(18) xor d(11) xor c(23) xor d(51) xor d(43) xor c(2) xor d(8) xor d(20) xor c(24) xor d(9) xor d(36) xor d(29) xor c(11) xor c(5) xor d(38) xor d(31) xor d(4);
        o(17) := c(12) xor c(6) xor d(32) xor d(24) xor c(28) xor c(21) xor c(7) xor d(41) xor d(6) xor d(33) xor d(25) xor d(17) xor d(10) xor c(14) xor d(50) xor d(49) xor d(42) xor c(1) xor d(7) xor c(23) xor c(9) xor d(8) xor d(35) xor d(19) xor c(24) xor c(3) xor d(28) xor c(25) xor d(37) xor d(30) xor d(3) xor d(22) xor d(54) xor d(46);
        o(18) := d(23) xor d(40) xor d(5) xor d(32) xor d(24) xor d(16) xor c(13) xor c(7) xor d(48) xor d(41) xor c(0) xor d(6) xor c(29) xor c(22) xor c(8) xor d(49) xor d(7) xor d(34) xor d(18) xor c(15) xor c(2) xor d(27) xor c(24) xor d(9) xor d(36) xor d(2) xor d(21) xor c(25) xor c(10) xor d(53) xor c(4) xor d(45) xor d(29) xor c(26) xor d(31);
        o(19) := d(23) xor c(27) xor d(15) xor d(47) xor d(40) xor d(39) xor d(5) xor d(48) xor c(0) xor d(6) xor d(33) xor c(30) xor d(17) xor c(14) xor c(8) xor c(1) xor d(26) xor c(23) xor c(9) xor d(8) xor d(35) xor d(1) xor d(20) xor c(16) xor d(52) xor c(3) xor d(44) xor d(28) xor c(25) xor d(30) xor d(22) xor c(26) xor c(11) xor c(5) xor d(4) xor d(31);
        o(20) := c(27) xor c(12) xor c(6) xor d(47) xor d(39) xor d(5) xor d(32) xor c(28) xor d(16) xor d(25) xor c(1) xor d(7) xor d(34) xor d(0) xor c(31) xor c(15) xor d(51) xor c(9) xor c(2) xor d(43) xor d(27) xor d(19) xor c(24) xor d(21) xor c(17) xor c(10) xor c(4) xor d(3) xor d(30) xor d(29) xor d(22) xor c(26) xor d(14) xor d(46) xor d(38) xor d(4);
        o(21) := c(27) xor d(15) xor d(24) xor c(28) xor c(13) xor c(7) xor c(0) xor d(6) xor d(33) xor c(29) xor d(50) xor d(42) xor d(26) xor d(18) xor c(2) xor d(20) xor c(16) xor c(3) xor d(2) xor d(28) xor d(21) xor c(25) xor d(13) xor c(10) xor d(45) xor d(37) xor d(3) xor d(29) xor c(18) xor c(11) xor c(5) xor d(46) xor d(38) xor d(4) xor d(31);
        o(22) := c(19) xor c(20) xor c(12) xor d(55) xor d(39) xor d(32) xor d(24) xor c(28) xor c(21) xor c(13) xor c(7) xor c(0) xor d(41) xor d(17) xor d(10) xor c(14) xor d(7) xor d(0) xor d(26) xor c(31) xor d(18) xor d(11) xor c(23) xor d(43) xor c(2) xor d(8) xor d(19) xor d(20) xor c(24) xor d(12) xor c(3) xor d(44) xor d(36) xor d(28) xor d(21) xor c(17) xor c(10) xor d(37) xor d(3) xor d(29) xor d(14) xor c(11) xor d(46) xor c(5) xor d(31);
        o(23) := c(12) xor d(55) xor d(40) xor d(39) xor d(5) xor d(24) xor d(16) xor c(7) xor d(6) xor c(30) xor d(17) xor c(22) xor c(14) xor d(49) xor d(42) xor d(0) xor d(26) xor c(31) xor c(23) xor c(15) xor c(2) xor d(8) xor d(35) xor d(1) xor d(19) xor d(20) xor c(3) xor d(9) xor d(36) xor d(28) xor d(21) xor d(13) xor c(25) xor c(10) xor d(29) xor c(26) xor c(18) xor c(11) xor d(54) xor d(46) xor c(5) xor d(38);
        o(24) := d(23) xor d(15) xor c(27) xor c(19) xor c(12) xor c(6) xor d(39) xor d(5) xor d(16) xor c(13) xor d(48) xor d(41) xor d(25) xor c(8) xor d(7) xor d(34) xor d(0) xor d(18) xor c(31) xor c(23) xor c(15) xor d(8) xor d(35) xor d(27) xor d(20) xor d(19) xor d(12) xor c(24) xor c(16) xor c(3) xor d(28) xor d(53) xor c(4) xor d(45) xor d(37) xor c(26) xor c(11) xor d(54) xor d(38) xor d(4);
        o(25) := c(27) xor d(15) xor c(20) xor c(12) xor d(47) xor d(40) xor d(24) xor c(28) xor c(13) xor c(7) xor d(6) xor d(33) xor d(17) xor c(14) xor d(7) xor d(34) xor d(26) xor d(18) xor d(11) xor c(9) xor d(27) xor d(19) xor c(24) xor c(16) xor d(52) xor d(44) xor d(36) xor c(25) xor c(17) xor d(53) xor c(4) xor d(37) xor d(3) xor d(22) xor d(14) xor c(5) xor d(38) xor d(4);
        o(26) := c(20) xor d(55) xor d(32) xor d(24) xor c(28) xor d(16) xor c(7) xor c(0) xor d(6) xor d(33) xor c(30) xor d(17) xor c(14) xor d(49) xor c(1) xor d(7) xor d(0) xor c(31) xor d(11) xor c(23) xor c(15) xor d(51) xor c(2) xor d(8) xor d(35) xor d(1) xor d(27) xor c(24) xor d(52) xor d(36) xor d(13) xor c(25) xor c(17) xor c(4) xor d(45) xor d(37) xor d(3) xor d(30) xor d(29) xor d(14) xor c(18) xor d(31);
        o(27) := d(23) xor d(15) xor c(19) xor d(5) xor d(32) xor d(16) xor c(21) xor d(48) xor c(0) xor d(6) xor c(29) xor d(10) xor c(8) xor d(50) xor c(1) xor d(7) xor d(34) xor d(0) xor d(26) xor c(31) xor c(15) xor d(51) xor c(2) xor d(35) xor d(12) xor c(24) xor c(16) xor c(3) xor d(44) xor d(36) xor d(2) xor d(28) xor c(25) xor d(13) xor d(30) xor d(29) xor c(26) xor c(18) xor d(54) xor c(5) xor d(31);
        o(28) := c(27) xor d(15) xor c(20) xor c(19) xor d(47) xor c(6) xor d(5) xor c(0) xor d(6) xor d(33) xor d(25) xor c(30) xor c(22) xor d(50) xor d(49) xor c(1) xor d(34) xor d(11) xor c(9) xor c(2) xor d(43) xor d(35) xor d(1) xor d(27) xor d(12) xor c(16) xor c(3) xor d(9) xor d(28) xor c(25) xor c(17) xor d(53) xor c(4) xor d(29) xor d(30) xor d(22) xor c(26) xor d(14) xor d(4) xor d(31);
        o(29) := c(27) xor c(20) xor d(5) xor d(32) xor d(24) xor c(28) xor c(21) xor c(7) xor d(48) xor d(33) xor d(10) xor d(49) xor c(1) xor d(42) xor d(34) xor d(0) xor d(26) xor c(31) xor c(23) xor d(11) xor c(2) xor d(8) xor d(27) xor d(52) xor c(3) xor d(28) xor d(21) xor d(13) xor c(17) xor c(10) xor c(4) xor d(3) xor d(30) xor d(29) xor c(26) xor d(14) xor c(18) xor d(46) xor c(5) xor d(4);
        o(30) := d(23) xor c(27) xor c(19) xor c(6) xor d(47) xor d(32) xor c(28) xor c(21) xor d(48) xor d(41) xor c(0) xor d(33) xor d(25) xor c(29) xor c(22) xor d(10) xor c(8) xor d(7) xor d(26) xor d(51) xor c(2) xor d(27) xor d(20) xor d(12) xor c(24) xor c(3) xor d(9) xor d(2) xor d(28) xor d(13) xor d(45) xor c(4) xor d(3) xor d(29) xor c(18) xor c(11) xor c(5) xor d(4) xor d(31);
        o(31) := c(20) xor c(19) xor c(12) xor c(6) xor d(47) xor d(40) xor d(32) xor d(24) xor c(28) xor c(7) xor c(0) xor d(6) xor d(25) xor c(29) xor c(30) xor c(22) xor d(50) xor c(1) xor d(26) xor c(23) xor d(11) xor c(9) xor d(8) xor d(1) xor d(27) xor d(19) xor d(12) xor d(44) xor c(3) xor d(9) xor d(2) xor d(28) xor c(25) xor c(4) xor d(3) xor d(30) xor d(22) xor c(5) xor d(46) xor d(31);
        return o;
    end function;

    --//////////////////////////////////////////////
    -- crc6B
    --//////////////////////////////////////////////
    function crc6B(
        c : in std_logic_vector(31 downto 0);
        d : in std_logic_vector(47 downto 0)
    ) return std_logic_vector is
        variable o : std_logic_vector(31 downto 0);
    begin
        o(0)  := d(41) xor d(23) xor c(0) xor d(15) xor c(9) xor c(10) xor d(35) xor d(17) xor c(29) xor c(12) xor d(10) xor c(14) xor d(19) xor d(37) xor d(47) xor d(3) xor c(16) xor d(22) xor c(8) xor c(18) xor c(28) xor d(16) xor d(0) xor c(21) xor c(31) xor d(18) xor c(13) xor d(2) xor c(15) xor d(21) xor d(38) xor d(13) xor d(31);
        o(1)  := d(23) xor c(19) xor c(12) xor d(47) xor d(40) xor c(28) xor c(21) xor d(41) xor c(0) xor c(30) xor d(10) xor c(22) xor c(8) xor c(1) xor d(34) xor d(0) xor c(31) xor d(35) xor d(1) xor d(20) xor d(19) xor d(12) xor d(9) xor d(36) xor d(13) xor c(17) xor d(3) xor d(30) xor d(14) xor c(18) xor c(11) xor d(46) xor d(38) xor d(31);
        o(2)  := d(23) xor d(15) xor c(20) xor c(19) xor d(47) xor d(40) xor d(39) xor c(28) xor d(16) xor c(21) xor d(41) xor c(0) xor d(33) xor d(17) xor d(10) xor c(22) xor c(14) xor c(8) xor c(1) xor d(34) xor d(11) xor c(23) xor c(15) xor c(2) xor d(8) xor d(12) xor c(16) xor d(9) xor d(21) xor c(10) xor d(45) xor d(29) xor d(3) xor d(30) xor d(46) xor d(38) xor d(31);
        o(3)  := d(15) xor c(20) xor d(40) xor d(39) xor d(32) xor d(16) xor c(21) xor d(33) xor c(29) xor d(10) xor c(22) xor c(1) xor d(7) xor c(23) xor d(11) xor c(15) xor c(9) xor c(2) xor d(8) xor d(20) xor c(24) xor c(16) xor c(3) xor d(44) xor d(9) xor d(28) xor d(2) xor c(17) xor d(45) xor d(37) xor d(30) xor d(29) xor d(22) xor d(14) xor c(11) xor d(46) xor d(38);
        o(4)  := d(23) xor d(47) xor d(39) xor d(32) xor c(28) xor d(16) xor c(13) xor d(41) xor d(6) xor d(17) xor c(29) xor c(30) xor c(22) xor c(14) xor c(8) xor d(7) xor d(0) xor c(31) xor d(18) xor c(23) xor c(15) xor c(9) xor c(2) xor d(43) xor d(35) xor d(8) xor d(1) xor d(27) xor c(24) xor c(3) xor d(44) xor d(9) xor d(36) xor d(2) xor d(28) xor c(25) xor c(17) xor c(4) xor d(45) xor d(29) xor d(3) xor d(22) xor d(14);
        o(5)  := d(23) xor c(12) xor d(47) xor d(40) xor d(5) xor c(28) xor c(21) xor c(13) xor d(41) xor d(6) xor c(30) xor d(10) xor c(8) xor d(42) xor d(7) xor d(34) xor d(26) xor d(18) xor c(23) xor d(43) xor d(8) xor d(1) xor d(27) xor d(19) xor c(24) xor c(3) xor d(44) xor d(28) xor c(25) xor c(4) xor d(37) xor d(3) xor c(26) xor c(5) xor d(46);
        o(6)  := c(27) xor c(6) xor d(40) xor d(39) xor d(5) xor c(13) xor d(41) xor d(6) xor d(33) xor d(25) xor c(29) xor d(17) xor c(22) xor c(14) xor d(42) xor d(7) xor d(0) xor d(26) xor c(31) xor d(18) xor c(9) xor d(43) xor d(27) xor c(24) xor d(9) xor d(36) xor d(2) xor c(25) xor c(4) xor d(45) xor d(22) xor c(26) xor d(46) xor c(5) xor d(4);
        o(7)  := d(23) xor c(27) xor d(15) xor c(12) xor d(47) xor c(6) xor d(39) xor d(40) xor d(5) xor d(32) xor d(24) xor c(21) xor c(13) xor c(7) xor c(0) xor d(6) xor d(25) xor c(29) xor c(30) xor d(10) xor c(8) xor d(42) xor d(0) xor d(26) xor c(31) xor d(18) xor c(23) xor c(9) xor d(8) xor d(1) xor d(19) xor c(16) xor d(44) xor d(2) xor d(13) xor c(25) xor d(45) xor d(37) xor d(22) xor c(26) xor c(18) xor c(5) xor d(4) xor d(31);
        o(8)  := c(27) xor d(15) xor c(19) xor c(12) xor d(47) xor c(6) xor d(39) xor d(5) xor d(24) xor d(16) xor c(21) xor c(7) xor d(25) xor c(29) xor c(30) xor d(10) xor c(22) xor c(1) xor d(7) xor c(15) xor d(43) xor d(35) xor d(1) xor d(19) xor c(24) xor d(12) xor c(16) xor d(44) xor d(9) xor d(36) xor d(2) xor d(13) xor c(17) xor d(37) xor d(30) xor c(26) xor d(14) xor c(18) xor d(46) xor d(4);
        o(9)  := d(23) xor c(27) xor d(15) xor c(19) xor c(20) xor d(24) xor c(28) xor c(13) xor c(7) xor d(6) xor c(30) xor c(22) xor c(8) xor d(42) xor d(34) xor d(0) xor c(31) xor d(18) xor c(23) xor d(11) xor c(2) xor d(43) xor d(8) xor d(35) xor d(1) xor d(12) xor c(16) xor d(9) xor d(36) xor c(25) xor d(13) xor c(17) xor d(45) xor d(3) xor d(29) xor d(14) xor c(18) xor d(46) xor d(38) xor d(4);
        o(10) := d(15) xor c(20) xor c(19) xor c(12) xor d(47) xor d(5) xor d(16) xor c(13) xor c(0) xor d(33) xor d(42) xor d(7) xor d(34) xor d(18) xor d(11) xor c(23) xor c(15) xor d(8) xor d(19) xor c(24) xor d(12) xor c(16) xor c(3) xor d(44) xor d(28) xor d(21) xor c(17) xor c(10) xor d(45) xor c(26) xor d(14) xor d(38) xor d(31);
        o(11) := d(23) xor c(27) xor c(20) xor c(12) xor d(47) xor d(32) xor c(28) xor d(16) xor c(0) xor d(6) xor d(33) xor c(29) xor c(8) xor c(1) xor d(7) xor d(0) xor c(31) xor d(11) xor c(15) xor c(9) xor d(43) xor d(35) xor d(27) xor d(20) xor d(19) xor c(24) xor d(44) xor d(2) xor d(21) xor c(25) xor c(17) xor c(10) xor c(4) xor d(3) xor d(30) xor d(22) xor d(14) xor c(11) xor d(46) xor d(38) xor d(4) xor d(31);
        o(12) := d(23) xor d(47) xor d(5) xor d(32) xor d(16) xor d(41) xor d(6) xor d(17) xor c(30) xor c(14) xor c(8) xor c(1) xor d(42) xor d(34) xor d(0) xor d(26) xor c(31) xor c(15) xor c(2) xor d(43) xor d(35) xor d(1) xor d(20) xor c(25) xor d(45) xor d(29) xor d(30) xor c(26) xor c(11) xor c(5) xor d(46) xor d(38);
        o(13) := c(27) xor d(15) xor c(12) xor c(6) xor d(40) xor d(5) xor d(16) xor c(0) xor d(41) xor d(33) xor d(25) xor d(42) xor d(34) xor d(0) xor c(31) xor c(15) xor c(9) xor c(2) xor d(19) xor c(16) xor c(3) xor d(44) xor d(28) xor d(45) xor d(37) xor d(29) xor d(22) xor c(26) xor d(46) xor d(4) xor d(31);
        o(14) := d(15) xor c(27) xor d(39) xor d(40) xor d(32) xor d(24) xor c(28) xor c(13) xor c(7) xor d(41) xor d(33) xor c(1) xor d(18) xor d(43) xor d(27) xor c(16) xor d(44) xor c(3) xor d(36) xor d(28) xor d(21) xor c(17) xor c(10) xor d(45) xor c(4) xor d(3) xor d(30) xor d(14) xor d(4);
        o(15) := d(23) xor d(40) xor d(39) xor d(32) xor c(28) xor c(0) xor c(29) xor d(17) xor c(14) xor c(8) xor d(42) xor d(26) xor c(2) xor d(43) xor d(35) xor d(27) xor d(20) xor d(44) xor d(2) xor d(13) xor c(17) xor c(4) xor d(3) xor d(29) xor d(14) xor c(18) xor c(11) xor c(5) xor d(38) xor d(31);
        o(16) := d(23) xor d(15) xor c(19) xor d(47) xor c(6) xor d(39) xor c(28) xor c(21) xor c(13) xor d(25) xor d(17) xor c(30) xor d(10) xor c(14) xor c(8) xor d(42) xor c(1) xor d(34) xor d(0) xor d(26) xor c(31) xor d(18) xor d(43) xor d(35) xor d(1) xor d(12) xor c(16) xor c(3) xor d(28) xor d(21) xor c(10) xor d(3) xor d(30) xor c(5);
        o(17) := c(20) xor c(6) xor d(24) xor d(16) xor c(7) xor d(41) xor d(33) xor d(25) xor c(29) xor d(17) xor c(22) xor c(14) xor d(42) xor d(34) xor d(0) xor c(31) xor d(11) xor c(15) xor c(9) xor c(2) xor d(27) xor d(20) xor d(9) xor d(2) xor c(17) xor c(4) xor d(29) xor d(22) xor d(14) xor c(11) xor d(46) xor d(38);
        o(18) := d(23) xor d(15) xor c(12) xor d(40) xor d(32) xor d(24) xor d(16) xor c(21) xor c(7) xor d(41) xor d(33) xor c(30) xor d(10) xor c(8) xor d(26) xor c(23) xor c(15) xor d(8) xor d(1) xor d(19) xor c(16) xor c(3) xor d(28) xor d(21) xor d(13) xor c(10) xor d(45) xor d(37) xor c(18) xor c(5);
        o(19) := d(23) xor d(15) xor c(19) xor c(6) xor d(39) xor d(40) xor d(32) xor c(13) xor c(0) xor d(25) xor c(22) xor c(8) xor d(7) xor d(0) xor c(31) xor d(18) xor c(9) xor d(27) xor d(20) xor c(24) xor d(12) xor c(16) xor d(44) xor d(9) xor d(36) xor c(17) xor c(4) xor d(22) xor d(14) xor c(11) xor d(31);
        o(20) := c(20) xor c(12) xor d(39) xor d(24) xor c(7) xor c(0) xor d(6) xor d(17) xor c(14) xor c(1) xor d(26) xor d(11) xor c(23) xor c(9) xor d(43) xor d(8) xor d(35) xor d(19) xor d(21) xor d(13) xor c(25) xor c(17) xor c(10) xor d(30) xor d(22) xor d(14) xor c(18) xor c(5) xor d(38) xor d(31);
        o(21) := d(23) xor c(19) xor c(6) xor d(5) xor d(16) xor c(21) xor c(13) xor d(25) xor d(10) xor c(8) xor d(42) xor c(1) xor d(7) xor d(34) xor d(18) xor c(15) xor c(2) xor d(20) xor d(12) xor c(24) xor d(21) xor d(13) xor c(10) xor d(37) xor d(30) xor d(29) xor c(26) xor c(18) xor c(11) xor d(38);
        o(22) := d(23) xor c(27) xor c(20) xor c(19) xor d(47) xor d(24) xor c(28) xor d(16) xor c(21) xor c(13) xor c(7) xor c(0) xor d(6) xor d(33) xor c(29) xor d(10) xor c(22) xor c(8) xor d(0) xor c(31) xor d(18) xor d(11) xor c(15) xor c(2) xor d(35) xor d(20) xor d(12) xor c(3) xor d(9) xor d(36) xor d(2) xor d(28) xor d(21) xor d(13) xor c(25) xor c(10) xor d(29) xor d(3) xor c(18) xor c(11) xor d(38) xor d(4) xor d(31);
        o(23) := c(20) xor c(19) xor d(47) xor d(5) xor d(32) xor d(16) xor c(13) xor d(41) xor c(0) xor c(30) xor c(22) xor c(1) xor d(34) xor d(0) xor c(31) xor d(18) xor d(11) xor c(23) xor c(15) xor d(8) xor d(1) xor d(27) xor d(20) xor d(12) xor c(3) xor d(9) xor d(28) xor d(21) xor d(13) xor c(10) xor c(4) xor d(30) xor c(26) xor c(18) xor c(11) xor d(46) xor d(38) xor d(31);
        o(24) := c(27) xor d(15) xor c(19) xor c(20) xor c(12) xor d(40) xor c(21) xor c(0) xor d(33) xor d(17) xor d(10) xor c(14) xor c(1) xor d(7) xor d(0) xor d(26) xor c(31) xor c(23) xor d(11) xor c(2) xor d(8) xor d(27) xor d(19) xor d(20) xor c(24) xor d(12) xor c(16) xor c(4) xor d(45) xor d(37) xor d(30) xor d(29) xor c(11) xor d(46) xor c(5) xor d(4) xor d(31);
        o(25) := c(20) xor c(12) xor c(6) xor d(39) xor d(32) xor c(28) xor d(16) xor c(21) xor c(13) xor d(6) xor d(25) xor c(22) xor d(10) xor c(1) xor d(7) xor d(26) xor d(18) xor d(11) xor c(15) xor c(2) xor d(19) xor c(24) xor d(44) xor c(3) xor d(9) xor d(36) xor d(28) xor c(25) xor c(17) xor d(45) xor d(3) xor d(30) xor d(29) xor d(14) xor c(5);
        o(26) := d(23) xor c(12) xor d(47) xor c(6) xor d(5) xor d(24) xor c(28) xor d(16) xor c(7) xor d(41) xor d(6) xor d(25) xor c(22) xor c(8) xor d(0) xor c(31) xor c(23) xor c(15) xor c(9) xor c(2) xor d(43) xor d(8) xor d(27) xor d(19) xor c(3) xor d(44) xor d(9) xor d(28) xor d(21) xor c(25) xor c(10) xor c(4) xor d(37) xor d(29) xor d(3) xor d(22) xor c(26);
        o(27) := d(23) xor c(27) xor d(15) xor d(40) xor d(5) xor d(24) xor c(13) xor c(7) xor c(29) xor c(8) xor d(42) xor d(7) xor d(26) xor d(18) xor c(23) xor c(9) xor d(43) xor d(8) xor d(27) xor d(20) xor c(24) xor c(16) xor c(3) xor d(36) xor d(28) xor d(2) xor d(21) xor c(10) xor c(4) xor d(22) xor c(26) xor c(11) xor d(46) xor c(5) xor d(4);
        o(28) := d(23) xor c(27) xor c(12) xor c(6) xor d(39) xor c(28) xor d(41) xor d(6) xor d(25) xor c(30) xor d(17) xor c(14) xor c(8) xor d(42) xor d(7) xor d(26) xor c(9) xor d(35) xor d(27) xor d(1) xor d(20) xor d(19) xor c(24) xor d(21) xor c(25) xor c(17) xor c(10) xor d(45) xor c(4) xor d(3) xor d(22) xor d(14) xor c(11) xor c(5) xor d(4);
        o(29) := c(12) xor c(6) xor d(40) xor d(5) xor d(24) xor d(16) xor c(28) xor c(13) xor c(7) xor d(41) xor d(6) xor d(25) xor c(29) xor d(34) xor d(26) xor d(0) xor c(31) xor d(18) xor c(15) xor c(9) xor d(20) xor d(19) xor d(44) xor d(2) xor d(21) xor c(25) xor d(13) xor c(10) xor d(3) xor d(22) xor c(26) xor c(18) xor c(11) xor c(5) xor d(38);
        o(30) := d(23) xor c(27) xor d(15) xor c(19) xor c(12) xor c(6) xor d(40) xor d(39) xor d(5) xor d(24) xor c(13) xor c(7) xor d(33) xor d(25) xor c(30) xor c(29) xor d(17) xor c(14) xor c(8) xor d(18) xor d(43) xor d(1) xor d(19) xor d(20) xor d(12) xor c(16) xor d(2) xor d(21) xor c(10) xor d(37) xor c(26) xor c(11) xor d(4);
        o(31) := c(17) xor d(23) xor c(27) xor c(9) xor c(20) xor c(30) xor d(17) xor c(12) xor d(1) xor d(20) xor c(14) xor d(19) xor d(3) xor d(22) xor d(39) xor d(14) xor c(8) xor d(32) xor d(42) xor d(24) xor c(28) xor c(11) xor d(16) xor d(0) xor d(36) xor d(18) xor c(31) xor c(13) xor d(11) xor c(15) xor d(38) xor d(4) xor c(7);
        return o;
        end function;

        --//////////////////////////////////////////////
        -- crc5B
        --//////////////////////////////////////////////
        function crc5B(
            c : in std_logic_vector(31 downto 0);
            d : in std_logic_vector(39 downto 0)
        ) return std_logic_vector is
            variable o : std_logic_vector(31 downto 0);
        begin
            o(0)  := c(17) xor d(23) xor d(33) xor d(15) xor c(20) xor c(2) xor c(29) xor d(8) xor d(27) xor c(22) xor c(4) xor d(10) xor c(24) xor d(30) xor d(29) xor d(39) xor c(16) xor d(5) xor c(26) xor d(14) xor c(8) xor c(18) xor c(1) xor d(7) xor c(21) xor d(9) xor d(2) xor d(11) xor c(23) xor d(13);
            o(1)  := d(23) xor d(33) xor d(15) xor d(6) xor c(27) xor c(9) xor c(19) xor c(20) xor c(29) xor c(30) xor d(27) xor d(1) xor c(4) xor d(12) xor d(30) xor d(39) xor c(16) xor d(22) xor d(5) xor c(26) xor c(8) xor d(32) xor c(1) xor d(26) xor c(3) xor d(2) xor d(11) xor c(5) xor d(28) xor d(38) xor c(25) xor d(4);
            o(2)  := d(23) xor c(0) xor d(33) xor d(15) xor c(10) xor c(27) xor c(9) xor d(25) xor c(29) xor c(30) xor d(8) xor c(22) xor d(1) xor d(37) xor d(3) xor c(24) xor d(30) xor c(6) xor d(39) xor c(16) xor d(22) xor c(8) xor d(32) xor c(18) xor c(1) xor c(28) xor d(7) xor d(0) xor d(26) xor d(9) xor c(31) xor d(2) xor c(23) xor c(5) xor d(21) xor d(38) xor d(4) xor d(13) xor d(31);
            o(3)  := c(17) xor c(0) xor d(6) xor c(9) xor c(10) xor c(19) xor c(2) xor d(25) xor d(8) xor c(29) xor c(30) xor d(1) xor d(20) xor d(37) xor c(24) xor d(3) xor d(12) xor d(29) xor c(6) xor d(30) xor d(22) xor d(32) xor d(14) xor d(24) xor c(1) xor c(11) xor d(7) xor c(28) xor d(0) xor c(31) xor d(36) xor d(2) xor c(23) xor d(38) xor d(21) xor c(25) xor d(31) xor c(7);
            o(4)  := d(15) xor c(12) xor d(39) xor d(24) xor c(21) xor c(7) xor c(0) xor d(33) xor d(6) xor c(30) xor c(22) xor d(10) xor d(0) xor c(31) xor c(23) xor d(8) xor d(35) xor d(27) xor d(1) xor d(20) xor d(19) xor c(16) xor c(3) xor d(9) xor d(36) xor d(28) xor d(21) xor c(25) xor c(17) xor c(10) xor c(4) xor d(37) xor d(14) xor c(11) xor d(31);
            o(5)  := d(15) xor c(20) xor c(12) xor d(39) xor d(32) xor c(21) xor c(13) xor d(33) xor c(29) xor d(10) xor d(34) xor d(0) xor d(26) xor c(31) xor d(18) xor d(11) xor c(2) xor d(35) xor d(20) xor d(19) xor c(16) xor d(36) xor d(2) xor d(29) xor c(11) xor c(5) xor d(38);
            o(6)  := c(12) xor c(6) xor d(32) xor c(21) xor c(13) xor c(0) xor d(33) xor d(25) xor c(30) xor d(17) xor d(10) xor c(22) xor c(14) xor d(34) xor d(18) xor d(35) xor d(1) xor d(19) xor c(3) xor d(9) xor d(28) xor c(17) xor d(37) xor d(14) xor d(38) xor d(31);
            o(7)  := d(23) xor d(15) xor c(20) xor d(39) xor d(5) xor d(32) xor d(24) xor d(16) xor c(21) xor c(13) xor c(7) xor c(0) xor c(29) xor d(17) xor d(10) xor c(14) xor c(8) xor d(7) xor d(34) xor d(0) xor c(31) xor d(18) xor d(11) xor c(15) xor c(2) xor c(24) xor c(16) xor d(36) xor d(2) xor c(17) xor d(37) xor d(29) xor c(26) xor d(14) xor d(31);
            o(8)  := c(0) xor d(6) xor c(27) xor c(9) xor c(20) xor c(2) xor c(29) xor c(30) xor d(8) xor d(17) xor d(35) xor d(27) xor d(1) xor c(4) xor c(14) xor c(24) xor d(29) xor d(39) xor d(22) xor d(5) xor c(26) xor d(7) xor d(16) xor c(3) xor d(36) xor d(2) xor d(11) xor c(23) xor d(28) xor d(38) xor c(15) xor c(25) xor d(4) xor d(31);
            o(9)  := c(27) xor d(6) xor d(15) xor c(10) xor c(30) xor d(35) xor d(1) xor d(10) xor d(27) xor c(4) xor d(37) xor c(24) xor d(3) xor d(30) xor c(16) xor d(5) xor c(26) xor c(1) xor d(7) xor d(16) xor c(28) xor d(34) xor d(26) xor d(0) xor c(21) xor c(3) xor c(31) xor c(5) xor d(28) xor d(38) xor c(15) xor d(21) xor d(4) xor c(25);
            o(10) := d(23) xor c(27) xor c(20) xor c(6) xor d(39) xor c(28) xor c(21) xor d(6) xor d(25) xor d(10) xor c(8) xor c(1) xor d(7) xor d(34) xor d(0) xor d(26) xor c(31) xor d(11) xor c(23) xor d(8) xor d(20) xor c(24) xor d(36) xor c(25) xor d(13) xor d(37) xor d(3) xor d(30) xor c(18) xor c(11) xor c(5) xor d(4);
            o(11) := c(17) xor d(23) xor d(15) xor d(6) xor c(9) xor c(19) xor c(20) xor d(25) xor d(8) xor c(12) xor d(35) xor d(27) xor c(4) xor d(19) xor d(3) xor d(12) xor d(30) xor c(6) xor d(39) xor c(16) xor d(22) xor d(14) xor c(8) xor d(24) xor c(18) xor c(1) xor c(28) xor d(36) xor d(11) xor c(23) xor d(38) xor c(25) xor c(7) xor d(13);
            o(12) := d(33) xor d(15) xor c(10) xor c(9) xor c(19) xor d(8) xor d(35) xor d(27) xor c(22) xor c(4) xor d(37) xor d(12) xor d(30) xor d(39) xor c(16) xor d(22) xor d(24) xor c(1) xor d(34) xor d(26) xor d(9) xor d(18) xor c(13) xor c(23) xor c(5) xor d(21) xor d(38) xor c(7);
            o(13) := c(17) xor d(23) xor c(10) xor d(33) xor c(20) xor c(2) xor d(25) xor d(8) xor d(17) xor d(20) xor c(14) xor d(37) xor c(24) xor d(29) xor c(6) xor d(32) xor d(14) xor c(8) xor c(11) xor d(7) xor d(34) xor d(26) xor d(36) xor c(23) xor d(11) xor c(5) xor d(38) xor d(21);
            o(14) := c(0) xor d(6) xor c(9) xor d(33) xor d(25) xor c(12) xor d(35) xor d(10) xor d(37) xor d(19) xor d(20) xor c(24) xor c(6) xor d(22) xor d(32) xor c(18) xor d(24) xor d(7) xor d(16) xor c(11) xor c(21) xor c(3) xor d(36) xor d(28) xor c(15) xor d(31) xor d(13) xor c(25) xor c(7);
            o(15) := d(23) xor c(0) xor d(6) xor d(15) xor c(10) xor c(19) xor d(35) xor c(12) xor c(22) xor d(27) xor c(4) xor d(19) xor d(30) xor d(12) xor c(16) xor d(5) xor c(26) xor c(8) xor d(32) xor d(24) xor c(1) xor d(34) xor d(36) xor d(18) xor d(9) xor c(13) xor d(21) xor c(25) xor c(7) xor d(31);
            o(16) := d(15) xor c(27) xor d(39) xor c(21) xor c(13) xor c(0) xor c(29) xor d(17) xor c(22) xor d(10) xor c(14) xor d(7) xor d(34) xor d(26) xor d(18) xor c(9) xor d(35) xor d(27) xor d(20) xor c(24) xor c(16) xor d(9) xor d(2) xor d(13) xor c(4) xor d(22) xor c(18) xor c(11) xor c(5) xor d(4) xor d(31);
            o(17) := c(17) xor d(6) xor d(33) xor c(10) xor c(19) xor d(25) xor d(8) xor c(30) xor d(17) xor c(12) xor d(1) xor c(22) xor c(14) xor d(19) xor d(3) xor d(12) xor c(6) xor d(30) xor d(14) xor c(1) xor d(16) xor c(28) xor d(34) xor d(26) xor d(9) xor c(23) xor c(5) xor d(38) xor c(15) xor d(21) xor c(25);
            o(18) := d(15) xor d(33) xor d(25) xor c(20) xor c(2) xor c(29) xor d(8) xor d(37) xor d(20) xor c(24) xor c(6) xor d(29) xor c(16) xor d(5) xor c(26) xor d(32) xor c(18) xor d(24) xor d(7) xor d(16) xor c(11) xor d(0) xor c(31) xor d(18) xor c(13) xor d(2) xor d(11) xor c(23) xor c(15) xor d(13) xor c(7);
            o(19) := c(17) xor d(23) xor c(0) xor d(6) xor d(15) xor c(27) xor c(19) xor c(30) xor d(17) xor c(12) xor d(1) xor d(10) xor c(14) xor d(19) xor d(12) xor c(24) xor c(16) xor d(14) xor d(32) xor c(8) xor d(24) xor d(7) xor c(21) xor c(3) xor d(36) xor d(28) xor c(25) xor d(4) xor c(7) xor d(31);
            o(20) := d(23) xor c(17) xor c(0) xor d(6) xor c(9) xor c(20) xor d(35) xor c(22) xor d(27) xor c(4) xor d(3) xor d(30) xor d(22) xor d(5) xor c(26) xor d(14) xor c(8) xor c(18) xor c(1) xor c(28) xor d(16) xor d(0) xor c(31) xor d(9) xor d(18) xor c(13) xor d(11) xor c(15) xor d(13) xor c(25) xor d(31);
            o(21) := c(27) xor c(9) xor d(15) xor c(10) xor c(19) xor c(2) xor c(29) xor d(8) xor d(17) xor d(10) xor c(14) xor d(12) xor d(30) xor d(29) xor d(22) xor c(16) xor d(5) xor c(26) xor c(18) xor c(1) xor d(34) xor c(21) xor d(26) xor d(2) xor c(23) xor c(5) xor d(21) xor d(4) xor d(13);
            o(22) := d(23) xor d(15) xor c(10) xor c(27) xor c(19) xor d(25) xor c(29) xor c(30) xor d(8) xor d(27) xor d(1) xor c(4) xor d(10) xor d(20) xor d(3) xor d(12) xor d(30) xor c(6) xor d(39) xor c(16) xor d(5) xor c(26) xor c(8) xor c(18) xor c(1) xor c(28) xor c(11) xor d(16) xor c(21) xor c(3) xor d(2) xor c(23) xor d(28) xor d(21) xor c(15) xor d(4) xor d(13);
            o(23) := d(23) xor d(33) xor c(27) xor c(9) xor c(19) xor c(30) xor d(8) xor c(12) xor d(1) xor d(10) xor d(20) xor d(19) xor d(3) xor d(12) xor d(30) xor d(39) xor d(22) xor d(5) xor c(26) xor c(8) xor d(24) xor c(18) xor c(1) xor c(28) xor c(11) xor d(0) xor c(21) xor d(26) xor c(31) xor c(23) xor c(5) xor d(38) xor d(4) xor c(7) xor d(13);
            o(24) := d(23) xor c(27) xor c(9) xor c(10) xor c(20) xor c(19) xor c(2) xor d(25) xor c(29) xor c(12) xor c(22) xor d(19) xor d(37) xor c(24) xor d(3) xor d(12) xor d(29) xor c(6) xor d(22) xor d(32) xor c(8) xor d(7) xor c(28) xor d(0) xor c(31) xor d(9) xor d(18) xor c(13) xor d(2) xor d(11) xor d(38) xor d(21) xor d(4);
            o(25) := c(0) xor d(6) xor c(9) xor c(10) xor c(20) xor c(30) xor c(29) xor d(8) xor d(17) xor d(1) xor d(10) xor d(37) xor c(14) xor d(20) xor d(3) xor d(22) xor d(24) xor c(28) xor c(11) xor c(21) xor c(3) xor d(18) xor c(13) xor d(36) xor d(2) xor d(11) xor d(28) xor c(23) xor d(21) xor d(31) xor c(25) xor c(7);
            o(26) := c(17) xor d(33) xor d(15) xor c(10) xor c(20) xor c(2) xor c(30) xor d(8) xor d(17) xor c(12) xor d(35) xor d(1) xor c(14) xor d(20) xor d(19) xor d(29) xor d(39) xor c(16) xor d(14) xor c(18) xor c(11) xor d(16) xor d(0) xor c(31) xor d(36) xor d(11) xor c(23) xor d(21) xor c(15) xor d(13);
            o(27) := c(17) xor d(15) xor c(19) xor c(12) xor d(35) xor d(10) xor d(20) xor d(19) xor c(24) xor d(12) xor c(16) xor d(32) xor d(14) xor c(18) xor c(11) xor d(7) xor d(16) xor d(34) xor d(0) xor c(21) xor c(3) xor c(31) xor d(18) xor c(13) xor d(28) xor d(38) xor c(15) xor d(13);
            o(28) := c(0) xor c(17) xor d(6) xor d(15) xor d(33) xor c(19) xor c(20) xor c(12) xor d(17) xor c(22) xor d(27) xor c(4) xor d(37) xor d(19) xor c(14) xor d(12) xor c(16) xor d(14) xor c(18) xor d(34) xor d(9) xor d(18) xor c(13) xor d(11) xor d(31) xor d(13) xor c(25);
            o(29) := c(17) xor d(33) xor c(19) xor c(20) xor d(8) xor d(17) xor d(10) xor c(14) xor d(30) xor d(12) xor d(5) xor c(26) xor d(14) xor d(32) xor c(1) xor c(18) xor d(16) xor c(21) xor d(26) xor d(36) xor d(18) xor c(13) xor c(23) xor d(11) xor c(5) xor c(15) xor d(13);
            o(30) := c(0) xor c(27) xor d(15) xor c(20) xor c(2) xor d(25) xor c(19) xor d(35) xor d(17) xor d(10) xor c(22) xor c(14) xor d(29) xor c(24) xor c(6) xor d(12) xor c(16) xor d(32) xor c(18) xor d(7) xor d(16) xor c(21) xor d(9) xor d(11) xor c(15) xor d(4) xor d(13) xor d(31);
            o(31) := c(17) xor c(0) xor d(6) xor d(15) xor c(19) xor c(20) xor d(8) xor d(10) xor c(22) xor d(3) xor d(12) xor d(30) xor c(16) xor d(14) xor d(24) xor c(1) xor d(34) xor d(16) xor c(28) xor c(21) xor c(3) xor d(9) xor d(28) xor c(23) xor d(11) xor c(15) xor c(25) xor c(7) xor d(31);
            return o;
        end function;

        --//////////////////////////////////////////////
        -- crc4B
        --//////////////////////////////////////////////
        function crc4B(
            c : in std_logic_vector(31 downto 0);
            d : in std_logic_vector(31 downto 0)
        ) return std_logic_vector is
            variable o : std_logic_vector(31 downto 0);
        begin
            o(0)  := c(0) xor d(6) xor d(15) xor c(9) xor c(10) xor d(25) xor c(30) xor c(12) xor c(29) xor d(1) xor d(19) xor c(24) xor d(3) xor c(6) xor c(16) xor d(22) xor d(5) xor c(26) xor d(7) xor c(28) xor d(0) xor c(31) xor d(2) xor d(21) xor d(31) xor c(25);
            o(1)  := c(0) xor c(17) xor c(27) xor d(15) xor c(9) xor d(25) xor c(12) xor d(19) xor d(20) xor c(24) xor d(3) xor c(6) xor d(30) xor c(16) xor d(22) xor d(14) xor d(24) xor c(1) xor d(7) xor c(28) xor c(11) xor d(18) xor c(13) xor d(31) xor d(4) xor c(7);
            o(2)  := c(0) xor c(17) xor d(23) xor d(15) xor c(9) xor d(25) xor c(2) xor c(30) xor d(17) xor d(1) xor c(14) xor c(24) xor c(6) xor d(30) xor d(29) xor c(16) xor d(22) xor d(5) xor c(26) xor d(14) xor c(8) xor c(18) xor d(24) xor c(1) xor d(7) xor d(0) xor c(31) xor d(18) xor c(13) xor d(31) xor d(13) xor c(7);
            o(3)  := c(17) xor d(23) xor d(6) xor c(27) xor c(10) xor c(9) xor c(19) xor c(2) xor d(17) xor c(14) xor d(30) xor d(12) xor d(29) xor d(22) xor d(14) xor c(8) xor d(24) xor c(1) xor c(18) xor d(16) xor d(0) xor c(3) xor c(31) xor d(28) xor d(21) xor c(15) xor c(25) xor d(4) xor c(7) xor d(13);
            o(4)  := c(0) xor d(23) xor d(6) xor d(25) xor c(19) xor c(20) xor c(2) xor c(30) xor c(12) xor c(29) xor d(1) xor d(27) xor c(4) xor d(19) xor d(20) xor c(24) xor c(6) xor d(12) xor d(29) xor c(8) xor c(18) xor d(7) xor d(16) xor c(11) xor d(0) xor c(3) xor c(31) xor d(2) xor d(11) xor d(28) xor c(15) xor d(31) xor d(13) xor c(25);
            o(5)  := c(0) xor c(10) xor d(25) xor c(19) xor c(20) xor c(29) xor d(10) xor d(27) xor c(4) xor c(24) xor d(3) xor c(6) xor d(12) xor d(30) xor d(24) xor c(1) xor d(7) xor c(28) xor c(21) xor c(3) xor d(26) xor d(18) xor c(13) xor d(2) xor d(11) xor d(28) xor c(5) xor d(21) xor d(31) xor c(7);
            o(6)  := d(23) xor d(6) xor c(20) xor c(2) xor d(25) xor c(29) xor c(30) xor d(17) xor c(22) xor d(1) xor d(10) xor d(27) xor c(4) xor d(20) xor c(14) xor d(30) xor d(29) xor c(6) xor c(8) xor d(24) xor c(1) xor c(11) xor c(21) xor d(26) xor d(9) xor d(2) xor d(11) xor c(5) xor c(25) xor c(7);
            o(7)  := c(0) xor d(23) xor d(6) xor d(15) xor c(10) xor c(2) xor c(29) xor d(8) xor d(10) xor c(22) xor c(24) xor d(3) xor d(29) xor c(16) xor c(8) xor d(24) xor d(7) xor c(28) xor d(16) xor c(21) xor c(3) xor d(26) xor d(9) xor d(2) xor c(23) xor d(28) xor c(5) xor c(15) xor d(21) xor d(31) xor c(25) xor c(7);
            o(8)  := c(0) xor c(17) xor d(23) xor c(10) xor c(12) xor d(8) xor c(22) xor d(27) xor c(4) xor d(19) xor d(20) xor d(3) xor d(30) xor d(14) xor c(8) xor c(1) xor c(28) xor c(11) xor d(0) xor c(3) xor c(31) xor d(9) xor c(23) xor d(28) xor d(21) xor d(31);
            o(9)  := c(9) xor c(2) xor c(29) xor d(8) xor c(12) xor d(27) xor c(4) xor d(20) xor d(19) xor d(30) xor d(29) xor c(24) xor d(22) xor c(1) xor c(18) xor c(11) xor d(7) xor d(26) xor d(18) xor c(13) xor d(2) xor c(23) xor c(5) xor d(13);
            o(10) := c(0) xor d(15) xor c(9) xor c(19) xor c(2) xor c(29) xor d(17) xor c(14) xor d(3) xor d(12) xor d(29) xor c(16) xor d(22) xor d(5) xor c(26) xor c(28) xor d(0) xor c(3) xor d(26) xor c(31) xor d(18) xor c(13) xor d(2) xor d(28) xor c(5) xor d(31);
            o(11) := c(0) xor c(17) xor c(27) xor d(6) xor d(15) xor c(9) xor c(20) xor c(12) xor d(17) xor d(27) xor c(4) xor d(19) xor c(14) xor c(24) xor d(3) xor d(30) xor c(16) xor d(22) xor d(5) xor c(26) xor d(14) xor c(1) xor d(7) xor c(28) xor d(16) xor d(0) xor c(3) xor c(31) xor d(11) xor d(28) xor c(15) xor d(31) xor d(4) xor c(25);
            o(12) := c(0) xor c(17) xor c(27) xor c(9) xor d(25) xor c(2) xor c(30) xor c(12) xor d(1) xor d(10) xor d(27) xor c(4) xor d(19) xor c(24) xor c(6) xor d(30) xor d(29) xor d(22) xor d(14) xor c(18) xor c(1) xor d(7) xor d(16) xor d(0) xor c(21) xor d(26) xor c(31) xor d(18) xor c(13) xor c(5) xor c(15) xor d(31) xor d(13) xor d(4);
            o(13) := d(6) xor d(15) xor c(10) xor c(19) xor c(2) xor d(25) xor d(17) xor c(22) xor c(14) xor d(30) xor d(12) xor d(3) xor d(29) xor c(6) xor c(16) xor d(24) xor c(1) xor c(18) xor c(28) xor d(0) xor c(3) xor d(26) xor d(18) xor c(31) xor d(9) xor c(13) xor d(28) xor c(5) xor d(21) xor c(25) xor c(7) xor d(13);
            o(14) := d(23) xor c(17) xor c(20) xor c(2) xor c(19) xor d(25) xor d(17) xor c(29) xor d(8) xor d(27) xor c(4) xor c(14) xor d(20) xor d(29) xor d(12) xor c(6) xor d(5) xor c(26) xor d(14) xor c(8) xor d(24) xor c(11) xor d(16) xor c(3) xor d(11) xor d(2) xor c(23) xor d(28) xor c(15) xor c(7);
            o(15) := d(23) xor c(27) xor c(9) xor d(15) xor c(20) xor c(30) xor c(12) xor d(10) xor d(1) xor d(27) xor c(4) xor d(19) xor c(24) xor d(22) xor c(16) xor c(8) xor c(18) xor d(24) xor d(16) xor d(7) xor c(21) xor c(3) xor d(26) xor d(28) xor d(11) xor c(5) xor c(15) xor d(4) xor d(13) xor c(7);
            o(16) := c(0) xor c(17) xor d(23) xor c(19) xor c(30) xor c(12) xor c(29) xor d(1) xor d(10) xor c(22) xor d(27) xor c(4) xor d(19) xor c(24) xor d(12) xor d(5) xor c(26) xor d(14) xor c(8) xor d(7) xor c(21) xor d(26) xor d(9) xor d(18) xor c(13) xor d(2) xor c(5) xor d(31);
            o(17) := d(6) xor c(27) xor c(9) xor c(20) xor d(25) xor d(8) xor c(30) xor d(17) xor c(22) xor d(1) xor c(14) xor d(30) xor c(6) xor d(22) xor c(1) xor c(18) xor d(0) xor d(26) xor d(18) xor c(31) xor d(9) xor c(13) xor c(23) xor d(11) xor c(5) xor c(25) xor d(4) xor d(13);
            o(18) := c(10) xor c(2) xor d(25) xor c(19) xor d(17) xor d(8) xor d(10) xor c(14) xor d(29) xor c(24) xor d(3) xor c(6) xor d(12) xor d(5) xor c(26) xor d(24) xor d(7) xor c(28) xor d(16) xor d(0) xor c(21) xor c(31) xor c(23) xor c(15) xor d(21) xor c(7);
            o(19) := d(23) xor c(27) xor d(6) xor d(15) xor c(20) xor c(29) xor c(22) xor d(20) xor c(24) xor c(16) xor c(8) xor d(24) xor d(16) xor d(7) xor c(11) xor c(3) xor d(9) xor d(28) xor d(2) xor d(11) xor c(15) xor d(4) xor c(25) xor c(7);
            o(20) := d(23) xor c(17) xor d(15) xor d(6) xor c(9) xor c(30) xor d(8) xor c(12) xor d(27) xor d(1) xor c(4) xor d(10) xor d(19) xor d(3) xor c(16) xor d(22) xor d(5) xor c(26) xor d(14) xor c(8) xor c(28) xor c(21) xor c(23) xor c(25);
            o(21) := c(17) xor c(27) xor c(9) xor c(10) xor c(29) xor c(22) xor c(24) xor d(22) xor d(14) xor d(5) xor c(26) xor c(18) xor d(7) xor d(26) xor d(0) xor c(31) xor d(9) xor d(18) xor c(13) xor d(2) xor c(5) xor d(21) xor d(4) xor d(13);
            o(22) := c(0) xor c(27) xor d(15) xor c(9) xor c(19) xor c(12) xor c(29) xor d(8) xor d(17) xor d(19) xor d(20) xor c(14) xor c(24) xor d(12) xor c(16) xor d(22) xor d(5) xor c(26) xor c(18) xor d(7) xor c(11) xor d(0) xor c(31) xor d(2) xor c(23) xor d(31) xor d(13) xor d(4);
            o(23) := c(0) xor c(17) xor c(27) xor d(15) xor c(9) xor d(25) xor c(19) xor c(20) xor c(29) xor c(6) xor d(12) xor d(30) xor c(16) xor d(22) xor d(5) xor c(26) xor d(14) xor c(1) xor d(16) xor d(0) xor c(31) xor d(18) xor c(13) xor d(2) xor d(11) xor c(15) xor d(31) xor d(4);
            o(24) := c(17) xor d(15) xor c(27) xor c(10) xor c(20) xor c(2) xor c(30) xor d(17) xor d(1) xor d(10) xor c(14) xor d(30) xor d(3) xor d(29) xor c(16) xor d(14) xor d(24) xor c(1) xor c(18) xor c(28) xor c(21) xor d(11) xor d(21) xor d(4) xor c(7) xor d(13);
            o(25) := d(23) xor c(17) xor c(2) xor c(19) xor c(29) xor d(10) xor c(22) xor d(20) xor d(29) xor d(3) xor d(12) xor d(14) xor c(8) xor c(18) xor c(28) xor c(11) xor d(16) xor d(0) xor c(21) xor c(3) xor c(31) xor d(9) xor d(2) xor d(28) xor c(15) xor d(13);
            o(26) := c(0) xor d(6) xor c(10) xor d(25) xor c(19) xor c(20) xor d(8) xor c(22) xor d(27) xor c(4) xor c(24) xor d(3) xor c(6) xor d(12) xor d(5) xor c(26) xor c(18) xor d(7) xor c(28) xor d(0) xor c(3) xor c(31) xor d(9) xor d(11) xor d(28) xor c(23) xor d(21) xor d(31) xor d(13) xor c(25);
            o(27) := d(6) xor c(27) xor c(19) xor c(20) xor c(29) xor d(8) xor d(10) xor d(27) xor c(4) xor d(20) xor d(30) xor d(12) xor c(24) xor d(5) xor c(26) xor d(24) xor c(1) xor c(11) xor d(7) xor c(21) xor d(26) xor d(2) xor c(23) xor d(11) xor c(5) xor c(25) xor d(4) xor c(7);
            o(28) := d(23) xor c(27) xor d(6) xor c(20) xor c(2) xor d(25) xor c(30) xor c(12) xor d(1) xor d(10) xor c(22) xor d(19) xor d(29) xor c(24) xor d(3) xor c(6) xor d(5) xor c(26) xor c(8) xor d(7) xor c(28) xor c(21) xor d(26) xor d(9) xor d(11) xor c(5) xor d(4) xor c(25);
            o(29) := c(27) xor d(6) xor c(9) xor d(25) xor c(29) xor d(8) xor d(10) xor c(22) xor d(3) xor c(6) xor d(22) xor d(5) xor c(26) xor d(24) xor c(28) xor d(0) xor c(21) xor c(3) xor c(31) xor d(9) xor d(18) xor c(13) xor d(28) xor d(2) xor c(23) xor d(4) xor c(25) xor c(7);
            o(30) := d(23) xor c(10) xor c(27) xor c(29) xor c(30) xor d(8) xor d(17) xor d(27) xor c(22) xor d(1) xor c(4) xor c(14) xor d(3) xor c(24) xor d(5) xor c(26) xor c(8) xor d(24) xor c(28) xor d(7) xor d(9) xor d(2) xor c(23) xor d(21) xor d(4) xor c(7);
            o(31) := d(23) xor c(27) xor d(6) xor c(9) xor d(8) xor c(29) xor c(30) xor d(1) xor d(20) xor c(24) xor d(3) xor d(22) xor c(8) xor c(11) xor d(7) xor d(16) xor c(28) xor d(26) xor d(0) xor c(31) xor d(2) xor c(23) xor c(5) xor c(15) xor d(4) xor c(25);
            return o;
        end function;

        --//////////////////////////////////////////////
        -- crc3B
        --//////////////////////////////////////////////
        function crc3B(
            c : in std_logic_vector(31 downto 0);
            d : in std_logic_vector(23 downto 0)
        ) return std_logic_vector is
            variable o : std_logic_vector(31 downto 0);
        begin
            o(0)  := d(23) xor c(17) xor c(20) xor d(17) xor c(14) xor c(24) xor c(8) xor d(14) xor c(18) xor d(7) xor d(11) xor d(13);
            o(1)  := d(23) xor c(17) xor d(6) xor c(9) xor c(20) xor c(19) xor d(17) xor d(10) xor c(14) xor c(24) xor d(12) xor d(22) xor d(14) xor c(8) xor d(7) xor d(16) xor c(21) xor d(11) xor c(15) xor c(25);
            o(2)  := d(23) xor c(17) xor d(6) xor c(9) xor d(15) xor c(10) xor d(17) xor d(10) xor c(22) xor c(14) xor c(24) xor d(22) xor c(16) xor d(5) xor c(26) xor d(14) xor c(8) xor d(7) xor d(16) xor c(21) xor d(9) xor c(15) xor d(21) xor c(25);
            o(3)  := c(17) xor c(27) xor d(6) xor c(9) xor d(15) xor c(10) xor d(8) xor c(22) xor d(20) xor d(22) xor c(16) xor d(5) xor c(26) xor d(14) xor c(18) xor d(16) xor c(11) xor d(9) xor c(23) xor c(15) xor d(21) xor d(4) xor c(25) xor d(13);
            o(4)  := d(23) xor c(27) xor d(15) xor c(10) xor c(20) xor c(19) xor d(17) xor d(8) xor c(12) xor c(14) xor d(20) xor d(19) xor d(3) xor d(12) xor c(16) xor d(5) xor c(26) xor c(8) xor c(28) xor c(11) xor d(11) xor c(23) xor d(21) xor d(4);
            o(5)  := d(23) xor c(27) xor c(9) xor d(17) xor c(29) xor c(12) xor d(10) xor c(14) xor d(20) xor d(19) xor d(3) xor d(22) xor c(8) xor c(18) xor c(28) xor d(16) xor c(11) xor c(21) xor d(18) xor c(13) xor d(2) xor c(15) xor d(4) xor d(13);
            o(6)  := c(9) xor d(15) xor c(10) xor c(19) xor c(30) xor c(29) xor c(12) xor d(17) xor d(1) xor c(22) xor d(19) xor c(14) xor d(3) xor d(12) xor d(22) xor c(16) xor d(16) xor c(28) xor d(9) xor d(18) xor c(13) xor d(2) xor c(15) xor d(21);
            o(7)  := d(23) xor d(15) xor c(10) xor c(29) xor c(30) xor d(8) xor d(1) xor d(20) xor c(24) xor c(16) xor c(8) xor c(18) xor d(7) xor c(11) xor d(16) xor d(0) xor c(31) xor d(18) xor c(13) xor d(2) xor c(23) xor d(21) xor c(15) xor d(13);
            o(8)  := d(23) xor d(6) xor c(9) xor d(15) xor c(20) xor c(19) xor c(30) xor c(12) xor d(1) xor d(20) xor d(19) xor d(12) xor d(22) xor c(16) xor c(8) xor c(18) xor c(11) xor d(0) xor c(31) xor d(11) xor d(13) xor c(25);
            o(9)  := c(17) xor c(9) xor c(10) xor c(19) xor c(20) xor c(12) xor d(10) xor d(19) xor d(12) xor d(22) xor d(5) xor c(26) xor d(14) xor d(0) xor c(21) xor c(31) xor d(18) xor c(13) xor d(11) xor d(21);
            o(10) := d(23) xor c(17) xor c(27) xor c(10) xor c(22) xor d(10) xor d(20) xor c(24) xor d(14) xor c(8) xor d(7) xor c(11) xor c(21) xor d(9) xor d(18) xor c(13) xor d(21) xor d(4);
            o(11) := d(23) xor c(17) xor d(6) xor c(9) xor c(20) xor d(8) xor c(12) xor c(22) xor d(20) xor d(19) xor c(24) xor d(3) xor d(22) xor d(14) xor c(8) xor d(7) xor c(28) xor c(11) xor d(9) xor d(11) xor c(23) xor c(25);
            o(12) := d(23) xor c(17) xor d(6) xor c(9) xor c(10) xor c(20) xor d(17) xor c(29) xor d(8) xor c(12) xor d(10) xor c(14) xor d(19) xor d(22) xor d(5) xor c(26) xor d(14) xor c(8) xor c(21) xor d(18) xor c(13) xor d(11) xor d(2) xor c(23) xor d(21) xor c(25);
            o(13) := c(27) xor c(9) xor c(10) xor c(30) xor d(17) xor d(10) xor d(1) xor c(22) xor d(20) xor c(14) xor c(24) xor d(22) xor d(5) xor c(26) xor c(18) xor d(16) xor d(7) xor c(11) xor c(21) xor d(9) xor d(18) xor c(13) xor c(15) xor d(21) xor d(4) xor d(13);
            o(14) := d(15) xor d(6) xor c(10) xor c(27) xor c(19) xor d(8) xor c(12) xor d(17) xor c(22) xor d(20) xor d(19) xor c(14) xor d(3) xor d(12) xor c(16) xor c(28) xor c(11) xor d(16) xor d(0) xor d(9) xor c(31) xor c(23) xor d(21) xor c(15) xor c(25) xor d(4);
            o(15) := c(17) xor d(15) xor c(20) xor d(8) xor c(29) xor c(12) xor d(20) xor d(19) xor c(24) xor d(3) xor c(16) xor d(14) xor d(5) xor c(26) xor c(11) xor d(7) xor c(28) xor d(16) xor d(18) xor c(13) xor d(2) xor c(23) xor d(11) xor c(15);
            o(16) := d(23) xor c(27) xor d(6) xor d(15) xor c(20) xor c(29) xor c(30) xor c(12) xor d(1) xor d(10) xor d(19) xor c(16) xor c(8) xor c(21) xor d(18) xor c(13) xor d(11) xor d(2) xor d(4) xor c(25);
            o(17) := c(17) xor c(9) xor c(30) xor d(17) xor d(10) xor d(1) xor c(22) xor c(14) xor d(3) xor d(22) xor d(5) xor c(26) xor d(14) xor c(28) xor d(0) xor c(21) xor c(31) xor d(18) xor d(9) xor c(13);
            o(18) := c(10) xor c(27) xor c(29) xor d(17) xor d(8) xor c(22) xor c(14) xor c(18) xor d(16) xor d(0) xor d(9) xor c(31) xor d(2) xor c(23) xor d(21) xor c(15) xor d(4) xor d(13);
            o(19) := d(15) xor c(19) xor d(8) xor c(30) xor d(1) xor d(20) xor c(24) xor d(3) xor d(12) xor c(16) xor c(11) xor d(16) xor d(7) xor c(28) xor c(23) xor c(15);
            o(20) := c(17) xor d(15) xor d(6) xor c(20) xor c(12) xor c(29) xor d(19) xor c(24) xor c(16) xor d(14) xor d(7) xor d(0) xor c(31) xor d(2) xor d(11) xor c(25);
            o(21) := c(17) xor d(6) xor c(30) xor d(1) xor d(10) xor d(14) xor d(5) xor c(26) xor c(18) xor c(21) xor d(18) xor c(13) xor c(25) xor d(13);
            o(22) := d(23) xor c(17) xor c(27) xor c(20) xor c(19) xor c(22) xor c(24) xor d(12) xor d(5) xor c(26) xor d(14) xor c(8) xor d(7) xor d(0) xor c(31) xor d(9) xor d(11) xor d(4);
            o(23) := d(23) xor c(17) xor c(27) xor d(6) xor c(9) xor d(17) xor d(8) xor d(10) xor c(14) xor c(24) xor d(3) xor d(22) xor d(14) xor c(8) xor d(7) xor c(28) xor c(21) xor c(23) xor d(4) xor c(25);
            o(24) := c(0) xor d(6) xor c(9) xor c(10) xor c(29) xor c(22) xor c(24) xor d(3) xor d(22) xor d(5) xor c(26) xor c(18) xor d(16) xor d(7) xor c(28) xor d(9) xor d(2) xor c(15) xor d(21) xor c(25) xor d(13);
            o(25) := d(15) xor d(6) xor c(10) xor c(27) xor c(19) xor c(29) xor c(30) xor d(8) xor d(1) xor d(20) xor d(12) xor c(16) xor d(5) xor c(26) xor c(1) xor c(11) xor d(2) xor c(23) xor d(21) xor c(25) xor d(4);
            o(26) := d(23) xor c(27) xor c(2) xor d(17) xor c(30) xor c(12) xor d(1) xor c(14) xor d(20) xor d(19) xor d(3) xor d(5) xor c(26) xor c(8) xor c(18) xor c(28) xor c(11) xor d(0) xor c(31) xor d(4) xor d(13);
            o(27) := c(27) xor c(9) xor c(19) xor c(29) xor c(12) xor d(19) xor d(3) xor d(12) xor d(22) xor d(16) xor c(28) xor d(0) xor c(3) xor c(31) xor d(18) xor c(13) xor d(2) xor c(15) xor d(4);
            o(28) := d(15) xor c(10) xor c(20) xor c(29) xor c(30) xor d(17) xor d(1) xor c(4) xor c(14) xor d(3) xor c(16) xor c(28) xor d(18) xor c(13) xor d(2) xor d(11) xor d(21);
            o(29) := c(17) xor c(29) xor c(30) xor d(17) xor d(1) xor d(10) xor d(20) xor c(14) xor d(14) xor c(11) xor d(16) xor d(0) xor c(21) xor c(31) xor d(2) xor c(5) xor c(15);
            o(30) := d(15) xor c(30) xor c(12) xor d(1) xor c(22) xor d(19) xor c(6) xor c(16) xor c(18) xor d(16) xor d(0) xor c(31) xor d(9) xor c(15) xor d(13);
            o(31) := c(17) xor d(15) xor c(19) xor d(8) xor d(12) xor c(16) xor d(14) xor d(0) xor d(18) xor c(31) xor c(13) xor c(23) xor c(7);
            return o;
        end function;

        --//////////////////////////////////////////////
        -- crc2B
        --//////////////////////////////////////////////
        function crc2B(
            c : in std_logic_vector(31 downto 0);
            d : in std_logic_vector(15 downto 0)
        ) return std_logic_vector is
            variable o : std_logic_vector(31 downto 0);
        begin
            o(0)  := d(9) xor c(22) xor d(5) xor c(26) xor d(15) xor d(6) xor d(3) xor c(28) xor c(25) xor c(16);
            o(1)  := c(17) xor d(15) xor d(6) xor c(27) xor c(29) xor d(8) xor c(22) xor d(3) xor c(16) xor d(14) xor c(28) xor d(9) xor c(23) xor d(2) xor d(4) xor c(25);
            o(2)  := c(17) xor d(15) xor d(6) xor d(8) xor c(29) xor c(30) xor c(22) xor d(1) xor c(24) xor c(16) xor d(14) xor c(18) xor d(7) xor d(9) xor d(2) xor c(23) xor c(25) xor d(13);
            o(3)  := c(17) xor d(6) xor c(19) xor d(8) xor c(30) xor d(1) xor c(24) xor d(12) xor d(14) xor d(5) xor c(26) xor c(18) xor d(7) xor d(0) xor c(31) xor c(23) xor d(13) xor c(25);
            o(4)  := d(15) xor c(27) xor c(20) xor c(19) xor c(22) xor d(3) xor c(24) xor d(12) xor c(16) xor c(18) xor c(28) xor d(7) xor d(0) xor d(9) xor c(31) xor d(11) xor d(13) xor d(4);
            o(5)  := c(17) xor d(15) xor c(19) xor c(20) xor d(8) xor c(29) xor c(22) xor d(10) xor d(12) xor c(16) xor d(5) xor c(26) xor d(14) xor c(21) xor d(9) xor d(2) xor c(23) xor d(11);
            o(6)  := c(17) xor c(27) xor c(20) xor d(8) xor c(30) xor d(1) xor c(22) xor d(10) xor c(24) xor d(14) xor c(18) xor d(7) xor c(21) xor d(9) xor c(23) xor d(11) xor d(4) xor d(13);
            o(7)  := d(15) xor c(19) xor d(8) xor d(10) xor c(24) xor d(12) xor c(16) xor d(5) xor c(26) xor c(18) xor d(7) xor d(0) xor c(21) xor c(31) xor c(23) xor d(13);
            o(8)  := c(17) xor d(15) xor c(27) xor c(19) xor c(20) xor d(3) xor d(12) xor c(24) xor c(16) xor d(5) xor c(26) xor d(14) xor c(28) xor d(7) xor d(11) xor d(4);
            o(9)  := c(17) xor c(27) xor d(6) xor c(20) xor c(29) xor d(10) xor d(3) xor d(14) xor c(18) xor c(28) xor c(21) xor d(2) xor d(11) xor d(4) xor d(13) xor c(25);
            o(10) := d(15) xor d(6) xor c(19) xor c(30) xor c(29) xor d(1) xor d(10) xor d(12) xor c(16) xor c(18) xor c(21) xor d(2) xor c(25) xor d(13);
            o(11) := c(17) xor d(15) xor d(6) xor c(19) xor c(20) xor c(30) xor d(1) xor d(3) xor d(12) xor c(16) xor d(14) xor c(28) xor d(0) xor c(31) xor d(11) xor c(25);
            o(12) := c(17) xor d(15) xor d(6) xor c(20) xor c(29) xor c(22) xor d(10) xor d(3) xor c(16) xor d(14) xor c(18) xor c(28) xor d(0) xor c(21) xor d(9) xor c(31) xor d(2) xor d(11) xor c(25) xor d(13);
            o(13) := c(17) xor c(19) xor d(8) xor c(29) xor c(30) xor d(1) xor d(10) xor c(22) xor d(12) xor d(14) xor d(5) xor c(26) xor c(18) xor c(21) xor d(9) xor d(2) xor c(23) xor d(13);
            o(14) := c(27) xor c(19) xor c(20) xor c(30) xor d(8) xor d(1) xor c(22) xor c(24) xor d(12) xor c(18) xor d(7) xor d(0) xor c(31) xor d(9) xor d(11) xor c(23) xor d(13) xor d(4);
            o(15) := d(6) xor c(20) xor c(19) xor d(8) xor d(10) xor d(12) xor c(24) xor d(3) xor d(7) xor c(28) xor d(0) xor c(21) xor c(31) xor c(23) xor d(11) xor c(25);
            o(16) := c(0) xor d(15) xor c(20) xor c(29) xor d(10) xor d(3) xor c(24) xor c(16) xor c(28) xor d(7) xor c(21) xor d(11) xor d(2);
            o(17) := c(17) xor d(6) xor c(29) xor c(30) xor d(10) xor d(1) xor c(22) xor d(14) xor c(1) xor c(21) xor d(9) xor d(2) xor c(25);
            o(18) := c(2) xor c(30) xor d(8) xor d(1) xor c(22) xor c(26) xor d(5) xor c(18) xor d(0) xor d(9) xor c(31) xor c(23) xor d(13);
            o(19) := c(27) xor c(19) xor d(8) xor d(12) xor c(24) xor d(7) xor d(0) xor c(3) xor c(31) xor c(23) xor d(4);
            o(20) := d(6) xor c(20) xor c(4) xor d(3) xor c(24) xor d(7) xor c(28) xor d(11) xor c(25);
            o(21) := d(6) xor c(29) xor d(10) xor c(26) xor d(5) xor c(21) xor c(5) xor d(2) xor c(25);
            o(22) := d(15) xor d(6) xor c(27) xor c(30) xor d(1) xor d(3) xor c(6) xor c(16) xor c(28) xor c(25) xor d(4);
            o(23) := c(17) xor d(15) xor d(6) xor c(29) xor c(22) xor c(16) xor d(14) xor d(0) xor d(9) xor c(31) xor d(2) xor c(25) xor c(7);
            o(24) := d(14) xor d(5) xor c(26) xor c(17) xor d(1) xor c(8) xor c(23) xor c(18) xor d(8) xor d(13) xor c(30);
            o(25) := c(31) xor c(27) xor c(18) xor c(9) xor d(7) xor c(24) xor d(12) xor c(19) xor d(13) xor d(4) xor d(0);
            o(26) := d(15) xor c(10) xor c(20) xor c(19) xor c(22) xor d(12) xor c(16) xor d(5) xor c(26) xor d(9) xor d(11);
            o(27) := c(17) xor c(27) xor c(20) xor d(8) xor d(10) xor d(14) xor c(11) xor c(21) xor c(23) xor d(11) xor d(4);
            o(28) := c(12) xor c(22) xor d(10) xor c(24) xor d(3) xor c(18) xor d(7) xor c(28) xor c(21) xor d(9) xor d(13);
            o(29) := d(6) xor c(19) xor d(8) xor c(29) xor c(22) xor d(12) xor c(13) xor d(9) xor d(2) xor c(23) xor c(25);
            o(30) := d(5) xor c(26) xor d(1) xor d(11) xor c(23) xor c(14) xor c(20) xor d(7) xor c(24) xor c(30) xor d(8);
            o(31) := d(10) xor c(31) xor c(27) xor d(6) xor d(7) xor c(24) xor c(15) xor d(4) xor d(0) xor c(21) xor c(25);
            return o;
        end function;

        --//////////////////////////////////////////////
        -- crc1B
        --//////////////////////////////////////////////
        function crc1B(
            c : in std_logic_vector(31 downto 0);
            d : in std_logic_vector(7 downto 0)
        ) return std_logic_vector is
            variable o : std_logic_vector(31 downto 0);
        begin
            o(0)  := d(1) xor d(7) xor c(24) xor c(30);
            o(1)  := d(1) xor c(31) xor d(6) xor d(7) xor c(24) xor c(30) xor d(0) xor c(25);
            o(2)  := d(1) xor c(31) xor d(5) xor c(26) xor d(6) xor d(7) xor c(24) xor c(30) xor d(0) xor c(25);
            o(3)  := c(31) xor d(5) xor c(26) xor d(6) xor c(27) xor d(0) xor c(25) xor d(4);
            o(4)  := d(1) xor d(5) xor c(26) xor c(27) xor d(7) xor c(24) xor d(3) xor c(28) xor c(30) xor d(4);
            o(5)  := c(27) xor d(6) xor c(30) xor c(29) xor d(1) xor d(3) xor c(24) xor d(7) xor c(28) xor d(0) xor c(31) xor d(2) xor d(4) xor c(25);
            o(6)  := d(6) xor c(30) xor c(29) xor d(1) xor d(3) xor c(26) xor d(5) xor c(28) xor d(0) xor c(31) xor d(2) xor c(25);
            o(7)  := d(5) xor c(26) xor c(31) xor c(27) xor d(2) xor d(7) xor c(24) xor d(4) xor c(29) xor d(0);
            o(8)  := c(0) xor d(6) xor c(27) xor d(7) xor c(24) xor d(3) xor c(28) xor c(25) xor d(4);
            o(9)  := d(5) xor c(26) xor d(6) xor d(2) xor c(1) xor d(3) xor c(28) xor c(25) xor c(29);
            o(10) := d(5) xor c(26) xor c(27) xor d(2) xor d(7) xor c(24) xor c(2) xor d(4) xor c(29);
            o(11) := d(6) xor c(27) xor d(7) xor c(24) xor d(3) xor c(28) xor c(25) xor d(4) xor c(3);
            o(12) := d(6) xor c(29) xor c(30) xor d(1) xor c(4) xor d(3) xor c(24) xor c(26) xor d(5) xor d(7) xor c(28) xor d(2) xor c(25);
            o(13) := d(6) xor c(27) xor c(30) xor c(29) xor d(1) xor c(26) xor d(5) xor d(0) xor c(31) xor c(5) xor d(2) xor d(4) xor c(25);
            o(14) := d(5) xor c(26) xor d(1) xor c(31) xor c(27) xor d(3) xor c(28) xor c(6) xor d(4) xor c(30) xor d(0);
            o(15) := c(31) xor c(27) xor d(2) xor d(3) xor c(28) xor d(4) xor c(29) xor d(0) xor c(7);
            o(16) := c(8) xor d(2) xor d(7) xor c(24) xor d(3) xor c(28) xor c(29);
            o(17) := d(1) xor d(6) xor d(2) xor c(9) xor c(25) xor c(29) xor c(30);
            o(18) := d(5) xor c(26) xor d(1) xor c(31) xor c(10) xor c(30) xor d(0);
            o(19) := c(31) xor c(27) xor c(11) xor d(4) xor d(0);
            o(20) := d(3) xor c(28) xor c(12);
            o(21) := c(13) xor d(2) xor c(29);
            o(22) := c(14) xor d(7) xor c(24);
            o(23) := d(1) xor d(6) xor d(7) xor c(24) xor c(15) xor c(30) xor c(25);
            o(24) := c(31) xor d(5) xor c(26) xor d(6) xor d(0) xor c(25) xor c(16);
            o(25) := d(5) xor c(26) xor c(17) xor c(27) xor d(4);
            o(26) := d(1) xor c(27) xor c(18) xor d(7) xor c(24) xor d(3) xor c(28) xor c(30) xor d(4);
            o(27) := c(31) xor d(6) xor d(2) xor d(3) xor c(28) xor c(19) xor d(0) xor c(25) xor c(29);
            o(28) := d(5) xor c(26) xor d(1) xor d(2) xor c(20) xor c(29) xor c(30);
            o(29) := d(1) xor c(31) xor c(27) xor d(4) xor c(30) xor d(0) xor c(21);
            o(30) := c(31) xor c(22) xor d(3) xor c(28) xor d(0);
            o(31) := d(2) xor c(23) xor c(29);
            return o;
        end function;

    end package body;