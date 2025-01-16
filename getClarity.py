import sys
import pandas as pd
import spacy
import re


try:
    nlp = spacy.load("en_core_web_sm")
except IOError:
    print("Model 'en_core_web_sm' not found. Please ensure it is installed.")
    sys.exit(1)


def extract_identifiers(ocl_expression):
    ocl_keywords = {
        'self', 'if', 'then', 'else', 'endif', 'let', 'in', 'implies', 'and', 'or',
        'xor', 'not', 'isUndefined', 'oclIsTypeOf', 'oclIsKindOf', 'oclAsType',
        'allInstances', 'any', 'collect', 'select', 'reject', 'one', 'exists',
        'forAll', 'isEmpty', 'notEmpty', 'size', 'includes', 'excludes', 'count',
        'append', 'prepend', 'insertAt', 'removeAt', 'including', 'excluding',
        'flatten', 'closure', 'iterate', 'sortedBy', 'orderBy', 'distinct'
    }

    if pd.isna(ocl_expression):
        return []

    pattern = r'\b[a-zA-Z_][a-zA-Z0-9_]*\b'
    matches = re.findall(pattern, ocl_expression)

    identifiers = [match for match in matches if match.lower() not in ocl_keywords]

    return identifiers


def extract_sentence_components(text):

    if pd.isna(text):
        return {}
    doc = nlp(text)
    components = {}

    for token in doc:
        if token.pos_ in ['NOUN', 'ADJ', 'ADV']:
            if token.pos_ not in components:
                components[token.pos_] = set()
            components[token.pos_].add(token.text)


    for pos in components:
        components[pos] = list(components[pos])

    return components


def calculate_clarity(ocl_identifiers, other_components):

    ocl_set = set(ocl_identifiers)
    other_words = set()

    for component_list in other_components.values():
        other_words.update(component_list)

    missing_words = ocl_set - other_words
    excess_words = other_words - ocl_set

    num_missing = len(missing_words)
    num_excess = len(excess_words)
    total_words = len(ocl_set)

    if total_words == 0:
        return 0

    clarity_score = (num_missing + num_excess) / total_words

    return clarity_score


def calculate_average_clarity(results, clarity_key):
    scores = [result[clarity_key] for result in results]
    if not scores:
        return 1
    return sum(scores) / len(scores)


df = pd.read_excel('result.xlsx')


data = df.head(327)


results = []

for index, row in data.iterrows():
    ocl_text = row['OCL']
    ocl2nl_text = row['OCL2NL']
    qwen_text = row['Qwen']
    gpt_text = row['GPT']


    ocl_identifiers = extract_identifiers(ocl_text)


    ocl2nl_components = extract_sentence_components(ocl2nl_text)
    qwen_components = extract_sentence_components(qwen_text)
    gpt_components = extract_sentence_components(gpt_text)


    clarity_ocl2nl = calculate_clarity(ocl_identifiers, ocl2nl_components)
    clarity_qwen = calculate_clarity(ocl_identifiers, qwen_components)
    clarity_gpt = calculate_clarity(ocl_identifiers, gpt_components)

    results.append({
        'Row': index + 1,
        'OCL Identifiers': ocl_identifiers,
        'OCL2NL Components': ocl2nl_components,
        'Qwen Components': qwen_components,
        'Clarity OCL2NL': clarity_ocl2nl,
        'Clarity Qwen': clarity_qwen,
        'Clarity GPT': clarity_gpt
    })

average_clarity_ocl2nl = calculate_average_clarity(results, 'Clarity OCL2NL')
average_clarity_qwen = calculate_average_clarity(results, 'Clarity Qwen')
average_clarity_gpt = calculate_average_clarity(results, 'Clarity GPT')


min_old, max_old = 0, 8
min_new, max_new = 0, 1

new_average_clarity_ocl2nl = (average_clarity_ocl2nl - min_old) / (max_old - min_old) * (max_new - min_new) + min_new
new_average_clarity_qwen = (average_clarity_qwen - min_old) / (max_old - min_old) * (max_new - min_new) + min_new
new_average_clarity_gpt = (average_clarity_gpt - min_old) / (max_old - min_old) * (max_new - min_new) + min_new

print(f"Average Clarity OCL2NL: {1-new_average_clarity_ocl2nl:.3f}")
print(f"Average Clarity Qwen: {1-new_average_clarity_qwen:.3f}")
print(f"Average Clarity GPT: {1-new_average_clarity_gpt:.3f}")
