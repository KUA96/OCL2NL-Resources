package com.rm2pt.generator.rm2doc.service

import java.util.ArrayList
import net.mydreamy.requirementmodel.rEMODEL.AtomicExpression
import net.mydreamy.requirementmodel.rEMODEL.BooleanLiteralExpCS
import net.mydreamy.requirementmodel.rEMODEL.ClassiferCallExpCS
import net.mydreamy.requirementmodel.rEMODEL.CollectionTypeCS
import net.mydreamy.requirementmodel.rEMODEL.Definition
import net.mydreamy.requirementmodel.rEMODEL.EntityType
import net.mydreamy.requirementmodel.rEMODEL.EnumLiteralExpCS
import net.mydreamy.requirementmodel.rEMODEL.IfExpCS
import net.mydreamy.requirementmodel.rEMODEL.IteratorExpCS
import net.mydreamy.requirementmodel.rEMODEL.LeftSubAtomicExpression
import net.mydreamy.requirementmodel.rEMODEL.LetExpCS
import net.mydreamy.requirementmodel.rEMODEL.LogicFormulaExpCS
import net.mydreamy.requirementmodel.rEMODEL.NestedExpCS
import net.mydreamy.requirementmodel.rEMODEL.NullLiteralExpCS
import net.mydreamy.requirementmodel.rEMODEL.NumberLiteralExpCS
import net.mydreamy.requirementmodel.rEMODEL.OCLExpressionCS
import net.mydreamy.requirementmodel.rEMODEL.OperationCallExpCS
import net.mydreamy.requirementmodel.rEMODEL.Postcondition
import net.mydreamy.requirementmodel.rEMODEL.Precondition
import net.mydreamy.requirementmodel.rEMODEL.PropertyCallExpCS
import net.mydreamy.requirementmodel.rEMODEL.RequirementModel
import net.mydreamy.requirementmodel.rEMODEL.RightSubAtomicExpression
import net.mydreamy.requirementmodel.rEMODEL.StandardDateOperation
import net.mydreamy.requirementmodel.rEMODEL.StandardNavigationCallExpCS
import net.mydreamy.requirementmodel.rEMODEL.StandardNoneParameterOperation
import net.mydreamy.requirementmodel.rEMODEL.StandardOperationExpCS
import net.mydreamy.requirementmodel.rEMODEL.StandardParameterOperation
import net.mydreamy.requirementmodel.rEMODEL.StringLiteralExpCS
import net.mydreamy.requirementmodel.rEMODEL.TypeCS
import net.mydreamy.requirementmodel.rEMODEL.VariableExpCS
import com.rm2pt.generator.rm2doc.utils.FileUtils
import net.mydreamy.requirementmodel.rEMODEL.VariableDeclarationCS
import net.mydreamy.requirementmodel.rEMODEL.Contract

/*
 * 类中各个方法的输入参数isPast
 * 当需要生成过去式时为真，需要生成现在时为假
 */
class LinkOcl2Nl {
	/*
	 * associationList中储存所有实体的refer，
	 * 用于区分实体的属性和refer
	 */
	var associationList = new ArrayList<String>

	/*
	 * objectList中储存各个Service中类型为EntityType的临时变量
	 * 用于区分对象和其他属性
	 */
	def printObjectList() {
		print(objectList)
	}

	var objectList = new ArrayList<String>
	/*
	 * isLink为真时，生成的句子带有链接
	 * 生成文档时isLink为true
	 * 生成remodel文件时为false
	 */
	var boolean isLink = false
	/*
	 * currentService是操作所在的服务，用于标识系统操作的链接
	 */
	var String currentService

	def defineList(RequirementModel r) {
		/*
		 * 设置associationList和objectList
		 */
		for (ser : r.useCaseModel.service)
			for (temp : ser.temp_property)
				if (temp.type instanceof EntityType) {
					if (!temp.ismultiple)
						objectList.add(temp.name)
				}

		for (e : r.domainModel.entity)
			for (refer : e.reference) {
				associationList.add(refer.name)
			}

	}

	def defineLink() {
		/*
		 * 设置 isLink为true，说明此时生成文档
		 */
		isLink = true
	}

	def defineService(String s) {
		/*
		 * 表示当前service，用于修正临时变量链接
		 * 区分不同的service中，命名相同的临时变量
		 */
		currentService = s
	}

	def String transNestedExpCS(NestedExpCS neCS, boolean isPast) {
		var String s = "("
		var nestedE = neCS.nestedExpression
		if (nestedE instanceof LogicFormulaExpCS) {
			for (i : 0 .. nestedE.atomicexp.size() - 1) {
				var ato = nestedE.atomicexp.get(i)
				if (i == nestedE.atomicexp.size() - 1) {
					if (ato instanceof AtomicExpression) {
						s = s + ato.transAtomicExpression(isPast) + ")"
					} else if (ato instanceof NestedExpCS) {
						s = s + ato.transNestedExpCS(isPast) + ")"
					} else {
						s = s + "ERROR01"
					}
				} else {
					if (ato instanceof AtomicExpression) {
						s = s + ato.transAtomicExpression(isPast) + ", " + nestedE.connector.get(i) + " "
					} else if (ato instanceof NestedExpCS) {
						s = s + ato.transNestedExpCS(isPast) + ", " + nestedE.connector.get(i) + " "
					} else {
						s = s + "ERROR02"
					}
				}
			}
		}
		return s
	}

