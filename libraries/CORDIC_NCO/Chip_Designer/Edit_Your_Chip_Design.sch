<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <blockdef name="CORDIC_NCO">
            <timestamp>2015-10-10T2:41:40</timestamp>
            <rect width="432" x="64" y="-192" height="192" />
            <rect width="64" x="0" y="-172" height="24" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="560" y1="-160" y2="-160" x1="496" />
            <rect width="64" x="496" y="-108" height="24" />
            <line x2="560" y1="-96" y2="-96" x1="496" />
            <rect width="64" x="496" y="-44" height="24" />
            <line x2="560" y1="-32" y2="-32" x1="496" />
        </blockdef>
        <block symbolname="CORDIC_NCO" name="XLXI_48">
            <blockpin name="wishbone_in(100:0)" />
            <blockpin name="d2a_clk" />
            <blockpin name="wishbone_out(100:0)" />
            <blockpin name="d2a_data(7:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="1760" height="1360">
        <instance x="704" y="688" name="XLXI_48" orien="R0">
        </instance>
    </sheet>
</drawing>