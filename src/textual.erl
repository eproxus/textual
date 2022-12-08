-module(textual).

% API
-export([titlecase/1]).
-ignore_xref([titlecase/1]).
-export([titlecase/2]).
-ignore_xref([titlecase/2]).

%--- Types ---------------------------------------------------------------------

-type titlecase_opts() :: #{
    style => apa,
    abbr => keep | capitalize
}.
% Options for customizing title case.
%
% Title `style' can be one of:
% <ul>
%   <li>`apa' (American Psychological Association)</li>
% </ul>
% `abbr' specifies how abbreviations (all uppercase words) are handled:
% <ul>
%   <li>`keep' abbreviations as is</li>
%   <li>`capitalize' them as normal words (i.e. lower case with capital first letter)</li>
% </ul>

%--- Macros --------------------------------------------------------------------

-define(DEFAULT_OPTS, #{style => apa, abbr => keep}).

-define(RE_SENTENCE, <<"((?::|\\.|\"|;)\s*)"/utf8>>).
-define(RE_WORDS, <<"(\s|,|\\(|\\)|-|—|\\/)"/utf8>>).

%--- API -----------------------------------------------------------------------

% @equiv titlecase(String, #{})
-spec titlecase(iodata()) -> iodata().
titlecase(String) -> titlecase(String, #{}).

% @doc Convert a text to title case.
%
% Converts all sentences in the input string to title case (sentences are text
% delimited with `.' or `:').
-spec titlecase(iodata(), titlecase_opts()) -> iodata().
titlecase("", _Opts) ->
    "";
titlecase(<<>>, _Opts) ->
    <<>>;
titlecase(String, UserOpts) ->
    Opts = maps:map(fun opt/2, maps:merge(?DEFAULT_OPTS, UserOpts)),
    Sentences = re:split(String, ?RE_SENTENCE),
    [titlecase_words(Opts, words(iolist_to_binary(S))) || S <- Sentences].

%--- Internal ------------------------------------------------------------------

opt(style, Style) when Style == apa -> Style;
opt(style, Style) -> error({invalid_style, Style});
opt(abbr, Abbr) when Abbr == keep; Abbr == capitalize -> Abbr;
opt(abbr, Abbr) -> error({invalid_abbr, Abbr}).

words(String) -> re:split(String, ?RE_WORDS).

titlecase_words(Opts, [First | Rest]) ->
    titlecase_words(Opts, Rest, [
        string:titlecase(titlecase_word(Opts, First))
    ]).

titlecase_words(_Opts, [], Acc) ->
    Acc;
titlecase_words(_Opts, [Last], Acc) ->
    lists:reverse([string:titlecase(Last) | Acc]);
titlecase_words(Opts, [Word | Rest], Acc) ->
    titlecase_words(Opts, Rest, [titlecase_word(Opts, Word) | Acc]).

titlecase_word(_Opts, <<" ">> = Word) ->
    Word;
titlecase_word(Opts, Word) ->
    titlecase_word(Opts, Word, string:uppercase(Word)).

titlecase_word(#{abbr := keep}, Upper, Upper) ->
    Upper;
titlecase_word(#{style := Style}, Word, Upper) ->
    case string:length(Word) of
        Length when Length >= 4 -> string:titlecase(Word);
        _ -> titlecase_word_(Style, Word, Upper)
    end.

titlecase_word_(apa, _Word, <<"A">>) -> <<"a">>;
titlecase_word_(apa, _Word, <<"AN">>) -> <<"an">>;
titlecase_word_(apa, _Word, <<"AND">>) -> <<"and">>;
titlecase_word_(apa, _Word, <<"AS">>) -> <<"as">>;
titlecase_word_(apa, _Word, <<"AT">>) -> <<"at">>;
titlecase_word_(apa, _Word, <<"BUT">>) -> <<"but">>;
titlecase_word_(apa, _Word, <<"BY">>) -> <<"by">>;
titlecase_word_(apa, _Word, <<"FOR">>) -> <<"for">>;
titlecase_word_(apa, _Word, <<"IF">>) -> <<"if">>;
titlecase_word_(apa, _Word, <<"IN">>) -> <<"in">>;
titlecase_word_(apa, _Word, <<"NOR">>) -> <<"nor">>;
titlecase_word_(apa, _Word, <<"OF">>) -> <<"of">>;
titlecase_word_(apa, _Word, <<"OFF">>) -> <<"off">>;
titlecase_word_(apa, _Word, <<"ON">>) -> <<"on">>;
titlecase_word_(apa, _Word, <<"OR">>) -> <<"or">>;
titlecase_word_(apa, _Word, <<"PER">>) -> <<"per">>;
titlecase_word_(apa, _Word, <<"SO">>) -> <<"so">>;
titlecase_word_(apa, _Word, <<"THE">>) -> <<"the">>;
titlecase_word_(apa, _Word, <<"TO">>) -> <<"to">>;
titlecase_word_(apa, _Word, <<"UP">>) -> <<"up">>;
titlecase_word_(apa, _Word, <<"VIA">>) -> <<"via">>;
titlecase_word_(apa, _Word, <<"YET">>) -> <<"yet">>;
titlecase_word_(apa, Word, _Upper) -> string:titlecase(string:lowercase(Word)).