	def String transIfNestedExpCS(NestedExpCS neCS, boolean isPast) {
		var String s = "("
		var nestedE = neCS.nestedExpression
		if (nestedE instanceof LogicFormulaExpCS) {
			for (i : 0 .. nestedE.atomicexp.size() - 1) {
				var ato = nestedE.atomicexp.get(i)
				if (i == nestedE.atomicexp.size() - 1) {
					if (ato instanceof AtomicExpression) {
						s = s + ato.transIfCon(isPast) + ")"
					} else if (ato instanceof NestedExpCS) {
						s = s + ato.transIfNestedExpCS(isPast) + ")"
					} else {
						s = s + "ERROR03"
					}
				} else {
					if (ato instanceof AtomicExpression) {
						s = s + ato.transIfCon(isPast) + ", " + nestedE.connector.get(i) + " "
					} else if (ato instanceof NestedExpCS) {
						s = s + ato.transIfNestedExpCS(isPast) + ", " + nestedE.connector.get(i) + " "
					} else {
						s = s + "ERROR04"
					}
				}
			}
		}
		return s
	}

	def String transAtomicExpression(AtomicExpression ato, boolean isPast) {
		if (isPast == true) {
			return ato.transPostAtomicExpression

		} else {
			return ato.transPreAtomicExpression

		}
	}

	def String transPreAtomicExpression(AtomicExpression ato) {
		return ato.transPreAtoIfcon(false)
	}

	def String transPreAtoIfcon(AtomicExpression ato, boolean isPast) {

		var left = ato.leftside
		if (ato.infixop !== null) {
			var right = ato.rightside
			var rightTrans = right.transRight(isPast)
			switch left {
				StandardOperationExpCS: {
					var String s
					if (left.predefinedop.name.equals("oclIsUndefined()")) {
						if (left.object.symbol.equals("self")) {
							if (objectList.contains(left.property.symbol)) {
								s = "the object " + left.property.symbol.linkTemp
							} else
								s = "the temporary variable " + left.property.symbol.linkTemp
						} else {
							if (objectList.contains(left.object.symbol)) {
								s = "the object " + left.object.symbol.toItalic
							} else {
								s = left.object.symbol.toItalic
							}

						}
						if (right instanceof BooleanLiteralExpCS) {
							var String ss
							if (right.symbol.equals("false")) {
								if(isPast == true) ss = " existed" else ss = " exists"
							} else if (right.symbol.equals("true")) {
								if(isPast == true) ss = " didn't exist" else ss = " doesn't exist"

							} else {
								ss = "ERROR05"
							}
							s = s + ss
						}
					} else {
						s = left.transStandardOperationExpCS(isPast) + ato.infixop.transInfixop(isPast) + rightTrans
					}
					return s
				}
				PropertyCallExpCS:
					return ato.calculation(isPast)
				VariableExpCS:
					return "the " + left.symbol.toItalic + ato.infixop.transInfixop(isPast) + rightTrans
				default:
					return "ERROR06"
			}
		} else {
			return left.aloneLeft(isPast)
		}
	}

	def inAndexclude(String n, boolean isPut) {
		/*
		 * 翻译includes和excludes关键字
		 * 后置条件 动作 isPut为真
		 * 判断 状态时 isPut为假
		 */
		var String inVerb
		if (n.equals("includes")) {

			inVerb = "in "
			if(isPut == true) inVerb = "put into "

		} else if (n.equals("excludes")) {

			inVerb = "not in "
			if(isPut == true) inVerb = "deleted from "

		} else {

			inVerb = "ERROR07"

		}
		return inVerb
	}

	def aloneLeft(LeftSubAtomicExpression left, boolean isPast) {
		var isVerb = " is "
		if (isPast == true) {
			isVerb = " was "
		}
		switch left {
			StandardNavigationCallExpCS: {
				if (left.propertycall !== null) {
					if (left.standardOP.name.equals("includes")) {
						return "the object " + left.propertycall.name.symbol.toItalic + isVerb +
							"linked to the object " + left.standardOP.object.toItalic + " by " +
							left.propertycall.attribute.toItalic
					} else if (left.standardOP.name.equals("excludes")) {
						return "the link from " + left.propertycall.name.symbol.toItalic + "to " +
							left.standardOP.object.toItalic + isVerb + " deleted"
					} else {
						return "ERROR08"
					}
				} else if (left.classifercall !== null) {
					var inset = left.classifercall.transClassiferCallExpCS
					return "the object " + left.standardOP.object.toItalic + isVerb +
						left.standardOP.name.inAndexclude(false) + inset
				} else {
					return "ERROR09"
				}
			}
			StandardOperationExpCS:
				return left.transStandardOperationExpCS(isPast)
			OperationCallExpCS:
				return "the system operation " + left.name.linkOP + isVerb + "executed"
			IteratorExpCS:
				return left.transIteratorExpCS(isPast)
			default:
				return "ERROR10"
		}
	}

