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
--   http:--www.netfpga-cic.org
--
-- Unless required by applicable law or agreed to in writing, Work distributed
-- under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
-- CONDITIONS OF ANY KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations under the License.
--
-- @NETFPGA_LICENSE_HEADER_END@

library IEEE;
use IEEE.std_logic_1164.all;

entity rx is port (

    -- Clks and resets
    clk                  : in  std_logic;
    rst                  : in  std_logic;

    -- Stats
    good_frames           : out std_logic_vector(31 downto 0);
    bad_frames           : out std_logic_vector(31 downto 0);

    -- Conf vectors
    configuration_vector : in  std_logic_vector(79 downto 0);

    -- XGMII
    xgmii_rxd            : in  std_logic_vector(63 downto 0);
    xgmii_rxc            : in  std_logic_vector(7 downto 0);

    -- AXIS
    axis_aresetn         : in  std_logic;
    axis_tdata           : out std_logic_vector(63 downto 0);
    axis_tkeep           : out std_logic_vector(7 downto 0);
    axis_tvalid          : out std_logic;
    axis_tlast           : out std_logic;
    axis_tuser           : out std_logic_vector(0 downto 0)
);
end entity;

architecture rtl of rx is
    ---------------------------------------------------------
    -- Local xgmii2axis
    ---------------------------------------------------------

    ---------------------------------------------------------
    -- Local 
    ---------------------------------------------------------
begin

    ---------------------------------------------------------
    -- assigns
    ---------------------------------------------------------

    ---------------------------------------------------------
    -- xgmii2axis
    ---------------------------------------------------------
    xgmii2axis_mod_i : entity work.xgmii2axis
        port map(
            clk                  => clk,                  -- I
            rst                  => rst,                  -- I
            -- Stats
            good_frames          => good_frames,          -- O [31:0]
            bad_frames           => bad_frames,           -- O [31:0]
            -- Conf vectors
            configuration_vector => configuration_vector, -- I [79:0]
            -- XGMII
            xgmii_d              => xgmii_rxd,            -- I [63:0]
            xgmii_c              => xgmii_rxc,            -- I [7:0]
            -- AXIS
            aresetn              => axis_aresetn,         -- I
            tdata                => axis_tdata,           -- O [63:0]
            tkeep                => axis_tkeep,           -- O [7:0]
            tvalid               => axis_tvalid,          -- O
            tlast                => axis_tlast,           -- O
            tuser                => axis_tuser            -- O [0:0]
        );

end architecture;