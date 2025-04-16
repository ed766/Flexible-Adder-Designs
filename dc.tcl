# Create output directories if they don’t exist
sh mkdir -p reports compiled

# Define bit-widths for synthesis
set bit_widths {32 64 128}

foreach width $bit_widths {
    set design_name "ripple_carry_adder_${width}"

    # Analyze the Verilog source file (assumes the file is in ./src/)
    analyze -format verilog "./src/ripple_carry_adder.sv"

    # Elaborate the design with the specific parameter
    elaborate ripple_carry_adder -parameter "WIDTH=${width}"

    # Rename the design to include the bit-width for clarity
    rename_design ripple_carry_adder ${design_name}
    current_design ${design_name}

    # Apply synthesis constraints (no clock constraint since it's combinational)
    set_max_area 0
    set_max_fanout 10 [get_ports *]
    set_max_transition 0.1 [get_ports *]

    # Compile with medium effort
    compile -map_effort medium

    # Generate individual synthesis reports
    report_area > "reports/${design_name}_area.rpt"
    report_timing > "reports/${design_name}_timing.rpt"
    report_power > "reports/${design_name}_power.rpt"

    # Save the compiled design
    write -format ddc -hierarchy -output "compiled/${design_name}.ddc"

    # Remove the design from memory to avoid conflicts in next iteration
    remove_design -all
}

# Concatenate all reports into one document
sh cat reports/* > consolidated_report.txt

# Exit Design Compiler
exit
