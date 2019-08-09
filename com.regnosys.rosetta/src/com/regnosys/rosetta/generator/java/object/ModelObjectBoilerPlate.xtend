package com.regnosys.rosetta.generator.java.object

import com.google.inject.Inject
import com.regnosys.rosetta.rosetta.RosettaClass
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.RosettaFeature
import java.util.Collections
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

import static extension com.regnosys.rosetta.generator.util.RosettaAttributeExtensions.*
import static extension com.regnosys.rosetta.generator.java.util.JavaClassTranslator.toJavaType
import com.regnosys.rosetta.generator.object.ExpandedAttribute

class ModelObjectBoilerPlate {

	@Inject extension ExternalHashcodeGenerator

	val toBuilder = [String s|s + 'Builder']
	val identity = [String s|s]

	def boilerPlate(RosettaClass c) '''
		«c.wrap.processMethod»
		«c.wrap.boilerPlate»
	'''

	def calculationResultBoilerPlate(String ownerName, List<RosettaFeature> features) {
		features.wrapCalculationResult(ownerName).boilerPlate
	}

	def builderBoilerPlate(RosettaClass c) '''
		«c.wrap.contributeEquals(toBuilder)»
		«c.wrap.contributeHashCode»
		«c.wrap.contributeToString(toBuilder)»
	'''

	def implementsClause(RosettaClass c) {
		implementsClause(c)[String s|s]
	}

	def implementsClause(extension RosettaClass it, (String)=>String nameFunc) {
		val interfaces = newHashSet
		
		if(globalKey)
			interfaces.add(nameFunc.apply('GlobalKey'))
			
		if(rosettaKeyValue)
			interfaces.add(nameFunc.apply('RosettaKeyValue'))
		
		if (interfaces.empty) '''''' else '''implements «interfaces.join(', ')» '''
	}

	def toType(ExpandedAttribute attribute) {
		if (attribute.isMultiple) '''List<«attribute.toTypeSingle»>''' 
		else attribute.toTypeSingle;
	}

	def toTypeSingle(ExpandedAttribute attribute) {
		if (!attribute.hasMetas) attribute.typeName.toJavaType
		else if (attribute.refIndex >= 0) {
			if (attribute.type instanceof RosettaClass)
				'''ReferenceWithMeta«attribute.typeName.toFirstUpper»'''
			else
				'''BasicReferenceWithMeta«attribute.typeName.toFirstUpper»'''
		} else
			'''FieldWithMeta«attribute.typeName.toFirstUpper»'''
	}

	private def boilerPlate(TypeData c) '''
		«c.contributeEquals(identity)»
		«c.contributeHashCode»
		«c.contributeToString(identity)»
	'''

	private def contributeHashCode(extension ExpandedAttribute it) {
		'''
			«IF enum»
				«IF list»
					_result = 31 * _result + («name» != null ? «name».stream().map(Object::getClass).map(Class::getName).mapToInt(String::hashCode).sum() : 0);
				«ELSE»
					_result = 31 * _result + («name» != null ? «name».getClass().getName().hashCode() : 0);
				«ENDIF»
			«ELSE»
				_result = 31 * _result + («name» != null ? «name».hashCode() : 0);
			«ENDIF»	
		'''
	}

	// the eventEffect attribute should not contribute to the hashcode. The EventEffect must first take the hash from Event, 
	// but once stamped onto EventEffect, this will change the hash for Event. 
	private def contributeHashCode(TypeData c) '''
		@Override
		public int hashCode() {
			int _result = «c.contribtueSuperHashCode»;
			«FOR field : c.attributes.filter[name != 'eventEffect']»
				«field.contributeHashCode»
			«ENDFOR»
			return _result;
		}
		
	'''

	private def contributeToString(TypeData c, (String)=>String classNameFunc) '''
		@Override
		public String toString() {
			return "«classNameFunc.apply(c.name)» {" +
				«FOR attribute : c.attributes.map[name] SEPARATOR ' ", " +'»
					"«attribute»=" + this.«attribute» +
				«ENDFOR»
			'}'«IF c.hasSuperType» + " " + super.toString()«ENDIF»;
		}
	'''

	// the eventEffect attribute should not contribute to the hashcode. The EventEffect must first take the hash from Event, 
	// but once stamped onto EventEffect, this will change the hash for Event. TODO: Have generic way of excluding attributes from the hash
	private def contributeEquals(TypeData c, (String)=>String classNameFunc) '''
		@Override
		public boolean equals(Object o) {
			if (this == o) return true;
			if (o == null || getClass() != o.getClass()) return false;
			«IF c.hasSuperType»
				if (!super.equals(o)) return false;
			«ENDIF»
		
			«classNameFunc.apply(c.name)» _that = («classNameFunc.apply(c.name)») o;
		
			«FOR field : c.attributes.filter[s | s.name != 'eventEffect']»
				«field.contributeToEquals»
			«ENDFOR»
			return true;
		}
		
	'''

	private def contributeToEquals(ExpandedAttribute a) '''
	«IF a.cardinalityIsListValue»
		if (!ListEquals.listEquals(«a.name», _that.«a.name»)) return false;
	«ELSE»
		if («a.name» != null ? !«a.name».equals(_that.«a.name») : _that.«a.name» != null) return false;
	«ENDIF»
	'''

	private def contribtueSuperHashCode(TypeData c) {
		if(c.hasSuperType) 'super.hashCode()' else '0'
	}

	private def TypeData wrap(RosettaClass rosettaClass) {
		return new TypeData(
			rosettaClass.name,
			rosettaClass.expandedAttributes,
			rosettaClass.superType !== null,
			rosettaClass,
			true
		);
	}

	private def TypeData wrapCalculationResult(List<RosettaFeature> features, String typeName) {
		return new TypeData(typeName, features.map [
			new ExpandedAttribute(null, getNameOrDefault, type, typeName, 0, 1, list, Collections.emptyList, null,
				false, it == RosettaEnumeration, false, Collections.emptyList)
		], false, null, false);
	}

	// the eventEffect attribute should not contribute to the rosettaKeyValueHashCode. 
	// TODO: Have generic way of excluding attributes from the hash
	static def boolean isIncludedInRosettaKeyValueHashCode(ExpandedAttribute a) {
		return !( a.hasCalculation || a.isQualified || a.name == 'eventEffect' || a.name == 'globalKey')
	}

	@Data
	static class TypeData {
		val String name
		val List<ExpandedAttribute> attributes
		val boolean hasSuperType
		val RosettaClass rosettaClass
		val boolean generateRosettaKeyValueHashCode
	}
}