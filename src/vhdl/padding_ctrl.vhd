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

entity padding_ctrl is
    port (

        -- Clks and resets
        clk           : in  std_logic;
        rst           : in  std_logic;

        -- AXIS In
        aresetn       : in  std_logic;
        s_axis_tdata  : in  std_logic_vector(63 downto 0);
        s_axis_tkeep  : in  std_logic_vector(7 downto 0);
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;
        s_axis_tlast  : in  std_logic;
        s_axis_tuser  : in  std_logic_vector(0 downto 0);

        -- AXIS Out
        m_axis_tdata  : out std_logic_vector(63 downto 0);
        m_axis_tkeep  : out std_logic_vector(7 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tready : in  std_logic;
        m_axis_tlast  : out std_logic;
        m_axis_tuser  : out std_logic_vector(0 downto 0);

        -- internal
        lane4_start   : in  std_logic;
        dic           : in  unsigned(1 downto 0)
    );
end entity;

architecture rtl of padding_ctrl is

    type t_fsm is (
        SRES,
        IDLE,
        ST,
        PAD_CHK,
        W3,
        W2,
        ERR_W_LAST,
        s7);

    ---------------------------------------------------------
    -- Local adapter
    ---------------------------------------------------------
    signal fsm              : t_fsm;
    signal trn              : unsigned(4 downto 0);
    signal m_axis_tdata_d0  : std_logic_vector(63 downto 0);
    signal m_axis_tvalid_d0 : std_logic;
    signal last_tkeep       : std_logic_vector(7 downto 0);
begin
    --//////////////////////////////////////////////
    -- adapter
    --//////////////////////////////////////////////
    process (clk, aresetn) begin

        if aresetn = '0' then
            s_axis_tready <= '0';
            m_axis_tvalid <= '0';
            fsm           <= SRES;

        elsif rising_edge(clk) then

            m_axis_tdata    <= m_axis_tdata_d0;
            m_axis_tvalid   <= m_axis_tvalid_d0;
            m_axis_tlast    <= '0';
            m_axis_tuser(0) <= '0';

            case fsm is
                when SRES =>
                    m_axis_tuser <= "0";
                    if m_axis_tready = '1' then
                        s_axis_tready <= '1';
                        fsm           <= IDLE;
                    end if;

                when IDLE =>
                    m_axis_tdata_d0 <= s_axis_tdata;
                    m_axis_tkeep    <= x"FF";
                    trn             <= to_unsigned(1, trn'length);
                    if s_axis_tvalid = '1' then
                        m_axis_tvalid_d0 <= '1';
                        fsm              <= ST;
                    end if;

                when ST =>
                    m_axis_tdata_d0 <= s_axis_tdata;
                    s_axis_tready   <= '0';
                    if trn(4) = '0' then
                        trn(3 downto 0) <= trn(3 downto 0) + 1;
                    end if;
                    if trn(3) = '1' then
                        trn(4) <= '1';
                    end if;
                    fsm <= PAD_CHK;

                    if s_axis_tvalid = '0' then
                        m_axis_tuser(0)  <= '1';
                        m_axis_tvalid_d0 <= '0';
                        fsm              <= W2;
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '0' and s_axis_tuser(0) = '1' then
                        m_axis_tuser(0)  <= '1';
                        m_axis_tvalid_d0 <= '0';
                        s_axis_tready    <= '1';
                        fsm              <= ERR_W_LAST;
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '1' then
                        m_axis_tuser(0)  <= '1';
                        m_axis_tvalid_d0 <= '0';
                        fsm              <= W2;
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '0' and s_axis_tuser(0) = '0' then
                        s_axis_tready <= '1';
                        fsm           <= ST;
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '0' and s_axis_tkeep(7) = '1' then
                        last_tkeep <= x"FF";
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '0' and s_axis_tkeep(7 downto 6) = "01" then
                        m_axis_tdata_d0 <= x"00" & s_axis_tdata(55 downto 0);
                        last_tkeep      <= x"7F";
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '0' and s_axis_tkeep(6 downto 5) = "01" then
                        m_axis_tdata_d0 <= x"0000" & s_axis_tdata(47 downto 0);
                        last_tkeep      <= x"3F";
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '0' and s_axis_tkeep(5 downto 4) = "01" then
                        m_axis_tdata_d0 <= x"000000" & s_axis_tdata(39 downto 0);
                        last_tkeep      <= x"1F";
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '0' and s_axis_tkeep(4 downto 3) = "01" then
                        m_axis_tdata_d0 <= x"00000000" & s_axis_tdata(31 downto 0);
                        last_tkeep      <= x"0F";
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '0' and s_axis_tkeep(3 downto 2) = "01" then
                        m_axis_tdata_d0 <= x"0000000000" & s_axis_tdata(23 downto 0);
                        last_tkeep      <= x"07";
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '0' and s_axis_tkeep(2 downto 1) = "01" then
                        m_axis_tdata_d0 <= x"000000000000" & s_axis_tdata(15 downto 0);
                        last_tkeep      <= x"03";
                    elsif s_axis_tvalid = '1' and s_axis_tlast = '1' and s_axis_tuser(0) = '0' and s_axis_tkeep(1 downto 0) = "01" then
                        m_axis_tdata_d0 <= x"00000000000000" & s_axis_tdata(7 downto 0);
                        last_tkeep      <= x"01";
                    end if;

                when PAD_CHK               =>
                    m_axis_tdata_d0 <= (others => '0');
                    last_tkeep      <= x"0F";
                    trn             <= trn + 1;
                    if (trn >= 8) then
                        m_axis_tvalid_d0 <= '0';
                        m_axis_tlast     <= '1';
                        m_axis_tkeep     <= last_tkeep;
                        -- L0
                        if lane4_start = '0' and dic = 0 and last_tkeep(7 downto 6) = "01" then -- 7f
                            fsm <= W2;
                        elsif lane4_start = '0' and dic = 0 and last_tkeep(6 downto 5) = "01" then -- 3f
                            fsm <= W2;
                        elsif lane4_start = '0' and dic = 1 and last_tkeep(6 downto 5) = "01" then -- 3f
                            fsm <= W2;
                        elsif lane4_start = '0' and dic = 0 and last_tkeep(5 downto 4) = "01" then -- 1f
                            fsm <= W2;
                        elsif lane4_start = '0' and dic = 1 and last_tkeep(5 downto 4) = "01" then -- 1f
                            fsm <= W2;
                        elsif lane4_start = '0' and dic = 2 and last_tkeep(5 downto 4) = "01" then -- 1f
                            fsm <= W2;
                        elsif lane4_start = '0' and last_tkeep(4) = '0' then -- 0f, 07, 03, 01
                            fsm <= W2;

                            -- L4
                        elsif lane4_start = '1' and dic = 0 and last_tkeep(3 downto 2) = "01" and trn(4) = '1' then -- 07
                            fsm <= W2;
                        elsif lane4_start = '1' and dic = 0 and last_tkeep(2 downto 1) = "01" and trn(4) = '1' then -- 03
                            fsm <= W2;
                        elsif lane4_start = '1' and dic = 1 and last_tkeep(2 downto 1) = "01" and trn(4) = '1' then -- 03
                            fsm <= W2;
                        elsif lane4_start = '1' and dic = 0 and last_tkeep(1 downto 0) = "01" and trn(4) = '1' then -- 01
                            fsm <= W2;
                        elsif lane4_start = '1' and dic = 1 and last_tkeep(1 downto 0) = "01" and trn(4) = '1' then -- 01
                            fsm <= W2;
                        elsif lane4_start = '1' and dic = 2 and last_tkeep(1 downto 0) = "01" and trn(4) = '1' then -- 01
                            fsm <= W2;

                            -- 8-trn
                        elsif lane4_start = '0' and last_tkeep(4) = '0' and trn(4) = '0' then -- 0f, 07, 03, 01
                            m_axis_tkeep <= x"0F";
                            fsm          <= W2;
                        elsif last_tkeep(3) = '0' and trn(4) = '0' then -- 07, 03, 01
                            m_axis_tkeep <= x"0F";
                            fsm          <= W3;
                        else
                            fsm <= W3;
                        end if;
                    end if;

                when W3 => fsm <= W2;

                when W2 =>
                    s_axis_tready <= '1';
                    fsm           <= IDLE;

                when ERR_W_LAST =>
                    if s_axis_tvalid = '0' or s_axis_tlast = '1' then
                        s_axis_tready <= '0';
                        fsm           <= W2;
                    end if;

                when others =>
                    fsm <= SRES;
            end case;
        end if;

    end process;

end architecture;