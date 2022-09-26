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

entity axis2xgmii is
    port (
        -- Clks and resets
        clk                  : in  std_logic;
        rst                  : in  std_logic;

        -- Stats
        good_frames          : out std_logic_vector(31 downto 0);
        bad_frames           : out std_logic_vector(31 downto 0);

        -- Conf vectors
        configuration_vector : in  std_logic_vector(79 downto 0);

        -- internal
        lane4_start          : out std_logic;
        dic_o                : out unsigned(1 downto 0);

        -- XGMII
        xgmii_d              : out std_logic_vector(63 downto 0);
        xgmii_c              : out std_logic_vector(7 downto 0);

        -- AXIS
        tdata                : in  std_logic_vector(63 downto 0);
        tkeep                : in  std_logic_vector(7 downto 0);
        tvalid               : in  std_logic;
        tready               : out std_logic;
        tlast                : in  std_logic;
        tuser                : in  std_logic_vector(0 downto 0)
    );
end entity;

architecture rtl of axis2xgmii is

    type t_fsm is (
        SRES,
        IDLE_L0,
        ST_LANE0,
        QW_IDLE,
        L0_FIN_8B,
        T_LANE4,
        L0_FIN_7B_6B_5B,
        T_LANE3,
        DW_IDLE,
        T_LANE2,
        T_LANE1,
        L0_FIN_4B,
        T_LANE0,
        L0_FIN_3B_2B_1B,
        T_LANE7,
        T_LANE6,
        T_LANE5,
        ST_LANE4,
        ST_LANE4_D,
        L4_FIN_8B,
        L4_FIN_7B_6B_5B,
        L4_FIN_4B,
        L4_FIN_3B_2B_1B);

    ---------------------------------------------------------
    -- Local adapter
    ---------------------------------------------------------
    signal fsm           : t_fsm := SRES;
    signal tdata_i       : std_logic_vector(63 downto 0);
    signal tkeep_i       : std_logic_vector(7 downto 0);
    signal d             : std_logic_vector(63 downto 0);
    signal c             : std_logic_vector(7 downto 0);
    signal aux_dw        : std_logic_vector(31 downto 0);
    signal dic           : unsigned(1 downto 0);

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
    signal calcted_crc4B : std_logic_vector(31 downto 0);
    signal crc_reg       : std_logic_vector(31 downto 0);
