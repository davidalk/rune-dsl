/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.formatting2

import com.regnosys.rosetta.rosetta.RosettaChoiceRule
import com.regnosys.rosetta.rosetta.RosettaClass
import com.regnosys.rosetta.rosetta.RosettaClassSynonym
import com.regnosys.rosetta.rosetta.RosettaContainsExpression
import com.regnosys.rosetta.rosetta.RosettaDataRule
import com.regnosys.rosetta.rosetta.RosettaEnumSynonym
import com.regnosys.rosetta.rosetta.RosettaEnumValue
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.RosettaExistsExpression
import com.regnosys.rosetta.rosetta.RosettaExpression
import com.regnosys.rosetta.rosetta.RosettaExternalClass
import com.regnosys.rosetta.rosetta.RosettaExternalRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaExternalSynonym
import com.regnosys.rosetta.rosetta.RosettaExternalSynonymSource
import com.regnosys.rosetta.rosetta.RosettaFeatureCall
import com.regnosys.rosetta.rosetta.RosettaGroupByFeatureCall
import com.regnosys.rosetta.rosetta.RosettaHeader
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.RosettaRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaRegulatoryReference
import com.regnosys.rosetta.rosetta.RosettaStereotype
import com.regnosys.rosetta.rosetta.RosettaSynonym
import com.regnosys.rosetta.rosetta.RosettaTreeNode
import com.regnosys.rosetta.rosetta.RosettaWorkflowRule
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.regionaccess.ISemanticRegion

class RosettaFormatter extends AbstractFormatter2 {

	def dispatch void format(RosettaModel rosettaModel, extension IFormattableDocument document) {
		rosettaModel.header.format
		formatChild(rosettaModel.elements, document)
	}

	def dispatch void format(RosettaHeader rosettaHeader, extension IFormattableDocument document) {
		rosettaHeader.regionFor.keyword('version').prepend[newLine]
		rosettaHeader.append[setNewLines(2)]
	}

	def dispatch void format(RosettaClass rosettaClass, extension IFormattableDocument document) {
		indentedBraces(rosettaClass, document)
		rosettaClass.getStereotype.format;
		formatChild(rosettaClass.synonyms, document)
		formatChild(rosettaClass.references, document)
		formatChild(rosettaClass.regularAttributes, document)
	}

	def dispatch void format(RosettaRegularAttribute rosettaAttribute, extension IFormattableDocument document) {
		rosettaAttribute.prepend[newLine].append[newLine]
		formatChild(rosettaAttribute.synonyms, document)
		formatChild(rosettaAttribute.references, document)
	}

	def dispatch void format(RosettaStereotype rosettaStereotype, extension IFormattableDocument document) {
		appendWithOneSpace(rosettaStereotype, document)
	}

	def dispatch void format(RosettaRegulatoryReference rosettaRegulatoryReference,
		extension IFormattableDocument document) {
		rosettaRegulatoryReference.prepend[newLine].surround[indent]
	}

	def dispatch void format(RosettaClassSynonym rosettaClassSynonym, extension IFormattableDocument document) {
		singleIndentedLine(rosettaClassSynonym, document)
	}

	def dispatch void format(RosettaSynonym rosettaSynonym, extension IFormattableDocument document) {
		singleIndentedLine(rosettaSynonym, document)
	}

	def dispatch void format(RosettaEnumeration rosettaEnumeration, extension IFormattableDocument document) {
		indentedBraces(rosettaEnumeration, document)
		formatChild(rosettaEnumeration.synonyms, document)
		formatChild(rosettaEnumeration.references, document)
		formatChild(rosettaEnumeration.enumValues, document)
	}

	def dispatch void format(RosettaEnumValue rosettaEnumValue, extension IFormattableDocument document) {
		rosettaEnumValue.prepend[newLine].append[noSpace]
		formatChild(rosettaEnumValue.enumSynonyms, document)
		formatChild(rosettaEnumValue.references, document)
	}

	def dispatch void format(RosettaEnumSynonym rosettaEnumSynonym, extension IFormattableDocument document) {
		rosettaEnumSynonym.prepend[newLine].surround[indent]
	}

	def dispatch void format(RosettaDataRule it, extension IFormattableDocument document) {
		indentedBraces(document)
	}

	def dispatch void format(RosettaContainsExpression rosettaContainsExpression,
		extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaExpression rosettaExpression, extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaWorkflowRule rosettaWorkflowRule, extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaTreeNode rosettaTreeNode, extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaChoiceRule rosettaChoiceRule, extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaExistsExpression rosettaExistsExpression, extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaFeatureCall rosettaAttributeCall, extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaGroupByFeatureCall rosettaGroupByFeatureCall, extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaExternalSynonymSource externalSynonymSource,
		extension IFormattableDocument document) {
		indentedBraces(externalSynonymSource, document)
		formatChild(externalSynonymSource.externalClasses, document)
	}

	def dispatch void format(RosettaExternalClass externalClass, extension IFormattableDocument document) {
		externalClass.regionFor.keyword(':').prepend[noSpace]
		externalClass.prepend[lowPriority; setNewLines(2)]
		formatChild(externalClass.regularAttributes, document)
	}

	def dispatch void format(RosettaExternalRegularAttribute externalRegularAttribute,
		extension IFormattableDocument document) {
		externalRegularAttribute.regionFor.keyword('+').append[oneSpace].prepend[newLine]
		externalRegularAttribute.surround[indent]
		formatChild(externalRegularAttribute.externalSynonyms, document)
	}

	def dispatch void format(RosettaExternalSynonym externalSynonym, extension IFormattableDocument document) {
		externalSynonym.prepend[newLine].surround[indent]
	}

	def void indentedBraces(EObject eObject, extension IFormattableDocument document) {
		val lcurly = eObject.regionFor.keyword('{').prepend[newLine].append[newLine]
		val rcurly = eObject.regionFor.keyword('}').prepend[newLine].append[setNewLines(2)]
		interior(lcurly, rcurly)[highPriority; indent]
	}

	def void formatChild(List<? extends EObject> children, extension IFormattableDocument document) {
		for (EObject child : children) {
			child.format;
		}
	}

	def void singleIndentedLine(EObject eObject, extension IFormattableDocument document) {
		eObject.prepend[newLine].append[newLine].surround[indent]
	}

	def void surroundWithOneSpace(EObject eObject, extension IFormattableDocument document) {
		for (ISemanticRegion w : eObject.allSemanticRegions) {
			w.surround[oneSpace];
		}
	}

	def void appendWithOneSpace(EObject eObject, extension IFormattableDocument document) {
		eObject.regionFor.keyword(',').append[oneSpace]
	}
}