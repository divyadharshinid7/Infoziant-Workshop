onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fa_4bit_tb/A
add wave -noupdate /fa_4bit_tb/B
add wave -noupdate /fa_4bit_tb/Cin
add wave -noupdate /fa_4bit_tb/Sum
add wave -noupdate /fa_4bit_tb/Cout
add wave -noupdate /fa_4bit_tb/uut/A
add wave -noupdate /fa_4bit_tb/uut/B
add wave -noupdate /fa_4bit_tb/uut/Cin
add wave -noupdate /fa_4bit_tb/uut/Sum
add wave -noupdate /fa_4bit_tb/uut/Cout
add wave -noupdate /fa_4bit_tb/uut/c
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 98
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
WaveRestoreZoom {0 ps} {314599 ps}
