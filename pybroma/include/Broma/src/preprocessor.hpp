#pragma once

#include "basic_components.hpp"
#include "state.hpp"

namespace broma {
	/// @brief The inner name of the file to be included.
	struct include_name : until<at<one<'>'>>> {};

	/// @brief A C++ include expression.
	///
	/// Currently, this only supports angle bracket includes.
	struct include_expr : seq<ascii::string<'#', 'i', 'n', 'c', 'l', 'u', 'd', 'e'>, sep, one<'<'>, include_name, one<'>'>> {};

	struct root_grammar;

	template <>
	struct run_action<include_name> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			file_input<> file_input(input.string());

			parse<root_grammar, broma::run_action>(file_input, root, scratch);
		}
	};
} // namespace broma
