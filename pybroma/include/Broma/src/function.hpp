#pragma once

#include <tao/pegtl.hpp>
using namespace tao::pegtl;

#include "basic_components.hpp"
#include "attribute.hpp"
#include "type.hpp"
#include "bind.hpp"
#include "state.hpp"

namespace broma {
	/// @brief A function signature / prototype.
	struct function_proto :
		seq <rule_begin<function_proto>,
			sep,
			tagged_rule<function_proto, type>,
			sep,
			tagged_rule<function_proto, identifier>,
			arg_list>
		{};

	template <>
	struct run_action<rule_begin<function_proto>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->is_class = false;
			scratch->wip_fn_proto = FunctionProto();
		}
	};

	template <>
	struct run_action<tagged_rule<function_proto, type>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_fn_proto.ret = scratch->wip_type;
		}
	};

	template <>
	struct run_action<tagged_rule<function_proto, identifier>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_fn_proto.name = input.string();
		}
	};

	/// @brief A full function (prototype and bindings).
	struct function : 
		seq<rule_begin<function>, function_proto, sep, bind>
		{};

	template <>
	struct run_action<function> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_fn_proto.attributes = scratch->wip_attributes;

			Function f;
			f.prototype = scratch->wip_fn_proto;
			root->functions.push_back(f);

			scratch->wip_attributes = Attributes();
		}
	};

	/// @brief A member function prototype.
	///
	/// This allows some more qualifiers than the free function prototype.
	struct member_function_proto :
		seq<rule_begin<member_function_proto>, sep, opt<attribute>, sep, sor<
			// ctor, dtor
			seq<
				named_rule("structor", success),
				opt<pad_space<keyword_virtual>>,
				opt<tagged_rule<member_function_proto, one<'~'>>>,
				tagged_rule<member_function_proto, identifier>,
				arg_list
			>,

			// not ctor, dtor
			if_then_must<
				sor<keyword_static, keyword_virtual, keyword_callback>,
				named_rule("fn_member", success),
				sep,
				tagged_rule<member_function_proto, type>,
				sep,
				tagged_rule<member_function_proto, identifier>,
				arg_list,
				sep,
				opt<tagged_rule<member_function_proto, keyword_const>>
			>
		>> {};

	template <>
	struct run_action<rule_begin<member_function_proto>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_attributes = Attributes();
			scratch->wip_attributes.links = scratch->wip_class.attributes.links;
			scratch->wip_attributes.missing = scratch->wip_class.attributes.missing;

			scratch->wip_mem_fn_proto = MemberFunctionProto();
		}
	};

	template <>
	struct run_action<member_function_proto> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.attributes = scratch->wip_attributes;

			for (auto& f : scratch->wip_class.fields) {
				if (auto fn = f.get_fn()) {
					if (*fn == scratch->wip_mem_fn_proto) {
						scratch->errors.push_back(parse_error("Function duplicate!", input.position()));
					}
				}
			}
		}
	};

	template <>
	struct run_action<tagged_rule<member_function_proto, identifier>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.name = input.string();

			if (scratch->wip_mem_fn_proto.type == FunctionType::Dtor)
				scratch->wip_mem_fn_proto.name = "~" + scratch->wip_mem_fn_proto.name;
		}
	};

	template <>
	struct run_action<tagged_rule<member_function_proto, keyword_const>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.is_const = true;
		}
	};

	template <>
	struct run_action<tagged_rule<member_function_proto, type>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.ret = scratch->wip_type;
		}
	};

	template <>
	struct run_action<named_rule("fn_member", success)> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.type = FunctionType::Normal;
		}
	};

	template <>
	struct run_action<named_rule("structor", success)> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.type = FunctionType::Ctor;
		}
	};

	template <>
	struct run_action<keyword_static> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.is_static = true;
		}
	};

	template <>
	struct run_action<tagged_rule<member_function_proto, one<'~'>>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.type = FunctionType::Dtor;
		}
	};

	template <>
	struct run_action<keyword_virtual> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.is_virtual = true;
		}
	};

	template <>
	struct run_action<keyword_callback> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_mem_fn_proto.is_callback = true;
		}
	};

	std::ptrdiff_t normalizePlatformNumber(std::ptrdiff_t num, bool has_inline) {
		// -1 = unspecified. if there's an inline, default to inlined constant
		if (num == -1 && has_inline) {
			return -2;
		}

		// -3 = explicit default, so it returns to unspecified after inline is applied
		if (num == -3) {
			return -1;
		}

		return num;
	}

	/// @brief An offset binding expression.
	struct bind_expr : seq<member_function_proto, sep, bind> {};

	template <>
	struct run_action<bind_expr> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			FunctionBindField f;
			f.prototype = scratch->wip_mem_fn_proto;
			f.binds = scratch->wip_bind;

			// normalize platform bindings. this is probably not very efficient, but whatever
			// should probably do lookahead lol

			auto has_inline = !scratch->wip_fn_body.empty() && !scratch->wip_has_explicit_inline;
			f.binds.android32 = normalizePlatformNumber(f.binds.android32, has_inline);
			f.binds.android64 = normalizePlatformNumber(f.binds.android64, has_inline);
			f.binds.imac = normalizePlatformNumber(f.binds.imac, has_inline);
			f.binds.m1 = normalizePlatformNumber(f.binds.m1, has_inline);
			f.binds.ios = normalizePlatformNumber(f.binds.ios, has_inline);
			f.binds.win = normalizePlatformNumber(f.binds.win, has_inline);

			f.inner = scratch->wip_fn_body;
			scratch->wip_field.inner = f;

			// clear state (there's probably a better way to do this too)
			scratch->wip_fn_body.clear();
			scratch->wip_has_explicit_inline = false;
		}
	};
} // namespace broma
