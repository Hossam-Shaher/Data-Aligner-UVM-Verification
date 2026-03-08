# Data Aligner: UVM Verification
The **Data Aligner** module takes in an unaligned stream of data and outputs it as an aligned stream of data based on its configuration.

In this project, the Data Aligner is modeled and verified using the **SystemVerilog HDVL** and the **Universal Verification Methodology (UVM)**. 

**Note:** This project is the course project of this Udemy course: [`Design Verification with SystemVerilog/UVM`](https://www.udemy.com/course/design-verification-with-systemverilog-uvm/).

## Design Under Test (DUT)

The Data Aligner has **three interfaces**:

1. A register access interface. 
2. An RX interface through which the Data Aligner receives the unaligned data.
3. A TX interface through which the Data Aligner sends the aligned data.

The first interface is a standard **AMBA3 APB** interface. The other two interfaces use a custom protocol.

In total, the Data Aligner has 23 pins (inputs and outputs).

The **block diagram** of the Data Aligner is shown below.

<img width="778.5" height="293.25" alt="image" src="https://github.com/user-attachments/assets/a9da31c3-d43e-4755-bd0c-fe4bd22f4412" />

The Data Aligner has several **control and status registers** accessible though the APB interface:

1. Control Register (`CTRL`).
2. Status Register (`STATUS`).
3. Interrupt Requests Enable Register (`IRQEN`).
4. Interrupt Requests Register (`IRQ`).

These **registers and their fields** are shown below.

<img width="732" height="351" alt="image" src="https://github.com/user-attachments/assets/7c0df5c6-8365-4f25-a5a5-30dea7ed728d" />

For more information about the Data Aligner module (its interfaces, registers, functionality, and more), see its specification: *Aligner Datasheet - v1.1*.

## UVM Testbench

**This repository contains:**

1. **The testbench used to verify this module.**

    * It is written in SystemVerilog. (**Constrained randomization**, **functional coverage**, and **assertions** are used). 
    * It follows the Universal Verification Methodology (UVM). (**Multiple agents** and **a Register Abstraction Layer (RAL)** are used).
    * It is file-based and well-constructed

2. **"Data Aligner - Architecture of The Verification Environment" (A PDF document).**
    * It shows the architecture of the verification environment, the transaction-level communication between its UVM components, and UML class diagrams of some classes.

3. **"Data Aligner - Verification Plan" (A PDF document).**
    * It contains three plans: (1) test plan, (2) coverage plan, and (3) assertion plan.

4. **"Data Aligner - Results" (A PDF document).**
    * It contains: (1) testing results, (2) coverage results, and (3) assertion results. 

The following figures show the **structure of the UVM testbench**. 

For more details, see: *Data Aligner - Architecture of The Verification Environment*.

<img width="617" height="506" alt="image" src="https://github.com/user-attachments/assets/ffda2e4a-31a6-4613-b330-80672c4512a5" />

<img width="931" height="527.5" alt="image" src="https://github.com/user-attachments/assets/6d2cf5c7-27ec-4600-8734-439fe9deff28" />

<img width="959.5" height="369.5" alt="image" src="https://github.com/user-attachments/assets/66ca7bf5-8866-4daf-9049-4f65518c5625" />
