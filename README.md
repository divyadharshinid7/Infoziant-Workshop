# Verilog RTL and RISC-V Practice Activities

**Name:** Divyadharshini D
**Workshop:** Infoziant – Verilog RTL and RISC-V Practice Activities
**GitHub:** [divyadharshinid7](https://github.com/divyadharshinid7)

---

## 1. Objective
To design, simulate and verify digital circuits in Verilog HDL, progressing from basic RTL building blocks and FSM controllers to a single-cycle and a pipelined RISC-V processor. The main designs are checked with self-checking testbenches that report PASS/FAIL automatically.

## 2. Tools Used
| Item | Details |
|---|---|
| Language | Verilog HDL |
| Simulator | ModelSim (Icarus Verilog commands are also given for the 2-stage RISC-V demo) |
| Waveforms | ModelSim Wave window, `.vcd` dumps saved in each day's `waves/` folder |
| Processor ISA | RISC-V RV32I (subset) |

---

## 3. Work Completed

### Day 1: RTL Building Blocks and Self-Checking Verification
| No. | Design | Description | Verification |
|---|---|---|---|
| 1.1 | Parameterized ALU | `WIDTH = 32`; ADD, SUB, AND, OR, XOR, signed SLT, SLL, SRL; zero, negative, carry and overflow flags | 25 directed cases + 500 random vectors against a reference model: **525 passed, 0 failed** |
| 1.2 | Up/Down Counter | 8-bit; synchronous reset, enable, up/down, parallel load | Directed checks: PASS |
| 1.3 | Barrel Shifter | 32-bit logical left, logical right, arithmetic right | All 32 amounts × 3 modes = **96 checks** |
| 1.4 | Register File | 32×32, two read ports, one write port, x0 hardwired to 0, write-to-read bypass | Directed + pseudo-random test against a model: **204 operations** |
| 1.5 | Ripple-Carry Adder/Subtractor | 8-bit, built from `full_adder` instances with a generate loop | **4,000 random vectors** (result, carry, overflow) |
| 1.6 | Priority Encoder and Decoder | 8-to-3 encoder (casez and if-else versions), 3-to-8 decoder with enable | All **256 inputs**; both encoders match |
| 1.7 | Shift Register and LFSR | 8-bit universal shift register (hold, left, right, load); 8-bit LFSR | LFSR visits **255 states** before repeating |
| 1.8 | Edge Detector and Debouncer | Two-flop synchronizer, counter-based debouncer, rising-edge pulse | Bouncing input gives exactly **one pulse** |

### Day 2: FSM Controllers and Memory Design
| No. | Design | Description | Verification |
|---|---|---|---|
| 2.1 | Sequence Detector | Overlapping `1011` detector as a Moore FSM (5 states) and a Mealy FSM (4 states) | Streams `1011`, `1011011` and zeros: both detect **3 matches** |
| 2.2 | Vending Machine | Accumulates 5/10 coins, dispenses at 15, returns change, cancel refunds | Exact payment, 10+10 with 5 change, and cancel |
| 2.3 | Synchronous FIFO | 16×8, 5-bit occupancy count, full/empty flags, simultaneous read/write | Fill, overflow, drain, underflow and wraparound |
| 2.4 | Design Review | Checked for inferred latches, missing defaults, multiple drivers | `locked` output of the ATM moved to a state decode |
| 2.5 | Traffic Light | Red/green/yellow FSM with a pedestrian WALK phase; timings are parameters | Request served; request during WALK ignored |
| 2.6 | ATM Controller | WAIT_CARD → WAIT_PIN → MENU → LOCKED; PIN `1234`, balance 1000, lockout on 3rd wrong PIN | Balance check, withdrawal, insufficient funds, lockout |
| 2.7 | Round-Robin Arbiter | 4 requesters, one-hot grant held until request is dropped | Grants are one-hot and fairly distributed |
| 2.8 | RAM, ROM and Watchdog | 16×8 synchronous RAM, ROM loaded from `rom.hex`, 16-bit watchdog with kick and timeout | RAM write/read, ROM value, timeout pulse, kick prevents timeout |

### Day 3: Single-Cycle RISC-V CPU (`rv32_single`)
The CPU has 256-word instruction and data memories and stops on `ECALL`.

| No. | Task | Description |
|---|---|---|
| 3.1 | Instruction extensions | ANDI, ORI, XORI, SLTI, SLLI, SRLI (SRAI also decoded), LUI, JAL; immediate generator for I, S, B, U and J formats |
| 3.2 | Assembly programs | `program1`: sum 1 to 10 (x2 = 55); `program2`: first 10 Fibonacci numbers stored to memory; `program3`: maximum of an 8-word array (x12 = 99) |
| 3.3 | Self-checking testbench | `cpu_tb` loads each program, runs it until `ECALL` (with a 5000-cycle limit) and prints PASS/FAIL |
| 3.4 | Waveform analysis | `pc`, instruction, `alu_result` and write-back data traced (see Section 5) |
| 3.5 | Branch and jump extensions | BNE, BLT, BGE (signed) and JALR |
| 3.6 | More assembly programs | Bubble sort (8 words), GCD by repeated subtraction (48, 18 → 6), shift-and-add multiplication (13 × 11 = 143). These are in `day4/programs/` and are checked on both CPUs by `pipeline_tb` |
| 3.7 | Instruction coverage | `coverage.s` exercises every supported instruction type (R, I, S, B, U, J) and checks signed branches, JAL and JALR |
| 3.8 | Bug-hunt | Three copies of the CPU, each with one injected bug, run by `bug_hunt_tb` |

**Instructions supported by the CPU:** LUI, ADDI, ANDI, ORI, XORI, SLTI, SLLI, SRLI, SRAI, ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA, LW, SW, BEQ, BNE, BLT, BGE, JAL, JALR, ECALL.

**Bug-hunt results**
| Injected bug | How it was detected |
|---|---|
| Negative immediate zero-extended | `x1 = 0x00000ff8` instead of `0xfffffff8` |
| x0 register writable | `x1 = 6` instead of `1` |
| Branch target adds 4 twice | CPU never reaches `ECALL` (still running at PC `0xA8`) |

### Day 4: Pipelined RISC-V CPU (`rv32_pipeline`)
A 5-stage pipeline (IF, ID, EX, MEM, WB) with four pipeline registers.

| No. | Task | Description |
|---|---|---|
| 4.1 | Data hazards | Forwarding from EX/MEM and MEM/WB into EX, a WB-to-ID bypass, and a one-cycle stall for load-use |
| 4.2 | Control hazards | Branches and jumps are resolved in EX; the two wrong-path instructions behind them are flushed |
| 4.3 | Performance comparison | `pipeline_tb` runs seven programs on both CPUs and compares results, cycles and CPI |
| 4.4 | Git submission | Work organised day-wise in this repository |
| 4.5 | Hazard waveform report | `hazard_tb` runs six pipeline copies: each hazard once with the fix removed and once with it enabled |
| 4.6 | Performance counters | Total cycles, retired instructions, stall cycles and flush events |
| 4.7 | Extended program runs | Sum, Fibonacci, array maximum, bubble sort, GCD, multiply and ISA coverage, all matching the single-cycle CPU |
| 4.8 | Pipeline waveforms | Single-cycle and pipelined CPU compared side by side (see Section 5) |

The hazard fixes are switched off using the mutation module `rv32_pipeline_mutation` (`day4/bugs/`), which has parameters `OMIT_FORWARDING`, `OMIT_LOAD_STALL` and `OMIT_FLUSH`.

### Additional Practice Designs
| Folder | Description | Testing |
|---|---|---|
| `D_flip_flop/` | Positive-edge D flip-flop | Stimulus with `$monitor` output |
| `8bit register/` | 8-bit register with asynchronous reset | Stimulus with `$monitor` output |
| `FA_4bit/` | 4-bit ripple-carry full adder written with gate equations | 5 test cases, including carry-out |
| `4bit FA using Dff/` | 4-bit adder with a registered 5-bit output and asynchronous reset | 3 test cases, including 15 + 1 |
| `ALU_4bit/` | 4-bit ALU: ADD, SUB, AND, OR, XOR with carry/borrow and zero flags | 8 test cases printed in a table |
| `ATM Controller/` | ATM FSM: IDLE, PIN_CHECK, SELECT, AMOUNT, DISPENSE, ERROR; balance 5000 | Successful withdrawal and insufficient balance |
| `fsm_verilog/` | Washing machine Moore FSM: IDLE → FILL → WASH → DRAIN → RINSE → SPIN → DONE | Self-checking: prints `TEST PASSED` |
| `basic_2stage_riscv_verilog/` | 2-stage RISC-V (ADD, SUB, AND, OR, ADDI, LW, SW, BEQ), no forwarding | Self-checking: prints `TEST PASSED` |
| `5STAGE RISCV/` | 5-stage RISC-V (same 8 instructions) with forwarding, WB bypass, load-use stall and branch flush | Self-checking: 14 register/memory checks |

---

## 4. Results

### Single-Cycle vs Pipelined CPU
| Program | Single-cycle (cycles / CPI) | Pipelined (cycles / CPI) |
|---|---|---|
| Sum 1 to 10 | 34 / 1.030 | 56 / 1.697 |
| Array maximum | 58 / 1.018 | 91 / 1.596 |

Both CPUs produce identical results. The pipelined CPU needs more cycles on these short, branch-heavy programs because of pipeline fill/drain time and flushes on taken branches (2 bubble cycles each). Its advantage is a higher possible clock frequency, not a lower CPI. Across six programs the pipelined CPI ranged from 1.311 (Fibonacci) to 1.895 (GCD), and bubble sort recorded 358 cycles, 28 stalls and 39 flush events.

### Hazard Test Results
| Hazard | Without fix | With fix |
|---|---|---|
| Back-to-back dependent instructions (RAW) | `x3 = 5` | `x3 = 12` |
| Load followed by dependent instruction | `x3 = 1` | `x3 = 43` |
| Taken branch | Wrong-path write `x5 = 7` | `x5` stays 0 |

---

## 5. Waveform Analysis
Waveforms were captured in ModelSim and saved as screenshots in each day's folder (`alu wave image.bmp`, `sequence wave image.bmp`, `cpu wave image.bmp`, `hazard wave image.bmp`, `pipe line wave image.bmp`). The `.vcd` files in each `waves/` folder hold the full data.

**Day 1: ALU testbench (`alu_tb`).** The waveform shows the inputs `a`, `b` and `op`, the DUT outputs (`result`, `zero`, `negative`, `carry`, `overflow`) and the reference-model values (`exp_res`, `exp_zero`, `exp_carry`, `exp_ovf`) side by side. The DUT outputs follow the expected values on every vector. At the end of the run `pass_cnt = 525` and `fail_cnt = 0`, and the simulation finishes at 525 ns, one vector per nanosecond.

**Day 2: Sequence detector (`sequence_tb`).** The Moore detector (`m`, 3-bit state) and the Mealy detector (`y`, 2-bit state) receive the same three input streams: `1011`, `1011011` and six zeros. Both detection counters finish at 3 and `errors = 0`. The Mealy output rises in the same cycle as the final `1`, while the Moore output rises one clock later because it depends only on the state.

**Day 3: Single-cycle CPU (`cpu_tb`).** The waveform shows four programs run one after another (sum, Fibonacci, array maximum and the instruction-coverage program), each started by a reset pulse and finished when `halted` goes high at the `ECALL`. It also shows `pc`, `instruction`, `alu_result`, `writeback_data`, the decoded fields and immediates, and control signals such as `reg_write`, `mem_write`, `branch` and `take_branch`. The run ends with `errors = 0`.

**Day 4: Hazard test (`hazard_tb`).** Six pipeline copies run together: three with one hazard fix removed (forwarding, load-use stall or branch flush) and three with the full design. All six `halted` flags go high within about 10 cycles. The testbench confirms that each copy with a fix removed gives a wrong result and each full design gives the correct one, ending with `errors = 0`.

**Day 4: Single-cycle vs pipelined CPU (`pipeline_tb`).** The single-cycle and pipelined CPUs run the same programs at the same time. The waveform shows the single-cycle `pc`, instruction and write-back values, the pipelined `pc`, and the pipeline counters `total_cycles`, `instructions_retired`, `stall_cycles` and `flush_cycles`. The single-cycle counters read 58 cycles and 57 instructions for the array-maximum program, and 248 cycles and 247 instructions for a later, longer program. The run ends with `errors = 0`, so both CPUs produced identical results.

---

## 6. Key Learnings
- A self-checking testbench with a reference model makes verification repeatable and does not depend on reading waveforms.
- Moore outputs depend only on the state, so they appear one clock after Mealy outputs.
- Every combinational block needs default values to avoid inferred latches, and each signal should have only one driver.
- Arithmetic right shift needs a signed operand, otherwise it behaves like a logical shift.
- A pipeline needs forwarding, a load-use stall and a branch flush to give the same results as the single-cycle CPU.
- Removing a fix on purpose (mutation testing) and injecting bugs shows whether a testbench really catches errors.

## 7. Reports
Detailed daily reports (approach, verification, results and issues) are in the [`REPORT/`](REPORT/) folder.

## 8. Conclusion
This workshop gave hands-on experience in RTL design, FSM and memory design, and processor architecture. The work progressed from adders and counters to a pipelined RISC-V CPU with hazard handling, and the main designs were verified with self-checking testbenches and waveform analysis.
