/*
 * Class to parse logical expression into ExpressionElement structure
*/
public class ExpressionParser {
    public string source;
    public list<Token> tokens = new list<Token>{};
    private integer current = 0;
    public integer maximumElementIndex;
    public ExpressionParser(string source, integer maximumElementIndex){
        this.source = source;
        this.maximumElementIndex = maximumElementIndex;
    }
    public ExpressionElement parse() {
        this.tokens = scanner(this.source, maximumElementIndex);
        ExpressionElement endAt = expression(null);
        if(!isAtEnd())
            throw new ExpressionParserException(string.format(system.label.Expression_Parser_Expected_Logical_Operator, new string[]{string.valueOf(tokens.get(current).type)}), tokens.get(current));
        return endAt;
    }
    //expression		-> inclusive
    private ExpressionElement expression(ExpressionElement parent) {
        // Initialize parent if not provided
        parent = parent==null ? new ExpressionElement(null, false, false): parent;
        return inclusive(parent);
    }
    // inclusive		-> exclusive ( OR exclusive )*
    private ExpressionElement inclusive(ExpressionElement parent) {
        exclusive(parent);
        while (match(TokenType.OR_TOKEN)) {
            parent.logicalAnd = false;
            exclusive(parent);
        }
        return parent;
    }
    // exclusive		-> unary ( AND unary )*
    private ExpressionElement exclusive(ExpressionElement parent) {
        
        ExpressionElement unaryElement = unary(parent);
        if(peek().type == TokenType.AND_TOKEN) {
            ExpressionElement element = new ExpressionElement(null, true, false);
            parent.elements.add(element);
            parent = element;
        }
        parent.elements.add(unaryElement);

        while (match(TokenType.AND_TOKEN)) {
            parent.logicalAnd = true;
            parent.elements.add(unary(parent));
        }
        return parent;
    }
    // unary 			-> NOT primary | primary
    private ExpressionElement unary(ExpressionElement parent) {
        return primary(parent, match(TokenType.NOT_TOKEN));
    }
    // primary 			-> NUMBER | "true" | "false" | "(" expression ")"
    private ExpressionElement primary(ExpressionElement parent, boolean logicalNot) {
        ExpressionElement element;
        if(match(TokenType.NUMBER_TOKEN)) {
            element = new ExpressionElement(previous().literal, logicalNot); 
        } else if(match(TokenType.LEFT_PAREN_TOKEN)) {
            element = new ExpressionElement(null, false, logicalNot);
            expression(element);
            consume(TokenType.RIGHT_PAREN_TOKEN, system.label.Expression_Parser_Expected_Right_Parant);
        } else if (match(TokenType.FALSE_TOKEN) || match(TokenType.TRUE_TOKEN)) {
            element = new ExpressionElement(null, logicalNot);
            element.staticResult = previous().type==TokenType.TRUE_TOKEN;
        } else
            throw new ExpressionParserException(system.label.Expression_Parser_Expected_Unary_Expression, advance());
        return element;
    }
    private Token consume(TokenType type, String message) {
        if (check(type)) return advance();
        throw new ExpressionParserException(message, peek());
    }
    
    
    private boolean match(TokenType matchType) {
        if (check(matchType)) {
            advance();
            return true;
        }
        return false;
    }
    
    private boolean check(TokenType tokenType) {
        return isAtEnd()? false: peek().type == tokenType;
    }
    
    private Token advance() {
        if (!isAtEnd()) current++;
        return previous();
    }
    private boolean isAtEnd() {
        return current>=tokens.size()-1? true : peek().type == TokenType.EOF_TOKEN;
    }
    
    private Token peek() {
        return tokens.get(current);
    }
    
    private Token previous() {
        return tokens.get(current - 1);
    }
    /*
     * expression		-> inclusive
     * inclusive		-> exclusive ( OR exclusive )*
     * exclusive		-> unary ( AND unary )* 
     * unary 			-> NOT primary | primary
     * primary 			-> NUMBER | "true" | "false" | "(" expression ")"
	*/

    public class ExpressionParserException extends Exception {
        integer position;
        public Token token;
        public ExpressionParserException(string description, integer charPosition){
            position = charPosition;
            setMessage(description);
        }
        public ExpressionParserException(string description, Token token){
            this.token = token;
            setMessage(description);
        }
        public string getDetail() {
            return getMessage()
                +(
                    token!=null ? 
                    string.format(system.label.Expression_Parser_Actual_Finding, new string[]{string.valueOf(token.type), (token.startIndex!=null ? token.startIndex.format() : '?')}) :
                    (position!=null ? string.format(system.label.Expression_Parser_At_Position, new string[]{position.format()}) : '')
                );
        }
        public integer getPos() {
            return token!=null ? token.startIndex : position;
        }
    }
    
