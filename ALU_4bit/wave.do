onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /alu4_tb/A
add wave -noupdate /alu4_tb/B
add wave -noupdate /alu4_tb/opcode
add wave -noupdate /alu4_tb/result
add wave -noupdate /alu4_tb/carry_borrow
add wave -noupdate /alu4_tb/zero
add wave -noupdate /alu4_tb/uut/A
add wave -noupdate /alu4_tb/uut/B
add wave -noupdate /alu4_tb/uut/opcode
add wave -noupdate /alu4_tb/uut/result
add wave -noupdate /alu4_tb/uut/carry_borrow
add wave -noupdate /alu4_tb/uut/zero
add wave -noupdate /alu4_tb/uut/temp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {168 ns}
