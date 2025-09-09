package com.rm2pt.generator.rm2doc.utils;

import java.util.ArrayList;

import org.eclipse.emf.common.util.EList;

import com.rm2pt.generator.rm2doc.service.ToLink;

import net.mydreamy.requirementmodel.rEMODEL.AbstractEnd;
import net.mydreamy.requirementmodel.rEMODEL.CallMessage;
import net.mydreamy.requirementmodel.rEMODEL.CombinedFragmentEnd;
import net.mydreamy.requirementmodel.rEMODEL.Interaction;
import net.mydreamy.requirementmodel.rEMODEL.Message;
import net.mydreamy.requirementmodel.rEMODEL.MessageEnd;
import net.mydreamy.requirementmodel.rEMODEL.OperandEnd;
import net.mydreamy.requirementmodel.rEMODEL.Parameter;

public class BasicPathWrite {
	
	public static void writeBasicpath(Interaction inter, ArrayList<String> list) {
		/*
		 * 为Interaction inter写一个基本路径，保存到ArrayList<String> list
		 * 在xtend模板表达式中，返回值会加入到输出中，因此将list作为输入参数，使得该方法没有返回值
		 */
		int lF = 0, aF = 0, index = 1;
		String stepIndex="",lFlag = null;
		for (AbstractEnd end : inter.getEnds()) {
			if (end instanceof CombinedFragmentEnd) {
				String operator = ((CombinedFragmentEnd) end).getOwner().getOperator();
				if (operator.equals("loop") && lF == 0) {
					lF = 1;
					continue;
				}
				if (operator.equals("loop") && lF == 1) {
					list.add("&emsp;<i>If " + lFlag + ", repeat the step(s) " + stepIndex + "</i>");
					lF = 0;
					continue;
				}
				if (operator.equals("alt") && aF == 0) {
					String altName = ((CombinedFragmentEnd) end).getOwner().getName();
					list.add(index + ". " + " Execute  " + altName);
					index++;
					aF = 1;
					continue;
				}
				if (operator.equals("alt") && aF == 1) {
					aF = 0;
					continue;
				}

			}
			if(end instanceof OperandEnd) {
				String operandName = ((OperandEnd) end).getOwner().getName();
				if(aF==1) {
					list.add("&emsp;" + "Select " + operandName + ":");
				}
				if(lF==1) {
					lFlag = operandName;
				}
			}
			if (end instanceof MessageEnd) {
				Message me = ((MessageEnd) end).getMessage();
				String actorName = ((MessageEnd) end).getContext().getName();
				if (me instanceof CallMessage) {
					CallMessage cm = ((CallMessage) me);
					String opName = cm.getOp().getName();
					if (lF == 0 && aF == 0) {
						if (cm.getOp().getParameter().isEmpty()) {
							list.add(index + ". " + actorName + " clicks to execute the operation " + ToLink.linkOP(opName));
							index++;
						} else {
							String pStr = "";
							EList<Parameter> _parameter = cm.getOp().getParameter();
							for (int i=0;i< _parameter.size();i++) {
								if (i==_parameter.size()-1)pStr = (pStr + _parameter.get(i).getName());
								else pStr = (pStr + _parameter.get(i).getName() + ", ");	
							}
							list.add(index + ". " + actorName + " clicks to execute the operation " + ToLink.linkOP(opName)+", with entering "+pStr);
							index++;
						}

					}
					if(lF==1) {
						if (cm.getOp().getParameter().isEmpty()) {
							list.add(index + ". " + actorName + " clicks to execute the operation " + ToLink.linkOP(opName));
							stepIndex = stepIndex + index + " ";
							index++;
						} else {
							String pStr = "";
							EList<Parameter> _parameter = cm.getOp().getParameter();
							for (int i=0;i< _parameter.size();i++) {
								if (i==_parameter.size()-1)pStr = (pStr + _parameter.get(i).getName());
								else pStr = (pStr + _parameter.get(i).getName() + ", ");	
							}
							list.add(index + ". " + actorName + " clicks to execute the operation " + ToLink.linkOP(opName)+", with entering "+pStr);
							stepIndex = stepIndex + index + " ";
							index++;
						}
					}
					if(aF==1) {
						if (cm.getOp().getParameter().isEmpty()) {
							list.add("&emsp;&emsp;" + actorName + " clicks to execute the operation " + ToLink.linkOP(opName));
						} else {
							String pStr = "";
							EList<Parameter> _parameter = cm.getOp().getParameter();
							for (int i=0;i< _parameter.size();i++) {
								if (i==_parameter.size()-1)pStr = (pStr + _parameter.get(i).getName());
								else pStr = (pStr + _parameter.get(i).getName() + ", ");	
							}
							list.add("&emsp;&emsp;" + actorName + " clicks to execute the operation " + ToLink.linkOP(opName)+", with entering "+pStr);
						}
					}
				}
			}

		}
	}

	
}
