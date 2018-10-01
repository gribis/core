/*
 * Class to capture one formulaic expression
 * Breaks down complex statements into actionable elements
 * TODO: Standarize to common interface for related classes, then call common methods via interface class
 * ExpressionInterface
 * 	- Analyze(map<string, set<string>>)
 * 	- Evaluate(object context)
 *  - Define(object def)
*/
public class ComplexExpression {
    // Tokenizer regular expression; compile expression into static object
    public static final Pattern activePattern = Pattern.compile('(")[^"\\\\]*(?:\\\\.[^"\\\\]*)*(")?|(\')[^\'\\\\]*(?:\\\\.[^\'\\\\]*)*(\')?|(?:\\/\\*([^*]|[\\r\\n]|(\\*+([^*\\/]|[\\r\\n])))*\\*+\\/)|(?:\\/\\/.*)|[\\[\\]\\(\\)\\{\\}\\.\\,\\;](")[^"\\\\]*(?:\\\\.[^"\\\\]*)*(")?|(\')[^\'\\\\]*(?:\\\\.[^\'\\\\]*)*(\')?|[\\[\\]\\(\\)\\{\\}\\.\\,\\;]|[\\+\\-\\=\\&\\|]{2}|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^]\\=|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^\\=]|\\$[A-Za-z0-9\\_]+|[A-Za-z0-9\\_]+|[\\+\\-\\=\\&\\|]{2}|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^]\\=|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^\\=]|\\$[A-Za-z0-9\\_]+|[A-Za-z0-9\\_]+');
    
