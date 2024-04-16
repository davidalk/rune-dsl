/*
 * Copyright 2024 REGnosys
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.regnosys.rosetta.tools.modelimport;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.xmlet.xsdparser.xsdelements.XsdAbstractElement;
import org.xmlet.xsdparser.xsdelements.XsdNamedElements;

import com.regnosys.rosetta.rosetta.RosettaRootElement;

public abstract class AbstractXsdImport<XsdType extends XsdAbstractElement, Result extends RosettaRootElement> {
	private final Class<XsdType> xsdType;
	public AbstractXsdImport(Class<XsdType> xsdType) {
		this.xsdType = xsdType;
	}

	public List<XsdType> filterTypes(List<XsdAbstractElement> elements) {
		return elements.stream()
				.filter(elem -> xsdType.isInstance(elem))
				.map(elem -> xsdType.cast(elem))
				.collect(Collectors.toList());
	}
	public abstract Result registerType(XsdType xsdType, RosettaXsdMapping typeMappings, Map<XsdNamedElements, String> rootTypeNames, GenerationProperties properties);
	public abstract void completeType(XsdType xsdType, RosettaXsdMapping typeMappings, Map<XsdNamedElements, String> rootTypeNames);
	public List<? extends RosettaRootElement> registerTypes(List<XsdAbstractElement> xsdElements, RosettaXsdMapping typeMappings, Map<XsdNamedElements, String> rootTypeNames, GenerationProperties properties) {
		List<XsdType> xsdTypes = filterTypes(xsdElements);
		return xsdTypes.stream()
			.map(t -> registerType(t, typeMappings, rootTypeNames, properties))
			.collect(Collectors.toList());
	}
	public void completeTypes(List<XsdAbstractElement> xsdElements, RosettaXsdMapping typeMappings, Map<XsdNamedElements, String> rootTypeNames) {
		List<XsdType> xsdTypes = filterTypes(xsdElements);
		xsdTypes.stream()
			.forEach(t -> completeType(t, typeMappings, rootTypeNames));
	}
}
