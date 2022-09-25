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

entity nfmac10g is
    generic (
        C_TX_SUBSYS_EN : integer := 1;
        C_RX_SUBSYS_EN : integer := 1
    );
    port (

        -- Clks and resets
        tx_clk0                 : in  std_logic;
        rx_clk0                 : in  std_logic;
        reset                   : in  std_logic;
        tx_dcm_locked           : in  std_logic;
        rx_dcm_locked           : in  std_logic;

        -- Flow control
        tx_ifg_delay            : in  std_logic_vector(7 downto 0);
        pause_val               : in  std_logic_vector(15 downto 0);
        pause_req               : in  std_logic;

        -- Conf and status vectors
        tx_configuration_vector : in  std_logic_vector(79 downto 0);
        rx_configuration_vector : in  std_logic_vector(79 downto 0);
        status_vector           : out std_logic_vector(1 downto 0);

        -- Statistic Vector Signals
        tx_statistics_vector    : out std_logic_vector(25 downto 0);
        tx_statistics_valid     : out std_logic;
        rx_statistics_vector    : out std_logic_vector(29 downto 0);
        rx_statistics_valid     : out std_logic;

        -- XGMII
        xgmii_txd               : out std_logic_vector(63 downto 0);
        xgmii_txc               : out std_logic_vector(7 downto 0);
        xgmii_rxd               : in  std_logic_vector(63 downto 0);
        xgmii_rxc               : in  std_logic_vector(7 downto 0);

        -- Tx AXIS
        tx_axis_aresetn         : in  std_logic;
        tx_axis_tdata           : in  std_logic_vector(63 downto 0);
        tx_axis_tkeep           : in  std_logic_vector(7 downto 0);
        tx_axis_tvalid          : in  std_logic;
        tx_axis_tready          : out std_logic;
        tx_axis_tlast           : in  std_logic;
        tx_axis_tuser           : in  std_logic_vector(0 downto 0);

        -- Rx AXIS
        rx_axis_aresetn         : in  std_logic;
        rx_axis_tdata           : out std_logic_vector(63 downto 0);
        rx_axis_tkeep           : out std_logic_vector(7 downto 0);
        rx_axis_tvalid          : out std_logic;
        rx_axis_tlast           : out std_logic;
        rx_axis_tuser           : out std_logic_vector(0 downto 0)
    );
end entity;

architecture rtl of nfmac10g is
    ---------------------------------------------------------
    -- Local clk
    ---------------------------------------------------------
    signal tx_clk         : std_logic;
    signal rx_clk         : std_logic;
    signal tx_rst         : std_logic;
    signal rx_rst         : std_logic;

    ---------------------------------------------------------
    -- Local Rx
    ---------------------------------------------------------
    signal rx_good_frames : std_logic_vector(31 downto 0);
    signal rx_bad_frames  : std_logic_vector(31 downto 0);

begin

    ---------------------------------------------------------
    -- tx_rst_mod
    ---------------------------------------------------------
    tx_rst_mod_i : entity work.rst_mod
        port map(
            clk        => tx_clk,        -- I
            reset      => reset,         -- I
            dcm_locked => tx_dcm_locked, -- I
            rst        => tx_rst         -- O
        );

    ---------------------------------------------------------
    -- rx_rst_mod
    ---------------------------------------------------------
    rx_rst_mod_i : entity work.rst_mod
        port map(
            clk        => rx_clk,        -- I
            reset      => reset,         -- I
            dcm_locked => rx_dcm_locked, -- I
            rst        => rx_rst         -- O
        );

    ---------------------------------------------------------
    -- assigns
    ---------------------------------------------------------
    tx_clk               <= tx_clk0;
    rx_clk               <= rx_clk0;
    status_vector        <= (others => '0');
    tx_statistics_vector <= (others => '0');
    tx_statistics_valid  <= '0';
    rx_statistics_vector <= (others => '0');
    rx_statistics_valid  <= '0';

    ---------------------------------------------------------
    -- Tx
    ---------------------------------------------------------
    gtx_on : if C_TX_SUBSYS_EN = 1 generate
        tx_mod_i : entity work.tx
            port map(
                clk                  => tx_clk,                  -- I
                rst                  => tx_rst,                  -- I
                -- Conf vectors
                configuration_vector => tx_configuration_vector, -- I [79:0]
                -- XGMII
                xgmii_txd            => xgmii_txd,               -- I [63:0]
                xgmii_txc            => xgmii_txc,               -- I [7:0]
                -- AXIS
                axis_aresetn         => tx_axis_aresetn,         -- I
                axis_tdata           => tx_axis_tdata,           -- I [63:0]
                axis_tkeep           => tx_axis_tkeep,           -- I [7:0]
                axis_tvalid          => tx_axis_tvalid,          -- I
                axis_tready          => tx_axis_tready,          -- O
                axis_tlast           => tx_axis_tlast,           -- I
                axis_tuser           => tx_axis_tuser            -- I [0:0]
            );
    end generate;

    gtx_off : if C_TX_SUBSYS_EN /= 1 generate
        xgmii_txd      <= x"0707070707070707";
        xgmii_txc      <= x"FF";
        tx_axis_tready <= '0';
    end generate;

    ---------------------------------------------------------
    -- Rx
    ---------------------------------------------------------
    grx_on : if C_RX_SUBSYS_EN = 1 generate
        rx_mod_i : entity work.rx
            port map(
                clk                  => rx_clk,                  -- I
                rst                  => rx_rst,                  -- I
                -- Stats
                good_frames          => rx_good_frames,          -- O [31:0]
                bad_frames           => rx_bad_frames,           -- O [31:0]
                -- Conf vectors
                configuration_vector => rx_configuration_vector, -- I [79:0]
                -- XGMII
                xgmii_rxd            => xgmii_rxd,               -- I [63:0]
                xgmii_rxc            => xgmii_rxc,               -- I [7:0]
                -- AXIS
                axis_aresetn         => rx_axis_aresetn,         -- I
                axis_tdata           => rx_axis_tdata,           -- O [63:0]
                axis_tkeep           => rx_axis_tkeep,           -- O [7:0]
                axis_tvalid          => rx_axis_tvalid,          -- O
                axis_tlast           => rx_axis_tlast,           -- O
                axis_tuser           => rx_axis_tuser            -- O [0:0]
            );
    end generate;

    grx_off : if C_RX_SUBSYS_EN /= 1 generate
        rx_good_frames <= (others => '0');
        rx_bad_frames  <= (others => '0');
        rx_axis_tdata  <= (others => '0');
        rx_axis_tkeep  <= (others => '0');
        rx_axis_tvalid <= '0';
        rx_axis_tlast  <= '0';
        rx_axis_tuser  <= "0";
    end generate;

end architecture;