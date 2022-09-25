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

entity rst_mod is
    port (

        -- Clks and resets
        clk        : in  std_logic;
        reset      : in  std_logic;
        dcm_locked : in  std_logic;

        -- Output
        rst        : out std_logic
    );
end entity;

architecture rtl of rst_mod is

    type t_fsm is (
        s0,
        s1,
        s2,
        s3,
        s4,
        s5,
        s6,
        s7);

    ---------------------------------------------------------
    -- Local gen_rst
    ---------------------------------------------------------
    signal fsm : t_fsm;
begin

    --//////////////////////////////////////////////
    -- gen_rst
    --//////////////////////////////////////////////
    process (clk, reset) begin

        if reset = '1' then
            rst <= '1';
            fsm <= s0;
        elsif rising_edge(clk) then

            case fsm is

                when s0 =>
                    rst            <= '1';
                    fsm            <= s1;

                when s1 => fsm <= s2;
                when s2 => fsm <= s3;
                when s3 => fsm <= s4;

                when s4 =>
                    if dcm_locked = '1' then
                        fsm <= s5;
                    end if;

                when s5 =>
                    rst <= '0';

                when others =>
                    fsm <= s0;
            end case;
        end if;
    end process;

end architecture;