	def String transPostAtomicExpression(AtomicExpression ato) {
		var String s
		if (ato.infixop !== null) {
			var String p
			if (ato.infixop.equals("=")) {
				p = " became "
			} else {
				p = "ERROR11"
			}
			var left = ato.leftside
			var right = ato.rightside
			var rightTrans = right.transRight(true)
			switch left {
				VariableExpCS:
					if (left.symbol.equals("result") || left.symbol.equals("return")) {
						return "the return value was " + rightTrans
					} else {
						if (right instanceof OperationCallExpCS) {
							return left.symbol.toItalic + p + rightTrans
						} else
							return "ERROR12"
					}
				PropertyCallExpCS:
					if (associationList.contains(left.attribute)) {
						var String ob
						if (left.selfproperty !== null) {
							ob = left.selfproperty.symbol.linkTemp
						} else {
							ob = left.name.symbol.toItalic
						}
						return "the object " + ob + " was linked to the object " + rightTrans + " by " +
							left.attribute.toItalic
					} else
						return left.transPropertyCallExpCS(true) + p + ato.expression(true)
				default:
					return "ERROR13"
			}
		} else if (ato.infixop === null) {
			var left = ato.leftside
			if (left instanceof StandardNavigationCallExpCS) {
				if (left.classifercall !== null) {
					var inset = left.classifercall.transClassiferCallExpCS
					return "the object " + left.standardOP.object.toItalic + " was " +
						left.standardOP.name.inAndexclude(true) + inset
				} else {
					return left.aloneLeft(true)
				}
			} else {
				return left.aloneLeft(true)
			}
		}
	}

	def expression(AtomicExpression ato, boolean isPast) {
		var String pp
		var rightTrans = ato.rightside.transRight(isPast)
		if (ato.op !== null) {
			if (ato.op.equals("*")) {
				pp = rightTrans + " times "
			} else if (ato.op.equals("-")) {
				pp = rightTrans + " minus "
			} else if (ato.op.equals("+")) {
				pp = rightTrans + " plus "
			} else {
				pp = "ERROR14"
			}
			if (ato.exp !== null) {
				pp = pp + ato.exp.leftside.transLeft(isPast)
			} else if (ato.num !== null) {
				pp = pp + ato.num.symbol.toBoldface
			} else {
				pp = pp + "ERROR15"
			}
		} else {
			pp = rightTrans
		}
		return pp
	}

	def String calculation(AtomicExpression ato, boolean isPast) {
		var String s
		var String isverb
		if (isPast == true) {
			isverb = " was "
		} else {
			isverb = " is "
		}
		var String p
		p = ato.infixop.transInfixop(isPast)
		var left = ato.leftside
		var right = ato.rightside

		var String rightTrans = right.transRight(isPast)

		if (left instanceof PropertyCallExpCS) {
			if (associationList.contains(left.attribute)) {
				s = "the object " + left.name.symbol.toItalic + isverb + "linked to the object " + rightTrans + " by " +
					left.attribute.toItalic
			} else {
				s = left.transPropertyCallExpCS(isPast) + p + ato.expression(isPast)
			}
		}

		return s
	}

	def String transIfCon(AtomicExpression ato, boolean isPast) {
		return ato.transPreAtoIfcon(isPast)
	}

	def transInfixop(String infixop, boolean past) {
		var String isverb = " is "
		if (past == true) {
			isverb = " was "
		}
		switch infixop {
			case "=":
				return isverb + "equal to "
			case ">":
				return isverb + "greater than "
			case "<":
				return isverb + "less than "
			case ">=":
				return isverb + "greater than or equal to "
			case "<=":
				return isverb + "less than or equal to "
			case "<>":
				return isverb + "not equal to "
			default:
				return isverb + "ERROR16"
		}
	}

	def ArrayList<String> transIfList(IfExpCS ifCS, boolean isPast) {
		var prepost = "pre"
		if (isPast == true) {
			prepost = "post"
		}
		var list = newArrayList
		var String s = "If "
		var con = ifCS.condition
		var tE = ifCS.thenExpression
		var eE = ifCS.elseExpression
		if (con instanceof LogicFormulaExpCS) {
			for (i : 0 .. con.atomicexp.size() - 1) {
				var atocon = con.atomicexp.get(i)
				if (i == con.atomicexp.size() - 1) {
					if (atocon instanceof AtomicExpression) {
						s = s + atocon.transIfCon(isPast)
					} else if (atocon instanceof NestedExpCS) {
						s = s + atocon.transIfNestedExpCS(isPast)
					} else {
						s = s + "ERROR17"
					}
				} else {
					if (atocon instanceof AtomicExpression) {
						s = s + atocon.transIfCon(isPast) + ", " + con.connector.get(i) + " "
					} else if (atocon instanceof NestedExpCS) {
						s = s + atocon.transIfNestedExpCS(isPast) + ", " + con.connector.get(i) + " "
					} else {
						s = s + "ERROR18"
					}
				}
			}
		} else if (con instanceof NestedExpCS) {
			s = s + con.transIfNestedExpCS(isPast)
		} else {
			s = s + "ERROR19"
		}
		s = s + ", take the following as " + prepost + "condition(s):"
		list.add(s)
		s = ""
		if (tE instanceof LogicFormulaExpCS) {
			for (atotE : tE.atomicexp) {
				if (atotE instanceof AtomicExpression) {
					s = atotE.transAtomicExpression(isPast).toNewLineSpace
				} else {
					s = "ERROR20"
				}
				list.add(s)
				s = ""
			}
		} else if (tE instanceof IfExpCS) {
			for (i : tE.transIfList(isPast)) {
				list.add(i.toNewLineSpace)
			}
		} else {
			list.add("ERROR21")
		}
		if (eE !== null) {
			list.add(("Otherwise, take the following as " + prepost + "condition(s):").toNewLine)
			s = ""
			if (eE instanceof LogicFormulaExpCS) {
				for (atoeE : eE.atomicexp) {
					if (atoeE instanceof AtomicExpression) {
						s = atoeE.transAtomicExpression(isPast).toNewLineSpace
					} else {
						s = "ERROR22"
					}
					list.add(s)
					s = ""
				}
			} else if (eE instanceof IfExpCS) {
				for (i : eE.transIfList(isPast)) {
					list.add(i.toNewLineSpace)
				}
			} else {
				list.add("ERROR23")
			}
		}
		return list
	}

