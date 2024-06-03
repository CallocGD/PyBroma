#pragma once

#include <tao/pegtl.hpp>
using namespace tao::pegtl;

#include "basic_components.hpp"
#include "state.hpp"

namespace broma {
	/// @brief The inner portion of an attribute.
	///
	/// This includes anything within the double brackets (`[[...]]`).
	template <typename Name, typename ...Parse>
	struct basic_attribute : seq<
			Name,
			one<'('>,
			if_then_else<
				at<one<')'>>,
				success,
				seq<Parse...>
			>,
			one<')'>
		> {};

	struct docs_literal : until<eolf> {};
	struct docs_attribute : seq<ascii::string<'/', '/', '/'>, tagged_rule<docs_attribute, docs_literal> > {};
	
	// seq<ascii::string<'/', '*'>, tagged_rule<docs_attribute, string_literal>, until<seq<ascii::string<'*', '/'>>>> /*basic_attribute<TAO_PEGTL_KEYWORD("docs"), tagged_rule<docs_attribute, string_literal>>*/ {};
	struct depends_attribute : basic_attribute<TAO_PEGTL_KEYWORD("depends"), tagged_rule<depends_attribute, qualified>> {};

	template <typename Attribute>
	struct platform_list : seq<
		sep, 
		list<opt<
			sep,
			tagged_platform<Attribute>,
			sep
		>, one<','>>,
		sep
	> {};

	struct link_attribute : basic_attribute<TAO_PEGTL_KEYWORD("link"), tagged_rule<link_attribute, 
		seq<
			rule_begin<link_attribute>,
			opt<platform_list<link_attribute>>
		>
	>> {};

	struct missing_attribute : basic_attribute<TAO_PEGTL_KEYWORD("missing"), tagged_rule<missing_attribute,
		seq<
			rule_begin<missing_attribute>,
			opt<platform_list<missing_attribute>>
		>
	>> {};

	/// @brief All allowed C++ attributes.
	///
	/// Currently, this includes the `docs(...)`, `depends(...)`, `link(...)` and `missing(...)` attributes.
	struct attribute_normal : 
		seq<
			ascii::string<'[', '['>,
			if_then_else<
				at<ascii::string<']', ']'>>,
				success,
				list<seq<
					sep,
					sor<depends_attribute, link_attribute, missing_attribute>,
					sep
				>, one<','>>
			>,
			ascii::string<']', ']'>
		> {};

	struct attribute : seq<
		sep, 
		opt<list<docs_attribute, sep>>,
		sep,
		opt<attribute_normal>
	> {};


	// depends

	template <>
	struct run_action<tagged_rule<depends_attribute, qualified>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_attributes.depends.push_back(input.string());
		}
	};

	// docs

	template <>
	struct run_action<tagged_rule<docs_attribute, docs_literal>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_attributes.docs += input.string() + '\n';
		}
	};

	// link

	template <>
	struct run_action<rule_begin<link_attribute>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_attributes.links = Platform::None;
		}
	};

	template <>
	struct run_action<tagged_platform<link_attribute>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_attributes.links |= str_to_platform(input.string());
		}
	};

	// missing

	template <>
	struct run_action<rule_begin<missing_attribute>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_attributes.missing = Platform::None;
		}
	};
	template <>
	struct run_action<tagged_platform<missing_attribute>> {
		template <typename T>
		static void apply(T& input, Root* root, ScratchData* scratch) {
			scratch->wip_attributes.missing |= str_to_platform(input.string());
		}
	};

} // namespace broma
