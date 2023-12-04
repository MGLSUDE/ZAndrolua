package com.myopicmobile.textwarrior.common;
/**
 * Singleton class containing the symbols and operators of the Java language
 */
public class LanguageJava extends Language {
    private static Language _theOne = null;

    private final static String[] keywords = {
        "abstract","default","null","switch","boolean",
        "do","if","package","nchronzed","break","double",
        "implements","private","this","byte","else",
        "import","protected","throw","throws","case",
        "extends","instanceof","public","transient","catch",
        "false","int","return","true","char","final",
        "interface","short","try","class","finally","long",
        "static","void","float","native","strictfp","volatile",
        "continue","for","new","super","while","assert","enum"
    };

    private final static String[] function = {};

    private final static char[] BASIC_C_OPERATORS = {
        '(', ')', '{', '}', '.', ',', ';', '=', '+', '-',
        '/', '*', '&', '!', '|', ':', '[', ']', '<', '>',
        '?', '~', '%', '^'
    };

    public static Language getInstance() {
        if (_theOne == null) {
            _theOne = new LanguageJava();
        }
        return _theOne;
    }

    private LanguageJava() {
        setOperators(BASIC_C_OPERATORS);
        setKeywords(keywords);
        setNames(function);
    }

    /**
     * Java has no preprocessors. Override base class implementation
     */
    public boolean isLineAStart(char c) {
        return false;
    }
}