	def String transIfExpCS(IfExpCS ifCS, boolean isPast) {
		var String s = ""
		for (i : ifCS.transIfList(isPast)) {
			s = s + i
		}
		return s
	}

	def String transLeftRight(Object left, boolean isPast) {
		var String o
		switch left {
			BooleanLiteralExpCS:
				return left.symbol.toBoldface
			NumberLiteralExpCS:
				return left.symbol.toBoldface
			PropertyCallExpCS:
				return left.transPropertyCallExpCS(isPast)
			VariableExpCS:
				return left.symbol.toItalic
			EnumLiteralExpCS:
				return left.eunmitem.toBoldface
			StandardOperationExpCS:
				return left.transStandardOperationExpCS(isPast)
			ClassiferCallExpCS:
				return left.transClassiferCallExpCS
			IteratorExpCS:
				return left.transIteratorExpCS(isPast)
			NullLiteralExpCS:
				return left.symbol.toBoldface
			StringLiteralExpCS:
				if (left.symbol == "\"\"") {
					return "null".toBoldface
				} else {
					return left.symbol.toBoldface
				}
			OperationCallExpCS:
				return "the return value of system operation " + left.name.linkOP
			default:
				return "ERROR29"
		}
	}

	def String transLeft(LeftSubAtomicExpression left, boolean isPast) {
		return left.transLeftRight(isPast)
	}

	def String transRight(RightSubAtomicExpression right, boolean isPast) {
		return right.transLeftRight(isPast)
	}

	def transClassiferCallExpCS(ClassiferCallExpCS ceCS) {
		var String s
		if (ceCS.op.equals("allInstance()")) {
			s = "the instance set of class " + ceCS.entity.linkClass
		} else {
			s = "ERROR31"
		}
		return s
	}

	def translationPreANDPostcondition(Object o, boolean isPast) {
		var OCLExpressionCS ooclExp
		if (o instanceof Postcondition) {
			ooclExp = o.oclexp
		} else if (o instanceof Precondition) {
			ooclExp = o.oclexp
		} else {
			// Object o 只能是 Postcondition或Precondition
		}
		var list = new ArrayList<String>
		if (ooclExp instanceof BooleanLiteralExpCS) {
			if(ooclExp.symbol.equals("true")) list.add("None") else list.add("ERROR32")
		} else if (ooclExp instanceof LetExpCS) {
			for (vaCS : ooclExp.variable) {
				objectList.add(vaCS.name)
				list.add(vaCS.name.toItalic + " represented the object of class " + vaCS.type.compileType)
			}
			var iinExpression = ooclExp.inExpression
			if (iinExpression instanceof LogicFormulaExpCS) {
				for (ato : iinExpression.atomicexp) {
					if (ato instanceof AtomicExpression) {
						list.add(ato.transAtomicExpression(isPast))
					} else if (ato instanceof IfExpCS) {
						list.add(ato.transIfExpCS(isPast))
					} else {
						list.add("ERROR33")
					}
				}
			} else {
				list.add("ERROR34")
			}

		} else if (ooclExp instanceof LogicFormulaExpCS) {
			for (ato : ooclExp.atomicexp) {
				if (ato instanceof AtomicExpression) {
					list.add(ato.transAtomicExpression(isPast))
				} else if (ato instanceof IfExpCS) {
					list.add(ato.transIfExpCS(isPast))
				} else if (ato instanceof NestedExpCS) {
					list.add(ato.transNestedExpCS(isPast))
				} else {
					list.add("ERROR35")
				}
			}

		} else if (ooclExp instanceof IfExpCS) {
			list.add(ooclExp.transIfExpCS(isPast))
		} else {
			list.add("ERROR36")
		}
		return list
	}

	def translationPrecondition(Precondition pre) {
		return pre.translationPreANDPostcondition(false)
	}

	def translationPostcondition(Postcondition post) {
		return post.translationPreANDPostcondition(true)
	}