begin
    ---------------------------------------------------------
    -- assigns
    ---------------------------------------------------------
    xgmii_d <= d;
    xgmii_c <= c;
    dic_o   <= dic;

    --//////////////////////////////////////////////
    -- adapter
    --//////////////////////////////////////////////
    process (clk, rst)
        variable aux_var_crc : std_logic_vector(31 downto 0);
    begin
        if rst = '1' then
            d      <= QW_IDLE_D;
            c      <= QW_IDLE_C;
            tready <= '0';
            fsm    <= SRES;
        elsif rising_edge(clk) then
            case fsm is

                when SRES =>
                    dic    <= to_unsigned(0, dic'length);
                    tready <= '1';
                    fsm    <= IDLE_L0;

                when IDLE_L0 =>
                    d           <= QW_IDLE_D;
                    c           <= QW_IDLE_C;
                    tdata_i     <= tdata;
                    tkeep_i     <= tkeep;
                    lane4_start <= '0';
                    if tvalid = '1' then
                        crc_32 <= crc8B(CRC802_3_PRESET, tdata);
                        d      <= PREAMBLE_LANE0_D;
                        c      <= PREAMBLE_LANE0_C;
                        fsm    <= ST_LANE0;
                    else
                        if dic /= 0 then
                            dic <= dic - 1;
                        end if;
                    end if;

                when ST_LANE0 =>
                    tready    <= '0';
                    tdata_i   <= tdata;
                    tkeep_i   <= tkeep;
                    d         <= tdata_i;
                    c         <= x"00";
                    crc_32    <= crc8B(crc_32, tdata);
                    crc_32_7B <= crc7B(crc_32, tdata(55 downto 0));
                    crc_32_6B <= crc6B(crc_32, tdata(47 downto 0));
                    crc_32_5B <= crc5B(crc_32, tdata(39 downto 0));
                    crc_32_4B <= crc4B(crc_32, tdata(31 downto 0));
                    crc_32_3B <= crc3B(crc_32, tdata(23 downto 0));
                    crc_32_2B <= crc2B(crc_32, tdata(15 downto 0));
                    crc_32_1B <= crc1B(crc_32, tdata(7 downto 0));

                    if tuser(0) = '1' then
                        d(7 downto 0)   <= XGMII_ERROR_L0_D;
                        d(63 downto 56) <= T;
                        c               <= XGMII_ERROR_L0_C;
                        c(7)            <= '1';
                        fsm             <= QW_IDLE;
                    elsif tuser(0) = '0' and tlast = '0' then
                        tready <= '1';
                    elsif tuser(0) = '0' and tlast = '1' and tkeep(7) = '1' then
                        fsm <= L0_FIN_8B;
                    elsif tuser(0) = '0' and tlast = '1' and tkeep(7) = '0' and tkeep(4) = '1' then
                        fsm <= L0_FIN_7B_6B_5B;
                    elsif tuser(0) = '0' and tlast = '1' and tkeep(4) = '0' and tkeep(3) = '1' then
                        fsm <= L0_FIN_4B;
                    elsif tuser(0) = '0' and tlast = '1' and tkeep(3) = '0' then
                        fsm <= L0_FIN_3B_2B_1B;
                    end if;

                when QW_IDLE =>
                    d      <= QW_IDLE_D;
                    c      <= QW_IDLE_C;
                    tready <= '1';
                    fsm    <= IDLE_L0;

                when L0_FIN_8B =>
                    d             <= tdata_i;
                    c             <= x"00";
                    calcted_crc4B <= not(crc_rev(crc_32));
                    fsm           <= T_LANE4;

                when T_LANE4 =>
                    d   <= I & I & I & T & calcted_crc4B;
                    c   <= x"F0";
                    fsm <= QW_IDLE;

                when L0_FIN_7B_6B_5B =>
                    if tkeep_i(6) = '1' then
                        aux_var_crc := not(crc_rev(crc_32_7B));
                        d   <= aux_var_crc(7 downto 0) & tdata_i(55 downto 0);
                        fsm <= T_LANE3;
                    elsif tkeep_i(6 downto 5) = "01" then
                        aux_var_crc := not(crc_rev(crc_32_6B));
                        d   <= aux_var_crc(15 downto 0) & tdata_i(47 downto 0);
                        fsm <= T_LANE2;
                    elsif tkeep_i(6 downto 4) = "001" then
                        aux_var_crc := not(crc_rev(crc_32_5B));
                        d   <= aux_var_crc(23 downto 0) & tdata_i(39 downto 0);
                        fsm <= T_LANE1;
                    end if;
                    c       <= x"00";
                    crc_reg <= aux_var_crc;

                when T_LANE3 =>
                    d <= I & I & I & I & T & crc_reg(31 downto 8);
                    c <= x"F8";
                    if (dic = 0) then
                        dic    <= to_unsigned(3, dic'length);
                        tready <= '1';
                        fsm    <= DW_IDLE;
                    else
                        dic <= dic - 1;
                        fsm <= QW_IDLE;
                    end if;

                when DW_IDLE =>
                    d       <= QW_IDLE_D;
                    c       <= QW_IDLE_C;
                    tdata_i <= tdata;
                    tkeep_i <= tkeep;
                    if tvalid = '1' then
                        crc_32 <= crc8B(CRC802_3_PRESET, tdata);
                        d      <= PREAMBLE_LANE4_D;
                        c      <= PREAMBLE_LANE4_C;
                        fsm    <= ST_LANE4;
                    else
                        fsm <= IDLE_L0;
                    end if;

                when T_LANE2 =>
                    d <= I & I & I & I & I & T & crc_reg(31 downto 16);
                    c <= x"FC";
                    if (dic < 2) then
                        dic    <= dic + 2;
                        tready <= '1';
                        fsm    <= DW_IDLE;
                    else
                        dic <= dic - 2;
                        fsm <= QW_IDLE;
                    end if;

                when T_LANE1 =>
                    d <= I & I & I & I & I & I & T & crc_reg(31 downto 24);
                    c <= x"FE";
                    if (dic < 3) then
                        dic    <= dic + 1;
                        tready <= '1';
                        fsm    <= DW_IDLE;
                    else
                        dic <= to_unsigned(0, dic'length);
                        fsm <= QW_IDLE;
                    end if;

                when L0_FIN_4B =>
                    d   <= not(crc_rev(crc_32_4B)) & tdata_i(31 downto 0);
                    c   <= x"00";
                    fsm <= T_LANE0;

                when T_LANE0 =>
                    d      <= I & I & I & I & I & I & I & T;
                    c      <= x"FF";
                    tready <= '1';
                    fsm    <= DW_IDLE;

                when L0_FIN_3B_2B_1B =>
                    if tkeep_i(2) = '1' then
                        d   <= T & not(crc_rev(crc_32_3B)) & tdata_i(23 downto 0);
                        c   <= x"80";
                        fsm <= T_LANE7;
                    elsif tkeep_i(2 downto 1) = "01" then
                        d   <= I & T & not(crc_rev(crc_32_2B)) & tdata_i(15 downto 0);
                        c   <= x"C0";
                        fsm <= T_LANE6;
                    elsif tkeep_i(2 downto 0) = "001" then
                        d   <= I & I & T & not(crc_rev(crc_32_1B)) & tdata_i(7 downto 0);
                        c   <= x"E0";
                        fsm <= T_LANE5;
                    end if;

                when T_LANE7 =>
                    d      <= QW_IDLE_D;
                    c      <= QW_IDLE_C;
                    tready <= '1';
                    if (dic = 0) then
                        dic <= to_unsigned(3, dic'length);
                        fsm <= IDLE_L0;
                    else
                        dic <= dic - 1;
                        fsm <= DW_IDLE;
                    end if;

                when T_LANE6 =>
                    d      <= QW_IDLE_D;
                    c      <= QW_IDLE_C;
                    tready <= '1';
                    if (dic < 2) then
                        dic <= dic + 2;
                        fsm <= IDLE_L0;
                    else
                        dic <= dic - 2;
                        fsm <= DW_IDLE;
                    end if;

                when T_LANE5 =>
                    d      <= QW_IDLE_D;
                    c      <= QW_IDLE_C;
                    tready <= '1';
                    if (dic < 3) then
                        dic <= dic + 1;
                        fsm <= IDLE_L0;
                    else
                        dic <= to_unsigned(0, dic'length);
                        fsm <= DW_IDLE;
                    end if;

                when ST_LANE4 =>
                    tdata_i     <= tdata;
                    tkeep_i     <= tkeep;
                    aux_dw      <= tdata_i(63 downto 32);
                    d           <= tdata_i(31 downto 0) & PREAMBLE_LANE4_END_D;
                    c           <= PREAMBLE_LANE4_END_C;
                    crc_32      <= crc8B(crc_32, tdata);
                    lane4_start <= '1';
                    if tuser(0) = '1' then
                        d(7 downto 0)   <= XGMII_ERROR_L0_D;
                        d(63 downto 56) <= T;
                        c               <= XGMII_ERROR_L0_C;
                        c(7)            <= '1';
                        tready          <= '0';
                        fsm             <= QW_IDLE;
                    else
                        fsm <= ST_LANE4_D;
                    end if;

                when ST_LANE4_D =>
                    tready    <= '0';
                    tdata_i   <= tdata;
                    tkeep_i   <= tkeep;
                    aux_dw    <= tdata_i(63 downto 32);
                    d         <= tdata_i(31 downto 0) & aux_dw;
                    c         <= x"00";
                    crc_32    <= crc8B(crc_32, tdata);
                    crc_32_7B <= crc7B(crc_32, tdata(55 downto 0));
                    crc_32_6B <= crc6B(crc_32, tdata(47 downto 0));
                    crc_32_5B <= crc5B(crc_32, tdata(39 downto 0));
                    crc_32_4B <= crc4B(crc_32, tdata(31 downto 0));
                    crc_32_3B <= crc3B(crc_32, tdata(23 downto 0));
                    crc_32_2B <= crc2B(crc_32, tdata(15 downto 0));
                    crc_32_1B <= crc1B(crc_32, tdata(7 downto 0));

                    if tuser(0) = '1' then
                        d(39 downto 32) <= XGMII_ERROR_L4_D;
                        c               <= XGMII_ERROR_L4_C;
                        fsm             <= QW_IDLE;
                    elsif tuser(0) = '0' and tlast = '0' then
                        tready <= '1';
                    elsif tuser(0) = '0' and tlast = '1' and tkeep(7) = '1' then
                        fsm <= L4_FIN_8B;
                    elsif tuser(0) = '0' and tlast = '1' and tkeep(7) = '0' and tkeep(4) = '1' then
                        fsm <= L4_FIN_7B_6B_5B;
                    elsif tuser(0) = '0' and tlast = '1' and tkeep(4) = '0' and tkeep(3) = '1' then
                        fsm <= L4_FIN_4B;
                    elsif tuser(0) = '0' and tlast = '1' and tkeep(3) = '0' then
                        fsm <= L4_FIN_3B_2B_1B;
                    end if;

                when L4_FIN_8B =>
                    d                    <= tdata_i(31 downto 0) & aux_dw;
                    c                    <= x"00";
                    tdata_i(31 downto 0) <= tdata_i(63 downto 32);
                    crc_32_4B            <= crc_32;
                    fsm                  <= L0_FIN_4B;

                when L4_FIN_7B_6B_5B =>
                    c                    <= x"00";
                    crc_32_1B            <= crc_32_5B;
                    crc_32_2B            <= crc_32_6B;
                    crc_32_3B            <= crc_32_7B;
                    tdata_i(31 downto 0) <= tdata_i(63 downto 32);
                    tkeep_i(2 downto 0)  <= tkeep_i(6 downto 4);
                    d                    <= tdata_i(31 downto 0) & aux_dw;
                    fsm                  <= L0_FIN_3B_2B_1B;

                when L4_FIN_4B =>
                    d             <= tdata_i(31 downto 0) & aux_dw;
                    c             <= x"00";
                    calcted_crc4B <= not(crc_rev(crc_32_4B));
                    fsm           <= T_LANE4;

                when L4_FIN_3B_2B_1B =>
                    if tkeep_i(2) = '1' then
                        aux_var_crc := not(crc_rev(crc_32_3B));
                        d   <= aux_var_crc(7 downto 0) & tdata_i(23 downto 0) & aux_dw;
                        fsm <= T_LANE3;
                    elsif tkeep_i(2 downto 1) = "01" then
                        aux_var_crc := not(crc_rev(crc_32_2B));
                        d   <= aux_var_crc(15 downto 0) & tdata_i(15 downto 0) & aux_dw;
                        fsm <= T_LANE2;
                    elsif tkeep_i(2 downto 0) = "001" then
                        aux_var_crc := not(crc_rev(crc_32_1B));
                        d   <= aux_var_crc(23 downto 0) & tdata_i(7 downto 0) & aux_dw;
                        fsm <= T_LANE1;
                    end if;
                    c       <= x"00";
                    crc_reg <= aux_var_crc;

                when others =>
                    fsm <= SRES;
            end case;
        end if;
    end process;

end architecture;