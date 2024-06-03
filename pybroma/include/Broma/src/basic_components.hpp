#pragma once

#include <tao/pegtl.hpp>
using namespace tao::pegtl;

namespace broma {
	/// @brief C and C++-style comments.
	struct comment : 
		disable<sor<
			seq<at<ascii::string<'/', '/'>, not_at<one<'/'>>>, until<eolf>>,
			seq<ascii::string<'/', '*'>, until<seq<ascii::string<'*', '/'>>>>
		>> {};

	/// @brief Noisy filler grammar elements we want to ignore when parsing.
	struct ignore : sor<comment, one<'\n', '\t', '\r', ' '>> {};

	/// @brief Separator (zero or more ignoreable elements).
	struct sep : star<ignore> {};
	/// @brief Whitespace (one or more ignoreable elements).
	struct whitespace : plus<ignore> {};

	/// @brief A grammar rule followed by required whitespace.
	template <typename ...Args>
	struct pad_space : seq<Args..., whitespace> {};

	/// @brief A grammar rule preceded by required whitespace.
	template <typename ...Args>
	struct rpad_space : seq<whitespace, Args...> {};

	template <typename R, typename ...S>
	struct if_then_must : if_then_else<R, must<S...>, seq<S...>> {};

	/// @brief A string literal.
	/// @tparam Quote The character that denotes the start and end of the literal.
	template <char Quote>
	struct basic_literal : if_must<one<Quote>, until<one<Quote>>> {};
	struct string_literal : sor<basic_literal<'"'>, basic_literal<'\''>> {};

	struct brace_end;
	/// @brief A C++ scope.
	///
	/// This grammar accounts for any recursive scopes, for inline function bodies.
	struct brace_start : seq<one<'{'>, brace_end> {};
	struct brace_end : until<one<'}'>, sor<string_literal, brace_start, any>> {};

	struct template_end;
	/// @brief A C++ template expression.
	///
	/// This grammar accounts for any recursive templates.
	struct template_start : seq<one<'<'>, template_end> {};
	struct template_end : until<one<'>'>, sor<string_literal, template_start, any>> {};

	/// @brief A convenience grammar for running AST actions.
	///
	/// See "How Broma uses PEGTL" in the Developer's Guide for more information.
	template <typename T, typename ...Args>
	struct tagged_rule : seq<Args...> {};

	/// @brief A convenience grammar for running AST actions for each parameter of the rule.
	///
	/// See "How Broma uses PEGTL" in the Developer's Guide for more information.
	template <typename T, typename Rule>
	struct tagged_for_each {};
	template <typename T, template<typename...> typename Rule, typename ...Args>
	struct tagged_for_each<T, Rule<Args...>> : Rule<tagged_rule<T, Args>...> {};

	/// @brief A rule to notate the beginning of a grammar.
	///
	/// See "How Broma uses PEGTL" in the Developer's Guide for more information.
	template <typename T>
	struct rule_begin : success {};

	#define named_rule(name, ...) tagged_rule<TAO_PEGTL_STRING(name), __VA_ARGS__>

	#define keyword(name) struct keyword_##name : TAO_PEGTL_KEYWORD(#name) {}

	keyword(const);
	keyword(static);
	keyword(virtual);
	keyword(callback);
	keyword(inline);
	keyword(default);
	keyword(class);
	keyword(struct);
	keyword(unsigned);
	keyword(mac);
	keyword(win);
	keyword(ios);
	keyword(android);
	keyword(android32);
	keyword(android64);
	keyword(m1);
	keyword(imac);
	keyword(PAD);

	#undef keyword

	/// @brief A C++ qualified identifier.
	///
	/// See https://en.cppreference.com/w/cpp/language/identifiers#Qualified_identifiers.
	struct qualified : list<seq<identifier, opt<template_start>>, ascii::string<':', ':'>>  {};

	// point of no return: '0x'
	/// @brief A hex literal.
	struct hex : if_must<ascii::string<'0', 'x'>, plus<ascii::xdigit>> {};

	/// @brief A platform identifier (mac, win, ios, android).
	template <typename T>
	struct tagged_platform : tagged_for_each<T, sor<keyword_mac, keyword_win, keyword_ios, keyword_android, keyword_android32, keyword_android64, keyword_imac, keyword_m1>> {};
} // namespace broma
