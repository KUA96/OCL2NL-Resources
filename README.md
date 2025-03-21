# OCL2NL-Resources

## Overview

This project provides tools for converting Object Constraint Language (OCL) expressions into natural language descriptions. The source code is located in the `com.rm2pt.generator.rm2doc/src/com/rm2pt/generator/rm2doc/ocl2nl` directory, containing utilities for parsing OCL expressions and generating human-readable descriptions.

Additionally, the project includes a dataset (`1_result.xlsx`) used for training and evaluating the conversion process, and a Python script (`getclarity.py`) for calculating the clarity and accuracy of generated natural language descriptions.

## Table of Contents

- [Usage](#usage)
- [Dataset](#dataset)
- [Clarity and Accuracy Calculation](#clarity-and-accuracy-calculation)
- [Directory Structure](#directory-structure)
- [License](#license)

## Usage

### Calculating Clarity

To calculate the clarity and accuracy of the generated natural language descriptions, use the provided Python script:

```bash
python getclarity.py
```

## Dataset

The dataset used for this project is stored in the `1_result.xlsx` file. This Excel file contains multiple sheets with various information related to OCL expressions and their corresponding natural language descriptions.

### Sheet Details

You can load this dataset using the following Python code:

```python
import pandas as pd

# Load the dataset from Sheet1
df_sheet1 = pd.read_excel('1_result.xlsx', sheet_name='Sheet1')

# Load the dataset from Sheet2
df_sheet2 = pd.read_excel('1_result.xlsx', sheet_name='Sheet2')

# Load the dataset from Sheet3
df_sheet3 = pd.read_excel('1_result.xlsx', sheet_name='Sheet3')
```

## Clarity Calculation

The `getclarity.py` script calculates the clarity and accuracy of the generated natural language descriptions. It extracts key elements from OCL expressions and evaluates the quality of the generated text based on these elements.

### Key Functions

#### Extracting OCL Elements

The `extract_ocl_elements(ocl_expr)` function extracts key elements such as class names, attribute names, and object names from OCL expressions and counts their frequencies.

#### Calculating Accuracy

The `calculate_accuracy(original_ocl, translated_text, lambda_val)` function calculates the accuracy of the generated text. It compares the key elements in the original OCL expression and the generated text to compute the base accuracy and applies a frequency penalty coefficient to adjust the final accuracy.

### Example Usage

Assuming you have an Excel file `1_result.xlsx` containing OCL expressions and their corresponding natural language descriptions, you can use the following command to calculate the accuracy for each model:

```bash
python getclarity.py
```

This will generate a table with accuracies per row and print the average accuracy:

```plaintext
[326 rows x 4 columns]

Average clarity comparison:
OCL2NL: 0.7623
GPT-3: 0.6644
Qwen:  0.6083
```
