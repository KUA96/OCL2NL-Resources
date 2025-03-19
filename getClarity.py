import pandas as pd
import re
from collections import defaultdict

# ====================== Configuration Parameters ======================
LAMBDA = 0.2  # Frequency penalty coefficient


# ====================== Key Elements Extraction Function ======================
def extract_ocl_elements(ocl_expr):
    """
    Extract key elements such as class names, attribute names, and object names from OCL expressions.
    Example implementation (adjust regular expressions based on actual OCL format):
    """
    # elements = []
    # # Match pattern for class::attribute (e.g., Order::totalPrice)
    # class_attr_matches = re.findall(r'(\w+)::(\w+)', ocl_expr)
    # for match in class_attr_matches:
    #     elements.extend([match[0], match[1]])
    #
    # # Match standalone object names (e.g., self.product)
    # obj_matches = re.findall(r'\b(self\.\w+|\w+\.\w+)\b', ocl_expr)
    # elements.extend(obj_matches)

    ocl_keywords = {
        # Logical operators
        'and', 'or', 'xor', 'not', 'implies',

        # Conditional expressions
        'if', 'then', 'else', 'endif',

        # Iteration and collection operations
        'collect', 'select', 'reject', 'exists', 'forAll',
        'any', 'one', 'allInstances', 'isUnique', 'iterate',
        'sortedBy', 'closure', 'flatten', 'product', 'sum',
        'min', 'max', 'size', 'count', 'includes', 'excludes',
        'including', 'excluding', 'append', 'prepend', 'insertAt',
        'removeAt', 'asSet', 'asSequence', 'asBag', 'asOrderedSet',
        'union', 'intersection', 'minus', 'distinct', 'orderBy',

        # Type operations
        'oclIsTypeOf', 'oclIsKindOf', 'oclAsType', 'oclIsNew',
        'oclIsInvalid', 'oclIsUndefined', 'oclType', 'oclIsInState',

        # Context and variables
        'self', 'let', 'in', 'def', 'context', 'package', 'endpackage',
        'result', 'pre', 'post', 'static',

        # Constraint type declarations
        'inv', 'init', 'derive',

        # Other reserved operations
        'isEmpty', 'notEmpty', 'isUndefined', 'implies', 'div', 'mod',
        'abs', 'floor', 'round', 'toUpper', 'toLower', 'substring', 'at'
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


# ====================== Accuracy Calculation Function ======================
def calculate_accuracy(original_ocl, translated_text, lambda_val):
    """
    Calculate accuracy metrics
    """
    # Extract key elements
    original_freq = extract_ocl_elements(original_ocl)
    translated_freq = extract_ocl_elements(translated_text)

    # Calculate base accuracy
    correct_matches = 0
    for elem in original_freq:
        if elem in translated_freq:
            correct_matches += 1
    base_accuracy = correct_matches / len(original_freq) if original_freq else 0

    # Calculate frequency penalty
    total_diff = 0
    total_original = sum(original_freq.values())
    for elem, o_count in original_freq.items():
        t_count = translated_freq.get(elem, 0)
        total_diff += abs(t_count - o_count)
    freq_penalty = total_diff / total_original if total_original else 0

    # Combined accuracy
    final_accuracy = base_accuracy - lambda_val * freq_penalty
    return max(final_accuracy, 0)  # Ensure it does not go below 0


# ====================== Main Process ======================
# Read input table
# df = pd.read_csv("result.csv")
df = pd.read_csv("result.csv").fillna("")  # Replace NaN values with empty strings

# Calculate accuracy for each row
results = []
for idx, row in df.iterrows():
    ocl_expr = row["OCL"]

    # Calculate OCL2NL accuracy
    ocl2nl_acc = calculate_accuracy(ocl_expr, row["OCL2NL"], LAMBDA)

    # Calculate GPT-3 accuracy
    gpt3_acc = calculate_accuracy(ocl_expr, row["GPT"], LAMBDA)

    # Calculate Qwen accuracy
    qwen_acc = calculate_accuracy(ocl_expr, row["Qwen"], LAMBDA)

    results.append({
        "Row": idx + 1,
        "OCL2NL_Accuracy": round(ocl2nl_acc, 4),
        "GPT3_Accuracy": round(gpt3_acc, 4),
        "Qwen_Accuracy": round(qwen_acc, 4)
    })

# Convert to DataFrame and display
result_df = pd.DataFrame(results)
print("Accuracy comparison per row:")
print(result_df)

# Calculate average accuracy
avg_ocl2nl = result_df["OCL2NL_Accuracy"].mean()
avg_gpt3 = result_df["GPT3_Accuracy"].mean()
avg_qwen = result_df["Qwen_Accuracy"].mean()
print(f"\nAverage accuracy comparison:")
print(f"OCL2NL: {avg_ocl2nl:.4f}")
print(f"GPT-3: {avg_gpt3:.4f}")
print(f"Qwen:  {avg_qwen:.4f}")
