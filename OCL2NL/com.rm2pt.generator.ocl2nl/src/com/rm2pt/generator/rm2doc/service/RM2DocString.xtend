package com.rm2pt.generator.rm2doc.service

class RM2DocString {
	public static final String DOCGEN = "Doc-gen";
	public static final String IMAGES = "Images";
	public static final String UseCaseDiagram = "Use Case Diagram"
	public static final String ConceptualClassDiagram = "Conceptual Class Diagram"

	def static imageFileName(String s) {
		return s.replace(" ", "_") + ".svg"
	}

}
