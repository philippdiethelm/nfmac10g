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

entity tx is port (

    -- Clks and resets
    clk                  : in  std_logic;
    rst                  : in  std_logic;

    -- Conf vectors
    configuration_vector : in  std_logic_vector(79 downto 0);

    -- XGMII
    xgmii_txd            : out  std_logic_vector(63 downto 0);
    xgmii_txc            : out  std_logic_vector(7 downto 0);

    -- AXIS
    axis_aresetn         : in  std_logic;
    axis_tdata           : in  std_logic_vector(63 downto 0);
    axis_tkeep           : in  std_logic_vector(7 downto 0);
    axis_tvalid          : in  std_logic;
    axis_tready          : out std_logic;
    axis_tlast           : in  std_logic;
    axis_tuser           : in  std_logic_vector(0 downto 0)
);
end entity;

architecture rtl of tx is

    ---------------------------------------------------------
    -- Local padding_ctrl
    ---------------------------------------------------------
    -- S
    signal s_axis_tdata  : std_logic_vector(63 downto 0);
    signal s_axis_tkeep  : std_logic_vector(7 downto 0);
    signal s_axis_tvalid : std_logic;
    signal s_axis_tready : std_logic;
    signal s_axis_tlast  : std_logic;
    signal s_axis_tuser  : std_logic_vector(0 downto 0);
    -- M
    signal m_axis_tdata  : std_logic_vector(63 downto 0);
    signal m_axis_tkeep  : std_logic_vector(7 downto 0);
    signal m_axis_tvalid : std_logic;
    signal m_axis_tready : std_logic;
    signal m_axis_tlast  : std_logic;
    signal m_axis_tuser  : std_logic_vector(0 downto 0);
    -- internal
    signal lane4_start   : std_logic;
    signal dic           : unsigned(1 downto 0);
begin
    ---------------------------------------------------------
    -- assigns
    ---------------------------------------------------------
    s_axis_tdata  <= axis_tdata;
    s_axis_tkeep  <= axis_tkeep;
    s_axis_tvalid <= axis_tvalid;
    axis_tready   <= s_axis_tready;
    s_axis_tlast  <= axis_tlast;
    s_axis_tuser  <= axis_tuser;

    ---------------------------------------------------------
    -- padding_ctrl
    ---------------------------------------------------------
    padding_ctrl_mod_i : entity work.padding_ctrl
        port map(
            clk           => clk,           -- I
            rst           => rst,           -- I
            -- AXIS In
            aresetn       => axis_aresetn,  -- I
            s_axis_tdata  => s_axis_tdata,  -- I [63:0]
            s_axis_tkeep  => s_axis_tkeep,  -- I [7:0]
            s_axis_tvalid => s_axis_tvalid, -- I
            s_axis_tready => s_axis_tready, -- O
            s_axis_tlast  => s_axis_tlast,  -- I
            s_axis_tuser  => s_axis_tuser,  -- I [0:0]
            -- AXIS Out
            m_axis_tdata  => m_axis_tdata,  -- O [63:0]
            m_axis_tkeep  => m_axis_tkeep,  -- O [7:0]
            m_axis_tvalid => m_axis_tvalid, -- O
            m_axis_tready => m_axis_tready, -- I
            m_axis_tlast  => m_axis_tlast,  -- O
            m_axis_tuser  => m_axis_tuser,  -- O [0:0]
            -- internal
            lane4_start   => lane4_start,   -- I
            dic           => dic            -- I [1:0]
        );

    ---------------------------------------------------------
    -- axis2xgmii
    ---------------------------------------------------------
    axis2xgmii_mod_i : entity work.axis2xgmii
        port map(
            clk                  => clk,                  -- I
            rst                  => rst,                  -- I
            -- Conf vectors
            configuration_vector => configuration_vector, -- I [79:0]
            -- internal
            lane4_start          => lane4_start,          -- O
            dic_o                => dic,                  -- O [1:0]
            -- XGMII
            xgmii_d              => xgmii_txd,            -- O [63:0]
            xgmii_c              => xgmii_txc,            -- O [7:0]
            -- AXIS
            tdata                => m_axis_tdata,         -- I [63:0]
            tkeep                => m_axis_tkeep,         -- I [7:0]
            tvalid               => m_axis_tvalid,        -- I
            tready               => m_axis_tready,        -- O
            tlast                => m_axis_tlast,         -- I
            tuser                => m_axis_tuser          -- I [0:0]
        );

end architecture;