###############################################################################
## Copyright (C) 2014-2023, 2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source $ad_hdl_dir/projects/common/zcu102/zcu102_system_bd.tcl
source ../common/adrv9001_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

if { [expr $ad_project_params(CMOS_LVDS_N) == 0] } {
  ad_ip_parameter axi_adrv9001 CONFIG.USE_RX_CLK_FOR_TX1 1
  ad_ip_parameter axi_adrv9001 CONFIG.USE_RX_CLK_FOR_TX2 2
}

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "$mem_init_sys_file_path/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

if {$ad_project_params(CMOS_LVDS_N) == 0} {
  set sys_cstring "LVDS"
} else {
  set sys_cstring "CMOS"
}

#FFH Signals
create_bd_port -dir O -from 9 -to 0 ffh_tdd_out
create_bd_port -dir I tx1_mute
create_bd_port -dir I tx2_mute
ad_ip_instance axi_tdd ffh_axi_tdd
ad_ip_parameter ffh_axi_tdd CONFIG.CHANNEL_COUNT 10
ad_cpu_interconnect 0x40000000  ffh_axi_tdd
ad_connect ffh_tdd_out ffh_axi_tdd/tdd_channel
ad_connect sys_ps8/pl_resetn0 ffh_axi_tdd/resetn
ad_connect axi_adrv9001/dac_1_clk ffh_axi_tdd/clk
ad_connect GND ffh_axi_tdd/sync_in
ad_connect tx1_mute axi_adrv9001/tx1_mute
ad_connect tx2_mute axi_adrv9001/tx2_mute


sysid_gen_sys_init_file $sys_cstring

set_property strategy Flow_RunPostRoutePhysOpt [get_runs impl_1]
