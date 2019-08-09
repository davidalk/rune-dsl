package com.regnosys.rosetta.generator.util

import com.google.common.collect.Iterables
import com.regnosys.rosetta.generator.object.ExpandedAttribute
import com.regnosys.rosetta.generator.object.ExpandedSynonym
import com.regnosys.rosetta.generator.object.ExpandedSynonymValue
import com.regnosys.rosetta.rosetta.RosettaAttributeBase
import com.regnosys.rosetta.rosetta.RosettaCalculationType
import com.regnosys.rosetta.rosetta.RosettaClass
import com.regnosys.rosetta.rosetta.RosettaClassSynonym
import com.regnosys.rosetta.rosetta.RosettaEnumSynonym
import com.regnosys.rosetta.rosetta.RosettaEnumValue
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.RosettaExternalClass
import com.regnosys.rosetta.rosetta.RosettaExternalRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaExternalSynonym
import com.regnosys.rosetta.rosetta.RosettaExternalSynonymSource
import com.regnosys.rosetta.rosetta.RosettaFactory
import com.regnosys.rosetta.rosetta.RosettaFeature
import com.regnosys.rosetta.rosetta.RosettaQualifiedType
import com.regnosys.rosetta.rosetta.RosettaRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaSynonym
import com.regnosys.rosetta.rosetta.RosettaSynonymBase
import com.regnosys.rosetta.rosetta.RosettaSynonymValue
import com.regnosys.rosetta.rosetta.RosettaType
import java.util.ArrayList
import java.util.Collections
import java.util.List
import java.util.Set

class RosettaAttributeExtensions {
	static def boolean cardinalityIsSingleValue(RosettaAttributeBase attribute) {
		return (attribute as RosettaRegularAttribute).card.sup === 1
	}
	
	static def boolean cardinalityIsListValue(RosettaAttributeBase attribute) {
		attribute.cardinalityIsSingleValue != true
	}
	
	static def boolean cardinalityIsSingleValue(ExpandedAttribute attribute) {
		attribute.sup === 1
	}
	
	static def boolean cardinalityIsListValue(ExpandedAttribute attribute) {
		attribute.cardinalityIsSingleValue != true
	}
	
	static def List<ExpandedAttribute> getExpandedAttributes(RosettaClass rosettaClass) {
		Iterables.concat(
			rosettaClass.regularAttributes.expandedAttributes,
			rosettaClass.materialiseAttributes.expandedAttributes
		).toList.sortBy[ExpandedAttribute a|a.name]
	}
	
	static def List<ExpandedAttribute> getExpandedAttributes(Set<RosettaClass> classes) {
		classes.flatMap[expandedAttributes].toList.sortBy[name]
	}
	
	private static def provideMetaFeildsType() {
		val metaFields = RosettaFactory.eINSTANCE.createRosettaClass
		metaFields.name = 'MetaFields' 
		return metaFields
	}

	private static def provideStringType() {
		val stringType = RosettaFactory.eINSTANCE.createRosettaBasicType
		stringType.name = 'string'
		return stringType
	}

	private static def provideOptionalCardinality() {
		val single = RosettaFactory.eINSTANCE.createRosettaCardinality
		single.inf = 0
		single.sup = 1
		return single
	}

	private static def provideSingleCardinality() {
		val single = RosettaFactory.eINSTANCE.createRosettaCardinality
		single.inf = 1
		single.sup = 1
		return single
	}
	
	static def List<RosettaRegularAttribute> materialiseAttributes(RosettaClass rosettaClass) {

		val metaFields = RosettaFactory.eINSTANCE.createRosettaRegularAttribute
		metaFields.name = 'meta'
		metaFields.type = provideMetaFeildsType
		metaFields.card = provideOptionalCardinality
		
		val rosettaKeyValue = RosettaFactory.eINSTANCE.createRosettaRegularAttribute
		rosettaKeyValue.name = 'rosettaKeyValue'
		rosettaKeyValue.type = provideStringType
		rosettaKeyValue.card = provideSingleCardinality
				
		val materialisedAttributes = newLinkedList
		
		if(rosettaClass.rosettaKeyValue) materialisedAttributes.add(rosettaKeyValue)
		if(rosettaClass.globalKey) materialisedAttributes.add(metaFields)
		
		return materialisedAttributes
	}
	
	static def List<ExpandedAttribute> getExpandedAttributes(RosettaEnumeration rosettaEnum) {
		rosettaEnum.enumValues.map[expandedEnumAttribute]
	}
	
	def static ExpandedAttribute expandedEnumAttribute(RosettaEnumValue value) {
		new ExpandedAttribute((value.eContainer as RosettaType), value.name, null, null, 0,0, false, value.enumSynonyms.map[toExpandedSynonym], 
			value.definition, false, true, false, Collections.emptyList
		)
	}
	
