# Data Aligner: UVM Verification
The **Data Aligner** module takes in an unaligned stream of data and outputs it as an aligned stream of data based on its configuration.

The Data Aligner has **three interfaces**:

1. A register access interface 
2. An RX interface through which the Data Aligner receives the unaligned data.
3. A TX interface through which the Data Aligner sends the aligned data.

The first interface is a standard **AMBA3 APB** interface. The other two interfaces use a custom protocol.

In total, the Data Aligner has 23 pins (inputs and outputs).

The **block diagram** of the Data Aligner is shown below.

*Figure*

The Data Aligner has several **control and status registers** accessible though the APB interface:

1. Control Register (CTRL).
2. Status Register (STATUS).
3. Interrupt Requests Enable Register (IRQEN).
4. Interrupt Requests Register (IRQ).

These **registers and their fields** are shown below.

*Figure*

For more details about the Data Aligner module (its interfaces, registers, functionality, and more), see its specification: *Aligener Datasheet - v1.1*.

**Note:** This project is the course project of this Udemy course: [`Design Verification with SystemVerilog/UVM`](https://www.udemy.com/course/design-verification-with-systemverilog-uvm/).

* * *

In this project, the Data Aligner is modeled and verified using the **SystemVerilog HDVL** and the **Universal Verification Methodology (UVM)**. 

**This repository contains:**

1. The testbench used to verify this module.

    * It is written in SystemVerilog. (**Constrained randomization**, **functional coverage**, and **assertions** are used). 
    * It follows the Universal Verification Methodology (UVM). (**Multiple agents** and **a Register Abstraction Layer (RAL)** are used).
    * It is file-based and well-constructed

2. "Data Aligner - Architecture of the verification environment" (A PDF document).

    * It contais a figure showing the structure of the UVM testbench (components and ports).
    * It contains UML class diagrams for the classes in the testbench.
    * It documents the model.

3. "Data Aligner - Verification plan" (A PDF document).
    * It contains three plans: (1) test plan, (2) coverage plan, and (3) assertion plan.

4. "Data Aligner - Results" (A PDF document).
    * It contains: (1) testing results, (2) coverage results, and (3) assertion results. 


The following figure shows **the structure of the UVM testbench**.

*Figure*

The following figure shows **the class inheritance tree of the tests used in this testbench**.

*Figure*
