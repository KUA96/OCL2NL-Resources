package com.rm2pt.generator.rm2doc.service

import net.mydreamy.requirementmodel.rEMODEL.TypeCS
import net.mydreamy.requirementmodel.rEMODEL.PrimitiveTypeCS
import net.mydreamy.requirementmodel.rEMODEL.EnumEntity
import net.mydreamy.requirementmodel.rEMODEL.EntityType
import java.util.ArrayList
import net.mydreamy.requirementmodel.rEMODEL.CollectionTypeCS

class CompileType {
	/* For primary and enum type */
	
	
	def static String transType(TypeCS ttype, boolean isLink) {

		if (ttype !== null) {
			switch ttype {
				PrimitiveTypeCS:
					switch ttype {
						case ttype.name == "Boolean": "Boolean"
						case ttype.name == "String": "String"
						case ttype.name == "Real": "Real"
						case ttype.name == "Integer": "Integer"
						case ttype.name == "Date": "LocalDate"
						default: ""
					}
				EnumEntity:
					compileEnumEntity(ttype)
				EntityType:
					ToLink.linkClass(ttype.entity.name,isLink)
				CollectionTypeCS:
					"Set of " + ttype.type.transType(false)
				default:
					""
			}
		} else {
			""
		}
	}

	def static compileEnumEntity(EnumEntity enumEntity) {
		var list = new ArrayList<String>()
		for (ele : enumEntity.element) {
			list.add(ele.name)
		}
		var s = "["
		for (i : 0 .. list.size - 1) {
			if(i == list.size - 1) s = s + list.get(i) + "]" else s = s + list.get(i) + "|"
		}
		return s
	}
}
