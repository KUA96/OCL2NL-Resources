import sys
import pandas as pd
import spacy
import re

# 加载 SpaCy 的英语模型
try:
    nlp = spacy.load("en_core_web_sm")
except IOError:
    print("Model 'en_core_web_sm' not found. Please ensure it is installed.")
    sys.exit(1)


def extract_identifiers(ocl_expression):
    """使用正则表达式从 OCL 表达式中提取标识符"""
    ocl_keywords = {
        'self', 'if', 'then', 'else', 'endif', 'let', 'in', 'implies', 'and', 'or',
        'xor', 'not', 'isUndefined', 'oclIsTypeOf', 'oclIsKindOf', 'oclAsType',
        'allInstances', 'any', 'collect', 'select', 'reject', 'one', 'exists',
        'forAll', 'isEmpty', 'notEmpty', 'size', 'includes', 'excludes', 'count',
        'append', 'prepend', 'insertAt', 'removeAt', 'including', 'excluding',
        'flatten', 'closure', 'iterate', 'sortedBy', 'orderBy', 'distinct'
    }

    if pd.isna(ocl_expression):  # 检查是否为空值
        return []
    # 匹配字母数字字符开头的单词（假设标识符由字母数字字符组成）
    pattern = r'\b[a-zA-Z_][a-zA-Z0-9_]*\b'
    matches = re.findall(pattern, ocl_expression)
    # 过滤掉关键字
    identifiers = [match for match in matches if match.lower() not in ocl_keywords]

    return identifiers


def extract_sentence_components(text):
    """从文本中提取句子成分（名词、形容词等）"""
    if pd.isna(text):  # 检查是否为空值
        return {}
    doc = nlp(text)
    components = {}

    for token in doc:
        if token.pos_ in ['NOUN', 'ADJ', 'ADV']:
            if token.pos_ not in components:
                components[token.pos_] = set()
            components[token.pos_].add(token.text)

    # 将集合转换为列表以便于后续处理
    for pos in components:
        components[pos] = list(components[pos])

    return components


def calculate_clarity(ocl_identifiers, other_components):
    """计算清晰度得分"""
    ocl_set = set(ocl_identifiers)
    other_words = set()

    # 合并其他列的所有词汇
    for component_list in other_components.values():
        other_words.update(component_list)

    missing_words = ocl_set - other_words
    excess_words = other_words - ocl_set

    num_missing = len(missing_words)
    num_excess = len(excess_words)
    total_words = len(ocl_set)

    if total_words == 0:
        return 0  # 如果 OCL 中没有实体，则认为是完全清晰的

    clarity_score = (num_missing + num_excess) / total_words

    return clarity_score


def calculate_average_clarity(results, clarity_key):
    """计算指定清晰度得分的平均值"""
    scores = [result[clarity_key] for result in results]
    if not scores:
        return 1
    return sum(scores) / len(scores)


# 读取 Excel 表格文件
# 替换 'result.xlsx' 为实际文件路径
df = pd.read_excel('result.xlsx')

# 获取前五行的数据
data = df.head(100)

# 初始化结果列表
results = []

for index, row in data.iterrows():
    ocl_text = row['OCL']
    ocl2nl_text = row['OCL2NL']
    qwen_text = row['Qwen']
    gpt_text = row['GPT']

    # 提取 OCL 列的标识符
    ocl_identifiers = extract_identifiers(ocl_text)

    # 提取 OCL2NL 和 Qwen 列的句子成分
    ocl2nl_components = extract_sentence_components(ocl2nl_text)
    qwen_components = extract_sentence_components(qwen_text)
    gpt_components = extract_sentence_components(gpt_text)

    # 计算清晰度
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

# 打印结果
for result in results:
    print(f"Row {result['Row']}:")
    print(f"Clarity OCL2NL: {result['Clarity OCL2NL']:.2f}")
    print(f"Clarity Qwen: {result['Clarity Qwen']:.2f}\n")
    print(f"Clarity GPT: {result['Clarity GPT']:.2f}\n")

# 计算并打印平均清晰度
average_clarity_ocl2nl = calculate_average_clarity(results, 'Clarity OCL2NL')
average_clarity_qwen = calculate_average_clarity(results, 'Clarity Qwen')
average_clarity_gpt = calculate_average_clarity(results, 'Clarity GPT')

# 归一化
min_old, max_old = 0, 8
min_new, max_new = 0, 1

new_average_clarity_ocl2nl = (average_clarity_ocl2nl - min_old) / (max_old - min_old) * (max_new - min_new) + min_new
new_average_clarity_qwen = (average_clarity_qwen - min_old) / (max_old - min_old) * (max_new - min_new) + min_new
new_average_clarity_gpt = (average_clarity_gpt - min_old) / (max_old - min_old) * (max_new - min_new) + min_new

print(f"Average Clarity OCL2NL: {1-new_average_clarity_ocl2nl:.3f}")
print(f"Average Clarity Qwen: {1-new_average_clarity_qwen:.3f}")
print(f"Average Clarity GPT: {1-new_average_clarity_gpt:.3f}")