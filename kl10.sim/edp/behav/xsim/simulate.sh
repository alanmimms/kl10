#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : simulate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for simulating the design by launching the simulator
#
# Generated by Vivado on Tue Jan 28 12:22:54 PST 2020
# SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: simulate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xsim edptb_behav -key {Behavioral:edp:Functional:edptb} -tclbatch edptb.tcl -view /home/alan/kl10-rtl/edptb_behav.wcfg -log simulate.log"
xsim edptb_behav -key {Behavioral:edp:Functional:edptb} -tclbatch edptb.tcl -view /home/alan/kl10-rtl/edptb_behav.wcfg -log simulate.log
