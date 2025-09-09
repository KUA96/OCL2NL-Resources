package com.rm2pt.generator.rm2doc

import java.util.ArrayList
import net.mydreamy.requirementmodel.rEMODEL.DomainModel
import net.mydreamy.requirementmodel.rEMODEL.EntityType
import net.mydreamy.requirementmodel.rEMODEL.EnumEntity
import net.mydreamy.requirementmodel.rEMODEL.PrimitiveTypeCS
import net.mydreamy.requirementmodel.rEMODEL.RequirementModel
import net.mydreamy.requirementmodel.rEMODEL.TypeCS
import net.mydreamy.requirementmodel.rEMODEL.UseCaseModel
import net.mydreamy.requirementmodel.rEMODEL.Attribute
import com.rm2pt.generator.rm2doc.DocumentGenerator
import com.rm2pt.generator.rm2doc.utils.FileUtils
import com.rm2pt.generator.rm2doc.utils.BasicPathWrite
import com.rm2pt.generator.rm2doc.service.RM2DocString
import com.rm2pt.generator.rm2doc.service.ToLink
import com.rm2pt.generator.rm2doc.service.CompileType

class Model2Doc {
	def static CharSequence generateDoc(RequirementModel r) {
		'''
			# 1   Introduction
			## 1.1   Purpose
			This subsection should
			
			- a) Delineate the purpose of the SRS;
			- b) Specify the intended audience for the SRS.
			## 1.2   Scope
			«r.useCaseModel.generateScope»
			## 1.3   Product Overview
			
			### 1.3.1  Product perspective
			This subsection of the SRS should put the product into perspective with other related products. If the product is independent and totally self-contained, it should be so stated here. If the SRS defines a product that is a component of a larger system, as frequently occurs, then this subsection should relate the requirements of that larger system to functionality of the software and should identify interfaces between that system and the software.
			 
			This subsection should also describe how the software operates inside various constraints. For example,
			these constraints could include
			- a) System interfaces;
			- b) User interfaces;
			- c) Hardware interfaces;
			- d) Software interfaces;
			- e) Communications interfaces;
			- f) Memory;
			- j) Operations;
			- k) Site adaptation requirements.
			#### 1.3.1.1   System interfaces
			«r.useCaseModel.generateService»
			 
			### 1.3.2  Product functions
			«r.useCaseModel.generateProductFunctions»
			### 1.3.3  User characteristics
			«r.useCaseModel.generateUserCharacteristics»
			### 1.3.4 Limitations
			This subsection of the SRS should provide a general description of any other items that will limit the developer’s options. These include
			
			- a) Regulatory policies;
			- b) Hardware limitations (e.g., signal timing requirements);
			- c) Interfaces to other applications;
			- d) Parallel operation;
			- e) Audit functions;
			- f) Control functions;
			- g) Higher-order language requirements;
			- h) Signal handshake protocols (e.g., XON-XOFF, ACK-NACK);
			- i) Reliability requirements;
			- j) Criticality of the application;
			- k) Safety and security considerations.
			- l) physical/mental considerations; and
			- m) limitations that are sourced from other systems, including real-time requirements from the controlled system through interfaces.

			## 1.4   Definitions
			This subsection should provide the defifinitions of all terms required to properly interpret the SRS. This information may be provided by reference to one or more appendixes in the SRS or by reference to other documents.

			# 2  References
			This subsection should
			
			- a) Provide a complete list of all documents referenced elsewhere in the SRS;
			- b) Identify each document by title, report number (if applicable), date, and publishing organization;
			- c) Specify the sources from which the references can be obtained.
			
			This information may be provided by reference to an appendix or to another document.
			
			# 3  Requirements
			## 3.1  Functions
			### 3.1.1   Use Case
			«r.useCaseModel.generateUseCaseDescription»
			 
			### 3.1.2   System Operation
			«DocumentGenerator.generateOperation(r)»
			 
			## 3.2  Database requirements
			#### 3.2.1   Entity Analysis
			«r.domainModel.generateEntityAnalysis»
			 
			#### 3.2.2   Other database requirements
			This should specify the logical requirements for any information that is to be placed into a database. This may include the following:
			
			- a) Types of information used by various functions;
			- b) Frequency of use;
			- c) Accessing capabilities;
			- d) Integrity constraints;
			- e) Data retention requirements.			
			
			 
			## 3.3  Performance requirements
			### 3.3.1  Static numerical requirements
			This subsection should specify both the static and the dynamic numerical requirements placed on the software or on human interaction with the software as a whole. Static numerical requirements may include the following:
			
			- a) The number of terminals to be supported;
			- b) The number of simultaneous users to be supported;
			- c) Amount and type of information to be handled.
			### 3.3.2  Dynamic numerical requirements
			Dynamic numerical requirements may include, for example, the numbers of transactions and tasks and the amount of data to be processed within certain time periods for both normal and peak workload conditions.
			
			All of these requirements should be stated in measurable terms.
			
			For example, 
			
			- *95% of the transactions shall be processed in less than 1 s.*
			
			rather than,
			
			- *An operator shall not have to wait for the transaction to complete.*
			
			NOTE:Numerical limits applied to one specifific function are normally specifified as part of the processing subparagraph description of that function. 
			
			## 3.4  Usability requirements
			Define usability and quality in use requirements and objectives for the software system that can include measurable effectiveness, efficiency, satisfaction criteria and avoidance of harm that could arise from use in specific contexts of use.
			## 3.5  Interface requirements
			### 3.5.1  User interfaces
			This should specify the following:
			- a) The logical characteristics of each interface between the software product and its users. This includes those configuration characteristics (e.g., required screen formats, page or window layouts, content of any reports or menus, or availability of programmable function keys) necessary to accomplish the software requirements.
			- b) All the aspects of optimizing the interface with the person who must use the system. This may simply comprise a list of do’s and don’ts on how the system will appear to the user. One example may be a requirement for the option of long or short error messages. Like all others, these requirements should be verifiable, e.g., “a clerk typist grade 4 can do function X in Z min after 1 h of training” rather than “a typist can do function X.” (This may also be specified in the Software System Attributes under a section titled Ease of Use.) 
			### 3.5.2  Hardware interfaces
			This should specify the logical characteristics of each interface between the software product and the hardware components of the system. This includes configuration characteristics (number of ports, instruction sets, etc.). It also covers such matters as what devices are to be supported, how they are to be supported, and protocols. For example, terminal support may specify full-screen support as opposed to line-by-line support.
			### 3.5.3  Software interfaces
			This should specify the use of other required software products (e.g., a data management system, an operating system, or a mathematical package), and interfaces with other application systems (e.g., the linkage between an accounts receivable system and a general ledger system). For each required software product, the following should be provided:
			- a) Name;
			- b) Mnemonic;
			- c) Specification number;
			- d) Version number;
			- e) Source.
			 
			For each interface, the following should be provided:
			- a) Discussion of the purpose of the interfacing software as related to this software product.
			- b) Definition of the interface in terms of message content and format. It is not necessary to detail any well-documented interface, but a reference to the document defining the interface is required.
			### 3.5.4  Communications interfaces
			This should specify the various interfaces to communications such as local network protocols, etc.
			
			## 3.6  Design constraints
			Specify constraints on the system design imposed by external standards, regulatory requirements or project limitations.
			### 3.6.1  Standards compliance
			This subsection should specify the requirements derived from existing standards or regulations. They may include the following:
					
			- a) Report format;
			- b) Data naming;
			- c) Accounting procedures;
			- d) Audit tracing.
					
			For example, this could specify the requirement for software to trace processing activity. Such traces are needed for some applications to meet minimum regulatory or financial standards. An audit trace requirement may, for example, state that all changes to a payroll database must be recorded in a trace file with before and after values.
			
			## 3.7  Software system attributes
			### 3.7.1  Reliability
			This should specify the factors required to establish the required reliability of the software system at time of delivery.
			### 3.7.2  Availability
			This should specify the factors required to guarantee a defined availability level for the entire system such as checkpoint, recovery, and restart.
			
			### 3.7.3  Security
			This should specify the factors that protect the software from accidental or malicious access, use, modification, destruction, or disclosure. Specific requirements in this area could include the need to
			
			- a) Utilize certain cryptographical techniques;
			- b) Keep specific log or history data sets;
			- c) Assign certain functions to different modules;
			- d) Restrict communications between some areas of the program;
			- e) Check data integrity for critical variables.
			### 3.7.4  Maintainability
			This should specify attributes of software that relate to the ease of maintenance of the software itself. There may be some requirement for certain modularity, interfaces, complexity, etc. Requirements should not be placed here just because they are thought to be good design practices.
			
			### 3.7.5  Portability
			This should specify attributes of software that relate to the ease of porting the software to other host machines and/or operating systems. This may include the following:
			
			- a) Percentage of components with host-dependent code;
			- b) Percentage of code that is host dependent;
			- c) Use of a proven portable language;
			- d) Use of a particular compiler or language subset;
			- e) Use of a particular operating system.
			## 3.8  Supporting information
			Additional supporting information to be considered includes:
			
			- a) sample input/output formats, descriptions of cost analysis studies or results of user surveys;
			- b) supporting or background information that can help the readers of the SRS;
			- c) a description of the problems to be solved by the software; and
			- d) special packaging instructions for the code and the media to meet security, export, initial loading or other requirements.
			
			The SRS should explicitly state whether or not these information items are to be considered part of the requirements.
						
			# 4  Verification
			Provide the verification approaches and methods planned to qualify the software. The information items for verification are recommended to be given in a parallel manner with the information items in 	Section 3.
			# 5  Appendices
			## 5.1  Assumptions and dependencies
			This subsection of the SRS should list each of the factors that affect the requirements stated in the SRS. These factors are not design constraints on the software but are, rather, any changes to them that can affect the requirements in the SRS. For example, an assumption may be that a specific operating system will be available on the hardware designated for the software product. If, in fact, the operating system is not available, the SRS would then have to change accordingly. 
			## 5.2 Apportioning of requirements
			Apportion the software requirements to software elements. For requirements that will require implementation over multiple software elements, or when allocation to a software element is initially undefined, this should be so stated. A cross-reference table by function and software element should be used to summarize the apportionments.
			
			Identify requirements that may be delayed until future versions of the system (e.g., blocks and/or increments).
			## 5.3  Acronyms and abbreviations
			This subsection should provide the acronyms and abbreviations required to properly interpret the SRS. This information may be provided by reference to one or more appendixes in the SRS or by reference to other documents.
		'''
	}

