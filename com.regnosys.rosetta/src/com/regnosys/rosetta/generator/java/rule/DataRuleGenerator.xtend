package com.regnosys.rosetta.generator.java.rule

import com.google.common.base.CaseFormat
import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.generator.java.RosettaJavaPackages
import com.regnosys.rosetta.generator.java.expression.RosettaExpressionJavaGenerator
import com.regnosys.rosetta.generator.java.expression.RosettaExpressionJavaGenerator.ParamMap
import com.regnosys.rosetta.generator.java.util.ImportGenerator
import com.regnosys.rosetta.generator.java.util.RosettaGrammarUtil
import com.regnosys.rosetta.rosetta.RosettaCallableCall
import com.regnosys.rosetta.rosetta.RosettaClass
import com.regnosys.rosetta.rosetta.RosettaDataRule
import com.regnosys.rosetta.rosetta.RosettaRootElement
import java.util.List
import org.eclipse.xtext.generator.IFileSystemAccess2

import static com.regnosys.rosetta.generator.java.util.ModelGeneratorUtil.*

class DataRuleGenerator {

	
	def generate(RosettaJavaPackages packages, IFileSystemAccess2 fsa, List<RosettaRootElement> elements, String version) {
		elements.filter(RosettaDataRule).forEach [
			fsa.generateFile('''«packages.dataRule.directoryName»/«dataRuleClassName(name)».java''', toJava(packages, version))
		]
	}

	def static String dataRuleClassName(String dataRuleName) {
		val allUnderscore = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, dataRuleName)
		val camel = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, allUnderscore)
		if (camel.endsWith('Data'))
			return camel +'Rule'
		if (camel.endsWith('DataRule'))
			return camel
		if (camel.endsWith('Rule'))
			return camel.substring(0, camel.lastIndexOf('Rule')) + 'DataRule'
		return camel + 'DataRule'
	}

	private def toJava(RosettaDataRule rule, RosettaJavaPackages packages, String version) {
		val rosettaClass = rosettaClassForRule(rule)
		val expressionHandler = new RosettaExpressionJavaGenerator()
		toJava(packages, rule, rosettaClass, expressionHandler, version)
	}
	
	private def static rosettaClassForRule(RosettaDataRule rule) {
		val rosettaClasses = newHashSet
		val extensions = new RosettaExtensions
		rule.when.eAllContents.filter(RosettaCallableCall).forEach[
			extensions.collectRootCalls(it, [if(it instanceof RosettaClass) rosettaClasses.add(it)])
		]
		if (rosettaClasses.size > 1) {
			throw new IllegalStateException(rule.name + ' compile failed. Found more then one class reference ' + rosettaClasses.map[name] + ' for this rule ' + rule.name)
		}
		if (rosettaClasses.size < 1) {
			throw new IllegalStateException(rule.name + ' compile failed. Found any class reference ' + rosettaClasses.map[name] + ' for this rule ' + rule.name)
		}
		
		return rosettaClasses.get(0)
	}
		
	private def toJava(RosettaJavaPackages packages, RosettaDataRule rule, RosettaClass rosettaClass, RosettaExpressionJavaGenerator expressionHandler, String version)  {
	val definition = RosettaGrammarUtil.quote(RosettaGrammarUtil.grammarWhenThen(rule.when, rule.then) );
	val imports = new ImportGenerator(packages)
	imports.addRule(rule)
	return '''
		package «packages.dataRule.packageName»;
		
		«FOR importClass : imports.imports.filter[imports.isImportable(it)]»
		import «importClass»;
		«ENDFOR»
		
		«FOR importClass : imports.staticImports»
		import static «importClass».*;
		«ENDFOR»

		«emptyJavadocWithVersion(version)»
		@RosettaDataRule("«rule.name»")
		public class «dataRuleClassName(rule.name)» implements Validator<«rosettaClass.name»> {
			
			private static final String NAME = "«rule.name»";
			private static final String DEFINITION = «definition»;
			
			@Override
			public ValidationResult<«rosettaClass.name»> validate(RosettaPath path, «rosettaClass.name» «rosettaClass.name.toFirstLower») {
				ComparisonResult result = executeDataRule(«rosettaClass.name.toFirstLower»);
				if (result.get()) {
					return ValidationResult.success(NAME, ValidationResult.ValidationType.DATA_RULE,  "«rosettaClass.name»", path, DEFINITION);
				}
				
				return ValidationResult.failure(NAME, ValidationResult.ValidationType.DATA_RULE, "«rosettaClass.name»", path, DEFINITION, result.getError());
			}
			
			@Override
			public ValidationResult<«rosettaClass.name»> validate(RosettaPath path, RosettaModelObjectBuilder «rosettaClass.name.toFirstLower») {
				ComparisonResult result = executeDataRule((«rosettaClass.name»)«rosettaClass.name.toFirstLower».build());
				if (result.get()) {
					return ValidationResult.success(NAME, ValidationResult.ValidationType.DATA_RULE, "«rosettaClass.name»", path, DEFINITION);
				}
				
				return ValidationResult.failure(NAME, ValidationResult.ValidationType.DATA_RULE,  "«rosettaClass.name»", path, DEFINITION, result.getError());
			}
			
			private ComparisonResult executeDataRule(«rosettaClass.name» «rosettaClass.name.toFirstLower») {
				if (ruleIsApplicable(«rosettaClass.name.toFirstLower»).get()) {
					return evaluateThenExpression(«rosettaClass.name.toFirstLower»);
				}
				return ComparisonResult.success();
			}
			
			private ComparisonResult ruleIsApplicable(«rosettaClass.name» «rosettaClass.name.toFirstLower») {
				return «expressionHandler.javaCode(rule.when, new ParamMap(rosettaClass))»;
			}
			
			private ComparisonResult evaluateThenExpression(«rosettaClass.name» «rosettaClass.name.toFirstLower») {
				return «expressionHandler.javaCode(rule.then, new ParamMap(rosettaClass))»;
			}
		}
	'''
	}
}
