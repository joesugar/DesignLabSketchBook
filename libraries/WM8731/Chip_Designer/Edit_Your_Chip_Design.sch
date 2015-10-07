<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <blockdef name="WM8731">
            <timestamp>2015-10-7T0:21:16</timestamp>
            <rect width="432" x="64" y="-256" height="256" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="560" y1="-224" y2="-224" x1="496" />
            <line x2="560" y1="-160" y2="-160" x1="496" />
            <line x2="560" y1="-96" y2="-96" x1="496" />
            <rect width="64" x="496" y="-44" height="24" />
            <line x2="560" y1="-32" y2="-32" x1="496" />
        </blockdef>
        <block symbolname="WM8731" name="XLXI_48">
            <blockpin name="wm_clk_i" />
            <blockpin name="wm_rst_i" />
            <blockpin name="wm_adcdat_i" />
            <blockpin name="wishbone_in(100:0)" />
            <blockpin name="wm_bclk_o" />
            <blockpin name="wm_lrc_o" />
            <blockpin name="wm_dacdat_o" />
            <blockpin name="wishbone_out(100:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="1760" height="1360">
        <instance x="640" y="512" name="XLXI_48" orien="M180">
        </instance>
    </sheet>
</drawing>