	def String transPropertyCallExpCS(PropertyCallExpCS pcCS, boolean isPast) {
		var String s
		var String ob
		var String p
		if (associationList.contains(pcCS.attribute)) {
			if (pcCS.selfproperty !== null) {
				ob = pcCS.selfproperty.symbol
			} else {
				ob = pcCS.name.symbol
			}
			var isVerb = " is "
			if (isPast == true) {
				isVerb = " was "
			}
			s = "the object which " + ob.toItalic + isVerb + "linked to" + " by " + pcCS.attribute.toItalic
		} else {

			if (pcCS.premark !== null) {
				if (pcCS.premark.equals("@pre")) {
					p = "previous "
				} else {
					p = "ERROR37"
				}
			} else {
				p = ""
			}
			if (pcCS.name.symbol.equals("self")) {
				if (pcCS.selfproperty !== null) {
					if (!p.equals("")) {
						s = "its previous value"
					} else {
						s = "the attribute " + pcCS.attribute.toItalic + " of the object " +
							pcCS.selfproperty.symbol.linkTemp
					}

				} else {
					if (objectList.contains(pcCS.attribute)) {
						if (!p.equals("")) {
							p = "ERROR38"
						}
						s = p + "the object " + pcCS.attribute.linkTemp
					} else {
						s = "the " + p + "value of temporary variable " + pcCS.attribute.linkTemp
					}
				}
			} else {
				if (!p.equals("")) {
					s = "its previous value"
				} else {
					s = p + "the attribute " + pcCS.attribute.toItalic + " of the object " + pcCS.name.symbol.toItalic

				}
			}
		}
		return s
	}

	def ArrayList<String> transIteratorList(IteratorExpCS ieCS, boolean isPast) {
		var list = newArrayList
		var String isverb
		var String representverb
		var String meetverb
		var String areverb
		var String existsverb
		if (isPast == true) {
			isverb = " was "
			representverb = " represented "
			meetverb = " meet:"
			areverb = " were "
			existsverb = " existed "
		} else {
			isverb = " is "
			representverb = " represents "
			meetverb = " meets:"
			areverb = " are "
			existsverb = " exists "
		}
		var String s
		var String ins
		if (ieCS.objectCall !== null) {
			var obCall = ieCS.objectCall
			if (obCall instanceof ClassiferCallExpCS) {
				ins = obCall.transClassiferCallExpCS
			} else if (obCall instanceof PropertyCallExpCS) {
				if (associationList.contains(obCall.attribute)) {
					var String obca
					if (obCall.selfproperty !== null) {
						obca = obCall.selfproperty.symbol
					} else {
						obca = obCall.name.symbol
					}
					ins = "all objects which " + obca.toItalic + isverb + "linked to by " + obCall.attribute.toItalic
				} else {
					if (obCall.name.symbol.equals("self")) {
						ins = "the set " + obCall.attribute.linkTemp
					} else {
						ins = "ERROR39"
					}
				}
			} else {
				ins = "ERROR40"
			}
		} else if (ieCS.simpleCall !== null) {
			ins = "the set " + ieCS.simpleCall.toItalic
		} else {
			ins = "ERROR41"
		}
		var forAllFlag = false
		if (ieCS.varibles.size().equals(1)) {
			var ob = ieCS.varibles.get(0)
			if (ieCS.iterator.equals("collect")) {
			} else {
				var obtype = ob.type.compileType
				var obname = ob.name.toItalic
				if (ieCS.iterator.equals("forAll")) {
					forAllFlag = true
					s = "For each object of class " + obtype + " in " + ins + ", " + obname + representverb +
						"it(the object) and the following operations" + areverb + "performed:"
				} else if (ieCS.iterator.equals("select")) {
					s = "the set of class " + obtype + ", including all " + obname + " in " + ins + ". " + obname +
						representverb + "an object of class " + obtype + ", and " + obname + meetverb
				} else if (ieCS.iterator.equals("any")) {
					s = "the object " + obname + " in " + ins + ". " + obname + representverb + "an object of class " +
						obtype + ", and " + obname + meetverb

				} else if (ieCS.iterator.equals("exists")) {
					s = "At least one " + obname + existsverb + "in " + ins + ". " + obname + representverb +
						"an object of class " + obtype + ", and " + obname + meetverb
				} else {
					s = "ERROR42"
				}
				list.add(s)
			}
		} else {
			list.add("ERROR43")
		}
		var eexp = ieCS.exp
		if (eexp instanceof LogicFormulaExpCS) {
			for (ato : eexp.atomicexp) {
				if (ato instanceof AtomicExpression) {
					var left = ato.leftside
					if (ieCS.iterator.equals("collect")) {
						if (left instanceof PropertyCallExpCS) {
							if (associationList.contains(left.attribute)) {
								list.add("all objects which each object in " + ins + isverb + "linked to by " +
									left.attribute.toItalic)
							} else {
								list.add("the " + left.attribute.toItalic + " of each object in " + ins)
							}

						} else {
							list.add("ERROR44")
						}
						return list
					}

					if (left instanceof IteratorExpCS) {
						for (i : left.transIteratorList(isPast)) {
							list.add(i.toNewLineSpace)
						}
					} else {
						if (forAllFlag) {
							list.add(ato.transAtomicExpression(isPast).toNewLineSpace)
						} else {
							list.add(ato.transPreAtoIfcon(isPast).toNewLineSpace)
						}
					}
				} else if (ato instanceof IfExpCS) {
					for (i : ato.transIfList(isPast)) {
						list.add(i.toNewLineSpace)
					}
				} else {
					list.add("ERROR45")
				}
			}
		} else {
			list.add("ERROR46")
		}

		return list
	}

