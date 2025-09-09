package com.rm2pt.generator.rm2doc.service

class ToLink {
	/*
	 *为各种情况的领域内名词添加链接，或添加字体
	 * 所有方法的传入参数boolean isLink，当生成文档时为真，生成注释时为假
	 */
	def static toItalic(String s) {
		/*
		 * 斜体
		 */
		return "<i>" + s + "</i>"
	}

	def static toItalic(String s, boolean isLink) {
		if (isLink == true) {
			return toItalic(s)
		} else {
			return s
		}
	}

	def static toBoldface(String s) {
		/*
		 * 粗体
		 */
		return "<b>" + s + "</b>"
	}

	def static toBoldface(String s, boolean isLink) {
		if (isLink == true) {
			return toBoldface(s)
		} else {
			return s
		}
	}

	def static spanLink(String s, String type) {
		/*
		 * spanLink方法用于指定锚点
		 * type用于修正字符串，避免重复
		 * 其取值可以为"ACTOR"，"UC"，"SERVICE"，"CLASS"，"OP"
		 */
		return "<span name =\"" + type + s + "\">" + s + "</span>"
	}

	def static link(String s, String type) {
		/*
		 * link到对应的锚点
		 * type用于修正字符串，避免重复
		 * 其取值可以为"ACTOR"，"UC"，"SERVICE"，"CLASS"，"OP"
		 */
		return "<a href=\"#" + type + s + "\">" + s + "</a>"
	}

	def static spanActor(String s) {
		return spanLink(s, "ACTOR")
	}

	def static linkActor(String s) {
		return link(s, "ACTOR")
	}

	def static spanUC(String s) {
		return spanLink(s, "UC")
	}

	def static linkUC(String s) {
		return link(s, "UC")
	}

	def static spanService(String s) {
		return spanLink(s, "SERVICE")
	}

	def static linkService(String s) {
		return link(s, "SERVICE")
	}

	def static spanClass(String s) {
		return spanLink(s, "CLASS")
	}

	def static linkClass(String s) {
		return link(s, "CLASS")
	}

	def static linkClass(String s, boolean isLink) {
		if (isLink == true)
			return linkClass(s)
		else
			return s
	}

	def static spanTemp(String s) {
//		return spanLink(s, "TEMP")
	}

	def static linkTemp(String s) {
//		return link(s, "TEMP")
	}

	def static linkTemp(String s, String ser, boolean isLink) {
		if (isLink == true)
			return link(s, ser)
		else
			return s
	}

	def static spanOP(String s) {
		return spanLink(s, "OP")
	}

	def static linkOP(String s) {
		return link(s, "OP")
	}

	def static linkOP(String s, boolean isLink) {
		if (isLink == true)
			return linkOP(s)
		else
			return s
	}
}
