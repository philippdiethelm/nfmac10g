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

library work;
use work.xgmii_includes.all;

entity xgmii2axis is port (

    -- Clks and resets
    clk                  : in  std_logic;
    rst                  : in  std_logic;

    -- Stats
    good_frames          : out std_logic_vector(31 downto 0);
    bad_frames           : out std_logic_vector(31 downto 0);

    -- Conf vectors
    configuration_vector : in  std_logic_vector(79 downto 0);

    -- XGMII
    xgmii_d              : in  std_logic_vector(63 downto 0);
    xgmii_c              : in  std_logic_vector(7 downto 0);

    -- AXIS
    aresetn              : in  std_logic;
    tdata                : out std_logic_vector(63 downto 0);
    tkeep                : out std_logic_vector(7 downto 0);
    tvalid               : out std_logic;
    tlast                : out std_logic;
    tuser                : out std_logic_vector(0 downto 0)
);
end entity;

architecture rtl of xgmii2axis is

    type t_fsm is (
        SRES,
        IDLE,
        ST_LANE0,
        ST_LANE4,
        FIN,
        D_LANE4,
        FINL4,
        s7
    );

    ---------------------------------------------------------
    -- Local output
    ---------------------------------------------------------
    signal synch         : std_logic;

    ---------------------------------------------------------
    -- Local adapter
    ---------------------------------------------------------
    signal fsm           : t_fsm;
    signal tdata_i       : std_logic_vector(63 downto 0);
    signal tkeep_i       : std_logic_vector(7 downto 0);
    signal last_tkeep_i  : std_logic_vector(7 downto 0);
    signal tvalid_i      : std_logic;
    signal tlast_i       : std_logic;
    signal tuser_i       : std_logic_vector(0 downto 0);
    signal tdata_d0      : std_logic_vector(63 downto 0);
    signal tvalid_d0     : std_logic;
    signal d             : std_logic_vector(63 downto 0);
    signal c             : std_logic_vector(7 downto 0);
    signal d_reg         : std_logic_vector(63 downto 0);
    signal c_reg         : std_logic_vector(7 downto 0);
    signal inbound_frame : std_logic;
    signal len           : unsigned(15 downto 0);
    signal aux_dw        : std_logic_vector(31 downto 0);
    signal chk_tchar     : boolean;

    ---------------------------------------------------------
    -- Local CRC32
    ---------------------------------------------------------
    signal crc_32        : std_logic_vector(31 downto 0);
    signal crc_32_7B     : std_logic_vector(31 downto 0);
    signal crc_32_6B     : std_logic_vector(31 downto 0);
    signal crc_32_5B     : std_logic_vector(31 downto 0);
    signal crc_32_4B     : std_logic_vector(31 downto 0);
    signal crc_32_3B     : std_logic_vector(31 downto 0);
    signal crc_32_2B     : std_logic_vector(31 downto 0);
    signal crc_32_1B     : std_logic_vector(31 downto 0);
    signal rcved_crc     : std_logic_vector(31 downto 0);
    signal calcted_crc   : std_logic_vector(31 downto 0);