	def static ExpandedSynonym toExpandedSynonym(RosettaEnumSynonym syn) {
		new ExpandedSynonym(syn.sources, Collections.singletonList(new ExpandedSynonymValue(syn.synonymValue, null, 0, false)), newArrayList, Collections.emptyList, null, null)
	}

	static def boolean isList(ExpandedAttribute a) {
		return a.cardinalityIsListValue
	}

	static def boolean isList(RosettaFeature f) {
		if (f instanceof RosettaRegularAttribute)
			return f.card.isIsMany
		else
			return false
	}	
	
	private static def List<ExpandedAttribute> getExpandedAttributes(List<RosettaRegularAttribute> attributes) {
		val List<ExpandedAttribute> attribs = newArrayList
		for (attr : attributes) {
			val List<ExpandedAttribute> metas = newArrayList
			for (var i = 0; i < attr.metaTypes.size; i++) {
				val meta = Iterables.get(attr.metaTypes, i)
				metas.add(new ExpandedAttribute((attr.eContainer as RosettaType),meta.name, meta.type, meta.type.name, 0, 1,	false, 
					attr.toRosettaExpandedSynonym(i), attr.definition, false, false, false, Collections.emptyList
				))
			}
			attribs.add(attr.toExpandedAttribute(metas))
		}
		return attribs
	}
	
	private static def toRosettaExpandedSynonym(RosettaRegularAttribute attr, int index) {
		attr.synonyms.filter[metaValues.size > index].map[
			s|new ExpandedSynonym(s.sources, s.body.values?.map[metaSynValue(s.metaValues.get(index))
				//new ExpandedSynonymValue(s.metaValues.get(index), path+"."+value, maps, true)
			].toList, s.body.hints, s.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], s.body.mappingLogic, s.mapper)
		]
		.filter[!values.isEmpty]
		.toList
	}

	static def toExpandedAttribute(RosettaRegularAttribute attr, List<ExpandedAttribute> metas) {
		new ExpandedAttribute(
			(attr.eContainer as RosettaType),
			attr.name,
			attr.type,
			attr.type.name,
			attr.card.inf,
			attr.card.sup,
			attr.card.unbounded,
			attr.synonyms.toRosettaExpandedSynonyms(-1),
			attr.definition,
			attr.calculation,
			attr.isEnumeration,
			attr.qualified,
			metas
		)
	}
	
	static def toRosettaExpandedSynonyms(List<RosettaSynonym> synonyms, int meta) {
		if (meta<0) {
			synonyms.map[new ExpandedSynonym(sources, body.values?.map[new ExpandedSynonymValue(name, path, maps, false)], body.hints, 
				metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], body.mappingLogic, mapper
			)]
		} else {
			synonyms.filter[metaValues.size>meta]
			.map[s|new ExpandedSynonym(s.sources, s.body.values?.map[metaSynValue(s.metaValues.get(meta))], s.body.hints, 
				s.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], s.body.mappingLogic, s.mapper
			)]
			.toList
		}
		
	}
	
	def static metaSynValue(RosettaSynonymValue value, String meta) {
		val path = if (value.path===null) value.name else value.path+"."+value.name
		val name = meta
		return new ExpandedSynonymValue(name, path, value.maps, true)
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaSynonymBase synonym) {
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaSynonym syn) {
		new ExpandedSynonym(syn.sources, syn.body.values?.map[new ExpandedSynonymValue(name, path, maps, false)], 
			syn.body.hints, syn.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], syn.body.mappingLogic, syn.mapper
		)
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaExternalSynonym syn) {
		val externalAttr = syn.eContainer as RosettaExternalRegularAttribute;
		val externalClass = externalAttr.eContainer as RosettaExternalClass
		val externalSynonymSource = externalClass.eContainer as RosettaExternalSynonymSource
		val superSynonym = externalSynonymSource.superSynonym;
		
		val sources = new ArrayList
		sources.add(externalSynonymSource)
		if  (superSynonym !== null) {
			sources.add(superSynonym)
		}
		
		new ExpandedSynonym(sources, syn.body.values?.map[new ExpandedSynonymValue(name, path, maps, false)], syn.body.hints, new ArrayList, syn.body.mappingLogic, null)
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaClassSynonym syn) {
		val synVals = if (syn.value===null) Collections.emptyList else newArrayList(new ExpandedSynonymValue(syn.value.name, syn.value.path, syn.value.maps, false))
		val synMetaVals = if (syn.metaValue!==null) newArrayList(new ExpandedSynonymValue(syn.metaValue.name, syn.metaValue.path, syn.metaValue.maps, true)) else Collections.emptyList
		new ExpandedSynonym(syn.sources, synVals, newArrayList, synMetaVals, null, null)
	}

	private def static boolean isCalculation(RosettaRegularAttribute a) {
		return a.type instanceof RosettaCalculationType
	}

	private def static boolean isEnumeration(RosettaRegularAttribute a) {
		return a.type instanceof RosettaEnumeration
	}

	private def static boolean isQualified(RosettaRegularAttribute a) {
		return a.type instanceof RosettaQualifiedType
	}
	
}