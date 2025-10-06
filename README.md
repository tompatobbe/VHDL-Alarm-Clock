# 🕒 VHDL Alarm Clock

A digital alarm clock implemented in **VHDL**, designed for synthesis on the **Altera DE1-SoC** FPGA development board.  
This repository contains all essential **VHDL source files**, but not a complete Quartus project setup.  
Users can easily recreate the project by adding these files to a new Quartus project.

---

## ⚙️ Overview

This repository contains VHDL code for an alarm clock that:
- Keeps real time (hours and minutes)
- Allows setting an alarm
- Triggers an alarm signal when the current time matches the alarm time
- Displays information on a seven-segment or LCD display

The design uses modular VHDL components for timekeeping, mode selection, display control, and alarm logic.

---

## 📁 Files Included

| File | Description |
|------|--------------|
| **Alarm_control.vhd** | Main alarm control unit — compares current time with the alarm time and triggers the alarm output. |
| **LCD_coverter.vhd** | Converts numerical time data into LCD/7-segment compatible output signals. |
| **Mode_selector.vhd** | Allows switching between time display and alarm setting modes. |
| **clock_1hz.vhd** | Clock divider generating a 1 Hz signal from the board’s main clock. |
| **clock_counter.vhd** | Implements the hour and minute counters. |
| **clock_merge.vhd** | Merges display and control signals for output. |
| **two_digit_display.vhd** | Drives a two-digit 7-segment or LCD display. |
| **BDF_alarm_clock2.bdf** | Quartus Block Diagram file for visual schematic connections. |

---

## 🧠 Usage

To use this code:
1. Open **Quartus Prime** and create a new project.
2. Add all `.vhd` files from this repository.
3. Set one module (or the BDF file) as the **top-level entity**.
4. Assign FPGA pins according to your **DE1-SoC** board layout.
5. Compile and program the FPGA.

---

## 📄 Documentation

For complete system design details, including diagrams, timing descriptions, and implementation notes,  
see the accompanying **PDF report** in this repository.

---

## 👤 Author

**Tobias Thorgren**  
Educational VHDL project for FPGA design and digital systems practice.