	def String transIteratorExpCS(IteratorExpCS ieCS, boolean isPast) {
		var String s = ""
		for (i : ieCS.transIteratorList(isPast)) {
			s = s + i
		}
		return s
	}

	def transStandardOperationExpCS(StandardOperationExpCS cs, boolean isPast) {
		var String isverb
		if (isPast == true) {
			isverb = " was "
		} else {
			isverb = " is "
		}
		var String s
		var pred = cs.predefinedop
		if (pred instanceof StandardDateOperation) {
			var String p
			var String p1
			var String p2
			var String pp = ""
			if (pred.datenum !== null) {
				p = pred.datenum.symbol.toBoldface + " days"
			} else {
				p = pred.object.toItalic
			}
			if (cs.property !== null) {
				var String ppre
				if (cs.premark !== null && cs.premark.equals("@pre")) {
					ppre = "previous value of "
				} else
					ppre = ""
				p1 = ppre + "the attribute " + cs.property.symbol.toItalic + " of the object " +
					cs.object.symbol.toItalic
			} else {
				p1 = cs.object.symbol.toItalic
			}
			if (pred.procall !== null) {

				p2 = "the attribute " + pred.procall.attribute.toItalic + " of the object " +
					pred.procall.name.symbol.toItalic
			} else {
				p2 = pred.object.toItalic
			}
			if (pred.nested !== null) {
				var String p4
				if (pred.nested.procall !== null) {
					p4 = "the attribute " + pred.nested.procall.attribute.toItalic + " of the object " +
						pred.nested.procall.name.symbol.toItalic
				} else {
					p4 = pred.nested.object.toItalic
				}
				if (pred.nested.name.equals("isAfter")) {
					pp = isverb + "after "
				} else if (pred.nested.name.equals("isBefore")) {
					pp = isverb + "before "
				} else if (pred.nested.name.equals("isEqual")) {
					pp = isverb + "equal to "
				} else {
					pp = "ERROR47"
				}
				pp = pp + p4
			}
			if (pred.name.equals("isEqual")) {
				s = p1 + isverb + "equal to " + p2
			} else if (pred.name.equals("After")) {
				s = "the day " + p + " after " + p1 + pp
			} else if (pred.name.equals("Before")) {
				s = "the day " + p + " before " + p1 + pp
			} else if (pred.name.equals("isAfter")) {
				s = p1 + isverb + "after " + p2
			} else if (pred.name.equals("isBefore")) {
				s = p1 + isverb + "before " + p2
			} else {
				s = "ERROR48"
			}
		} else if (pred instanceof StandardNoneParameterOperation) {
			if (pred.name.equals("oclIsNew()")) {
				s = "the object " + cs.object.symbol.toItalic + isverb + "created"
			} else if (pred.name.equals("sum()")) {
				s = "the sum of " + cs.object.symbol.toItalic
			} else if (pred.name.equals("size()")) {
				s = "the size of " + cs.object.symbol.toItalic
			} else if (pred.name.equals("notEmpty()")) {
				s = "the set " + cs.object.symbol.toItalic + isverb + "not empty"
			} else {
				s = "ERROR49"
			}
		} else if (pred instanceof StandardParameterOperation) {
			if (pred.name.equals("oclIsTypeOf")) {
				s = "the type of parameter " + cs.object.symbol.toItalic + isverb + "equal to " + pred.type.compileType
			} else {
				s = "ERROR50"
			}
		} else {
			s = "ERROR51"
		}
		return s
	}

	def transVariable(VariableDeclarationCS vdCS) {
		var String s
		s = vdCS.name.toItalic + " is "
		var String o
		var selectFlag = 0
		var initCS = vdCS.initExpression
		if (initCS instanceof LogicFormulaExpCS) {
			var ato = initCS.atomicexp.get(0)
			if (ato instanceof AtomicExpression) {
				var left = ato.leftside
				if (left instanceof IteratorExpCS) {
					o = left.transIteratorExpCS(false)
					if (left.iterator.equals("select")) {
						selectFlag = 1
					}
				} else if (left instanceof PropertyCallExpCS) {
					o = " which " + left.name.symbol.toItalic + " is linked to"
				} else {
					o = "ERROR52"
				}
			} else {
				o = "ERROR53"
			}
		} else {

			o = "ERROR54"
		}
		var ttype = vdCS.type
		if (ttype instanceof EntityType) {
			s = vdCS.name.toItalic + " is "
			objectList.add(vdCS.name)
		} else if (ttype instanceof CollectionTypeCS) {
			if (selectFlag == 1) {
				s = vdCS.name.toItalic + " is "
			} else {
				s = vdCS.name.toItalic + " is the " + ttype.name.name + " of "
				if (ttype.type instanceof EntityType) {
					s = s + "class "
				}
				s = s + ttype.type.compileType() + ", including "
			}
		} else {
			s = "ERROR55"
		}
		return s + o
	}

	def transDefinition(Definition definition) {
		var list = newArrayList
		for (vdCS : definition.variable) {

			list.add(vdCS.transVariable)
		}
		return list
	}

	def compileType(TypeCS type) {
		return CompileType.transType(type, isLink)
	}