	def static generateScope(UseCaseModel useCaseModel) {
		var String sys = ""
		for (ser : useCaseModel.service) {
			if (ser.name.endsWith("System")) {
				sys = ser.name.substring(0, ser.name.length() - 6)
				if (sys.endsWith("System")) {
					sys = sys.substring(0, ser.name.length() - 6)
				}
			}
		}
		'''
			Name of software to be developed: «sys» System
			
			This subsection should
			
			- b) Explain what the software product(s) will, and, if necessary, will not do;
			- c) Describe the application of the software being specifified, including relevant benefifits, objectives, and goals;
			- d) Be consistent with similar statements in higher-level specififications (e.g., the system requirements specifification), if they exist.
		'''
	}
	def static citeImagePath(String s){
		return RM2DocString.IMAGES+"/"+ RM2DocString.imageFileName(s)
	}
	def static generateProductFunctions(UseCaseModel useCaseModel) {
		var ucId = 1
		'''
		<b>Use Case Diagram</b>
		 
		![Use Case Diagram](«citeImagePath(RM2DocString.UseCaseDiagram)»)
		 
		<table>
			<tr>
				<td><b>ID</b></td>
				<td><b>Use Case Name</b></td>
				<td><b>Use Case Description</b></td>
				<td><b>Subfunction</b></td>
			</tr>«FOR usecase : useCaseModel.uc»
			<tr>
				<td>UC«ucId++»</td>
				<td>«ToLink.linkUC(usecase.name)»</td>
				<td>«IF usecase.description!==null »«usecase.description.replace("\"", "")»«ENDIF»</td>
				<td>«FOR ser:useCaseModel.service»«IF ser.name.startsWith(FileUtils.capitString(usecase.name))»«FOR op:ser.operation»<p>«ToLink.linkOP(op.name)»</p>«ENDFOR»«ENDIF»
				«ENDFOR»</td>
			</tr>
			«ENDFOR»
		</table>
		'''
	}
	def static generateUserCharacteristics(UseCaseModel useCaseModel) {
		var actId = 1
		'''
		
		<table>
			<tr>
				<td><b>ID</b></td>
				<td><b>Actor</b></td>
				<td><b>Description</b></td>
				<td><b>Super Actor</b></td>
			</tr>
			«FOR act : useCaseModel.actor»<tr>
				<td>A«actId++»</td>
				<td>«ToLink.spanActor(act.name)»</td>
				<td>«IF act.description!==null »«act.description.replace("\"", "")»«ENDIF»</td>
				<td>«IF act.superActor!==null»«ToLink.linkActor(act.superActor.name)»«ENDIF»</td>
			</tr>«ENDFOR»
		</table>
		
«««			The applicable objects of this system are «FOR act : useCaseModel.actor»«IF act.label!==null »«act.label.replace("\"", "")»«ELSE»«act.name»«ENDIF»«IF !act.equals(useCaseModel.actor.get(useCaseModel.actor.size()-1))», «ENDIF»«ENDFOR».
«««			If they know the basic operation of computer, they can use the system to operate the required functions.
«««			Maybe some users need some relevant training.
		'''
	}

//	def static generateUserRequirements(UseCaseModel useCaseModel) {
//		var actId=1
//		'''		
//			<b>Use Case Diagram</b>
//			 
//			![Use Case Diagram](Images/Use_Case_Diagram.svg)
//			 
//			«FOR act : useCaseModel.actor»
//				<b>A«actId» - «act.name»</b>
//				<table>
//					<tr>
//						<td><b>Actor Name:</b></td>
//						<td colspan="5">«ToLink.spanActor(act.name)»</td>
//					</tr>
//					<tr>
//						<td><b>Actor ID:</b></td>
//						<td colspan="5">A«actId++»</td>
//					</tr>
//					<tr>
//						<td><b>Description:</b></td>
//						<td colspan="5">«IF act.description!==null »«act.description.replace("\"", "")»«ENDIF»</td>
//					</tr>				   
//				«IF act.superActor!==null»<tr>
//							<td><b>Super Actor:</b></td>
//							<td colspan="5">«ToLink.linkActor(act.superActor.name)»</td>
//				</tr>«ENDIF»
//				<tr>
//					<td colspan="5"><b>Required Functions</b></td>
//					<td><b>Related Use Case</b></td>
//				</tr>
//				«IF act.superActor!==null»«FOR usca:act.superActor.uc»<tr>
//							<td colspan="5">«IF usca.description!==null»«usca.description.replace("\"", "")»«ENDIF»</td>
//							<td>«ToLink.linkUC(usca.name)»</td>
//				</tr>«ENDFOR»«ENDIF»
//				«FOR usca:act.uc»<tr>
//							<td colspan="5">«IF usca.description!==null»«usca.description.replace("\"", "")»«ENDIF»</td>
//							<td>«ToLink.linkUC(usca.name)»</td>
//					</tr>
//				«ENDFOR»
//				</table>
//			«ENDFOR»
//			
//		'''
//	}

