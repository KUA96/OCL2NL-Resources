import pandas as pd
import re
from collections import defaultdict

# ====================== Configuration Parameters ======================
LAMBDA = 0.2  # Frequency penalty coefficient


# ====================== Key Elements Extraction Function ======================
def extract_ocl_elements(ocl_expr):
    """
    Extract key elements such as class names, attribute names, and object names from OCL expressions.
    """
    ocl_keywords = {
        'context', 'package', 'endpackage', 'inv', 'def', 'pre', 'post', 'body',
    'init', 'derive', 'static', 'if', 'then', 'else', 'endif', 'let', 'in',
    'self', 'result', '@pre', 'null', 'invalid', 'and', 'or', 'xor', 'not',
    'implies', 'Tuple', 'Enum', 'oclIsTypeOf', 'oclIsKindOf', 'oclAsType',
    'oclIsUndefined', 'oclIsInvalid', 'oclType', 'oclIsInState', 'oclIsNew',
    'size', 'isEmpty', 'notEmpty', 'includes', 'excludes', 'includesAll',
    'excludesAll', 'count', 'sum', 'flatten', 'asSet', 'asBag', 'asSequence',
    'asOrderedSet', 'forAll', 'exists', 'one', 'select', 'reject', 'collect',
    'collectNested', 'any', 'isUnique', 'sortedBy', 'iterate', 'union',
    'intersection', 'including', 'excluding', 'symmetricDifference',
    'product', 'isSubsetOf', 'isProperSubsetOf', '-', 'at', 'first', 'last',
    'indexOf', 'append', 'prepend', 'subSequence', 'subOrderedSet',
    'insertAt', 'removeAt', 'abs', 'max', 'min', 'floor', 'round', 'div',
    'mod', 'toUpper', 'toLower', 'substring', 'concat'
    }

    if pd.isna(ocl_expr):
        return []

    pattern = r'\b[a-zA-Z_][a-zA-Z0-9_]*\b'
    matches = re.findall(pattern, ocl_expr)

    elements = [match for match in matches if match.lower() not in ocl_keywords]

    # Count frequencies
    freq = defaultdict(int)
    for elem in elements:
        freq[elem] += 1
    return freq


# ====================== Clarity Calculation Function ======================
def calculate_clarity(original_ocl, translated_text, lambda_val):
    """
    Calculate clarity metrics
    """
    # Extract key elements
    original_freq = extract_ocl_elements(original_ocl)
    translated_freq = extract_ocl_elements(translated_text)

    # Calculate base clarity
    correct_matches = 0
    for elem in original_freq:
        if elem in translated_freq:
            correct_matches += 1
    base_clarity = correct_matches / len(original_freq) if original_freq else 0

    # Calculate frequency penalty
    total_diff = 0
    total_original = sum(original_freq.values())
    for elem, o_count in original_freq.items():
        t_count = translated_freq.get(elem, 0)
        total_diff += abs(t_count - o_count)
    freq_penalty = total_diff / total_original if total_original else 0

    # Combined clarity
    final_clarity = base_clarity - lambda_val * freq_penalty
    return max(min(final_clarity, 1.0), 0.0)  # Ensure it does not go below 0


# ====================== Main Process ======================
# Read input Excel file instead of CSV
df = pd.read_excel("result.xlsx").fillna("")  # Replace NaN values with empty strings

# Calculate clarity for each row
results = []
for idx, row in df.iterrows():
    ocl_expr = row["OCL"]

    # Calculate OCL2NL clarity
    ocl2nl_acc = calculate_clarity(ocl_expr, row["OCL2NL"], LAMBDA)

    # Calculate GPT-3 clarity
    gpt3_acc = calculate_clarity(ocl_expr, row["GPT"], LAMBDA)

    # Calculate Qwen clarity
    qwen_acc = calculate_clarity(ocl_expr, row["Qwen"], LAMBDA)

    results.append({
        "Row": idx + 1,
        "OCL2NL_Clarity": round(ocl2nl_acc, 4),
        "GPT3_Clarity": round(gpt3_acc, 4),
        "Qwen_Clarity": round(qwen_acc, 4)
    })

# Convert to DataFrame and display
result_df = pd.DataFrame(results)
print("Clarity comparison per row:")
print(result_df)

# Calculate average clarity
avg_ocl2nl = result_df["OCL2NL_Clarity"].mean()
avg_gpt3 = result_df["GPT3_Clarity"].mean()
avg_qwen = result_df["Qwen_Clarity"].mean()
print(f"\nAverage clarity comparison:")
print(f"OCL2NL: {avg_ocl2nl:.4f}")
print(f"GPT-3: {avg_gpt3:.4f}")
print(f"Qwen:  {avg_qwen:.4f}")

