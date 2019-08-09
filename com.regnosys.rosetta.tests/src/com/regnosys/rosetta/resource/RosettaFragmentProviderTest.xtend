package com.regnosys.rosetta.resource

import com.google.inject.Inject
import com.regnosys.rosetta.rosetta.RosettaClass
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class RosettaFragmentProviderTest {
	
	@Inject extension ParseHelper<RosettaModel> 
	
	@Test
	def testURIFragments() {
		val clazz = '''
			class Foo {
				foo Foo (1..1);
			}
		'''.parse.elements.filter(RosettaClass).head
		val resourceSet = clazz.eResource.resourceSet
		val classURI = EcoreUtil.getURI(clazz)
		assertEquals('Foo', classURI.fragment)
		assertEquals(clazz, resourceSet.getEObject(classURI, false))
		
		val attribute = clazz.regularAttributes.head
		val attributeURI = EcoreUtil.getURI(attribute)
		assertEquals('Foo.foo', attributeURI.fragment)
		assertEquals(attribute, resourceSet.getEObject(attributeURI, false))
	}
}