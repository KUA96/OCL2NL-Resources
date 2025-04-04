# OCL2NL-Resources

## Overview

This project provides tools for converting Object Constraint Language (OCL) expressions into natural language descriptions. The source code is located in the `com.rm2pt.generator.rm2doc/src/com/rm2pt/generator/rm2doc/ocl2nl` directory, containing utilities for parsing OCL expressions and generating human-readable descriptions.

Additionally, the project includes a dataset (`1_result.xlsx`) used for training and evaluating the conversion process, and a Python script (`getclarity.py`) for calculating the clarity and accuracy of generated natural language descriptions.

## Table of Contents

- [Usage](#usage)
- [Dataset](#dataset)
- [Clarity Calculation](#clarity-calculation)

## Usage

### Calculating Clarity

To calculate the clarity and accuracy of the generated natural language descriptions, use the provided Python script:

```bash
python getclarity.py
```

## Dataset

The dataset used for this project is stored in the `1_result.xlsx` file. This Excel file contains a single sheet that includes the original OCL expressions and their natural language descriptions generated by different models.

#### Sheet Details

The specific structure of this sheet is as follows:

- **First Column (Original OCL)**: Contains the original OCL expressions.
- **Second Column (OCL2NL Translation)**: Contains the natural language descriptions generated using the OCL2NL tool.
- **Third Column (Qwen Translation)**: Contains the natural language descriptions generated using the Qwen model.
- **Fourth Column (GPT Translation)**: Contains the natural language descriptions generated using the GPT model.

## Clarity Calculation

The `getclarity.py` script calculates the clarity and accuracy of the generated natural language descriptions. It extracts key elements from OCL expressions and evaluates the quality of the generated text based on these elements.

