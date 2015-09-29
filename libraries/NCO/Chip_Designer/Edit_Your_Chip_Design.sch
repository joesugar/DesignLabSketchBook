<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <blockdef name="NCO">
            <timestamp>2015-9-26T20:38:56</timestamp>
            <rect width="432" x="96" y="-240" height="128" />
            <rect width="64" x="528" y="-220" height="24" />
            <line x2="592" y1="-208" y2="-208" x1="528" />
            <line x2="592" y1="-144" y2="-144" x1="528" />
            <rect width="64" x="528" y="-156" height="24" />
            <rect width="64" x="32" y="-220" height="24" />
            <line x2="32" y1="-208" y2="-208" x1="96" />
        </blockdef>
        <block symbolname="NCO" name="XLXI_48">
            <blockpin name="wishbone_out(100:0)" />
            <blockpin name="nco_out(7:0)" />
            <blockpin name="wishbone_in(100:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="1760" height="1360">
        <instance x="592" y="864" name="XLXI_48" orien="R0">
        </instance>
    </sheet>
</drawing>