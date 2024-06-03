#pragma	once

#include "state.hpp"
#include <algorithm>
#include <iostream>

namespace broma	{
	/// @brief Sort classes by required dependencies.
	///
	/// @param cls The class whose requirements will be sorted.
	/// @param root The AST (must be the same AST where the class was found).
	/// @param output A vector to output the sorted classes to.
	inline void	sort_class(Class cls, Root&	root, std::vector<Class>& output) {
		root.classes.erase(std::remove(root.classes.begin(), root.classes.end(), cls), root.classes.end());
		for	(auto name : cls.attributes.depends) {
			if (root[name])
				sort_class(*root[name],	root, output);
		}
		output.push_back(cls);
	}

	/// @brief Post process step after the AST is generated.
	///
	/// This step sorts all classes by their dependencies.
	/// This makes it easier to use the AST, as users of Broma do not need
	/// to worry about emitting classes in the right order.
	inline void	post_process(Root& root) {
		std::vector<Class> out;

		while (root.classes.size())
			sort_class(root.classes[0],	root, out);

		root.classes = out;
	}
}
