#pragma once

#include <tao/pegtl.hpp>
using namespace tao::pegtl;

#include "basic_components.hpp"
#include "state.hpp"

namespace broma {
	/// @brief A bound offset expression.
	struct bind :
		seq<rule_begin<bind>, opt_must<
			one<'='>,
			sep, 
			list<opt<
				sep,
				tagged_platform<bind>,
				sep,
				tagged_rule<bind, sor<hex, keyword_default, keyword_inline>>
			>, one<','>>,
			sep
		>, sor<tagged_rule<bind, brace_start>, one<';'>>> {};

	template <>
	struct run_action<tagged_rule<bind, brace_start>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_fn_body = input.string();
		}
	};

	template <>
	struct run_action<rule_begin<bind>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			// Res
			scratch->wip_bind = PlatformNumber();
		}
	};

	template <>
	struct run_action<tagged_platform<bind>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_bind_platform = str_to_platform(input.string());
		}
	};

	template <>
	struct run_action<tagged_rule<bind, sor<hex, keyword_default, keyword_inline>>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			auto text = input.string();

			std::size_t out = -1;
			if (text == "default") {
				// special internal constant used for normalization
				// feel free to increment if needed (it isn't exposed anywhere public)
				out = -3;
			} else if (text == "inline") {
				// potential forwards compatibility
				// if one platform has explicit inline then default should be not inline
				out = -2;
				scratch->wip_has_explicit_inline = true;
			} else {
				out = std::stoul(text, nullptr, 16);
			}

			switch (scratch->wip_bind_platform) {
				// define mac as intel mac to avoid exploding the older bindings
				case Platform::Mac:
					scratch->wip_bind.imac = out;
					break;
				case Platform::MacIntel:
					scratch->wip_bind.imac = out;
					break;
				case Platform::MacArm:
					scratch->wip_bind.m1 = out;
					break;
				case Platform::iOS:
					scratch->wip_bind.ios = out;
					break;
				case Platform::Windows:
					scratch->wip_bind.win = out;
					break;
				// for default syntax
				case Platform::Android:
					scratch->wip_bind.android32 = out;
					scratch->wip_bind.android64 = out;
					break;
				case Platform::Android32:
					scratch->wip_bind.android32 = out;
					break;
				case Platform::Android64:
					scratch->wip_bind.android64 = out;
					break;
				default:
					break;
			}
		}
	};
} // namespace broma