	def linkClass(String s) {
		return ToLink.linkClass(s, isLink)
	}

	def linkOP(String s) {
		return ToLink.linkOP(s, isLink)
	}

	def linkTemp(String s) {
		return ToLink.linkTemp(s, currentService, isLink)
	}

	def toItalic(String s) {
		return ToLink.toItalic(s, isLink)
	}

	def toBoldface(String s) {
		return ToLink.toBoldface(s, isLink)
	}

	def toNewLine(String s) {
		return toNewLine(s, isLink)
	}

	def toNewLine(String s, boolean isLink) {
		if (isLink == true) {
			return "</p><p>" + s
		} else {
			return "\r\n" + s
		}
	}

	def toNewLineSpace(String s) {
		return toNewLineSpace(s, isLink)
	}

	def toNewLineSpace(String s, boolean isLink) {
		var String ss
		if (isLink == true) {
			if (s.startsWith("</p><p>")) {
				ss = "</p><p>&emsp;&emsp;" + s.substring(7, s.length());
			} else {
				ss = "</p><p>&emsp;&emsp;" + FileUtils.capitTheString(s)
			}
		} else {
			if (s.startsWith("\r\n")) {
				ss = "\r\n    " + s.substring(2, s.length());
			} else {
				ss = "\r\n    " + FileUtils.capitTheString(s)
			}
		}
		return ss
	}

	def summaryContract(Contract con) {
//		var ops = con.op
//		var opName = ops.name.stringToWord
//		if (ops.returnType.compileType.equals("Boolean")) {
//			if(ops.parameter.size == 0){
//				return opName
//			}else{
//				var s=""
//				for(para:con.op.parameter){
//					s=s+"\r\n"+transPara(con,para.name)
//				}
//				
//				return opName+s
//			}
//
//		} else {
//			return opName+"\r\n"+con.summaryContractNotBoolean
//		}
		var ops = con.op
		var opName = ops.name.stringToWord
//		if (ops.parameter.size == 0) {
//			return opName + "\r\n" + con.summaryContractNotBoolean
//		} else {
		var s = ""
		for (para : con.op.parameter) {
			s = s + "\r\n" + transPara(con, para.name)
		}
		return opName + s + "\r\n" + con.summaryContractNotBoolean

	}

	def transPara(Contract con, String para) {
//		var ArrayList<String> list
		if (con.def !== null) {
			var vari = getDefPara(con, para)
			if (vari !== null) {
//				var atoList = getPostPara(con, para)
//				if (atoList !== null) {
//					
//				} else {
				return "The parameter <" + para + ">" + vari.transVari
//				}
			}
		}

	}

	def transVari(VariableDeclarationCS vari) {
		var initE = vari.initExpression
		if (initE instanceof LogicFormulaExpCS) {
			var ato = initE.atomicexp.get(0)
			if (ato instanceof AtomicExpression) {
				var left = ato.leftside
				if (left instanceof IteratorExpCS) {
					return " is used to find the" + left.findRightIteratorExpCS
				}
			}
		}
	}

	/*
	 * 参数在def出现
	 */
	def getDefPara(Contract con, String para) {

		for (vari : con.def.variable) {
			if (vari.transVariable.judgeContain(para)) {
				return vari
			}
		}
		return null
	}

	def getPostPara(Contract con, String para) {
		var ArrayList<AtomicExpression> list
		for (ato : con.post.oclexp.findAto) {
			if (ato.transAtomicExpression(true).judgeContain(para)) {
				list.add(ato)
			}
		}
		return list
	}

	def ArrayList<AtomicExpression> findAto(OCLExpressionCS oclE) {
		var ArrayList<AtomicExpression> list
		switch oclE {
			LogicFormulaExpCS: {
				for (ato : oclE.atomicexp) {
					if (ato instanceof AtomicExpression) {
						list.add(ato)
					} else if (ato instanceof IfExpCS) {
						list.addAll(ato.findAto)
					} else if (ato instanceof NestedExpCS) {
						list.addAll(ato.findAto)
					} else {
					}
				}

				return list
			}
			NestedExpCS: {
				list.addAll(oclE.nestedExpression.findAto)
				return list
			}
			IfExpCS: {
				list.addAll(oclE.thenExpression.findAto)
				return list
			}
			LetExpCS: {
				list.addAll(oclE.inExpression.findAto)
				return list
			}
			default:
				return null
		}
	}

	def judgeContain(String s, String o) {
		var news = " " + s + " "
		if (news.contains(" " + o + " ") || news.contains(" " + o + ".") || news.contains(" " + o + ",")) {
			return true
		} else {
			return false
		}
	}

	/*
	 * 返回值不为boolean
	 */
	def summaryContractNotBoolean(Contract con) {

		var String s = con.op.name.stringToWord
		var o = ""
		var result = con.findResult
		if (result !== null) {
			if (result.transResult.startsWith("VariableExpCS")) {
				var varname = result.transResult.substring(13)
				for (varia : con.def.variable) {
					if (varia.name.equals(varname)) {
//						var initE = varia.initExpression
//						if (initE instanceof LogicFormulaExpCS) {
//							var ato = initE.atomicexp.get(0)
//							if (ato instanceof AtomicExpression) {
//								var left = ato.leftside
//								if (left instanceof IteratorExpCS) {
//									o = "Return " + left.transRightIteratorExpCS
//								}
//							}
//						}
						o = "Return the" + varia.type.compileType.stringToWord
					}
				}
				if (o.equals("")) {
					o = "Return " + varname
				}
			} else
				o = result.transResult
		}
		return o
	}

