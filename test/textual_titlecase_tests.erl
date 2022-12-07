-module(textual_titlecase_tests).

-include_lib("eunit/include/eunit.hrl").

-define(SHORT_CONJUCTIONS, [
    "and", "as", "but", "for", "if", "nor", "or", "so", "yet"
]).
-define(ARTICLES, ["a", "an", "the"]).
-define(SHORT_PREPOSITIONS, [
    "as", "at", "by", "for", "in", "of", "off", "on", "per", "to", "up", "via"
]).

%--- Tests ---------------------------------------------------------------------

titlecase_option_test() ->
    ?assertError(
        {invalid_style, foobar}, textual:titlecase("Foobar", #{style => foobar})
    ),
    ?assertError(
        {invalid_abbr, foobar}, textual:titlecase("Foobar", #{abbr => foobar})
    ).

titlecase_empty_test_() ->
    {inparallel, [
        ?_assertEqual("", textual:titlecase("")),
        ?_assertEqual(<<"">>, textual:titlecase(<<"">>))
    ]}.

titlecase_apa_test_() ->
    {inparallel,
        lists:flatten([
            [
                ?_assertEqual(to_bin(U), to_bin(textual:titlecase(L))),
                ?_assertEqual(to_bin(U), to_bin(textual:titlecase(to_bin(L))))
            ]
         || {U, L} <-
                [
                    {
                        "FYI: Erlang and OTP Together Are Erlang/OTP, Not Erlang/Erlang",
                        "FYI: erlang and OTP together are erlang/OTP, not erlang/erlang"
                    },
                    {
                        "The Quick Brown Fox Jumps Over the Lazy Dog. Not the Bear.",
                        "the quick brown fox jumps over The lazy dog. not the bear."
                    },
                    {
                        "Turning Frowns (and Smiles) Upside Down: A Multilevel Examination of Surface Acting Positive and Negative Emotions on Well-Being",
                        "Turning Frowns (And Smiles) Upside Down: a Multilevel Examination of Surface Acting Positive and Negative Emotions on Well-being"
                    },
                    {
                        "Train Your Mind for Peak Performance: A Science-Based Approach for Achieving Your Goals",
                        "train your mind For peak performance: a science-based approach For achieving your goals"
                    }
                ] ++
                    [
                        {
                            lists:join($\s, [
                                string:titlecase(W), W, string:titlecase(W)
                            ]),
                            lists:join($\s, [W, W, W])
                        }
                     || W <-
                            ?SHORT_CONJUCTIONS ++ ?ARTICLES ++
                                ?SHORT_PREPOSITIONS
                    ]
        ])}.

assume_abbr_test() ->
    ?assertEqual(
        to_bin(
            "Fyi: Erlang and Otp Together Are Erlang/Otp, Not Erlang/Erlang"
        ),
        to_bin(
            textual:titlecase(
                "FYI: erlang and OTP together are erlang/OTP, not erlang/erlang",
                #{abbr => capitalize}
            )
        )
    ).

%--- Internal ------------------------------------------------------------------

to_bin(IOList) -> iolist_to_binary(IOList).