	def static generateUseCaseDescription(UseCaseModel useCaseModel) {
//		var list= new ArrayList<ArrayList<String>>();
		var ucId = 1
		'''
			«FOR usecase : useCaseModel.uc»
				<b>UC«ucId» - «usecase.name»</b>
				«IF usecase.ssd!==null»
				«IF usecase.ssd.size()!==0»
				<p>System Sequence Diagram:</p>
				 
				«ENDIF»
				«FOR sd:usecase.ssd»![«sd.name»](«citeImagePath(sd.name)»)«ENDFOR»
				 
				«ENDIF»
				<p>Use Case Description:</p>
				 
				<table>
					<tr>
						<td><b>UseCase Name:</b></td>
						<td>«ToLink.spanUC(usecase.name)»</td>
					</tr>
					<tr>
						<td><b>UseCase ID:</b></td>
						<td>UC«ucId++»</td>
					</tr>
					<tr>
						<td><b>Brief Description:</b></td>
						<td>«IF usecase.description!==null »«usecase.description.replace("\"", "")»«ENDIF»</td>
					</tr>
					<tr>
						<td><b>Involved Actor:</b></td>
					<td>«FOR act:useCaseModel.actor»«IF act.uc.contains(usecase)»«ToLink.linkActor(act.name)»«ENDIF»«ENDFOR»</td>
					</tr>
					<tr>
						<td><b>Preconditions:</b></td>
						<td><ol></ol></td>
					</tr>
					<tr>
						<td><b>Postconditions:</b></td>
						<td><ol></ol></td>
					</tr>						
					<tr>
						<td><b>Basic Path:</b></td>
					<td>«IF usecase.ssd!==null»«FOR sd:usecase.ssd»«var basicList=new ArrayList<String>»«BasicPathWrite.writeBasicpath(sd,basicList)»«FOR basic:basicList»<p>«basic»</p>«ENDFOR»«ENDFOR»«ENDIF»</td>
					</tr>
					<tr>
						<td><b>Alternative Path:</b></td>
						<td></td>
					</tr>
					</table>

			«ENDFOR»
		'''
	}

