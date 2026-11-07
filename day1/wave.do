onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /alu_tb/a
add wave -noupdate /alu_tb/b
add wave -noupdate /alu_tb/op
add wave -noupdate /alu_tb/result
add wave -noupdate /alu_tb/zero
add wave -noupdate /alu_tb/negative
add wave -noupdate /alu_tb/carry
add wave -noupdate /alu_tb/overflow
add wave -noupdate /alu_tb/pass_cnt
add wave -noupdate /alu_tb/fail_cnt
add wave -noupdate /alu_tb/i
add wave -noupdate /alu_tb/exp_res
add wave -noupdate /alu_tb/exp_zero
add wave -noupdate /alu_tb/exp_neg
add wave -noupdate /alu_tb/exp_carry
add wave -noupdate /alu_tb/exp_ovf
add wave -noupdate /alu_tb/ref_model/ra
add wave -noupdate /alu_tb/ref_model/rb
add wave -noupdate /alu_tb/ref_model/rop
add wave -noupdate /alu_tb/ref_model/wide
add wave -noupdate /alu_tb/check/ta
add wave -noupdate /alu_tb/check/tb_
add wave -noupdate /alu_tb/check/top
add wave -noupdate /alu_tb/dut/a
add wave -noupdate /alu_tb/dut/b
add wave -noupdate /alu_tb/dut/op
add wave -noupdate /alu_tb/dut/result
add wave -noupdate /alu_tb/dut/zero
add wave -noupdate /alu_tb/dut/negative
add wave -noupdate /alu_tb/dut/carry
add wave -noupdate /alu_tb/dut/overflow
add wave -noupdate /alu_tb/dut/sub
add wave -noupdate /alu_tb/dut/b_in
add wave -noupdate /alu_tb/dut/sum
add wave -noupdate /alu_tb/dut/add_ovf
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
WaveRestoreZoom {0 ps} {7398 ps}