	public enum TokenType {
        // Single-character tokens.
        LEFT_PAREN_TOKEN, RIGHT_PAREN_TOKEN,
        // Literals.
        NUMBER_TOKEN,
        // Keywords.
        AND_TOKEN, FALSE_TOKEN, OR_TOKEN, TRUE_TOKEN, NOT_TOKEN, EOF_TOKEN
    }
    public static final map<string, TokenType> lexemeMap = new map<string, TokenType> {
        '!' => TokenType.NOT_TOKEN,
        'not' => TokenType.NOT_TOKEN,
        'and' => TokenType.AND_TOKEN,
        '&&' => TokenType.AND_TOKEN,
        'or' => TokenType.OR_TOKEN,
        '||' => TokenType.OR_TOKEN,
        '(' => TokenType.LEFT_PAREN_TOKEN,
        ')' => TokenType.RIGHT_PAREN_TOKEN,
        'true' => TokenType.TRUE_TOKEN,
        'false' => TokenType.FALSE_TOKEN
    };
    
    public class Token {
        public TokenType type{get;set;}
        public Integer literal{get;set;}
        public integer startIndex{get;set;}
        public string source{get;set;}
        public Token(TokenType type, integer literal, integer startIndex){
            this.type = type;
            this.literal = literal;
            this.startIndex = startIndex;
            this.source = literal!=null?literal.format():'';
        }
        public Token(string sourceString, integer start){
            this.source = sourceString;
            startIndex = start;
            if(string.isblank(sourceString))
                throw new ExpressionParserException(string.format(system.label.Expression_Parser_Unexpected_Token_Content,new string[]{null}), start);
            if(sourceString.isNumeric()) {
                type = TokenType.NUMBER_TOKEN;
                literal = integer.valueOf(sourceString);
            } else if(lexemeMap.containsKey(sourceString.toLowerCase()))
                type = lexemeMap.get(sourceString.toLowerCase());
            else
                throw new ExpressionParserException(string.format(system.label.Expression_Parser_Unexpected_Token_Content,new string[]{sourceString}), start);
        }
    }
    
    // Scans an input string and returns logical tokens
    public Token[] scanner(string sourceString, integer maximumElementIndex) {
        Token[] tokenList = new Token[]{};
        string regExTokenizer = '\\d+|([Aa][Nn][Dd])|[Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]|([\\&][\\&])|([Oo][Rr])|([\\|][\\|])|([Nn][Oo][Tt])|[\\(\\)\\!]';
        Pattern tokenPattern = Pattern.compile(regExTokenizer);
        matcher tokenMatcher = tokenPattern.matcher(sourceString);
        integer lastTokenEnd = 0;
        while (tokenMatcher.find()) {
            string lexeme = tokenMatcher.group();
            integer tokenStart = tokenMatcher.start();
            integer tokenEnd = tokenMatcher.end();
            // Confirm sequence did not skip over invalid characters
            if(tokenStart > lastTokenEnd) {
                string gapString = sourceString.substring(lastTokenEnd, tokenStart-1);
                if(string.isNotBlank(gapString)) // ignore blank space
                    throw new ExpressionParserException(string.format(system.label.Expression_Parser_Unrecognized_Characters, new string[]{gapString}), lastTokenEnd+1);
            }
            if(string.isNotBlank(lexeme)) {
                tokenList.add(new Token(lexeme, tokenStart));
            	if(maximumElementIndex!=null && tokenList[tokenList.size()-1].type==TokenType.NUMBER_TOKEN ? tokenList[tokenList.size()-1].literal> maximumElementIndex: false)
                    throw new ExpressionParserException(string.format(system.label.Expression_Parser_Element_Index_Out_Of_Range, new string[]{tokenList[tokenList.size()-1].literal.format(), maximumElementIndex.format()}), tokenStart);
            }
            lastTokenEnd = tokenEnd;
        }
        if (tokenList.isEmpty())
            throw new ExpressionParserException(string.format(system.label.Expression_Parser_No_token_found_in_source,new string[]{sourceString}), 0);
        else
            tokenList.add(new Token(TokenType.EOF_TOKEN, null, sourceString.length()));
        return tokenList;
    }
}