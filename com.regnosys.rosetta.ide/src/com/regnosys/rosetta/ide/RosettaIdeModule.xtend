/*
 * generated by Xtext 2.12.0
 */
package com.regnosys.rosetta.ide

import com.regnosys.rosetta.generator.RosettaOutputConfigurationProvider
import org.eclipse.xtext.generator.IContextualOutputConfigurationProvider

/**
 * Use this class to register ide components.
 */
class RosettaIdeModule extends AbstractRosettaIdeModule {
	
	def Class<? extends IContextualOutputConfigurationProvider> bindIContextualOutputConfigurationProvider() {
		return RosettaOutputConfigurationProvider
	}
	
}