    public class ComplexExpressionException extends exception {
        integer position;
        public ComplexToken token;
        public ComplexExpressionException(string description, integer charPosition){
            position = charPosition;
            setMessage(description);
        }
        public ComplexExpressionException(string description, ComplexToken token){
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

    

	// Operator definition
	// Preceding element type
	// Closing element type
	// Precedence level
	// Type
    public class operator {
        public ComplexToken.Token type;
        public ComplexToken.Token priorType;
        public ComplexToken.Token subsequentType;
        public operator(ComplexToken.Token type, ComplexToken.Token prior, ComplexToken.Token subsequent) {
            this.type = type;
            this.priorType = prior;
            this.subsequentType = subsequent;
        }
    }
    
    // Delimiters that indicate strings
    public static map<string,operator> operators = new map<string, operator> {
        '!' => new operator(ComplexToken.Token.OP_NEGATION,null,ComplexToken.Token.EXPRESSION)
    };
    public static map<String, Schema.SOAPType> primaryTypes = new map<string, Schema.SOAPType> {
        'ANY' => Schema.SOAPType.anytype,
        'BASE64'  => Schema.SOAPType.base64binary,
        'BOOLEAN' => Schema.SOAPType.Boolean,
		'DATE' => Schema.SOAPType.Date,
		'DATETIME' => Schema.SOAPType.DateTime,
		'DOUBLE' => Schema.SOAPType.Double,
		'ID' => Schema.SOAPType.ID,
		'INTEGER' => Schema.SOAPType.Integer,
        'STRING'  => Schema.SOAPType.String,
        'TIME' => Schema.SOAPType.Time
	};

        
    // Scans an input string and returns logical tokens
    //public Token[] scanner(string sourceString, integer maximumElementIndex) {
    public void scanner(string sourceString, integer maximumElementIndex) {
        ComplexToken[] tokens = new ComplexToken[]{};
        // See documentation for string tokenizer regex definition
        //string tokenizeCode = '(")[^"\\\\]*(?:\\\\.[^"\\\\]*)*(")?|(\')[^\'\\\\]*(?:\\\\.[^\'\\\\]*)*(\')?|[\\[\\]\\(\\)\\{\\}\\.\\,\\;]|[\\+\\-\\=\\&\\|]{2}|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^]\\=|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^\\=]|\\$[A-Za-z0-9\\_]+|[A-Za-z0-9\\_]+';
//        string tokenizeCode = '(")[^"\\\\]*(?:\\\\.[^"\\\\]*)*(")?|(\')[^\'\\\\]*(?:\\\\.[^\'\\\\]*)*(\')?|(?:\\/\\*([^*]|[\\r\\n]|(\\*+([^*\\/]|[\\r\\n])))*\\*+\\/)|(?:\\/\\/.*)|[\\[\\]\\(\\)\\{\\}\\.\\,\\;](")[^"\\\\]*(?:\\\\.[^"\\\\]*)*(")?|(\')[^\'\\\\]*(?:\\\\.[^\'\\\\]*)*(\')?|[\\[\\]\\(\\)\\{\\}\\.\\,\\;]|[\\+\\-\\=\\&\\|]{2}|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^]\\=|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^\\=]|\\$[A-Za-z0-9\\_]+|[A-Za-z0-9\\_]+|[\\+\\-\\=\\&\\|]{2}|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^]\\=|[\\<\\>\\!\\*\\/\\+\\-\\&\\|\\^\\=]|\\$[A-Za-z0-9\\_]+|[A-Za-z0-9\\_]+';
        tokens = new ComplexToken[]{};
        integer position = 0;
            if(string.isNotBlank(sourceString)) {
//            	Pattern activePattern = Pattern.compile(tokenizeCode);
                Matcher activeMatcher = activePattern.matcher(sourceString);
                integer matchCount = 0;
                while(activeMatcher.find()) {
                    // Assure conntent of skipped elements are blank
                    if(activeMatcher.Start(0)>position ? !sourceString.mid(position, activeMatcher.Start(0)).isWhitespace() : false) {
                        throw new ComplexExpressionException(string.format(system.label.Expression_Parser_Unrecognized_Characters, new string[]{sourceString.mid(position, activeMatcher.Start(0))}), position+1);
                    }
                    position = activeMatcher.End(0);
                    matchCount++;
                    // Identify Token
                    string tokenString = activeMatcher.group(0);
                    if(activeMatcher.groupCount()>=3?String.isNotBlank(activeMatcher.group(1))||String.isNotBlank(activeMatcher.group(3)):false) {
                    	if(tokenString.left(1)!=tokenString.right(1))
                            throw new ComplexExpressionException(string.format('A string value did not include a closing delimiter', new string[]{sourceString.mid(position, activeMatcher.Start(0))}), position+1);
                        tokens.add(new ComplexToken(tokenString.unescapeJava(), ComplexToken.TokenClass.Primary));
                    } else if(tokenString.startsWith('/*')||tokenString.startsWith('//')) {
                        // Skip token; this is a comment only
                    } else if(operators.containsKey(tokenString)) {
                        tokens.add(new ComplexToken(null, operators.get(tokenString).type));
                    } else if(tokenString.isNumeric()) {
                        // How do we combine whole numbers and fractions??? look ahead, then skip if fraction found
                        tokens.add(new ComplexToken(tokenString, null));
                    } else {
                        // It's a reference of sorts. Determine detail based on suroudning tokens
                        tokens.add(new ComplexToken(tokenString, null));
                    }
                    
                    //result += 'Found match '+String.valueOf(matchCount)+' ['+string.valueOf(activeMatcher.Start(0))+'-'+string.valueOf(activeMatcher.End(0))+']:'+activeMatcher.group(0)+'\n';
                    //for(integer i = 1; i < activeMatcher.groupCount(); i++){
                        //result+='-- Subgroup '+String.valueOf(i)+': '+activeMatcher.group(i)+'\n';
                    //}
                }
            }
        
        /*
 *             integer tokenStart = tokenMatcher.start();
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
*/
        }
//        if (tokenList.isEmpty())
//            throw new ExpressionParserException(string.format(system.label.Expression_Parser_No_token_found_in_source,new string[]{sourceString}), 0);
//        else
//            tokenList.add(new Token(TokenType.EOF_TOKEN, null, sourceString.length()));
//        return tokenList;

}