begin

    ---------------------------------------------------------
    -- assigns
    ---------------------------------------------------------
    d <= xgmii_d;
    c <= xgmii_c;

    --//////////////////////////////////////////////
    -- output
    --//////////////////////////////////////////////
    process (clk, aresetn) begin

        if aresetn = '0' then
            tvalid <= '0';
            synch  <= '0';
        elsif rising_edge(clk) then

            if inbound_frame = '0' or synch = '1' then
                synch  <= '1';
                tdata  <= tdata_i;
                tkeep  <= tkeep_i;
                tvalid <= tvalid_i;
                tlast  <= tlast_i;
                tuser  <= tuser_i;
            else
                tvalid <= '0';
            end if;

        end if;
    end process;

    --//////////////////////////////////////////////
    -- adapter
    --//////////////////////////////////////////////
    process (clk, rst) begin

        if rst = '1' then
            tvalid_i <= '0';
            fsm      <= SRES;
        elsif rising_edge(clk) then

            if tvalid = '1' and tlast = '1' and tuser(0) = '1' then
                good_frames <= std_logic_vector(unsigned(good_frames) + 1);
            end if;

            if tvalid = '1' and tlast = '1' and tuser(0) = '0' then
                bad_frames <= std_logic_vector(unsigned(bad_frames) + 1);
            end if;

            tdata_i  <= tdata_d0;
            tvalid_i <= tvalid_d0;

            case fsm is

                when SRES              =>
                    good_frames <= (others => '0');
                    bad_frames  <= (others => '0');
                    fsm         <= IDLE;

                when IDLE =>
                    tvalid_d0     <= '0';
                    tlast_i       <= '0';
                    tuser_i       <= "0";
                    crc_32        <= CRC802_3_PRESET;
                    inbound_frame <= '0';
                    d_reg         <= d;
                    c_reg         <= c;
                    len           <= to_unsigned(0, len'length);
                    if sof_lane0(d, c) then
                        inbound_frame <= '1';
                        fsm           <= ST_LANE0;
                    elsif sof_lane4(d, c) then
                        inbound_frame <= '1';
                        fsm           <= ST_LANE4;
                    end if;

                when ST_LANE0 =>
                    tdata_d0  <= d;
                    tvalid_d0 <= '1';
                    tkeep_i   <= x"FF";
                    tlast_i   <= '0';
                    tuser_i   <= "0";
                    d_reg     <= d;
                    c_reg     <= c;
                    crc_32    <= crc8B(crc_32, d);
                    crc_32_7B <= crc7B(crc_32, d(55 downto 0));
                    crc_32_6B <= crc6B(crc_32, d(47 downto 0));
                    crc_32_5B <= crc5B(crc_32, d(39 downto 0));
                    crc_32_4B <= crc4B(crc_32, d(31 downto 0));

                    case c is
                        when x"00" =>
                            len <= len + 8;

                        when x"FF" =>
                            len       <= len;
                            tkeep_i   <= x"0F";
                            tvalid_d0 <= '0';
                            tlast_i   <= '1';
                            if not(crc_rev(crc_32_4B)) = d_reg(63 downto 32) and is_tchar(d(7 downto 0)) then
                                tuser_i(0) <= '1';
                            end if;
                            fsm <= IDLE;

                        when x"FE" =>
                            len       <= len + 1;
                            tkeep_i   <= x"1F";
                            tvalid_d0 <= '0';
                            tlast_i   <= '1';
                            if not(crc_rev(crc_32_5B)) = d(7 downto 0) & d_reg(63 downto 40) and is_tchar(d(15 downto 8)) then
                                tuser_i(0) <= '1';
                            end if;
                            fsm <= IDLE;

                        when x"FC" =>
                            len       <= len + 2;
                            tkeep_i   <= x"3F";
                            tvalid_d0 <= '0';
                            tlast_i   <= '1';
                            if not(crc_rev(crc_32_6B)) = d(15 downto 0) & d_reg(63 downto 48) and is_tchar(d(23 downto 16)) then
                                tuser_i(0) <= '1';
                            end if;
                            fsm <= IDLE;

                        when x"F8" =>
                            len       <= len + 3;
                            tkeep_i   <= x"7F";
                            tvalid_d0 <= '0';
                            tlast_i   <= '1';
                            if not(crc_rev(crc_32_7B)) = d(23 downto 0) & d_reg(63 downto 56) and is_tchar(d(31 downto 24)) then
                                tuser_i(0) <= '1';
                            end if;
                            fsm <= IDLE;

                        when x"F0" =>
                            len       <= len + 4;
                            tvalid_d0 <= '0';
                            tlast_i   <= '1';
                            if not(crc_rev(crc_32)) = d(31 downto 0) and is_tchar(d(39 downto 32)) then
                                tuser_i(0) <= '1';
                            end if;
                            fsm <= IDLE;

                        when x"E0" =>
                            len          <= len + 5;
                            last_tkeep_i <= x"01";
                            rcved_crc    <= d(39 downto 8);
                            calcted_crc  <= crc1B(crc_32, d(7 downto 0));
                            chk_tchar    <= is_tchar(d(47 downto 40));
                            fsm          <= FIN;

                        when x"C0" =>
                            len          <= len + 6;
                            last_tkeep_i <= x"03";
                            rcved_crc    <= d(47 downto 16);
                            calcted_crc  <= crc2B(crc_32, d(15 downto 0));
                            chk_tchar    <= is_tchar(d(55 downto 48));
                            fsm          <= FIN;

                        when x"80" =>
                            len          <= len + 7;
                            last_tkeep_i <= x"07";
                            rcved_crc    <= d(55 downto 24);
                            calcted_crc  <= crc3B(crc_32, d(23 downto 0));
                            chk_tchar    <= is_tchar(d(63 downto 56));
                            fsm          <= FIN;

                        when others =>
                            tlast_i   <= '1';
                            tvalid_d0 <= '0';
                            tvalid_i  <= '1';
                            fsm       <= IDLE;
                    end case;

                when FIN =>
                    tkeep_i   <= last_tkeep_i;
                    tlast_i   <= '1';
                    tvalid_d0 <= '0';
                    crc_32    <= CRC802_3_PRESET;
                    if not(crc_rev(calcted_crc)) = rcved_crc and chk_tchar then
                        tuser_i(0) <= '1';
                    end if;
                    if sof_lane4(d, c) then
                        fsm <= ST_LANE4;
                    else
                        fsm <= IDLE;
                    end if;

                when ST_LANE4 =>
                    len     <= to_unsigned(4, len'length);
                    tlast_i <= '0';
                    tuser_i <= (others => '0');
                    crc_32  <= crc4B(crc_32, d(63 downto 32));
                    aux_dw  <= d(63 downto 32);
                    if c /= x"00" then
                        fsm <= D_LANE4;
                    else
                        fsm <= IDLE;
                    end if;

                when D_LANE4 =>
                    tdata_d0  <= d(31 downto 0) & aux_dw;
                    tvalid_d0 <= '1';
                    tkeep_i   <= x"FF";
                    aux_dw    <= d(63 downto 32);
                    d_reg     <= d;
                    c_reg     <= c;
                    crc_32    <= crc8B(crc_32, d);
                    crc_32_4B <= crc4B(crc_32, d(31 downto 0));
                    crc_32_5B <= crc5B(crc_32, d(39 downto 0));
                    crc_32_6B <= crc6B(crc_32, d(47 downto 0));
                    crc_32_7B <= crc7B(crc_32, d(55 downto 0));

                    case c is
                        when x"00" =>
                            len <= len + 8;

                        when x"FF" =>
                            len       <= len;
                            tvalid_d0 <= '0';
                            tlast_i   <= '1';
                            if not(crc_rev(crc_32_4B)) = d_reg(63 downto 32) and is_tchar(d(7 downto 0)) then
                                tuser_i(0) <= '1';
                            end if;
                            fsm <= IDLE;

                        when x"FE" =>
                            len          <= len + 1;
                            last_tkeep_i <= x"01";
                            rcved_crc    <= d(7 downto 0) & aux_dw(31 downto 8);
                            calcted_crc  <= crc_32_5B;
                            chk_tchar    <= is_tchar(d(15 downto 8));
                            fsm          <= FINL4;

                        when x"FC" =>
                            len          <= len + 2;
                            last_tkeep_i <= x"03";
                            rcved_crc    <= d(15 downto 0) & aux_dw(31 downto 16);
                            calcted_crc  <= crc_32_6B;
                            chk_tchar    <= is_tchar(d(23 downto 16));
                            fsm          <= FINL4;

                        when x"F8" =>
                            len          <= len + 3;
                            last_tkeep_i <= x"07";
                            rcved_crc    <= d(23 downto 0) & aux_dw(31 downto 24);
                            calcted_crc  <= crc_32_7B;
                            chk_tchar    <= is_tchar(d(31 downto 24));
                            fsm          <= FINL4;

                        when x"F0" =>
                            len          <= len + 4;
                            last_tkeep_i <= x"0F";
                            rcved_crc    <= d(31 downto 0);
                            calcted_crc  <= crc_32;
                            chk_tchar    <= is_tchar(d(39 downto 32));
                            fsm          <= FIN;

                        when x"E0" =>
                            len          <= len + 5;
                            last_tkeep_i <= x"1F";
                            rcved_crc    <= d(39 downto 8);
                            calcted_crc  <= crc1B(crc_32, d(7 downto 0));
                            chk_tchar    <= is_tchar(d(47 downto 40));
                            fsm          <= FIN;

                        when x"C0" =>
                            len          <= len + 6;
                            last_tkeep_i <= x"3F";
                            rcved_crc    <= d(47 downto 16);
                            calcted_crc  <= crc2B(crc_32, d(15 downto 0));
                            chk_tchar    <= is_tchar(d(55 downto 48));
                            fsm          <= FIN;

                        when x"80" =>
                            len          <= len + 7;
                            last_tkeep_i <= x"7F";
                            rcved_crc    <= d(55 downto 24);
                            calcted_crc  <= crc3B(crc_32, d(23 downto 0));
                            chk_tchar    <= is_tchar(d(63 downto 56));
                            fsm          <= FIN;

                        when others =>
                            tlast_i   <= '1';
                            tvalid_d0 <= '0';
                            tvalid_i  <= '1';
                            fsm       <= IDLE;
                    end case;

                when FINL4 =>
                    len       <= to_unsigned(0, len'length);
                    tkeep_i   <= last_tkeep_i;
                    tlast_i   <= '1';
                    tvalid_d0 <= '0';
                    crc_32    <= CRC802_3_PRESET;
                    if not(crc_rev(calcted_crc)) = rcved_crc and chk_tchar then
                        tuser_i(0) <= '1';
                    end if;
                    if sof_lane0(d, c) then
                        fsm <= ST_LANE0;
                    elsif sof_lane4(d, c) then
                        fsm <= ST_LANE4;
                    else
                        fsm <= IDLE;
                    end if;

                when others =>
                    fsm <= IDLE;
            end case;
        end if;
    end process;

end architecture;