	def static generateService(UseCaseModel useCaseModel) {
		var serId=1
		'''
			«FOR ser : useCaseModel.service»
				<b>SI«serId» - «ser.name»</b>
				<table>
					<tr>
						<td><b>Service Name:</b></td>
						<td>«ToLink.spanService(ser.name)»</td>
					</tr>
					<tr>
						<td><b>Service ID:</b></td>
						<td>SI«serId++»</td>
					</tr>
					<tr>
						<td><b>Description:</b></td>
						<td>«IF ser.description!==null »«ser.description.replace("\"", "")»«ENDIF»</td>
					</tr>
					<tr>
						<td><b>Operation:</b></td>
					<td>«IF ser.operation !== null»<ul>«FOR op:ser.operation»<li>«ToLink.linkOP(op.name)»</li>«ENDFOR»</ul>«ENDIF»</td>
					</tr>
				«IF ser.temp_property !== null»«IF ser.temp_property.size()!==0»<tr>
							<td><b>Temporary Variable</b></td>
							<td><b>Variable Description</b></td>
					</tr>«FOR temp:ser.temp_property»
						<tr>
							<td>«ToLink.spanLink(temp.name,ser.name)»</td>
							<td>«temp.compileTempproperty»</td>
					</tr>«ENDFOR»«ENDIF»«ENDIF»
					</table>
					 
				«ENDFOR»
		'''
	}

	
	def static compileTempproperty(Attribute temp) {
		var ttype=temp.type
		switch ttype {
			PrimitiveTypeCS:
				'''the type of «temp.name» is «ttype.compileType»'''
			EntityType:
				if(temp.ismultiple)'''«temp.name» is a set of «ttype.compileType»'''
				else'''«temp.name» is a object of «ttype.compileType»'''
			EnumEntity: 
				'''«temp.name» has several options: «ttype.compileType»'''
		}
	}

