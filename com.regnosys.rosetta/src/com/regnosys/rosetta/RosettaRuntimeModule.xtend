/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta

import com.regnosys.rosetta.generator.RosettaOutputConfigurationProvider
import com.regnosys.rosetta.generator.external.EmptyExternalGeneratorsProvider
import com.regnosys.rosetta.resource.RosettaFragmentProvider
import com.regnosys.rosetta.resource.RosettaResourceDescriptionManager
import com.regnosys.rosetta.resource.RosettaResourceDescriptionStrategy
import com.regnosys.rosetta.scoping.RosettaQualifiedNameProvider
import org.eclipse.xtext.generator.IOutputConfigurationProvider
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.resource.IFragmentProvider
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import com.regnosys.rosetta.generator.external.ExternalGenerators
import com.google.inject.Provider

/* Use this class to register components to be used at runtime / without the Equinox extension registry.*/
class RosettaRuntimeModule extends AbstractRosettaRuntimeModule {
	override Class<? extends IFragmentProvider> bindIFragmentProvider() {
		RosettaFragmentProvider
	}
	
	def Class<? extends DefaultResourceDescriptionStrategy> bindDefaultResourceDescriptionStrategy() {
		RosettaResourceDescriptionStrategy
	}
	
	override Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return RosettaQualifiedNameProvider
	}
	
	def Class<? extends IOutputConfigurationProvider> bindIOutputConfigurationProvider() {
		return RosettaOutputConfigurationProvider
	}
	
	def Class<? extends IResourceDescription.Manager> bindIResourceDescriptionManager() {
		RosettaResourceDescriptionManager
	}
	
	def Class<? extends Provider<ExternalGenerators>> provideExternalGenerators() {
		EmptyExternalGeneratorsProvider
	}
}