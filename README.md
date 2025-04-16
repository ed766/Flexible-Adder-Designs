## ECEN 603 Final Project – High‑Performance Adder Architectures  
Parameterised Verilog | 32‑/64‑/128‑bit Synthesis Reports

### What’s inside?
This repo accompanies **“Design and Performance Analysis of Ripple Carry, Carry Lookahead, Brent‑Kung, and Hybrid Brent‑Kung CLA Using Verilog.”**  
It contains fully‑parameterised RTL and self‑checking test‑benches for five adders, together with the final paper (see `ECEN603_Final_Project_Paper-1.pdf`).

| Folder | Contents |
| ------ | -------- |
| `ripple_carry_adder/` | `rca.sv` &nbsp;– N‑bit RCA<br>`tb_ripple_carry_adder.sv` |
| `cla_adder/` | `cla.sv` (serial) & `pipelined_cla.sv`<br>`tb_pipelined_cla.sv` |
| `brent_kung_adder/` | `brent_kung_adder_full.sv`<br>`tb_brent_kung_adder_full.sv` |
| `hybrid_adder/` | `hybrid_brent_kung_cla.sv`<br>`tb_hybrid_brent_kung_cla.sv` |
| root | Paper PDF + this `README.md` |

Each test‑bench generates random vectors, compares against a software “golden” model, and prints **PASS/FAIL**; no external stimulus files are required.

---

### Why so many adders?  
Different applications prioritise **power, performance, or area (PPA)**. By implementing classic and modern architectures side‑by‑side we can see the trade‑offs clearly:

| 32‑bit implementation | Power (µW) | Delay (ns) | Area (µm²) | Take‑away |
| --------------------- | ---------- | ---------- | ---------- | --------- |
| Ripple Carry Adder | 59.68 | 4.79 | 426 | Simple but slow |
| Carry Lookahead Adder | 65.59 | 3.02 | 514 | Faster, modest cost |
| *Pipelined* CLA | 117.03 | **0.18** | 2 054 | Ultra‑low latency, big area/power hit |
| Brent–Kung Adder | 54.67 | 3.35 | 441 | Balanced depth & resources |
| **Hybrid BKA‑CLA** | **51.05** | 2.90 | **403** | Best overall balance |

*(Full 32/64/128‑bit tables and methodology in the paper.)* citeturn0file0

---

### Quick‑start (simulation)

```bash
# Example with Icarus Verilog
cd cla_adder
iverilog -g2012 cla.sv tb_pipelined_cla.sv -o tb
./tb          # prints PASS if all random trials succeed
```

*Change `WORD_WIDTH` parameter on the compile line to regenerate 64‑ or 128‑bit versions.*

### Quick‑start (synthesis)

All results were obtained with **Synopsys Design Compiler** using a 45 nm typical‑Vt library:

```tcl
dc_shell -f scripts/synth_rca.tcl
```

The DC scripts inside each folder elaborate the design for 32/64/128 bits, constrain max‐fan‑out/transition, then emit area, timing and power reports under `reports/`.

---

### Re‑using this repo
* Clone and drop your own standard‑cell library + SDF settings into `libs/`.
* Swap in a different technology node to see PPA scaling.
* Plug any adder module into your datapath: each design exposes the same parameterised interface  
  `module adder #(parameter N=32) (input  logic [N-1:0] A, B, input logic Cin, output logic [N-1:0] Sum, output logic Cout);`

---

### Paper
`ECEN603_Final_Project_Paper-1.pdf` details background, equations, test methodology, and full result tables/plots. Feel free to cite or fork for your own research.

Happy coding!