	def transRightIteratorExpCS(IteratorExpCS right) {
		var e = right.varibles.get(0).type.compileType.stringToWord
		var rightExp = right.exp
		var ee = ""
		if (rightExp instanceof LogicFormulaExpCS) {
			ee = rightExp.transAtoInIterator
		}
		var ce = ""
		var ob = right.objectCall
		if (ob instanceof ClassiferCallExpCS) {
			ce = " all"
		} else {
			ce = "ERROR92"
		}
		switch right.iterator {
			case "select": {
//				return ce + e + "(s) " + ee
				return " the" + e + "(s) " + ee
			}
			case "any": {
				return "the" + e + " " + ee
			}
			case "collect": {
				return "ERROR93"
			}
			default:
				return "ERROR93"
		}
	}

	def findRightIteratorExpCS(IteratorExpCS right) {
//		var e = right.varibles.get(0).type.compileType.stringToWord
//		var rightExp = right.exp
//		var ee = ""
//		if (rightExp instanceof LogicFormulaExpCS) {
//			ee = rightExp.transAtoInIterator
//		}
//		var ce = ""
//		var ob = right.objectCall
//		if (ob instanceof ClassiferCallExpCS) {
//			ce = "all"
//		} else {
//			ce = "ERROR92"
//		}
//		switch right.iterator {
//			case "select": {
//				return ce + e + "(s) " + ee
//			}
//			case "any": {
//				return "the" + e + " " + ee
//			}
//			case "collect": {
//				return "ERROR93"
//			}
//			default:
//				return "ERROR93"
//		}
		var e = right.varibles.get(0).type.compileType.stringToWord
		var rightExp = right.exp
		var ee = ""
		if (rightExp instanceof LogicFormulaExpCS) {
			ee = rightExp.transAtoInIterator
		}
		var ce = ""
		var ob = right.objectCall
		if (ob instanceof ClassiferCallExpCS) {
			ce = "all"
		} else {
			ce = "ERROR92"
		}
		switch right.iterator {
			case "select": {
				return e + "(s) "
			}
			case "any": {
				return e
			}
			case "collect": {
				return "ERROR93"
			}
			default:
				return "ERROR93"
		}

	}

	def transResult(AtomicExpression result) {

		var right = result.rightside
		switch right {
			PropertyCallExpCS: {
				var String e
				if (right.selfproperty != null) {
					e = right.selfproperty.symbol
				} else {
					e = right.name.symbol
				}
				return "Return the" + right.attribute.stringToWord + " of " + e.stringToWord
			}
			IteratorExpCS: {
				return "Return" + right.transRightIteratorExpCS
			}
			ClassiferCallExpCS: {
				return "Return all" + right.entity.stringToWord + "(s)"
			}
			VariableExpCS: {
				return "VariableExpCS" + right.symbol
			}
			BooleanLiteralExpCS: {
//				println("111111111111111")
				return "Return " + right.symbol
			}
			default:
				return "ERROR94"
		}

	}

	def transAtoInIterator(LogicFormulaExpCS atos) {
		var String s = ""
		for (ato : atos.atomicexp) {
			if (ato instanceof AtomicExpression) {
				var left = ato.leftside
				if (left instanceof PropertyCallExpCS) {
					var String o = left.attribute.stringToWord + ato.infixop.transInfixopInIterator + "<"+
						ato.rightside.transRight(false)+ ">"
					if (ato == atos.atomicexp.get(0)) {
						o = "whose" + o
					} else if (ato == atos.atomicexp.get(atos.atomicexp.size - 1)) {
						o = "and" + o
					} else {
						o = "," + o
					}
					s = s + o
				} else {
					s = s + "ERROR95"
				}

			} else {
				s = s + "ERROR95"
			}
		}
		return s
	}

	def transInfixopInIterator(String infixop) {
		switch infixop {
			case "=":
				return " is equal to "
			case ">":
				return " is greater than "
			case "<":
				return " is less than "
			case ">=":
				return " is greater than or equal to "
			case "<=":
				return " is less than or equal to "
			case "<>":
				return " is not equal to "
			default:
				return " ERROR16 "
		}
	}

	def findResult(Contract con) {
		var oclExp = con.post.oclexp
		findResultInOCLExpressionCS(oclExp)
	}

	def AtomicExpression findResultInOCLExpressionCS(OCLExpressionCS oclExp) {
		if (oclExp instanceof LogicFormulaExpCS) {
			for (ato : oclExp.atomicexp)
				if (ato instanceof AtomicExpression) {
					var left = ato.leftside
					if (left instanceof VariableExpCS)
						if (left.symbol.equals("result")) {
							return ato
						}
				}
		} else if (oclExp instanceof LetExpCS) {
			findResultInOCLExpressionCS(oclExp.inExpression)
		}
	}

	def stringToWord(String s) {
		var temp = s.replaceAll("[A-Z]", " $0")
		return temp.toLowerCase()
	}

}
