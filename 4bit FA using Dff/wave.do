onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fa_using_dff_tb/clk
add wave -noupdate /fa_using_dff_tb/rst
add wave -noupdate /fa_using_dff_tb/A
add wave -noupdate /fa_using_dff_tb/B
add wave -noupdate /fa_using_dff_tb/Cin
add wave -noupdate /fa_using_dff_tb/Q
add wave -noupdate /fa_using_dff_tb/dut/clk
add wave -noupdate /fa_using_dff_tb/dut/rst
add wave -noupdate /fa_using_dff_tb/dut/A
add wave -noupdate /fa_using_dff_tb/dut/B
add wave -noupdate /fa_using_dff_tb/dut/Cin
add wave -noupdate /fa_using_dff_tb/dut/Q
add wave -noupdate /fa_using_dff_tb/dut/sum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3433 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {42 ns}
