/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.validation

import com.google.inject.Inject
import com.regnosys.rosetta.rosetta.RosettaDataRule
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import com.regnosys.rosetta.tests.util.ModelHelper
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static com.regnosys.rosetta.rosetta.RosettaPackage.Literals.*
import static com.regnosys.rosetta.rosetta.simple.SimplePackage.Literals.*
import com.regnosys.rosetta.rosetta.simple.Condition

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class RosettaValidatorTest implements RosettaIssueCodes {

	@Inject extension ValidationTestHelper
	@Inject extension ModelHelper
	
	@Test
	def void testLowerCaseClass() {
		val model =
		'''
			type partyIdentifier: <"">
				partyId string (1..1) <"">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
		'''.parseRosettaWithNoErrors
		model.assertWarning(DATA, INVALID_CASE,
            "Type name should start with a capital")
	}
	
	@Test
	def void testLowerCaseEnumeration() {
		val model =
		'''
			enum quoteRejectReasonEnum: <"">
				UnknownSymbol
				Other
		'''.parseRosettaWithNoErrors
		model.assertWarning(ROSETTA_ENUMERATION, INVALID_CASE,
            "Enumeration name should start with a capital")
	}
	
	@Test
	def void testUpperCaseAttribute() {
		val model =
		'''
			type PartyIdentifier: <"">
					PartyId string (1..1) <"">
						[synonym FIX value "PartyID" tag 448]
						[synonym FpML value "partyId"]
		'''.parseRosettaWithNoErrors
		model.assertWarning(ATTRIBUTE, INVALID_CASE,
            "Attribute name should start with a lower case")
	}
	
	@Test
	def void testLowerCaseDataRule() {
		val model = 
		'''
			data rule quote <"">
				when Foo exists
				then Bar exists
					
			class Foo{
			}
			
			class Bar{
			}
		'''.parseRosettaWithNoErrors
		model.assertWarning(ROSETTA_DATA_RULE, INVALID_CASE,
			"Rule name should start with a capital")
	}
	
	@Test
	def void testLowerCaseProductQualifier() {
		val model = 
		'''
			isProduct bar
				EconomicTerms -> economic exists
					
			type EconomicTerms:
				economic string (1..1)
		'''.parseRosettaWithNoErrors
		model.assertWarning(ROSETTA_PRODUCT, INVALID_CASE,
			"Product qualifier name should start with a capital")
	}
	
	@Test
	def void testLowerCaseWorkflowRule() {
		val model = 
		'''
			workflow rule quote <"Bla">
				Foo precedes Bar
					
			type Foo:
			
			type Bar:
		'''.parseRosettaWithNoErrors
		model.assertWarning(ROSETTA_WORKFLOW_RULE, INVALID_CASE,
			"Workflow rule name should start with a capital")
	}
	
	@Test
	def void testInconsistentCommonAttributeType() {
		val model =
		'''
			type Foo:
				id int (1..1)
			type Bar:
				id boolean (1..1)
			
			workflow rule WorkflowRule
			Foo precedes Bar
			commonId id
		'''.parseRosetta
		model.assertError(ROSETTA_TREE_NODE, TYPE_ERROR, 
			"Attribute 'id' of class 'Bar' is of type 'boolean' (expected 'int')")
	}
	
	@Test
	def void testMissingCommonAttribute() {
		val model =
		'''
			type Foo:
				id int (1..1)
			type Bar: <"">
			
			workflow rule
			WorkflowRule
			Foo precedes Bar
			commonId id
		'''.parseRosetta
		model.assertError(ROSETTA_TREE_NODE, MISSING_ATTRIBUTE, 
			"Class 'Bar' does not have an attribute")
	}
	
	@Test
	def void testTypeExpectation() {
		val model =
		'''
			type Foo:
				id int (1..1)
			
				condition R: 
					if id = True
					then id < 1
		'''.parseRosetta
		model.assertError(ROSETTA_CONDITIONAL_EXPRESSION, TYPE_ERROR, 
			"Incompatible types: cannot use operator '=' with int and boolean.")
	}
	
	@Test
	def void testTypeExpectationMagicType() {
		'''
			qualifiedType productType {}
			type Foo:
				id productType (1..1)
				val int (1..1)
			
			condition R:
				if  id = "Type"
				then val < 1
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testTypeExpectationNoError() {
		val model =
		'''
			type Foo:
				id int (1..1)
			
			condition R:
				if id = 1
				then id < 1
		'''.parseRosettaWithNoErrors
		model.assertNoError(TYPE_ERROR)
	}
	
	@Test
	def void testTypeExpectationError() {
		val model =
		'''
			type Foo:
				id boolean (1..1)
			condition R:
				if id = True
				then id < 1
		'''.parseRosetta
		model.assertError(ROSETTA_CONDITIONAL_EXPRESSION, TYPE_ERROR, "Incompatible types: cannot use operator '<' with boolean and int.")
	}
	
	@Test
	def void testTypeErrorAssignment_01() {
		val model =
		'''
			namespace "test"
			version "test"
			
			type Foo:
				id boolean (1..1)
			
			func Test:
				inputs: in0 Foo (0..1)
				output: out Foo (0..1)
				assign-output out:
					"not a Foo"
		'''.parseRosetta
		model.assertError(OPERATION, TYPE_ERROR, "Expected type 'Foo' but was 'string'")
	}
	
	
	@Test
	def void testTypeErrorAssignment_02() {
		val model =
		'''
			namespace "test"
			version "test"
			
			type Foo:
				id boolean (1..1)
			
			func Test:
				inputs: in0 Foo (0..1)
				output: out Foo (0..1)
				assign-output out -> id:
					"not a boolean"
		'''.parseRosetta
		model.assertError(OPERATION, TYPE_ERROR, "Expected type 'boolean' but was 'string'")
	}
	
	@Test
	def void testTypeErrorAssignment_03() {
		val model =
		'''
			type WithKey:
				[metadata key]
			
			type TypeToUse:
				attr WithKey (0..1)
				[metadata reference]
			
			func Bar:
			  inputs:
			    in1 TypeToUse (1..1)
			  output: result TypeToUse (1..1)
			  assign-output result -> attr:
			     in1 as-key
		'''.parseRosetta
		model.assertError(OPERATION, TYPE_ERROR, "Expected type 'WithKey' but was 'TypeToUse'")
	}
	
	@Test
	def void testTypeErrorAssignment_04() {
		val model =
		'''
			namespace "test"
			version "test"

			enum Enumerate : X Y Z

			type Type:
				other Enumerate (0..1)

			func Funcy:
				inputs: in0 Type (0..1)
				output: out string (0..1)
				alias Ali : in0 -> other = Enumerate -> X
		'''.parseRosetta
		model.assertNoErrors
	}

	@Test
	def void testCardinalityErrorAssignment_01() {
		val model =
		'''
			type WithMeta:
				[metadata key]

			type OtherType:
				attrSingle WithMeta (0..1)
				[metadata reference]
				attrMulti WithMeta (0..*)
				[metadata reference]

			func asKeyUsage:
				inputs: withMeta WithMeta(0..*)
				output: out OtherType (0..1)
				assign-output out -> attrMulti[1]:
					withMeta as-key
		'''.parseRosetta
		model.assertError(OPERATION, null, "Expecting single cardinality as value. Use 'only-element' to assign only first value.")
	}

	@Test
	def void testDuplicateAttribute() {
		val model = '''
			type Foo:
				i int (1..1)
			
			type Bar extends Foo:
				i int (1..1)
		'''.parseRosetta
		model.assertError(ATTRIBUTE, DUPLICATE_ATTRIBUTE, 'Duplicate attribute')
	}

	@Test
	def void testDuplicateEnumLiteral() {
		val model = '''
			enum Foo:
				BAR BAZ BAR
		'''.parseRosetta
		model.assertError(ROSETTA_ENUM_VALUE, DUPLICATE_ENUM_VALUE, 'Duplicate enum value')
	}
	
	@Test 
	def void testDuplicateType() {
		val model = '''
			type Bar:
			
			type Foo:
			
			enum Foo: BAR
		'''.parseRosetta
		model.assertError(ROSETTA_TYPE, DUPLICATE_ELEMENT_NAME, 'Duplicate element name')
	}
	
	@Test
	def void testDuplicateDataRule_ClassName() {
		val model = '''
			class Foo {
			}
			
			data rule Foo
				when Foo exists
				then Foo must exist
		'''.parseRosetta
		model.assertError(ROSETTA_DATA_RULE, DUPLICATE_ELEMENT_NAME, 'Duplicate element name')
	}
	
	@Test
	def void testDuplicateDataRule_EnumName() {
		val model = '''
			class Foo {
			}
			
			enum Bar:
				Entry
			
			data rule Bar
				when Foo exists
				then Foo must exist
		'''.parseRosetta
		model.assertError(ROSETTA_DATA_RULE, DUPLICATE_ELEMENT_NAME, 'Duplicate element name')
	}
	
	@Test
	def void testDuplicateWorkflowRule_ClassName() {
		val model = '''
			type Foo:
			
			type Bar:
			
			workflow rule Foo
				Foo must precede Bar
		'''.parseRosetta
		model.assertError(ROSETTA_WORKFLOW_RULE, DUPLICATE_ELEMENT_NAME, 'Duplicate element name')
	}
	
	@Test
	def void testDuplicateWorkflowRule_EnumName() {
		val model = '''
			enum Foo: Entry
			
			type Bar:
			
			type Baz:
			
			workflow rule Foo
				Bar must precede Baz
		'''.parseRosetta
		model.assertError(ROSETTA_WORKFLOW_RULE, DUPLICATE_ELEMENT_NAME, 'Duplicate element name')
	}
	
	@Test
	def void testDuplicateChoiceRuleAttribute_thisOne() {
		val model = '''
			type Bar:
				attribute1 string (0..1)
				attribute2 string (0..1)
				attribute3 string (0..1)
			
				condition Foo:
					required choice
					attribute1, attribute1
		'''.parseRosetta
		model.assertError(CONDITION, DUPLICATE_CHOICE_RULE_ATTRIBUTE, 'Duplicate attribute')
	}
	
	@Test
	def void testDuplicateChoiceRuleAttribute_thatOne() {
		val model = '''
			type Bar:
				attribute1 string (0..1)
				attribute2 string (0..1)
				attribute3 string (0..1)
			
			condition Foo:
				required choice attribute1 , attribute2 , attribute2
		'''.parseRosetta
		model.assertError(CONDITION, DUPLICATE_CHOICE_RULE_ATTRIBUTE, 'Duplicate attribute')
	}
	
	@Test
	def void testClassWithChoiceRuleAndOneOfRule() {
		val model = '''
			type Foo:
				attribute1 string (0..1)
				attribute2 string (0..1)
				attribute3 string (0..1)
			
				condition Foo_oneOfRule: one-of
				condition Foo_choiceRule:
					required choice
						attribute1, attribute2
		'''.parseRosetta
		model.assertError(DATA, CLASS_WITH_CHOICE_RULE_AND_ONE_OF_RULE, 'Type Foo has both choice condition and one-of condition.')
	}


 	@Test
	def checkMappingMultipleSetToWithoutWhenCases() {
		val model = '''
			type Quote:
				attr int (1..1)
					[synonym FIX 
							set to 1,
							set to 2]
		'''.parseRosetta
		model.assertError(ROSETTA_MAPPING, null, "Only one set to with no when clause allowed.")
	}
	
	@Test
	def checkMappingMultipleSetToOrdering() {
		val model = '''
			type Quote:
				attr int (1..1)
					[synonym FIX 
							set to 1,
							set to 2 when "a.b.c" exists]
		'''.parseRosetta
		model.assertError(ROSETTA_MAPPING, null, "Set to without when case must be ordered last.")
	}
	
	@Test
	def checkMappingSetToTypeCheck() {
		val model = '''
			type Foo:
				value0 string (1..1)
			
			type Quote:
				attr Foo (1..1)
					[synonym FIX 
							set to "hello"]
		'''.parseRosetta
		model.assertError(ROSETTA_MAPPING, null, "Set to constant type does not match type of field.")
	}
	
	@Test
	def checkMappingSetToEnumTypeCheck() {
		val model = '''
			enum Foo: ONE
			

			enum Bar: BAR
			
			type Quote:
				attr Foo (1..1)
					[synonym FIX 
							set to Bar.BAR]
		'''.parseRosetta
		model.assertError(ROSETTA_MAPPING, null, "Set to constant type does not match type of field.")
	}
	
	@Test
	def checkMappingSetToWhenTypeCheck() {
		val model = '''
			type Foo:
				stringVal string (1..1)
			
			type Quote:
				attr Foo (1..1)
					[synonym FpML value "foo" set when "foo->bar" exists]
		'''.parseRosetta
		model.assertNoErrors
	}
	
	@Test
	def checkOperationTypes() {
	val model = '''
			class Clazz {
				test boolean (0..1);
			}
			data rule DataRule
				when 
					Clazz -> test = True 
					or False <> False
					or 1 > 0
					or 1 < 0
					or 1 >= 0
					or 1 <= 0
					or 1 <> 0
					or 1 = 0
				then 1.1 = .0
					and 0.2 <> 0.1
					and 0.2 > 0.1
					and 0.2 < 0.1
					and 0.2 <= 0.1
					and 0.2 >= 0.1
		'''.parseRosetta
		model.assertNoErrors
	}

	@Test
	def checkValidIsProductClassPath() {
		val model = '''
			type Foo:
				foo string (1..1)
			type Bar:
				bar Foo (0..1)
			
			isProduct FooBar
				Foo -> foo
				and Bar -> bar -> foo
		'''.parseRosetta
		model.assertError(ROSETTA_PRODUCT, MULIPLE_CLASS_REFERENCES_DEFINED_FOR_ROSETTA_QUALIFIABLE, 
			'isProduct "FooBar" has multiple class references Foo, Bar. isProduct expressions should always start from the same class')
	}
	
	@Test
	def checkValidIsProductClass() {
		val model = '''
			isProduct root Foo;
			
			type Foo:
				foo string (1..1)
			type Bar:
				bar Foo (0..1)
			isProduct FooBar
				Bar -> bar -> foo
		'''.parseRosetta
		model.assertError(ROSETTA_PRODUCT, MULIPLE_CLASS_REFERENCES_DEFINED_FOR_ROSETTA_QUALIFIABLE, 
			"isProduct expressions should always start from the 'Foo' class. But found 'Bar'.")
	}
	
	@Test
	def void testUpperCaseAlias() {
		val model =
		'''
			type Bar:
				bar string (0..1)
			
			alias Foo
				Bar -> bar
		'''.parseRosettaWithNoErrors
		model.assertWarning(ROSETTA_ALIAS, INVALID_CASE,
            "Alias name should start with a lower case")
	}
	
	
	@Test
	def checkDateZonedDateTypes() {
		val model = '''
			recordType date{}
			recordType zonedDateTime{}
			
			func Foo:
			  inputs:
			    timestamp zonedDateTime (1..1)
			  output: result date (1..1)
			
			func Bar:
			  inputs:
			    timestamp date (1..1)
			  output: result boolean (1..1)
			  assign-output result:
			     Foo(timestamp) = timestamp
			
		'''.parseRosetta
		model.assertError(ROSETTA_CALLABLE_WITH_ARGS_CALL, TYPE_ERROR, 
			"Expected type 'zonedDateTime' but was 'date'")
	}
	
	@Test
	def checkAsKeyUsage_01() {
		val model = '''
			type WithKey:
				[metadata key]
			
			type TypeToUse:
				attr WithKey (0..1)
				[metadata reference]
			
			func Bar:
			  inputs:
			    in0 WithKey (1..1)
			  output: result TypeToUse (1..1)
			  assign-output result -> attr:
			     in0 as-key
		'''.parseRosetta
		model.assertNoErrors
	}
	
	@Test
	def checkAsKeyUsage_02() {
		val model = '''
			type WithKey:
				[metadata key]
			
			type TypeToUse:
				attr WithKey (0..1)
				[metadata reference]
				attr2 TypeToUse (0..1)
			
			func Bar:
			  inputs:
			    in0 WithKey (1..1)
			    in1 TypeToUse (1..1)
			  output: result TypeToUse (1..1)
			  assign-output result -> attr2:
			     in1 as-key
		'''.parseRosetta
		model.assertError(SEGMENT, null,
			"'as-key' can only be used with attributes annotated with [metadata reference] annotation.")
	}
	
	@Test
	def checkAsKeyUsage_03() {
		val model = '''
			type WithKey:
			
			type TypeToUse:
				attr WithKey (0..1)
				[metadata reference]
		'''.parseRosetta
		model.assertWarning(ATTRIBUTE, null,
			"WithKey must be annotated with [metadata key] as reference annotation is used")
	}
	
	@Test
	def checkAsKeyUsage_04() {
		val model = '''
			type WithKey:
				[metadata key]
			
			type TypeToUse:
				attr WithKey (0..1)
				[metadata reference]
			
			func Bar:
			  inputs:
			    in0 WithKey (1..1)
			  output: result WithKey (1..1)
			  assign-output result:
			     in0 as-key
		'''.parseRosetta
		model.assertError(OPERATION, null,
			"'as-key' can only be used when assigning an attribute. Example: \"assign-output out -> attribute: value as-key\"")
	}
	
	@Test
	def checkSynonymPathSyntax_01() {
		val model = '''
			type TypeToUse:
				attr string (0..1)
				[synonym FpML value "adjustedDate" path "relative.date" meta id]
		'''.parseRosetta
		model.assertError(ROSETTA_SYNONYM_VALUE_BASE, null,
			"Dot is not allowed in paths. Use '->' to separate path segments.")
	}

	@Test
	def checkSynonymPathSyntax_02() {
		val model = '''
			type TypeToUse:
				attr string (0..1)
				[synonym FpML set to "Custom" when "Pty.Src" = "D"]
		'''.parseRosetta
		model.assertError(ROSETTA_MAP_PATH_VALUE, null,
			"Dot is not allowed in paths. Use '->' to separate path segments.")
	}
}