	def static generateEntityAnalysis(DomainModel domainModel) {
		var eId = 1
		'''			
			<b>Conceptual Class Diagram</b> 
			 
			![Conceptual Class Diagram](«citeImagePath(RM2DocString.ConceptualClassDiagram)»)
			 
			«FOR e : domainModel.entity»
				<b>E«eId» - «e.name»</b>
				 
				<table>
					<tr>
						<td><b>Entity Name:</b></td>
						   <td colspan="2">«ToLink.spanClass(e.name)»</td>
					</tr>
					<tr>
						<td><b>Entity ID:</b></td>
						   <td colspan="2">E«eId++»</td>
					</tr>
					<tr>
					    <td><b>Entity Description:</b></td>
					    <td colspan="2">«IF e.description!==null »«e.description.replace("\"", "")»«ENDIF»</td>
					</tr>«IF e.superEntity!==null»
						<tr>
							<td><b>Super Entity:</b></td>
							<td colspan="2">«ToLink.linkClass(e.superEntity.name)»</td>
					</tr>«ENDIF»
					<tr>
					    <td><b>Attribute Name</b></td>
						<td><b>Attribute Type</b></td>
						<td><b>Attribute Description</b></td>
					</tr>«FOR attribute : e.attributes»
						<tr>
						    <td>«attribute.name»</td>
						<td>«attribute.type.compileType»</td>
						<td>The «attribute.name» of «e.name»</td>
					</tr>«ENDFOR»«IF !e.reference.isEmpty()»
						<tr>
						    <td><b>Relationship Name</b></td>
						<td><b>Related Entity</b></td>
						<td><b>Relationship Type</b></td>
						</tr>«FOR refer : e.reference»
							<tr>
								<td>«refer.name»</td>
								<td>«ToLink.linkClass(refer.entity.name)»</td>
								<td>«refer.type»: «IF refer.ismultiple»One-to-Many«ELSE»One-to-One«ENDIF»</td>
							</tr>«ENDFOR»«ENDIF»
					</table>
					 
				«ENDFOR»
		'''
	}

	/* For primary and enum type */
	def static String compileType(TypeCS type) {
		return CompileType.transType(type,true)
	}
	
}
